package pvpshot.weapon;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.WeakHashMap;

import net.minecraft.core.registries.Registries;
import net.minecraft.resources.Identifier;
import net.minecraft.resources.ResourceKey;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.sounds.SoundSource;
import net.minecraft.world.damagesource.DamageSource;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.projectile.arrow.AbstractArrow;
import net.minecraft.world.level.ClipContext;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.world.phys.EntityHitResult;
import net.minecraft.world.phys.HitResult;
import net.minecraft.world.phys.Vec3;

/**
 * 弓与弩的服务端规则（M4.1，从旧的插桩模块移植）。
 *
 * <p>移植思路：**完全复用原版箭矢**的运动、碰撞、护甲与盾牌结算，
 * 只在这三条钩子上补充本项目的规则：
 *
 * <ul>
 *   <li>{@link #tick} —— 弩箭走直线（取消重力 + 固定初速），弓箭补充"近炸"判定；</li>
 *   <li>{@link #onHitEntity} —— 按飞行距离换算伤害（弓越远越痛，弩 20 格后致命）；</li>
 *   <li>{@link #onHitBlock} —— 撞墙时，弓箭在 20 格外触发近炸。</li>
 * </ul>
 *
 * <p>之所以不自己写一套箭，是因为原版的 {@code AbstractArrow} 已经处理好了
 * 扫掠式线段判定（不会高速穿透）、盾牌格挡、护甲减免和击杀归属 ——
 * 这些自己重写几乎不可能做对。
 */
public final class ArrowMechanics {

    /** 箭的发射点与蓄力：用于按飞行距离计算伤害。 */
    private record Origin(Vec3 position, double charge) {
    }

    /** 弩箭的固定飞行速度（直线用）。 */
    private static final Map<AbstractArrow, Vec3> BOLT_MOTION = new WeakHashMap<>();
    private static final Map<AbstractArrow, Origin> ORIGINS = new WeakHashMap<>();

    /** 弓箭的有效射程上限（超过就消失）。 */
    private static final double BOW_MAX_RANGE = 240.0;
    /** 近炸的触发距离。 */
    private static final double BURST_RANGE = 20.0;
    /** 近炸的伤害半径。 */
    private static final double BURST_RADIUS = 2.5;
    /** 贴脸时的额外命中判定膨胀（补偿玩家移动）。 */
    private static final double PROXIMITY_INFLATE = 0.75;

    private ArrowMechanics() {
    }

    /** 这支箭是不是本项目发出来的（弓或弩）。 */
    public static boolean isOurs(AbstractArrow arrow) {
        String weapon = WeaponIds.of(arrow.getWeaponItem());
        return weapon.equals("bow") || weapon.equals("crossbow");
    }

    private static String weaponOf(AbstractArrow arrow) {
        return WeaponIds.of(arrow.getWeaponItem());
    }

    private static boolean isBow(AbstractArrow arrow) {
        return weaponOf(arrow).equals("bow");
    }

    /**
     * 记录发射点与蓄力。
     *
     * <p>用实体标签持久化，这样跨区块卸载、甚至服务器重启后仍然能算出真实射程。
     */
    private static Origin origin(AbstractArrow arrow) {
        return ORIGINS.computeIfAbsent(arrow, key -> {
            for (String tag : key.entityTags()) {
                if (tag.startsWith("pvp.origin:")) {
                    try {
                        String[] parts = tag.substring(11).split(",");
                        return new Origin(new Vec3(Double.parseDouble(parts[0]),
                                Double.parseDouble(parts[1]), Double.parseDouble(parts[2])),
                                Double.parseDouble(parts[3]));
                    } catch (RuntimeException ignored) {
                        // 标签损坏就退回用当前位置
                    }
                }
            }
            Origin origin = new Origin(key.position(), Math.min(1, key.getDeltaMovement().length() / 3));
            key.addTag("pvp.origin:" + origin.position().x + "," + origin.position().y + ","
                    + origin.position().z + "," + origin.charge());
            return origin;
        });
    }

    private static double travelled(AbstractArrow arrow, Vec3 hit) {
        return origin(arrow).position().distanceTo(hit);
    }

    private static Vec3 body(Entity entity) {
        return entity.getBoundingBox().getCenter();
    }

    /** 两点之间有没有方块遮挡（爆炸伤害用得上）。 */
    private static boolean visible(ServerLevel level, Entity target, Vec3 from, Vec3 to) {
        return level.clip(new ClipContext(from, to, ClipContext.Block.COLLIDER,
                ClipContext.Fluid.NONE, target)).getType() == HitResult.Type.MISS;
    }

    private static DamageSource customDamage(ServerLevel level, String id, Entity direct, Entity owner) {
        return new DamageSource(level.registryAccess()
                .lookupOrThrow(Registries.DAMAGE_TYPE)
                .getOrThrow(ResourceKey.create(Registries.DAMAGE_TYPE, Identifier.parse(id))),
                direct, owner);
    }

    /**
     * 近炸：远距离命中时在落点炸开一小圈。
     * 排除直接命中的那个目标，避免同一次命中结算两次伤害。
     */
    private static void burst(AbstractArrow arrow, Vec3 at, Entity exclude) {
        ServerLevel level = (ServerLevel) arrow.level();
        level.sendParticles(net.minecraft.core.particles.ParticleTypes.EXPLOSION,
                at.x, at.y, at.z, 1, 0, 0, 0, 0);
        level.playSound(null, at.x, at.y, at.z, SoundEvents.GENERIC_EXPLODE.value(),
                SoundSource.PLAYERS, 0.4F, 1.6F);

        double charge = origin(arrow).charge();
        List<ServerPlayer> players = level.players();
        for (int i = 0; i < players.size(); i++) {
            ServerPlayer player = players.get(i);
            if (player == exclude || player.isSpectator() || !player.isAlive()) {
                continue;
            }
            double distance = body(player).distanceTo(at);
            if (distance > BURST_RADIUS || !visible(level, player, at, body(player))) {
                continue;
            }
            float damage = (float) ((distance <= BURST_RADIUS / 2 ? 12 : 6) * charge);
            player.hurtServer(level, customDamage(level, "pvpshot:rifle", arrow, arrow.getOwner()), damage);
        }
    }

    /** 弩箭：取消重力并保持初速，看起来就是一条直线。 */
    private static void straighten(AbstractArrow arrow) {
        arrow.setNoGravity(true);
        Vec3 motion = BOLT_MOTION.computeIfAbsent(arrow, key -> {
            for (String tag : key.entityTags()) {
                if (tag.startsWith("pvp.straight:")) {
                    try {
                        String[] parts = tag.substring(13).split(",");
                        return new Vec3(Double.parseDouble(parts[0]), Double.parseDouble(parts[1]),
                                Double.parseDouble(parts[2]));
                    } catch (RuntimeException ignored) {
                        // 标签损坏就退回当前速度
                    }
                }
                Vec3 velocity = key.getDeltaMovement();
                key.addTag("pvp.straight:" + velocity.x + "," + velocity.y + "," + velocity.z);
                return velocity;
            }
            return arrow.getDeltaMovement();
        });
        arrow.setDeltaMovement(motion);
    }

    /** 每 tick：弩走直线；弓检查"擦身而过"的近炸。返回 true 表示这支箭应当被移除。 */
    public static boolean tick(AbstractArrow arrow) {
        if (!isOurs(arrow) || !(arrow.level() instanceof ServerLevel level)) {
            return false;
        }
        origin(arrow);
        if (arrow.entityTags().contains("pvp.landed")) {
            return false;
        }
        if (!isBow(arrow)) {
            if (travelled(arrow, arrow.position()) > BOW_MAX_RANGE) {
                arrow.discard();
                return true;
            }
            straighten(arrow);
            return false;
        }

        Vec3 start = arrow.position();
        Vec3 end = start.add(arrow.getDeltaMovement());
        BlockHitResult wall = level.clip(new ClipContext(start, end, ClipContext.Block.COLLIDER,
                ClipContext.Fluid.NONE, arrow));
        if (wall.getType() != HitResult.Type.MISS) {
            end = wall.getLocation();
        }

        // 沿这一 tick 的完整线段扫描：快速箭矢也不会跳过目标
        Vec3 closest = null;
        double best = Double.MAX_VALUE;
        List<ServerPlayer> players = level.players();
        for (int i = 0; i < players.size(); i++) {
            ServerPlayer player = players.get(i);
            if (player.isSpectator() || !player.isAlive() || player == arrow.getOwner()) {
                continue;
            }
            var directBox = player.getBoundingBox();
            if (directBox.clip(start, end).isPresent() || directBox.contains(start)) {
                continue; // 原生直击会精确结算一次，这里不重复处理
            }
            var proximity = player.getBoundingBox().inflate(PROXIMITY_INFLATE);
            Optional<Vec3> hit = proximity.contains(start) ? Optional.of(start) : proximity.clip(start, end);
            if (hit.isEmpty()) {
                continue;
            }
            Vec3 at = hit.get();
            if (travelled(arrow, at) < BURST_RANGE || !visible(level, player, at, body(player))) {
                continue;
            }
            double distance = start.distanceToSqr(at);
            if (distance < best) {
                best = distance;
                closest = at;
            }
        }
        if (closest != null) {
            burst(arrow, closest, null);
            arrow.discard();
            return true;
        }
        return false;
    }

    /** 命中实体：按飞行距离换算伤害。返回 true 表示要取消原版结算。 */
    public static boolean onHitEntity(AbstractArrow arrow, EntityHitResult hit) {
        if (!isOurs(arrow)) {
            return false;
        }
        Entity target = hit.getEntity();
        double distance = travelled(arrow, hit.getLocation());
        boolean bow = isBow(arrow);
        if (!bow) {
            arrow.addTag("pvp.landed");
        }
        double damage = bow
                ? Math.min(24, 3 + Math.max(0, distance - 12) * 21 / 36) * origin(arrow).charge()
                : (distance >= BURST_RANGE ? 100 : 4);
        // 原版结算会保留盾牌、护甲、友伤与击杀归属，所以只调基础伤害
        arrow.setCritArrow(false);
        arrow.setBaseDamage(Math.max(0, damage - 0.001) / Math.max(0.001, arrow.getDeltaMovement().length()));
        if (bow && distance >= BURST_RANGE) {
            burst(arrow, hit.getLocation(), target);
        }
        return false;
    }

    /** 命中方块：弓箭在远处撞墙时同样近炸。返回 true 表示要取消原版结算。 */
    public static boolean onHitBlock(AbstractArrow arrow, BlockHitResult hit) {
        if (!isOurs(arrow)) {
            return false;
        }
        arrow.addTag("pvp.landed");
        if (isBow(arrow) && travelled(arrow, hit.getLocation()) >= BURST_RANGE) {
            Vec3 normal = Vec3.atLowerCornerOf(hit.getDirection().getUnitVec3i());
            burst(arrow, hit.getLocation().add(normal.scale(0.05)), null);
            arrow.discard();
            return true;
        }
        return false;
    }

    /** 清掉缓存里已经消失的箭，避免 WeakHashMap 之外还留着引用（防御性）。 */
    public static void prune() {
        ORIGINS.keySet().removeIf(arrow -> arrow == null || arrow.isRemoved());
        BOLT_MOTION.keySet().removeIf(arrow -> arrow == null || arrow.isRemoved());
        List<AbstractArrow> dead = new ArrayList<>();
        for (AbstractArrow arrow : ORIGINS.keySet()) {
            if (arrow.isRemoved()) {
                dead.add(arrow);
            }
        }
        for (AbstractArrow arrow : dead) {
            ORIGINS.remove(arrow);
            BOLT_MOTION.remove(arrow);
        }
    }
}
