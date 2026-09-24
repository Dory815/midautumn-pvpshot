package pvpshot.weapon;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.WeakHashMap;

import net.minecraft.core.BlockPos;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.sounds.SoundSource;
import net.minecraft.world.entity.EntityTypes;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.item.PrimedTnt;
import net.minecraft.world.level.ClipContext;
import net.minecraft.world.level.Level;
import net.minecraft.world.phys.HitResult;
import net.minecraft.world.phys.Vec3;

/**
 * 枪械类武器（M4.2，从旧插桩模块移植）：SMG 连射、霰弹枪、三种一次性重武器。
 *
 * <p>与原实现保持一致的要点：
 * <ul>
 *   <li>SMG 用"服务器游戏时间的下一次可射 tick"限速，不依赖客户端节奏；</li>
 *   <li>霰弹枪把 10 颗弹丸的伤害**合并成一次结算**，否则原版受伤冷却会吞掉大部分弹丸；</li>
 *   <li>重武器走"延时打击队列"，每次世界 tick 推进，不做长时间阻塞。</li>
 * </ul>
 */
public final class WeaponSystems {

    /** 每个玩家下一次可以开火的游戏时间。 */
    private static final Map<ServerPlayer, Long> SMG_NEXT = new WeakHashMap<>();

    /** 待执行的重武器打击（按世界分组）。 */
    private static final Map<ServerLevel, List<Strike>> STRIKES = new WeakHashMap<>();
    private static final Map<ServerLevel, Long> WORLD_TIME = new WeakHashMap<>();

    /** SMG 的射速间隔（tick）。 */
    private static final int SMG_INTERVAL = 3;

    /** 重武器种类：1 = 轨道 380（每 10 tick 一发，共 24 发）、2 = 飞鹰 500（单次大范围）、3 = 空爆火箭筒。 */
    public static final int ORBITAL_380 = 1;
    public static final int EAGLE_500 = 2;
    public static final int AIRBURST = 3;

    private WeaponSystems() {
    }

    // ------------------------------------------------------------------ SMG

    /** 鸡蛋冲锋枪：按住右键连续射击，每 {@link #SMG_INTERVAL} tick 一发。 */
    public static void tickSmg(ServerPlayer player) {
        if (!player.isAlive() || player.isSpectator() || !player.isUsingItem()) {
            return;
        }
        var stack = player.getUseItem();
        if (stack.isEmpty() || !WeaponIds.of(stack).equals("egg")) {
            return;
        }
        long now = player.level().getGameTime();
        if (now < SMG_NEXT.getOrDefault(player, Long.MIN_VALUE)) {
            return;
        }
        SMG_NEXT.put(player, now + SMG_INTERVAL);

        // 先发弹再扣弹：数据包回调可能改动选中的物品
        CombatUtil.command(player, "function pvpshot:smg/launch");
        stack.shrink(1);
        if (stack.isEmpty()) {
            player.stopUsingItem();
        }
        player.getInventory().setChanged();
    }

    // -------------------------------------------------------------- 霰弹枪

    /** 霰弹枪：10 颗弹丸，按距离衰减，合并成一次伤害结算。 */
    public static void fireShotgun(ServerPlayer player) {
        ServerLevel level = player.level();
        Vec3 from = player.getEyePosition();
        Vec3 forward = player.getLookAngle().normalize();
        Vec3 right = forward.cross(new Vec3(0, 1, 0)).normalize();
        if (right.lengthSqr() < 0.01) {
            right = new Vec3(1, 0, 0);
        }
        Vec3 up = right.cross(forward).normalize();

        Map<LivingEntity, Float> damage = new HashMap<>();
        for (int i = 0; i < 10; i++) {
            // 第 1 颗走正中，其余按黄金角散布成均匀圆面
            double radius = i == 0 ? 0 : (i <= 3 ? 0.025 : 0.065);
            double angle = i * 2.399963229728653;
            Vec3 direction = forward
                    .add(right.scale(Math.cos(angle) * radius))
                    .add(up.scale(Math.sin(angle) * radius))
                    .normalize();
            Vec3 end = from.add(direction.scale(24));
            var wall = level.clip(new ClipContext(from, end, ClipContext.Block.COLLIDER,
                    ClipContext.Fluid.NONE, player));
            if (wall.getType() != HitResult.Type.MISS) {
                end = wall.getLocation();
            }
            var target = CombatUtil.nearestAlong(level, from, end, player, 0.5);
            Vec3 hit = end;
            double nearest = from.distanceToSqr(end);
            if (target != null) {
                hit = target.hit();
                nearest = target.distanceSquared();
                double range = Math.sqrt(nearest);
                float perPellet = range <= 8 ? 3F : range <= 16 ? 2F : 1F;
                damage.merge(target.entity(), perPellet, Float::sum);
            }
            // 弹道轨迹
            for (double t = 1; t < from.distanceTo(hit); t += 2) {
                Vec3 at = from.add(direction.scale(t));
                level.sendParticles(ParticleTypes.CRIT, at.x, at.y, at.z, 1, 0, 0, 0, 0);
            }
        }
        // 合并成一次伤害：原版受伤冷却否则会吞掉大部分弹丸
        for (var entry : damage.entrySet()) {
            entry.getKey().hurtServer(level,
                    CombatUtil.customDamage(level, "pvpshot:rifle", player, player), entry.getValue());
        }
        level.playSound(null, player.blockPosition(), SoundEvents.GENERIC_EXPLODE.value(),
                SoundSource.PLAYERS, 0.6F, 1.6F);
        CombatUtil.command(player, "function pvpshot:regen/in_combat");
    }

    // ------------------------------------------------------------ 重武器

    /** 启动一次重武器打击（由数据包的 trigger 分数触发）。 */
    public static void fireHeavy(ServerPlayer player, int kind) {
        Vec3 at = kind == AIRBURST
                ? player.getEyePosition().add(player.getLookAngle().scale(1.2))
                : CombatUtil.aimPoint(player);
        STRIKES.computeIfAbsent(player.level(), key -> new ArrayList<>())
                .add(new Strike(player, kind, at, player.getLookAngle().normalize(),
                        CombatUtil.named(player.level(), "#ordnance.epoch", "pvpshot.cal")));

        if (kind != AIRBURST) {
            int count = kind == EAGLE_500 ? 200 : 60;
            double spread = kind == EAGLE_500 ? 10 : 2;
            player.level().sendParticles(ParticleTypes.FLAME, at.x, at.y, at.z,
                    count, spread, 0.6, spread, 0.02);
            CombatUtil.message(player, (kind == ORBITAL_380
                    ? "轨道 380：3 秒后点射 "
                    : "飞鹰 500：3 秒后轰炸 ")
                    + Math.round(at.x) + " / " + Math.round(at.y) + " / " + Math.round(at.z));
        }
        CombatUtil.command(player, "function pvpshot:regen/in_combat");
    }

    /** 世界 tick：推进所有待执行的重武器打击。 */
    public static void tickWorld(ServerLevel level) {
        long now = level.getGameTime();
        if (java.util.Objects.equals(WORLD_TIME.put(level, now), now)) {
            return;
        }
        List<Strike> list = STRIKES.get(level);
        if (list != null) {
            list.removeIf(strike -> updateStrike(strike, now));
        }
    }

    /** 推进一发重武器打击；返回 true 表示它已经结束。 */
    private static boolean updateStrike(Strike strike, long now) {
        ServerLevel level = strike.owner.level();
        long age = now - strike.start;

        // 使用者掉线、换维度、换局或整场复原时就地作废
        if (strike.owner.hasDisconnected() || strike.owner.level() != strike.level
                || strike.epoch != CombatUtil.named(level, "#ordnance.epoch", "pvpshot.cal")
                || CombatUtil.named(level, "#reset.active", "ustc.clock") == 1) {
            return true;
        }

        if (strike.kind == AIRBURST) {
            return updateAirburst(strike, level, age);
        }

        // 前 3 秒：在地面画出预告圈
        if (age % 10 == 0) {
            int points = strike.kind == ORBITAL_380 ? 24 : 48;
            double ring = strike.kind == ORBITAL_380 ? 32 : 42;
            for (int i = 0; i < points; i++) {
                double a = i * Math.PI * 2 / points;
                level.sendParticles(ParticleTypes.FLAME,
                        strike.origin.x + Math.cos(a) * ring, strike.origin.y + 0.2,
                        strike.origin.z + Math.sin(a) * ring, 1, 0, 0, 0, 0);
                if (strike.kind == EAGLE_500) {
                    level.sendParticles(ParticleTypes.LARGE_SMOKE,
                            strike.origin.x + Math.cos(a) * ring, strike.origin.y + 1,
                            strike.origin.z + Math.sin(a) * ring, 1, 0.2, 0.4, 0.2, 0);
                }
            }
            level.playSound(null, BlockPos.containing(strike.origin),
                    SoundEvents.NOTE_BLOCK_BELL.value(), SoundSource.PLAYERS,
                    1F, strike.kind == ORBITAL_380 ? 0.7F : 1.2F);
        }

        if (strike.kind == EAGLE_500) {
            if (age >= 60 && age < 80) {
                double height = (80 - age) * 2.4;
                level.sendParticles(ParticleTypes.CAMPFIRE_COSY_SMOKE,
                        strike.origin.x, strike.origin.y + height, strike.origin.z, 48, 8, 2, 8, 0);
                level.sendParticles(ParticleTypes.FLAME,
                        strike.origin.x, strike.origin.y + height, strike.origin.z, 32, 6, 1.2, 6, 0.02);
            }
            if (age >= 80) {
                level.sendParticles(ParticleTypes.EXPLOSION_EMITTER,
                        strike.origin.x, strike.origin.y + 1, strike.origin.z, 8, 6, 1, 6, 0);
                heavyBlast(strike, strike.origin, 22, 42, 48);
                return true;
            }
            return age > 360;
        }

        // 轨道 380：从第 3 秒开始每 10 tick 一发，共 24 发
        if (age >= 60 + strike.fired * 10) {
            double angle = strike.fired * 2.399963229728653;
            double r = strike.fired % 4 == 0 ? 0 : 10 + (strike.fired % 3) * 11;
            Vec3 top = strike.origin.add(Math.cos(angle) * r, 48, Math.sin(angle) * r);
            var ground = level.clip(new ClipContext(top, top.add(0, -96, 0),
                    ClipContext.Block.COLLIDER, ClipContext.Fluid.NONE, strike.owner));
            Vec3 impact = ground.getType() == HitResult.Type.MISS
                    ? strike.origin.add(Math.cos(angle) * r, 1, Math.sin(angle) * r)
                    : ground.getLocation();
            level.sendParticles(ParticleTypes.FLAME, impact.x, impact.y + 10, impact.z, 25, 0.1, 6, 0.1, 0);
            heavyBlast(strike, impact, 10, 16, 28);
            return ++strike.fired >= 24;
        }
        return age > 360;
    }

    /** 空爆火箭筒：贴着视线飞，撞到方块或敌人才炸，最多飞 90 格。 */
    private static boolean updateAirburst(Strike strike, ServerLevel level, long age) {
        Vec3 start = strike.position;
        Vec3 end = start.add(strike.direction.scale(3));
        var wall = level.clip(new ClipContext(start, end, ClipContext.Block.COLLIDER,
                ClipContext.Fluid.NONE, strike.owner));
        boolean hit = wall.getType() != HitResult.Type.MISS;
        if (hit) {
            end = wall.getLocation();
        }
        if (strike.travel >= 12) {
            List<ServerPlayer> players = level.players();
            for (int i = 0; i < players.size(); i++) {
                ServerPlayer other = players.get(i);
                if (other == strike.owner || !other.isAlive() || other.isSpectator()
                        || CombatUtil.sameTeam(other, strike.owner)) {
                    continue;
                }
                var box = other.getBoundingBox().inflate(2.5);
                var crossing = box.contains(start) ? java.util.Optional.of(start) : box.clip(start, end);
                if (crossing.isPresent()
                        && CombatUtil.visible(level, other, crossing.get(), CombatUtil.body(other))) {
                    end = crossing.get();
                    hit = true;
                    break;
                }
            }
        }
        strike.travel += start.distanceTo(end);
        strike.position = end;
        level.sendParticles(ParticleTypes.FLAME, end.x, end.y, end.z, 4, 0.08, 0.08, 0.08, 0);
        level.sendParticles(ParticleTypes.SMOKE, end.x, end.y, end.z, 4, 0.12, 0.12, 0.12, 0);

        if (hit || strike.travel >= 90) {
            explosion(strike, end, 5);
            scatterTnt(strike, end);
            return true;
        }
        return age > 80;
    }

    private static void heavyBlast(Strike strike, Vec3 at, float power, double radius, float maxDamage) {
        Vec3 center = CombatUtil.openAir(strike.owner.level(), at);
        hurtBlast(strike, center, radius, maxDamage);
        explosion(strike, center, power);
    }

    /** 范围伤害：越靠近越痛，最低 6 点。不使用原版爆炸，避免误伤地形。 */
    private static void hurtBlast(Strike strike, Vec3 at, double radius, float maxDamage) {
        ServerLevel level = strike.owner.level();
        List<LivingEntity> entities = level.getEntitiesOfClass(LivingEntity.class,
                new net.minecraft.world.phys.AABB(at, at).inflate(radius),
                entity -> entity.isAlive() && !entity.isSpectator());
        for (int i = 0; i < entities.size(); i++) {
            LivingEntity entity = entities.get(i);
            double distance = Math.sqrt(entity.distanceToSqr(at));
            if (distance > radius) {
                continue;
            }
            float damage = Math.max(6F, maxDamage * (float) (1 - distance / radius));
            entity.hurtServer(level, level.damageSources().explosion(strike.owner, strike.owner), damage);
        }
    }

    private static void explosion(Strike strike, Vec3 at, float power) {
        ServerLevel level = strike.owner.level();
        Vec3 center = CombatUtil.openAir(level, at);
        level.explode(strike.owner, level.damageSources().explosion(strike.owner, strike.owner),
                null, center.x, center.y, center.z, power, false, Level.ExplosionInteraction.TNT);
    }

    /** 空爆弹落地后散出一圈小 TNT，制造二次爆炸。 */
    private static void scatterTnt(Strike strike, Vec3 at) {
        ServerLevel level = strike.owner.level();
        var random = strike.owner.getRandom();
        int count = 6 + random.nextInt(3);
        Vec3 center = CombatUtil.openAir(level, at);
        for (int i = 0; i < count; i++) {
            double angle = i * Math.PI * 2 / count + random.nextDouble() * 0.6;
            PrimedTnt tnt = new PrimedTnt(level, center.x, center.y + 0.5, center.z, strike.owner);
            tnt.setFuse(28 + random.nextInt(24));
            double speed = 0.7 + random.nextDouble() * 0.5;
            tnt.setDeltaMovement(Math.cos(angle) * speed, 0.45 + random.nextDouble() * 0.45,
                    Math.sin(angle) * speed);
            tnt.addTag("pvpshot.airburst_frag");
            level.addFreshEntity(tnt);
        }
    }

    /** 清理某个玩家的未完打击（掉线时调用）。 */
    public static void forget(ServerPlayer player) {
        SMG_NEXT.remove(player);
        List<Strike> list = STRIKES.get(player.level());
        if (list != null) {
            list.removeIf(strike -> strike.owner == player);
        }
    }

    /** 一次重武器打击的状态。 */
    private static final class Strike {
        final ServerPlayer owner;
        final int kind;
        final Level level;
        final long start;
        final int epoch;
        final Vec3 direction;
        final Vec3 origin;
        Vec3 position;
        double travel;
        int fired;

        Strike(ServerPlayer owner, int kind, Vec3 at, Vec3 direction, int epoch) {
            this.owner = owner;
            this.kind = kind;
            this.level = owner.level();
            this.start = owner.level().getGameTime();
            this.epoch = epoch;
            this.direction = direction;
            this.origin = at;
            this.position = at;
        }
    }
}
