package pvpshot.match;

import java.util.List;

import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.scores.PlayerTeam;

import pvpshot.protect.ProtectionRegions;

/**
 * 一个占领点。
 *
 * <p>判定规则完全照搬现状数据包（{@code pvpshot:point/tick_one} 与 {@code point/count}）：
 *
 * <ul>
 *   <li>参与统计的玩家：本方队伍、非旁观、非创造、存活；</li>
 *   <li>距离点位中心 ≤ RADIUS 格（3D 距离），且脚部高度与点位高度差 ≤ POINT_HEIGHT；</li>
 *   <li>人多的那一方每 tick 推进 1 点进度，人数相同则冻结；</li>
 *   <li>进度范围 -CAPTURE_FULL .. +CAPTURE_FULL，跨过 0 先中立化，再被对方占满；</li>
 *   <li>计分脉冲时：点被己方占领且**敌方无人在点内**，己方 +POINT_SCORE。</li>
 * </ul>
 */
public final class CapturePoint {

    /** 队伍名（与数据包一致）。 */
    public static final String TEAM_RED = "pvpshot.red";
    public static final String TEAM_BLUE = "pvpshot.blue";

    private static final double RADIUS_SQUARED =
            (double) MatchConfig.POINT_RADIUS * MatchConfig.POINT_RADIUS;

    private final String id;
    private final double x;
    private final double y;
    private final double z;

    /** 0 = 中立，1 = 红方占领，2 = 蓝方占领。 */
    private int owner;
    /** 占领进度：+CAPTURE_FULL 红占满，-CAPTURE_FULL 蓝占满。 */
    private int capture;

    /** 上一次统计到的人数（用于 UI 与调试）。 */
    private int redCount;
    private int blueCount;

    public CapturePoint(String id, double x, double y, double z) {
        this.id = id;
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public String id() {
        return id;
    }

    public double x() {
        return x;
    }

    public double y() {
        return y;
    }

    public double z() {
        return z;
    }

    public int owner() {
        return owner;
    }

    public int capture() {
        return capture;
    }

    public int redCount() {
        return redCount;
    }

    public int blueCount() {
        return blueCount;
    }

    /** 占领进度百分比（-100..100 映射到 0..100 的"红方占据程度"）。 */
    public float progressForRed() {
        return (capture + MatchConfig.CAPTURE_FULL) / (float) (MatchConfig.CAPTURE_FULL * 2);
    }

    public boolean isOwnedByRed() {
        return owner == 1;
    }

    public boolean isOwnedByBlue() {
        return owner == 2;
    }

    /** 归零（重置比赛时用）。 */
    public void reset() {
        owner = 0;
        capture = 0;
        redCount = 0;
        blueCount = 0;
    }

    /**
     * 推进一个 tick。返回本 tick 因占领产生的分数变化：{红方加分, 蓝方加分}。
     */
    public int[] tick(ServerLevel level, boolean scorePulse) {
        countPlayers(level);

        if (redCount > blueCount && capture < MatchConfig.CAPTURE_FULL) {
            capture++;
        } else if (blueCount > redCount && capture > -MatchConfig.CAPTURE_FULL) {
            capture--;
        }

        // 跨过 0 先中立化，再由对方占满（与数据包顺序一致）
        if (owner == 1 && capture <= 0) {
            owner = 0;
        }
        if (owner == 2 && capture >= 0) {
            owner = 0;
        }
        if (capture >= MatchConfig.CAPTURE_FULL) {
            owner = 1;
        }
        if (capture <= -MatchConfig.CAPTURE_FULL) {
            owner = 2;
        }

        // 敌方有人在点内就停止得分（即使点仍归己方）
        if (!scorePulse) {
            return null;
        }
        if (owner == 1 && blueCount == 0) {
            return new int[]{MatchConfig.POINT_SCORE, 0};
        }
        if (owner == 2 && redCount == 0) {
            return new int[]{0, MatchConfig.POINT_SCORE};
        }
        return null;
    }

    private void countPlayers(ServerLevel level) {
        int red = 0;
        int blue = 0;
        List<ServerPlayer> players = level.players();
        for (int i = 0; i < players.size(); i++) {
            ServerPlayer player = players.get(i);
            if (!countsAsCombatant(player)) {
                continue;
            }
            double dx = player.getX() - x;
            double dy = player.getY() - y;
            double dz = player.getZ() - z;
            if (dx * dx + dy * dy + dz * dz > RADIUS_SQUARED) {
                continue;
            }
            if (Math.abs(dy) > MatchConfig.POINT_HEIGHT) {
                continue;
            }
            String team = teamOf(level, player);
            if (TEAM_RED.equals(team)) {
                red++;
            } else if (TEAM_BLUE.equals(team)) {
                blue++;
            }
        }
        redCount = red;
        blueCount = blue;
    }

    private static boolean countsAsCombatant(ServerPlayer player) {
        // 与数据包的过滤条件一致：gamemode=!spectator、gamemode=!creative、Health > 0
        return !player.isSpectator() && !player.isCreative() && player.isAlive();
    }

    public static String teamOf(ServerLevel level, ServerPlayer player) {
        PlayerTeam team = level.getScoreboard().getPlayersTeam(player.getScoreboardName());
        return team == null ? "" : team.getName();
    }

    /** 该点位是否参与当前模式（三点模式只用 A/B/C）。 */
    public boolean activeIn(MatchEngine.Mode mode) {
        return switch (mode) {
            case THREE_POINT -> id.equals("A") || id.equals("B") || id.equals("C");
            case FIVE_POINT -> true;
            case DEATHMATCH -> false;
        };
    }

    /** 供 UI 显示的点位归属标记。 */
    public String shortStatus() {
        return id + ":" + ownerLabel();
    }

    /** 归属的单字标记：红 / 蓝 / 中。 */
    public String ownerLabel() {
        return switch (owner) {
            case 1 -> "红";
            case 2 -> "蓝";
            default -> "中";
        };
    }

    /** 该点是否受设施保护（保护区里包含点位核心与旗杆）。 */
    public boolean isProtected(ServerLevel level) {
        return ProtectionRegions.protectedAt(level,
                net.minecraft.core.BlockPos.containing(x, y, z));
    }
}
