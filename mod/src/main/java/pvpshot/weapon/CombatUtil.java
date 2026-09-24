package pvpshot.weapon;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import net.minecraft.core.BlockPos;
import net.minecraft.core.registries.Registries;
import net.minecraft.network.chat.Component;
import net.minecraft.resources.Identifier;
import net.minecraft.resources.ResourceKey;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.damagesource.DamageSource;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.level.ClipContext;
import net.minecraft.world.level.Level;
import net.minecraft.world.phys.AABB;
import net.minecraft.world.phys.HitResult;
import net.minecraft.world.phys.Vec3;
import net.minecraft.world.scores.Objective;
import net.minecraft.world.scores.ReadOnlyScoreInfo;
import net.minecraft.world.scores.ScoreHolder;
import net.minecraft.world.scores.Scoreboard;

/**
 * 武器系统共用的工具方法（从旧插桩模块移植）。
 *
 * <p>这一层保留与数据包的互操作：分数读写、执行数据包命令、消息提示。
 * 在模组完全接管玩法之前，这些仍是与旧逻辑衔接的接口。
 */
public final class CombatUtil {

    /** 竞技场范围（与数据包一致），用于限制某些逻辑只在战场内生效。 */
    public static boolean inArena(Entity entity) {
        return entity.level().dimension() == Level.OVERWORLD
                && entity.getX() >= -2149 && entity.getX() < -1568
                && entity.getZ() >= -1807 && entity.getZ() < -1152;
    }

    public static int score(ServerLevel level, ScoreHolder holder, String objective) {
        Scoreboard board = level.getScoreboard();
        Objective obj = board.getObjective(objective);
        if (obj == null) {
            return 0;
        }
        ReadOnlyScoreInfo info = board.getPlayerScoreInfo(holder, obj);
        return info == null ? 0 : info.value();
    }

    public static int score(ServerPlayer player, String objective) {
        return score(player.level(), player, objective);
    }

    public static int named(ServerLevel level, String name, String objective) {
        return score(level, ScoreHolder.forNameOnly(name), objective);
    }

    public static void setScore(ServerPlayer player, String objective, int value) {
        Scoreboard board = player.level().getScoreboard();
        Objective obj = board.getObjective(objective);
        if (obj != null) {
            board.getOrCreatePlayerScore(player, obj).set(value);
        }
    }

    /** 以玩家身份执行一条原版/数据包命令（保留与旧数据包的互操作）。 */
    public static void command(ServerPlayer player, String line) {
        var server = player.level().getServer();
        server.getCommands().performPrefixedCommand(
                server.createCommandSourceStack()
                        .withLevel(player.level())
                        .withEntity(player)
                        .withPosition(player.position())
                        .withRotation(player.getRotationVector())
                        .withSuppressedOutput(),
                line);
    }

    public static void message(ServerPlayer player, String text) {
        player.sendSystemMessage(Component.literal(text), true);
    }

    public static DamageSource customDamage(ServerLevel level, String id, Entity direct, Entity owner) {
        return new DamageSource(level.registryAccess()
                .lookupOrThrow(Registries.DAMAGE_TYPE)
                .getOrThrow(ResourceKey.create(Registries.DAMAGE_TYPE, Identifier.parse(id))),
                direct, owner);
    }

    public static Vec3 body(Entity entity) {
        return entity.getBoundingBox().getCenter();
    }

    public static boolean visible(ServerLevel level, Entity target, Vec3 from, Vec3 to) {
        return level.clip(new ClipContext(from, to, ClipContext.Block.COLLIDER,
                ClipContext.Fluid.NONE, target)).getType() == HitResult.Type.MISS;
    }

    /** 把落点抬到附近的开阔空气里，避免爆炸卡在方块内。 */
    public static Vec3 openAir(ServerLevel level, Vec3 at) {
        BlockPos pos = BlockPos.containing(at);
        if (!level.getBlockState(pos).isAir()) {
            for (int dy = 1; dy <= 8; dy++) {
                BlockPos up = pos.above(dy);
                if (level.getBlockState(up).isAir()) {
                    return Vec3.atCenterOf(up);
                }
            }
            return at.add(0, 1.5, 0);
        }
        return at.add(0, 0.8, 0);
    }

    /** 射线瞄准点：命中方块就用命中点，否则取最大射程处向下的落点。 */
    public static Vec3 aimPoint(ServerPlayer player) {
        Vec3 start = player.getEyePosition();
        Vec3 end = start.add(player.getLookAngle().scale(120));
        var hit = player.level().clip(new ClipContext(start, end, ClipContext.Block.COLLIDER,
                ClipContext.Fluid.NONE, player));
        if (hit.getType() != HitResult.Type.MISS) {
            return hit.getLocation().add(0, 0.2, 0);
        }
        var down = player.level().clip(new ClipContext(end, end.add(0, -160, 0),
                ClipContext.Block.COLLIDER, ClipContext.Fluid.NONE, player));
        return down.getType() == HitResult.Type.MISS ? end : down.getLocation().add(0, 0.2, 0);
    }

    /** 收集一段线段上最近的活体目标（排除自己）。 */
    public static LivingTarget nearestAlong(ServerLevel level, Vec3 from, Vec3 to, Entity exclude,
                                            double inflate) {
        LivingTarget best = null;
        double bestDistance = from.distanceToSqr(to);
        List<net.minecraft.world.entity.LivingEntity> candidates =
                level.getEntitiesOfClass(net.minecraft.world.entity.LivingEntity.class,
                        new AABB(from, to).inflate(inflate),
                        entity -> entity != exclude && entity.isAlive() && !entity.isSpectator());
        for (int i = 0; i < candidates.size(); i++) {
            var entity = candidates.get(i);
            var box = entity.getBoundingBox().inflate(0.1);
            Optional<Vec3> crossing = box.contains(from) ? Optional.of(from) : box.clip(from, to);
            if (crossing.isEmpty()) {
                continue;
            }
            double distance = from.distanceToSqr(crossing.get());
            if (distance < bestDistance) {
                bestDistance = distance;
                best = new LivingTarget(entity, crossing.get(), distance);
            }
        }
        return best;
    }

    /** 线段命中的活体目标。 */
    public record LivingTarget(net.minecraft.world.entity.LivingEntity entity, Vec3 hit, double distanceSquared) {
        public double range() {
            return Math.sqrt(distanceSquared);
        }
    }

    /** 玩家背包里某种武器的总数量。 */
    public static int countWeapon(ServerPlayer player, String weaponId) {
        int total = 0;
        var inventory = player.getInventory();
        for (int i = 0; i < inventory.getContainerSize(); i++) {
            var stack = inventory.getItem(i);
            if (WeaponIds.of(stack).equals(weaponId)) {
                total += stack.getCount();
            }
        }
        return total;
    }

    /** 清掉玩家身上所有以某前缀开头的自定义武器物品（例如战斗机装备）。 */
    public static void clearWeaponsWithPrefix(ServerPlayer player, String prefix) {
        var inventory = player.getInventory();
        for (int i = 0; i < inventory.getContainerSize(); i++) {
            if (WeaponIds.of(inventory.getItem(i)).startsWith(prefix)) {
                inventory.setItem(i, net.minecraft.world.item.ItemStack.EMPTY);
            }
        }
    }

    /** 只清理正面增益，保留缓降（与原实现一致）。 */
    public static void clearBuffs(ServerPlayer player) {
        for (var effect : new ArrayList<>(player.getActiveEffects())) {
            if (effect.getEffect().value().getCategory()
                    == net.minecraft.world.effect.MobEffectCategory.BENEFICIAL
                    && !effect.getEffect().equals(net.minecraft.world.effect.MobEffects.SLOW_FALLING)) {
                player.removeEffect(effect.getEffect());
            }
        }
    }

    /** 是否同队（用于避免误伤判定）。 */
    public static boolean sameTeam(Player a, Player b) {
        var teamA = a.getTeam();
        return teamA != null && teamA == b.getTeam();
    }

    private CombatUtil() {
    }
}
