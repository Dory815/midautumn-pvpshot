package pvpshot.weapon;

import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.item.ItemEntity;
import net.minecraft.world.level.Level;

/**
 * 掉落物拦截（M4.4，从旧插桩模块移植）。
 *
 * <p>原实现用三层处理（关掉落规则 + Java 拦截 + 数据包清理）。这里承担中间那层：
 * 只要数据包把 {@code #drops.clear} 置 1（比赛进行中），战场范围内就不允许生成掉落物，
 * 避免有人靠丢装备给队友或满地垃圾影响服务器。
 */
public final class DropGuard {

    /** 是否应当拦截这个实体的生成。 */
    public static boolean shouldDeny(Entity entity) {
        if (!(entity instanceof ItemEntity)) {
            return false;
        }
        ServerLevel level = (ServerLevel) entity.level();
        if (level.dimension() != Level.OVERWORLD || !CombatUtil.inArena(entity)) {
            return false;
        }
        return CombatUtil.named(level, "#drops.clear", "ustc.clock") == 1;
    }

    private DropGuard() {
    }
}
