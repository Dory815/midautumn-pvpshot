package pvpshot.weapon;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.WeakHashMap;

import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.network.protocol.game.ClientboundSetEntityMotionPacket;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.sounds.SoundSource;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.world.effect.MobEffects;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.EntityTypes;
import net.minecraft.world.entity.EquipmentSlot;
import net.minecraft.world.entity.decoration.ArmorStand;
import net.minecraft.world.entity.item.PrimedTnt;
import net.minecraft.world.entity.projectile.hurtingprojectile.LargeFireball;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.phys.Vec3;

/**
 * 装备类玩法（M4.3，从旧插桩模块移植）：温雷、战斗机、楼顶弹射器。
 *
 * <p>这三样都涉及"玩家状态 + 实体 + 数据包命令"的组合，因此实现上刻意保留
 * 与原数据包的互操作（发放物品用 loot table、进入战斗态调用数据包函数），
 * 这样模组与数据包可以继续共存，不会出现"模组接管后箱子里的东西拿不出来"。
 */
public final class EquipmentSystems {

    /**
     * 手雷/温雷引信（tick）。**3 秒 = 60 tick**。
     *
     * <p>作者 2026-09-25 定稿：按下右键点火、引信 3 秒、松开右键扔出；
     * 按住不放超过 3 秒则在手里炸。
     */
    private static final int FUSE_TICKS = 60;

    /** 正在温雷的玩家 → 已点燃的物品与起始时刻。 */
    private static final Map<ServerPlayer, Cooking> COOKING = new WeakHashMap<>();

    /** 弹射器的冷却（玩家 → 下次可用时间）。 */
    private static final Map<ServerPlayer, Long> LAUNCH_NEXT = new WeakHashMap<>();

    /** 楼顶弹射器 marker 缓存。 */
    private static final List<Entity> PADS = new ArrayList<>();

    private EquipmentSystems() {
    }

    // ---------------------------------------------------------------- 温雷

    private record Cooking(ItemStack stack, int started, net.minecraft.world.InteractionHand hand) {
    }

    /** 可以"点火—松开投掷"的投掷物：手雷本体与旧的温雷（现在两者行为一致）。 */
    private static boolean isCookable(String weapon) {
        return weapon.equals("grenade") || weapon.equals("cooked_grenade");
    }

    /**
     * 手雷爆炸伤害减半（作者 2026-09-25 要求：伤害太高）。
     *
     * <p>只减**对实体的伤害**，不改地形破坏与击退：命中判定在
     * {@code ServerLivingEntityEvents.ALLOW_DAMAGE} 里，如果伤害来源是
     * 我们生成的手雷 TNT（tag {@code pvpshot.grenade}），就取消这次伤害并按一半重新结算，
     * 用的是同一个 {@code DamageSource}，所以击杀归属、死亡消息都不变。
     *
     * <p>重入保护：重新结算时会再次触发同一个事件，用 {@link #HALVING} 标记跳过一层。
     */
    private static final ThreadLocal<Boolean> HALVING = ThreadLocal.withInitial(() -> Boolean.FALSE);

    public static boolean halveGrenadeDamage(net.minecraft.world.entity.LivingEntity victim,
                                             net.minecraft.world.damagesource.DamageSource source,
                                             float amount) {
        if (HALVING.get() || amount <= 0.0F) {
            return true;
        }
        net.minecraft.world.entity.Entity direct = source.getDirectEntity();
        net.minecraft.world.entity.Entity causing = source.getEntity();
        boolean ours = isGrenadeTnt(direct) || isGrenadeTnt(causing);
        if (!ours) {
            return true;
        }
        float half = amount * 0.5F;
        HALVING.set(Boolean.TRUE);
        try {
            victim.hurtServer((net.minecraft.server.level.ServerLevel) victim.level(), source, half);
        } finally {
            HALVING.set(Boolean.FALSE);
        }
        return false;
    }

    private static boolean isGrenadeTnt(net.minecraft.world.entity.Entity entity) {
        return entity instanceof PrimedTnt tnt && tnt.entityTags().contains("pvpshot.grenade");
    }

    /** 投出（或原地炸掉）手里的温雷。 */
    private static void throwCooked(ServerPlayer player, Cooking cooking, boolean handBlast) {
        COOKING.remove(player);
        // 保留对已点燃物品的引用：切槽也不能把雷"退回"
        player.getCooldowns().addCooldown(
                net.minecraft.resources.Identifier.parse("pvpshot:grenade"), 40);
        if (!cooking.stack().isEmpty()) {
            cooking.stack().shrink(1);
        }
        player.stopUsingItem();
        int remaining = Math.max(0, FUSE_TICKS - (player.tickCount - cooking.started()));
        Vec3 position = player.getEyePosition()
                .add(player.getLookAngle().scale(handBlast ? 0 : 0.8));

        PrimedTnt tnt = new PrimedTnt(player.level(), position.x, position.y, position.z, player);
        tnt.setFuse(handBlast ? 0 : remaining);
        tnt.setDeltaMovement(handBlast
                ? Vec3.ZERO
                : player.getLookAngle().scale(0.9).add(0, 0.2, 0));
        tnt.addTag("pvpshot.grenade");
        player.level().addFreshEntity(tnt);
        CombatUtil.command(player, "function pvpshot:regen/in_combat");
    }

    /**
     * 温雷状态机：
     * <ul>
     *   <li>{@code /trigger pvp_cook} 切换"温雷模式"（开/关）；</li>
     *   <li>开启时手持手雷会被换成"已点燃"版本，按住右键开始计时；</li>
     *   <li>松手按剩余引信投出，超时则在手里炸。</li>
     * </ul>
     */
    public static void tickCooking(ServerPlayer player) {
        if (CombatUtil.score(player, "pvp_cook") > 0) {
            if (COOKING.containsKey(player)) {
                throwCooked(player, COOKING.get(player), false);
            }
            boolean enable = !player.entityTags().contains("pvpshot.cook");
            if (enable) {
                player.addTag("pvpshot.cook");
            } else {
                player.removeTag("pvpshot.cook");
            }
            CombatUtil.setScore(player, "pvp_cook", 0);
            CombatUtil.message(player, enable
                    ? "温雷标记已开启（手雷现在本来就是这套机制：右键点火 · 引信 3 秒 · 松开扔出）"
                    : "温雷标记已关闭（手雷机制不变：右键点火 · 引信 3 秒 · 松开扔出）");
        }

        boolean cookingMode = player.entityTags().contains("pvpshot.cook");
        if (!player.isUsingItem()) {
            var inventory = player.getInventory();
            for (int i = 0; i < inventory.getContainerSize(); i++) {
                String weapon = WeaponIds.of(inventory.getItem(i));
                boolean needsCook = cookingMode && weapon.equals("grenade");
                boolean needsNormal = !cookingMode && weapon.equals("cooked_grenade");
                if (needsCook || needsNormal) {
                    CombatUtil.command(player, "item modify entity @s " + slotName(i)
                            + " pvpshot:" + (cookingMode ? "grenade_cook" : "grenade_normal"));
                }
            }
        }

        Cooking armed = COOKING.get(player);
        if (armed != null) {
            int elapsed = player.tickCount - armed.started();
            // "-1" 是给原版消耗留的 1 tick 容差：引信刚好走完时原版可能已经先把物品吃掉，
            // 这时必须判定成"在手里炸"，而不是误判成松手投掷。
            if (!player.isAlive() || elapsed >= FUSE_TICKS - 1) {
                throwCooked(player, armed, true);
            } else if (!player.isUsingItem() || player.getUseItem() != armed.stack()) {
                throwCooked(player, armed, false);
            } else if (elapsed % 5 == 0) {
                // 屏幕提示（actionbar）：剩余引信 + 松手投掷
                CombatUtil.message(player, String.format("引信 %.1f 秒 · 松开右键扔出",
                        Math.max(0, FUSE_TICKS - elapsed) / 20.0));
            }
        } else if (player.isAlive() && player.isUsingItem()
                && isCookable(WeaponIds.of(player.getUseItem()))) {
            CombatUtil.command(player, "function pvpshot:regen/in_combat");
            COOKING.put(player, new Cooking(player.getUseItem(), player.tickCount,
                    player.getUsedItemHand()));
            CombatUtil.message(player, "已点火 · 引信 3 秒 · 松开右键扔出");
        }
    }

    /** 背包槽位 → 命令用的槽位名。 */
    private static String slotName(int index) {
        if (index < 9) {
            return "hotbar." + index;
        }
        if (index < 36) {
            return "inventory." + (index - 9);
        }
        return switch (index) {
            case 36 -> "armor.feet";
            case 37 -> "armor.legs";
            case 38 -> "armor.chest";
            case 39 -> "armor.head";
            default -> "weapon.offhand";
        };
    }

    // ------------------------------------------------------------ 战斗机

    /** 战斗机持续时间（tick）：30 秒。 */
    private static final int FLIGHT_TICKS = 600;

    private static List<? extends ArmorStand> planeHolders(ServerPlayer player) {
        return player.level().getEntities(EntityTypes.ARMOR_STAND,
                entity -> entity.entityTags().contains("pvp.plane.owner:" + player.getUUID()));
    }

    private static void endPlane(ServerPlayer player) {
        if (!player.entityTags().contains("pvpshot.plane")) {
            return;
        }
        CombatUtil.clearWeaponsWithPrefix(player, "plane_");
        // 归还起飞前保存的胸甲
        for (var holder : planeHolders(player)) {
            player.setItemSlot(EquipmentSlot.CHEST, holder.getItemBySlot(EquipmentSlot.CHEST).copy());
            holder.discard();
        }
        for (String tag : new ArrayList<>(player.entityTags())) {
            if (tag.startsWith("pvp.flight.until:")) {
                player.removeTag(tag);
            }
        }
        CombatUtil.setScore(player, "pvpshot.airtime", 0);
        player.removeTag("pvpshot.plane");
        player.addTag("pvpshot.landing");
        player.stopFallFlying();
        player.addEffect(new MobEffectInstance(MobEffects.SLOW_FALLING, 200, 0));
        CombatUtil.setScore(player, "pvpshot.gun", 0);
        CombatUtil.setScore(player, "pvpshot.bomb", 0);
        CombatUtil.setScore(player, "pvp_land", 0);
        CombatUtil.message(player, "战斗机退出：缓降保护持续至落地");
    }

    private static void startPlane(ServerPlayer player) {
        if (player.entityTags().contains("pvpshot.plane")) {
            CombatUtil.command(player, "loot give @s loot pvpshot:item/fighter");
            CombatUtil.message(player, "已在使用战斗机");
            return;
        }
        int free = 0;
        for (int i = 0; i < 36; i++) {
            if (player.getInventory().getItem(i).isEmpty()) {
                free++;
            }
        }
        if (free < 3) {
            CombatUtil.command(player, "loot give @s loot pvpshot:item/fighter");
            CombatUtil.message(player, "请腾出 3 个背包空格再启用战斗机");
            return;
        }

        // 用一个隐形盔甲架暂存起飞前的胸甲
        ArmorStand holder = new ArmorStand(player.level(), player.getX(), player.getY(), player.getZ());
        holder.setInvisible(true);
        holder.setInvulnerable(true);
        holder.setNoGravity(true);
        holder.setSilent(true);
        holder.addTag("pvpshot.plane_holder");
        holder.addTag("pvp.plane.owner:" + player.getUUID());
        holder.setItemSlot(EquipmentSlot.CHEST, player.getItemBySlot(EquipmentSlot.CHEST).copy());
        player.level().addFreshEntity(holder);
        player.addTag("pvpshot.plane");
        CombatUtil.command(player, "data merge entity " + holder.getUUID()
                + " {Marker:1b,DisabledSlots:4144959}");

        CombatUtil.command(player, "loot replace entity @s armor.chest loot pvpshot:item/plane_elytra");
        for (String item : List.of("plane_gun", "plane_bomb", "plane_boost")) {
            CombatUtil.command(player, "loot give @s loot pvpshot:item/" + item);
        }
        CombatUtil.setScore(player, "pvpshot.gun", 24);
        CombatUtil.setScore(player, "pvpshot.bomb", 4);
        CombatUtil.setScore(player, "pvpshot.airtime", FLIGHT_TICKS);
        player.addTag("pvp.flight.until:" + (player.level().getGameTime() + FLIGHT_TICKS));
        player.addEffect(new MobEffectInstance(MobEffects.LEVITATION, 40, 8));
        player.addEffect(new MobEffectInstance(MobEffects.SLOW_FALLING, 100, 0));
        CombatUtil.message(player, "起飞抬升 2 秒，空中按跳跃展开鞘翅；限时 30 秒；"
                + "机炮 24 / 炸弹 4 / 助推 12；/trigger pvp_land 退出");
    }

    /** 每 tick 维护战斗机状态：限时、弹药、退出清理。 */
    public static void tickPlane(ServerPlayer player) {
        if (CombatUtil.score(player, "pvpshot.flight") > 0) {
            CombatUtil.setScore(player, "pvpshot.flight", 0);
            startPlane(player);
        }
        if (player.entityTags().contains("pvpshot.plane")) {
            // 让暂存盔甲架跟着玩家，避免胸甲丢失
            for (var stand : planeHolders(player)) {
                stand.setPos(player.position());
            }
            long deadline = 0;
            for (String tag : player.entityTags()) {
                if (tag.startsWith("pvp.flight.until:")) {
                    try {
                        deadline = Long.parseLong(tag.substring(17));
                    } catch (RuntimeException ignored) {
                        // 标签损坏就当作已超时
                    }
                }
            }
            CombatUtil.setScore(player, "pvpshot.airtime",
                    (int) Math.max(0, deadline - player.level().getGameTime()));
            boolean expired = CombatUtil.score(player, "pvpshot.airtime") <= 0;
            boolean landed = CombatUtil.score(player, "pvp_land") > 0;
            boolean lostWings = !WeaponIds.of(player.getItemBySlot(EquipmentSlot.CHEST))
                    .equals("plane_elytra");
            boolean resetting = CombatUtil.named(player.level(), "#reset.active", "ustc.clock") == 1;
            if (expired || !player.isAlive() || landed || lostWings || resetting) {
                endPlane(player);
            } else {
                if (CombatUtil.score(player, "pvpshot.airgun") > 0) {
                    CombatUtil.setScore(player, "pvpshot.airgun", 0);
                    if (CombatUtil.score(player, "pvpshot.gun") > 0) {
                        CombatUtil.setScore(player, "pvpshot.gun",
                                CombatUtil.score(player, "pvpshot.gun") - 1);
                        LargeFireball shot = new LargeFireball(player.level(), player,
                                player.getLookAngle().scale(0.1), 2);
                        shot.setPos(player.getEyePosition().add(player.getLookAngle().scale(1.2)));
                        shot.setDeltaMovement(player.getLookAngle().scale(2.5));
                        shot.addTag("pvpshot.airgun");
                        player.level().addFreshEntity(shot);
                    }
                }
                if (CombatUtil.score(player, "pvpshot.airbomb") > 0) {
                    CombatUtil.setScore(player, "pvpshot.airbomb", 0);
                    if (CombatUtil.score(player, "pvpshot.bomb") > 0) {
                        CombatUtil.setScore(player, "pvpshot.bomb",
                                CombatUtil.score(player, "pvpshot.bomb") - 1);
                        PrimedTnt tnt = new PrimedTnt(player.level(),
                                player.getX(), player.getY() - 0.5, player.getZ(), player);
                        tnt.setFuse(100);
                        tnt.setDeltaMovement(player.getDeltaMovement().multiply(0.5, 0, 0.5)
                                .add(0, -0.6, 0));
                        tnt.addTag("pvpshot.airbomb");
                        player.level().addFreshEntity(tnt);
                    }
                }
                boolean noGun = CombatUtil.score(player, "pvpshot.gun") == 0
                        || CombatUtil.countWeapon(player, "plane_gun") == 0;
                boolean noBomb = CombatUtil.score(player, "pvpshot.bomb") == 0
                        || CombatUtil.countWeapon(player, "plane_bomb") == 0;
                if (noGun && noBomb) {
                    endPlane(player);
                }
            }
        } else {
            CombatUtil.setScore(player, "pvpshot.airgun", 0);
            CombatUtil.setScore(player, "pvpshot.airbomb", 0);
        }

        // 缓降保护：落地或落水后解除
        if (player.entityTags().contains("pvpshot.landing")) {
            boolean done = (player.onGround() && !player.entityTags().contains("pvpshot.launching"))
                    || player.isInWater() || !player.isAlive();
            if (done) {
                player.removeTag("pvpshot.landing");
                player.removeEffect(MobEffects.SLOW_FALLING);
            } else {
                player.addEffect(new MobEffectInstance(MobEffects.SLOW_FALLING, 60, 0));
            }
        }
    }

    // -------------------------------------------------------- 楼顶弹射器

    /** 单把已装填弩的负重等级（三级缓慢 ≈ 移速 -45%）。 */
    private static final int WEIGHT_LEVEL_PER_CROSSBOW = 3;

    /** 负重效果持续时间（tick）：略长于检测间隔，保证连续生效、又不会残留太久。 */
    private static final int WEIGHT_DURATION = 100;

    /**
     * 弩的负重惩罚（作者方案，替代原来的"单弩限制"）。
     *
     * <p>不再强行移除多余的弩，而是：**每带一把已经装填好的弩，就叠三级的沉重效果**
     * （原版 {@code SLOWNESS} 每级 -15% 移速，三级约 -45%，接近作者要求的 -40%）。
     * 这样"背着一排上膛的弩"在机动性上就有代价，而不是被系统直接没收。
     *
     * <p>只统计**已装填**的弩：空弩背着不重，想享受多弩火力就必须先付出装填时间。
     */
    public static void applyCrossbowWeight(ServerPlayer player) {
        int charged = 0;
        var inventory = player.getInventory();
        for (int i = 0; i < inventory.getContainerSize(); i++) {
            ItemStack stack = inventory.getItem(i);
            if (!stack.is(net.minecraft.world.item.Items.CROSSBOW)) {
                continue;
            }
            var loaded = stack.getOrDefault(
                    net.minecraft.core.component.DataComponents.CHARGED_PROJECTILES,
                    net.minecraft.world.item.component.ChargedProjectiles.EMPTY);
            if (!loaded.isEmpty()) {
                charged++;
            }
        }
        if (charged > 0) {
            player.addEffect(new MobEffectInstance(
                    MobEffects.SLOWNESS,
                    WEIGHT_DURATION,
                    charged * WEIGHT_LEVEL_PER_CROSSBOW - 1,
                    false,   // 环境效果（不产生额外粒子）
                    false,   // 不显示药水粒子
                    true));  // 但要在 HUD 上显示图标，让玩家知道为什么变慢
        }
    }

    /** 站在弹射器上会被自动抬升到对应的楼顶点。 */
    public static void tickLaunchPads(ServerLevel level) {
        if ((level.getGameTime() & 31) == 0) {
            PADS.clear();
            PADS.addAll(level.getEntities(EntityTypes.MARKER,
                    entity -> entity.entityTags().contains("ustc.launch")));
        }
        if (PADS.isEmpty()) {
            return;
        }
        for (Entity marker : PADS) {
            if (!marker.isAlive()) {
                continue;
            }
            ServerPlayer near = null;
            List<ServerPlayer> players = level.players();
            for (int i = 0; i < players.size(); i++) {
                ServerPlayer player = players.get(i);
                if (!player.isAlive() || player.isSpectator() || !player.onGround()
                        || level.getGameTime() < LAUNCH_NEXT.getOrDefault(player, 0L)) {
                    continue;
                }
                if (marker.distanceToSqr(player) < 4) {
                    near = player;
                    break;
                }
            }
            if (near == null) {
                continue;
            }
            Vec3 target = null;
            for (String tag : marker.entityTags()) {
                if (tag.startsWith("pvp.launch:")) {
                    try {
                        String[] parts = tag.substring(11).split(",");
                        target = new Vec3(Double.parseDouble(parts[0]), Double.parseDouble(parts[1]),
                                Double.parseDouble(parts[2]));
                    } catch (RuntimeException ignored) {
                        // 标签损坏则跳过这个弹射器
                    }
                }
            }
            if (target == null) {
                continue;
            }
            near.addTag("pvpshot.launching");
            near.addTag("pvp.roof:" + target.x + "," + target.y + "," + target.z);
            near.addTag("pvpshot.landing");
            near.addEffect(new MobEffectInstance(MobEffects.SLOW_FALLING, 200, 0));
            near.setDeltaMovement(0, 3.2, 0);
            near.connection.send(new ClientboundSetEntityMotionPacket(near));
            LAUNCH_NEXT.put(near, level.getGameTime() + 140);
            CombatUtil.message(near, "楼顶弹射器：自动抬升，落地前保留缓降");
        }
    }

    /** 抬升途中的横向修正。 */
    public static void tickLaunchMotion(ServerPlayer player) {
        if (!player.entityTags().contains("pvpshot.launching")) {
            return;
        }
        for (String tag : new ArrayList<>(player.entityTags())) {
            if (!tag.startsWith("pvp.roof:")) {
                continue;
            }
            String[] parts = tag.substring(9).split(",");
            Vec3 target = new Vec3(Double.parseDouble(parts[0]), Double.parseDouble(parts[1]),
                    Double.parseDouble(parts[2]));
            if (!player.isAlive()
                    || player.level().getGameTime() >= LAUNCH_NEXT.getOrDefault(player, 0L)) {
                player.removeTag(tag);
                player.removeTag("pvpshot.launching");
                continue;
            }
            if (player.getY() >= target.y + 2) {
                Vec3 delta = target.subtract(player.position());
                player.setDeltaMovement(new Vec3(delta.x, 0, delta.z).normalize().scale(2.2)
                        .add(0, 0.3, 0));
                player.connection.send(new ClientboundSetEntityMotionPacket(player));
                player.removeTag(tag);
                player.removeTag("pvpshot.launching");
            }
        }
    }

    /** 掉线清理：手里的雷、飞机状态都要收干净。 */
    public static void onLogout(ServerPlayer player) {
        Cooking cooking = COOKING.get(player);
        if (cooking != null) {
            throwCooked(player, cooking, false);
        }
        endPlane(player);
        LAUNCH_NEXT.remove(player);
    }

    /** 投射物生成时清除玩家增益（开火即脱战）。 */
    public static void onProjectileSpawned(Entity entity) {
        if (entity instanceof net.minecraft.world.entity.projectile.Projectile projectile
                && projectile.getOwner() instanceof ServerPlayer owner
                && owner.level().getScoreboard().getObjective("pvpshot.flight") != null) {
            CombatUtil.clearBuffs(owner);
            CombatUtil.command(owner, "function pvpshot:regen/in_combat");
        }
    }

}
