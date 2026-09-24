package pvpshot.match;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import net.minecraft.network.chat.Component;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.level.ServerBossEvent;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.BossEvent;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.EntityTypes;

import pvpshot.PvpShotMod;

/**
 * 比赛引擎（M3）：占领点扫描、占领推进、计分、胜负、比分条。
 *
 * <p>设计上刻意做成"可以随时关闭"：{@link #enabled} 默认 false，此时模组完全不干预比赛，
 * 旧数据包照常运行。等实测确认行为一致后再打开，实现平滑交接。
 *
 * <p>本类目前覆盖**占领模式**（三点/五点）。团队死斗需要击杀事件驱动，
 * 与玩家死亡/复活逻辑一起在下一步做。
 */
public final class MatchEngine {

    /** 比赛模式。 */
    public enum Mode {
        /** 三点占领：A/B/C，目标 600。 */
        THREE_POINT("三点占领"),
        /** 五点占领：A~E，目标 1000。 */
        FIVE_POINT("五点占领"),
        /** 团队死斗：目标 60（击杀计分，尚未实现）。 */
        DEATHMATCH("团队死斗");

        private final String label;

        Mode(String label) {
            this.label = label;
        }

        public String label() {
            return label;
        }
    }

    private static final UUID BAR_ID = UUID.fromString("6b4c1a52-3d7e-4a1c-9f6b-2f2b7c9d1e01");
    private static final ServerBossEvent SCORE_BAR = new ServerBossEvent(
            BAR_ID, Component.literal("比分"), BossEvent.BossBarColor.WHITE,
            BossEvent.BossBarOverlay.PROGRESS);

    private static final List<CapturePoint> POINTS = new ArrayList<>();

    private static boolean enabled;
    private static Mode mode = Mode.FIVE_POINT;
    private static int redScore;
    private static int blueScore;
    private static boolean finished;
    private static int scoreClock;

    private MatchEngine() {
    }

    public static boolean isEnabled() {
        return enabled;
    }

    public static Mode mode() {
        return mode;
    }

    public static int redScore() {
        return redScore;
    }

    public static int blueScore() {
        return blueScore;
    }

    public static int goal() {
        return switch (mode) {
            case THREE_POINT -> MatchConfig.GOAL_THREE_POINT;
            case FIVE_POINT -> MatchConfig.GOAL_FIVE_POINT;
            case DEATHMATCH -> MatchConfig.GOAL_DEATHMATCH;
        };
    }

    public static List<CapturePoint> points() {
        return POINTS;
    }

    // ---------------------------------------------------------------- 生命周期

    /** 开关模组接管。默认关闭，避免与旧数据包同时驱动比赛。 */
    public static String setEnabled(boolean value, MinecraftServer server) {
        enabled = value;
        if (!value) {
            SCORE_BAR.setVisible(false);
            SCORE_BAR.removeAllPlayers();
            return "模组比赛引擎已关闭（改由数据包驱动）";
        }
        rescanPoints(server.overworld());
        SCORE_BAR.setVisible(true);
        return "模组比赛引擎已开启：" + mode.label() + "，目标 " + goal() + " 分，"
                + "识别到 " + POINTS.size() + " 个占领点";
    }

    public static String setMode(Mode value) {
        mode = value;
        finished = false;
        redScore = 0;
        blueScore = 0;
        scoreClock = 0;
        return "模式已切换为 " + value.label() + "（目标 " + goal() + " 分），比分已清零";
    }

    /** 重新开始一局（比分与点位归属清零）。 */
    public static String restart() {
        redScore = 0;
        blueScore = 0;
        finished = false;
        scoreClock = 0;
        for (CapturePoint point : POINTS) {
            point.reset();
        }
        return "已重置比分与点位归属";
    }

    /** 从世界里的 marker 实体扫描占领点（点位由地图数据保留，不写死在代码里）。 */
    public static void rescanPoints(ServerLevel overworld) {
        POINTS.clear();
        // 用 EntityTypes（复数）与现有代码保持一致
        for (Entity marker : overworld.getEntities(EntityTypes.MARKER,
                entity -> entity.entityTags().contains("ustc.point"))) {
            String id = null;
            for (String tag : marker.entityTags()) {
                if (tag.startsWith("ustc.point.") && tag.length() > "ustc.point.".length()) {
                    id = tag.substring("ustc.point.".length());
                    break;
                }
            }
            if (id == null) {
                continue;
            }
            POINTS.add(new CapturePoint(id, marker.getX(), marker.getY(), marker.getZ()));
        }
        POINTS.sort(Comparator.comparing(CapturePoint::id));
        PvpShotMod.LOGGER.info("[pvpshot] 扫描到 {} 个占领点：{}", POINTS.size(),
                POINTS.stream().map(CapturePoint::id).toList());
    }

    // ------------------------------------------------------------------- 主循环

    public static void tick(MinecraftServer server) {
        if (!enabled) {
            return;
        }
        ServerLevel overworld = server.overworld();
        if (POINTS.isEmpty()) {
            rescanPoints(overworld);
            if (POINTS.isEmpty()) {
                return;
            }
        }

        if (finished) {
            updateBar(server);
            return;
        }

        scoreClock++;
        boolean scorePulse = scoreClock >= MatchConfig.POINT_INTERVAL_TICKS;
        if (scorePulse) {
            scoreClock = 0;
        }

        for (int i = 0; i < POINTS.size(); i++) {
            CapturePoint point = POINTS.get(i);
            if (!point.activeIn(mode)) {
                continue;
            }
            int[] delta = point.tick(overworld, scorePulse);
            if (delta != null) {
                redScore += delta[0];
                blueScore += delta[1];
            }
        }

        updateBar(server);
        checkWin(server);
    }

    private static void checkWin(MinecraftServer server) {
        int goal = goal();
        if (redScore < goal && blueScore < goal) {
            return;
        }
        finished = true;
        String text = redScore > blueScore ? "红方获胜！"
                : blueScore > redScore ? "蓝方获胜！" : "平局！";
        String message = String.format("[PVP] %s 最终比分 红 %d : %d 蓝", text, redScore, blueScore);
        PvpShotMod.LOGGER.info("[pvpshot] {}", message);
        for (ServerPlayer player : server.getPlayerList().getPlayers()) {
            player.sendSystemMessage(Component.literal(message));
        }
    }

    private static void updateBar(MinecraftServer server) {
        StringBuilder pointsLine = new StringBuilder();
        for (CapturePoint point : POINTS) {
            if (!point.activeIn(mode)) {
                continue;
            }
            pointsLine.append(' ').append(point.shortStatus());
        }
        SCORE_BAR.setName(Component.literal(
                String.format("红 %d : %d 蓝   |%s", redScore, blueScore, pointsLine)));
        SCORE_BAR.setProgress(Math.min(1.0F, Math.max(redScore, blueScore) / (float) goal()));
        for (ServerPlayer player : server.getPlayerList().getPlayers()) {
            SCORE_BAR.addPlayer(player);
        }
    }

    // -------------------------------------------------------------------- 查询

    public static String statusText() {
        StringBuilder builder = new StringBuilder();
        builder.append("比赛引擎：").append(enabled ? "已开启（模组驱动）" : "已关闭（数据包驱动）");
        builder.append("，模式 ").append(mode.label()).append("，目标 ").append(goal()).append(" 分");
        builder.append("，比分 红 ").append(redScore).append(" : ").append(blueScore).append(" 蓝");
        if (finished) {
            builder.append("（已结束）");
        }
        if (!POINTS.isEmpty()) {
            builder.append("；点位：");
            for (CapturePoint point : POINTS) {
                builder.append(' ').append(point.id())
                        .append('(').append(point.ownerLabel())
                        .append(" 红").append(point.redCount())
                        .append(" 蓝").append(point.blueCount())
                        .append(')');
            }
        }
        return builder.toString();
    }
}
