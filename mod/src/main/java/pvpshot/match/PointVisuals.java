package pvpshot.match;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import net.minecraft.core.particles.DustParticleOptions;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.EntityTypes;
import net.minecraft.world.entity.decoration.ArmorStand;
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
    private static final int RING_POINTS = 32;

    /** 玩家离点位多远之内才需要画粒子（避免远处白刷）。 */
    private static final double PARTICLE_NEARBY_RANGE = 64.0;

    private static final Map<String, Entity> MARKERS = new HashMap<>();
    private static final Map<String, TeamColor> LAST_COLORS = new HashMap<>();

    private static boolean enabled = true;
    private static int clock;

    private PointVisuals() {
    }

    public static boolean isEnabled() {
        return enabled;
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
            // 不启用的点位：留在原地但不发光（作者要求）
            marker.setGlowingTag(active);
            TeamColor color = active ? colorFor(point.owner()) : TeamColor.GRAY;
            applyTeam(level, point, marker, color, active);

            if (active && drawParticles && hasPlayerNearby(level, point)) {
                drawRangeRing(level, point, color);
            }
        }
    }

    /** 找一个点位的标记实体；没有就新建一个隐形盔甲架。 */
    private static Entity markerFor(ServerLevel level, CapturePoint point) {
        Entity cached = MARKERS.get(point.id());
        if (cached != null && cached.isAlive() && !cached.isRemoved()) {
            return cached;
        }
        String tag = TAG_PREFIX + point.id();
        for (Entity entity : level.getEntities(EntityTypes.ARMOR_STAND,
                candidate -> candidate.entityTags().contains(tag))) {
            MARKERS.put(point.id(), entity);
            return entity;
        }
        ArmorStand stand = new ArmorStand(level, point.x(), point.y() + 1.5, point.z());
        stand.setInvisible(true);
        stand.setInvulnerable(true);
        stand.setNoGravity(true);
        stand.setSilent(true);
        stand.setCustomNameVisible(false);
        stand.addTag(tag);
        if (!level.addFreshEntity(stand)) {
            return null;
        }
        MARKERS.put(point.id(), stand);
        PvpShotMod.LOGGER.info("[pvpshot] 为点位 {} 创建了标记实体", point.id());
        return stand;
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

    /** 在判定范围的上/下两个高度各画一个圆环，把范围"框"出来。 */
    private static void drawRangeRing(ServerLevel level, CapturePoint point, TeamColor color) {
        DustParticleOptions dust = new DustParticleOptions(color.rgb(), 1.6F);
        double radius = MatchConfig.POINT_RADIUS;
        double lower = point.y() - MatchConfig.POINT_HEIGHT;
        double upper = point.y() + MatchConfig.POINT_HEIGHT;

        for (int i = 0; i < RING_POINTS; i++) {
            double angle = (i * 2.0 * Math.PI) / RING_POINTS;
            double dx = Math.cos(angle) * radius;
            double dz = Math.sin(angle) * radius;
            level.sendParticles(dust, point.x() + dx, upper, point.z() + dz, 1, 0, 0, 0, 0);
            level.sendParticles(dust, point.x() + dx, lower, point.z() + dz, 1, 0, 0, 0, 0);
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
