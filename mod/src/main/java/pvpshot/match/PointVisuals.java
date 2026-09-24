package pvpshot.match;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import net.minecraft.core.particles.DustParticleOptions;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.network.chat.Component;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.util.Mth;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.EntityTypes;
import net.minecraft.world.entity.Display;
import net.minecraft.world.item.DyeColor;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.levelgen.Heightmap;
import net.minecraft.world.scores.Objective;
import net.minecraft.world.scores.PlayerTeam;
import net.minecraft.world.scores.ReadOnlyScoreInfo;
import net.minecraft.world.scores.ScoreHolder;
import net.minecraft.world.scores.Scoreboard;
import net.minecraft.world.scores.Team;
import net.minecraft.world.scores.TeamColor;

import pvpshot.PvpShotMod;

/**
 * 占领点的可视化：范围边框 + 发光标记实体。
 *
 * <p>两件事都是**纯服务端、原版客户端可见**的做法，不注册任何自定义内容：
 *
 * <ol>
 *   <li><b>范围边框</b>：用原版 {@code dust} 粒子在判定范围的上/下两个高度各画一个圆环，
 *       半径与判定半径一致（{@link MatchConfig#POINT_RADIUS}），高度用
 *       {@link MatchConfig#POINT_HEIGHT}。粒子颜色跟随点位归属。</li>
 *   <li><b>发光标记</b>：每个点位一个隐形盔甲架（{@code ArmorStand}），
 *       用原版 {@code setGlowingTag} 打开发光；发光轮廓的颜色由**队伍颜色**决定，
 *       因此给每个点位单独建一个显示用队伍，按归属切换红/蓝/白。
 *       点位在当前模式下不启用（例如三点模式下的 D、E）时关闭发光。</li>
 * </ol>
 *
 * <p>性能上的两个自我约束：只在点位附近有玩家时才画粒子；颜色只在发生变化时才更新，
 * 避免每 tick 向客户端推送队伍更新包。
 */
public final class PointVisuals {

    private static final String TAG_PREFIX = "pvpshot.mark.";
    private static final String TEAM_PREFIX = "pvpshot.mark.";

    /** 粒子刷新间隔（tick）：0.5 秒画一次边框。 */
    private static final int PARTICLE_INTERVAL_TICKS = 10;

    /** 每个圆环的采样点数。 */
    private static final int RING_POINTS = 36;

    /** 每层之间的高度间隔（格）。 */
    private static final double RING_LAYER_STEP = 2.0;

    /** 最少画几层（即使点位很低也要有多层，保证显眼）。 */
    private static final int RING_MIN_LAYERS = 3;

    /** 最多画几层（避免高塔上刷太多粒子）。 */
    private static final int RING_MAX_LAYERS = 7;

    /** 方位指示的刷新间隔（tick）：60 tick = 3 秒。 */
    private static final int COMPASS_INTERVAL_TICKS = 60;

    /** 玩家离点位多远之内才需要画粒子（避免远处白刷）。 */
    private static final double PARTICLE_NEARBY_RANGE = 64.0;

    private static final Map<String, Entity> MARKERS = new HashMap<>();
    private static final Map<String, TeamColor> LAST_COLORS = new HashMap<>();

    private static boolean enabled = true;
    private static int clock;

    /** 方位指示：每 60 tick（3 秒）给每个玩家发一条 actionbar，列出各点的方向、距离与归属。 */
    private static boolean compassEnabled = true;
    private static int compassClock;

    private PointVisuals() {
    }

    public static boolean isEnabled() {
        return enabled;
    }

    public static String setCompassEnabled(boolean value) {
        compassEnabled = value;
        return value
                ? "方位指示已开启（每 3 秒在物品栏上方显示各点方向）"
                : "方位指示已关闭";
    }

    public static String setEnabled(boolean value, ServerLevel level) {
        enabled = value;
        if (!value) {
            for (Entity marker : MARKERS.values()) {
                if (marker.isAlive()) {
                    marker.setGlowingTag(false);
                }
            }
            return "点位可视化已关闭（标记实体保留，但不再发光、不再画范围）";
        }
        return "点位可视化已开启";
    }

    /** 当前应采用哪个模式：模组引擎开着就听它的，否则读数据包写在记分板上的 #preset。 */
    public static MatchEngine.Mode resolveMode(ServerLevel level) {
        if (MatchEngine.isEnabled()) {
            return MatchEngine.mode();
        }
        int preset = readPreset(level);
        return switch (preset) {
            case 3 -> MatchEngine.Mode.THREE_POINT;
            case 1 -> MatchEngine.Mode.DEATHMATCH;
            default -> MatchEngine.Mode.FIVE_POINT;
        };
    }

    private static int readPreset(ServerLevel level) {
        Scoreboard board = level.getScoreboard();
        Objective clockObjective = board.getObjective("ustc.clock");
        if (clockObjective == null) {
            return 0;
        }
        ReadOnlyScoreInfo info =
                board.getPlayerScoreInfo(ScoreHolder.forNameOnly("#preset"), clockObjective);
        return info == null ? 0 : info.value();
    }

    public static void tick(MinecraftServer server) {
        if (!enabled) {
            return;
        }
        ServerLevel level = server.overworld();
        List<CapturePoint> points = MatchEngine.points();
        if (points.isEmpty()) {
            return;
        }
        MatchEngine.Mode mode = resolveMode(level);
        clock++;
        boolean drawParticles = clock % PARTICLE_INTERVAL_TICKS == 0;

        for (int i = 0; i < points.size(); i++) {
            CapturePoint point = points.get(i);
            boolean active = point.activeIn(mode);
            Entity marker = markerFor(level, point);
            if (marker == null) {
                continue;
            }
            TeamColor color = active ? colorFor(point.owner()) : TeamColor.GRAY;
            // 不启用的点位：留在原地但不发光、也不画范围（作者要求）
            applyAppearance(level, point, marker, color, active);

            if (active && drawParticles && hasPlayerNearby(level, point)) {
                drawRangeRings(level, point, color);
            }
        }

        // 方位指示：跟实体/粒子不同，走 UI，不受视距限制
        if (compassEnabled && ++compassClock >= COMPASS_INTERVAL_TICKS) {
            compassClock = 0;
            sendCompass(server, points, mode);
        }
    }

    /**
     * 给每个玩家单独算一份"点位罗盘"。
     *
     * <p>为什么不用 Bossbar：Bossbar 的名称是全体共用的，而方位是相对每个玩家的，
     * 只有 actionbar / title 这类 per-player 的 UI 才能做到"各自看到各自的方向"。
     */
    private static void sendCompass(MinecraftServer server, List<CapturePoint> points,
                                    MatchEngine.Mode mode) {
        for (ServerPlayer player : server.getPlayerList().getPlayers()) {
            StringBuilder line = new StringBuilder();
            for (int i = 0; i < points.size(); i++) {
                CapturePoint point = points.get(i);
                if (!point.activeIn(mode)) {
                    continue;
                }
                double dx = point.x() - player.getX();
                double dz = point.z() - player.getZ();
                int distance = (int) Math.round(Math.sqrt(dx * dx + dz * dz));
                if (line.length() > 0) {
                    line.append("  ");
                }
                line.append(point.id()).append(point.ownerLabel())
                        .append(arrowFor(dx, dz)).append(distance);
            }
            if (line.length() > 0) {
                // 第二个参数 true = 显示在物品栏上方（actionbar）
                player.sendSystemMessage(Component.literal(line.toString()), true);
            }
        }
    }

    /** 八方向箭头：0=北，顺时针。 */
    private static final String[] ARROWS = {"↑", "↗", "→", "↘", "↓", "↙", "←", "↖"};

    private static String arrowFor(double dx, double dz) {
        // atan2(dx, -dz)：正北为 0°，顺时针增大
        double degrees = Math.toDegrees(Math.atan2(dx, -dz));
        int index = (int) Math.round(degrees / 45.0) & 7;
        return ARROWS[index];
    }

    /**
     * 找一个点位的标记实体（方块显示实体）。
     *
     * <p>早期版本用的是隐形盔甲架，只有一层很细的人形轮廓，非常不显眼（作者反馈）。
     * 现在改成展示一个**方块**：方块本身的颜色就跟随归属（红/蓝/白混凝土），
     * 再叠加一层同样颜色的发光轮廓，远近都能看清。
     * 第一次扫描时会把旧的盔甲架标记清掉，不需要手动清理存档。
     */
    private static Entity markerFor(ServerLevel level, CapturePoint point) {
        Entity cached = MARKERS.get(point.id());
        if (cached != null && cached.isAlive() && !cached.isRemoved()
                && cached instanceof Display.BlockDisplay) {
            return cached;
        }
        String tag = TAG_PREFIX + point.id();
        // 清理早期版本留下的隐形盔甲架
        for (Entity old : level.getEntities(EntityTypes.ARMOR_STAND,
                candidate -> candidate.entityTags().contains(tag))) {
            old.discard();
        }
        for (Entity existing : level.getEntities(EntityTypes.BLOCK_DISPLAY,
                candidate -> candidate.entityTags().contains(tag))) {
            MARKERS.put(point.id(), existing);
            return existing;
        }
        Display.BlockDisplay display = new Display.BlockDisplay(EntityTypes.BLOCK_DISPLAY, level);
        display.setPos(point.x(), point.y() + 0.5, point.z());
        display.setBlockState(Blocks.CONCRETE.pick(DyeColor.WHITE).defaultBlockState());
        display.setInvulnerable(true);
        display.setNoGravity(true);
        display.addTag(tag);
        if (!level.addFreshEntity(display)) {
            return null;
        }
        MARKERS.put(point.id(), display);
        PvpShotMod.LOGGER.info("[pvpshot] 为点位 {} 创建了方块标记实体", point.id());
        return display;
    }

    /** 更新标记的外观：方块颜色 + 发光轮廓都跟随归属；未启用则不发光、方块置灰。 */
    private static void applyAppearance(ServerLevel level, CapturePoint point, Entity marker,
                                        TeamColor color, boolean active) {
        if (marker instanceof Display.BlockDisplay display) {
            BlockState wanted = active
                    ? blockForOwner(point.owner())
                    : Blocks.CONCRETE.pick(DyeColor.GRAY).defaultBlockState();
            if (display.getBlockState() != wanted) {
                display.setBlockState(wanted);
            }
        }
        marker.setGlowingTag(active);
        applyTeam(level, point, marker, color, active);
    }

    private static BlockState blockForOwner(int owner) {
        return switch (owner) {
            case 1 -> Blocks.CONCRETE.pick(DyeColor.RED).defaultBlockState();
            case 2 -> Blocks.CONCRETE.pick(DyeColor.BLUE).defaultBlockState();
            default -> Blocks.CONCRETE.pick(DyeColor.WHITE).defaultBlockState();
        };
    }

    /** 把标记实体放进一个点位专属的队伍，并让队伍颜色等于归属颜色（发光轮廓取队伍颜色）。 */
    private static void applyTeam(ServerLevel level, CapturePoint point, Entity marker, TeamColor color,
                                  boolean active) {
        Scoreboard board = level.getScoreboard();
        String teamName = TEAM_PREFIX + point.id();
        PlayerTeam team = board.getPlayerTeam(teamName);
        if (team == null) {
            team = board.addPlayerTeam(teamName);
            team.setNameTagVisibility(Team.Visibility.NEVER);
            team.setColor(Optional.of(color));
            board.onTeamChanged(team);
        } else {
            TeamColor previous = LAST_COLORS.get(point.id());
            if (previous != color) {
                team.setColor(Optional.of(color));
                board.onTeamChanged(team);
            }
        }
        LAST_COLORS.put(point.id(), color);

        String entry = marker.getScoreboardName();
        if (board.getPlayersTeam(entry) != team) {
            board.addPlayerToTeam(entry, team);
        }
    }

    private static TeamColor colorFor(int owner) {
        return switch (owner) {
            case 1 -> TeamColor.RED;
            case 2 -> TeamColor.BLUE;
            default -> TeamColor.WHITE;
        };
    }

    private static boolean hasPlayerNearby(ServerLevel level, CapturePoint point) {
        double rangeSquared = PARTICLE_NEARBY_RANGE * PARTICLE_NEARBY_RANGE;
        List<ServerPlayer> players = level.players();
        for (int i = 0; i < players.size(); i++) {
            ServerPlayer player = players.get(i);
            if (player.position().distanceToSqr(point.x(), point.y(), point.z()) <= rangeSquared) {
                return true;
            }
        }
        return false;
    }

    /**
     * 把判定范围画成一叠"火焰圆环"，从**地面**往上每 {@link #RING_LAYER_STEP} 格一层。
     *
     * <p>改动原因（作者反馈）：原来只有上下两个粉尘环，又细又暗，基本看不清。
     * 现在的主体用原版火焰粒子（自带闪烁、亮、在昏暗环境里也显眼），
     * 每隔几个点插一个队伍色粉尘点，兼顾"归属颜色"的可读性；
     * 最下面一层贴着地面并留 0.2 格余量，玩家站在地上就能看到脚下的圈。
     */
    private static void drawRangeRings(ServerLevel level, CapturePoint point, TeamColor color) {
        DustParticleOptions accent = new DustParticleOptions(color.rgb(), 1.2F);
        double radius = MatchConfig.POINT_RADIUS;
        int surface = level.getHeight(Heightmap.Types.MOTION_BLOCKING,
                Mth.floor(point.x()), Mth.floor(point.z()));
        double top = point.y() + MatchConfig.POINT_HEIGHT;
        int layers = Mth.clamp((int) Math.ceil((top - surface) / RING_LAYER_STEP) + 1,
                RING_MIN_LAYERS, RING_MAX_LAYERS);

        for (int layer = 0; layer < layers; layer++) {
            double y = surface + 0.2 + layer * RING_LAYER_STEP;
            for (int i = 0; i < RING_POINTS; i++) {
                double angle = (i * 2.0 * Math.PI) / RING_POINTS;
                double px = point.x() + Math.cos(angle) * radius;
                double pz = point.z() + Math.sin(angle) * radius;
                if (i % 4 == 0) {
                    // 每 4 个点插一个队伍色粉尘，标明这个圈现在归谁
                    level.sendParticles(accent, px, y, pz, 1, 0.0, 0.0, 0.0, 0.0);
                } else {
                    level.sendParticles(ParticleTypes.FLAME, px, y, pz, 1, 0.01, 0.01, 0.01, 0.0);
                }
            }
        }
    }

    public static String statusText(MinecraftServer server) {
        ServerLevel level = server.overworld();
        MatchEngine.Mode mode = resolveMode(level);
        StringBuilder builder = new StringBuilder();
        builder.append("点位可视化：").append(enabled ? "开启" : "关闭");
        builder.append("；当前模式 ").append(mode.label());
        builder.append("；标记实体 ").append(MARKERS.size()).append(" 个。点位状态：");
        for (CapturePoint point : MatchEngine.points()) {
            builder.append(' ').append(point.id())
                    .append(point.activeIn(mode) ? "(启用," : "(未启用,")
                    .append(point.ownerLabel()).append(')');
        }
        return builder.toString();
    }
}
