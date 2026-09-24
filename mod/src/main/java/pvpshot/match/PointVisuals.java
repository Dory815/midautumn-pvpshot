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
import net.minecraft.world.entity.ai.attributes.AttributeInstance;
import net.minecraft.world.entity.ai.attributes.Attributes;
import net.minecraft.world.entity.monster.cubemob.Slime;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.world.effect.MobEffects;
import net.minecraft.core.BlockPos;
import net.minecraft.world.item.DyeColor;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.Block;
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

    /**
     * 航点传输/接收范围（格）。
     *
     * <p>原版 {@code waypoint_transmit_range} 与 {@code waypoint_receive_range} 的默认值都是 <b>0</b>，
     * 也就是"默认不传输"。必须显式设置成大于 0，点位才会出现在原版定位条上。
     * 这里给到 1000 格，覆盖整张校园地图。
     */
    private static final double WAYPOINT_RANGE = 1000.0;

    /** 承载航点的隐形实体 tag 前缀（与可见标记分开，便于各自维护）。 */
    private static final String BEACON_TAG_PREFIX = "pvpshot.wp.";

    /** 航点埋在多深（相对点位中心，格）。 */
    private static final double BEACON_DEPTH = 2.0;

    /** 多久检查一次基岩外壳（整场复原会把它覆盖掉，需要补回来）。 */
    private static final int SHELL_CHECK_INTERVAL = 100;

    private static int shellClock;

    /** 玩家离点位多远之内才需要画粒子（避免远处白刷）。 */
    private static final double PARTICLE_NEARBY_RANGE = 64.0;

    private static final Map<String, TeamColor> LAST_COLORS = new HashMap<>();

    /**
     * 航点载体缓存。
     *
     * <p>**不要**用 {@code level.getEntities} 来判断"航点是否已存在"：
     * 那个方法只返回**已加载区块**里的实体，点位离玩家远时区块没加载，
     * 于是每 tick 都会误判为"不存在"并新建一个 —— 之前的 bug 就是这样
     * 在几分钟里堆出了 1000 多个隐形史莱姆，定位条被图标糊满。
     */
    private static final Map<String, Slime> BEACONS = new HashMap<>();

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
            for (Slime beacon : BEACONS.values()) {
                if (beacon.isAlive()) {
                    beacon.setGlowingTag(false);
                }
            }
            return "点位可视化已关闭（航点实体保留，但不再发光、不再画范围）";
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
        if (!legacyCleaned) {
            legacyCleaned = true;
            cleanLegacyMarkers(level);
        }
        MatchEngine.Mode mode = resolveMode(level);
        clock++;
        boolean drawParticles = clock % PARTICLE_INTERVAL_TICKS == 0;

        for (int i = 0; i < points.size(); i++) {
            CapturePoint point = points.get(i);
            boolean active = point.activeIn(mode);
            TeamColor color = active ? colorFor(point.owner()) : TeamColor.GRAY;
            // 航点实体：埋在地下、基岩包裹、发光轮廓跟随归属（作者方案）
            ensureWaypoint(level, point, color, active);
            // 信标光柱：换掉信标上方的染色玻璃，光柱颜色就跟着队伍走（原版机制）
            if (active) {
                updateBeaconBeam(level, point, point.owner());
            }
            if (active && drawParticles && hasPlayerNearby(level, point)) {
                drawRangeRings(level, point, color);
            }
        }

        // 玩家之间也要能互相看到（团队死斗尤其依赖这个）：收发范围默认都是 0，需要放开
        for (ServerPlayer player : server.getPlayerList().getPlayers()) {
            AttributeInstance transmit = player.getAttribute(Attributes.WAYPOINT_TRANSMIT_RANGE);
            if (transmit != null && transmit.getBaseValue() != WAYPOINT_RANGE) {
                transmit.setBaseValue(WAYPOINT_RANGE);
            }
            AttributeInstance receive = player.getAttribute(Attributes.WAYPOINT_RECEIVE_RANGE);
            if (receive != null && receive.getBaseValue() != WAYPOINT_RANGE) {
                receive.setBaseValue(WAYPOINT_RANGE);
            }
        }
    }

    /** 旧版本用过盔甲架和方块显示实体当标记，这里一次性清掉，避免玩家看到残留的方块。 */
    private static boolean legacyCleaned;

    private static void cleanLegacyMarkers(ServerLevel level) {
        int removed = 0;
        for (Entity entity : level.getEntities(EntityTypes.BLOCK_DISPLAY,
                candidate -> candidate.entityTags().stream()
                        .anyMatch(tag -> tag.startsWith("pvpshot.mark.")))) {
            entity.discard();
            removed++;
        }
        for (Entity entity : level.getEntities(EntityTypes.ARMOR_STAND,
                candidate -> candidate.entityTags().stream()
                        .anyMatch(tag -> tag.startsWith("pvpshot.mark.")))) {
            entity.discard();
            removed++;
        }
        if (removed > 0) {
            PvpShotMod.LOGGER.info("[pvpshot] 清理了 {} 个旧版点位标记实体", removed);
        }
    }

    /**
     * 保证点位有一个"航点载体"。
     *
     * <p>原版的 {@code WaypointTransmitter} 只由 {@code LivingEntity} 实现，
     * 所以可见的 {@code BlockDisplay} 上不了定位条。这里额外放一个**隐形史莱姆**专门当航点：
     * 位置与可见标记重合，不开 AI、无声、无敌、不受重力，只负责让点位出现在定位条上。
     * 归属颜色不用手动设 —— 原版会读取实体所在队伍的颜色（我们每个点位都有专属队伍）。
     */
    private static void ensureWaypoint(ServerLevel level, CapturePoint point, TeamColor color,
                                       boolean active) {
        String tag = BEACON_TAG_PREFIX + point.id();
        Slime beacon = BEACONS.get(point.id());
        if (beacon == null || beacon.isRemoved()) {
            // 先同步加载区块再扫描：getEntities 只返回已加载区块里的实体，
            // 不先加载的话会"找不到已有航点"→ 又建一个（这正是之前重复创建的原因）
            BlockPos anchor = BlockPos.containing(point.x(), point.y(), point.z());
            level.getChunk(anchor.getX() >> 4, anchor.getZ() >> 4);
            beacon = findExistingBeacon(level, tag);
            if (beacon == null) {
                beacon = createBeacon(level, point, tag);
                if (beacon == null) {
                    return;
                }
            }
            BEACONS.put(point.id(), beacon);
        }
        // 让航点所在区块常加载：否则区块一卸载，实体就被卸载，
        // 航点从定位条消失、下一 tick 还会重复创建一个新的（之前 589 个就是这么来的）
        keepChunkLoaded(level, beacon.blockPosition());
        // 发光轮廓：颜色由队伍决定，所以直接给实体打开发光即可（未启用则关掉）
        beacon.setGlowingTag(active);
        applyTeam(level, point, beacon, color, active);
        // 基岩外壳有可能被整场复原覆盖掉，这里按需补回来
        if (++shellClock % SHELL_CHECK_INTERVAL == 0) {
            sealWithBedrock(level, beacon);
        }
        // 关键：范围必须 > 0，否则实体根本不对外广播航点
        AttributeInstance transmit = beacon.getAttribute(Attributes.WAYPOINT_TRANSMIT_RANGE);
        double wanted = active ? WAYPOINT_RANGE : 0.0;
        if (transmit != null && transmit.getBaseValue() != wanted) {
            transmit.setBaseValue(wanted);
            // 已经建立的航点连接不会因为范围变化自动断开，需要显式通知管理器
            if (level.getWaypointManager() != null) {
                if (active) {
                    level.getWaypointManager().trackWaypoint(beacon);
                } else {
                    level.getWaypointManager().untrackWaypoint(beacon);
                }
            }
        }
        if (active) {
            applyWaypointStyle(level, tag, point);
        }
    }

    /** 已申请强制加载的区块，避免重复申请。 */
    private static final java.util.Set<Long> FORCED_CHUNKS = new java.util.HashSet<>();

    private static void keepChunkLoaded(ServerLevel level, BlockPos pos) {
        long key = ((long) pos.getX() >> 4) << 32 ^ ((pos.getZ() >> 4) & 0xFFFFFFFFL);
        if (FORCED_CHUNKS.add(key)) {
            level.setChunkForced(pos.getX() >> 4, pos.getZ() >> 4, true);
            PvpShotMod.LOGGER.info("[pvpshot] 已让航点所在区块常加载：{}, {}",
                    pos.getX() >> 4, pos.getZ() >> 4);
        }
    }

    /**
     * 只在缓存失效时（首次运行 / 重启后）扫一次世界，找回已存在的航点实体；
     * 如果因为历史 bug 留下了多个重复实体，只保留第一个，其余就地清理。
     */
    private static Slime findExistingBeacon(ServerLevel level, String tag) {
        Slime found = null;
        int duplicates = 0;
        for (Entity candidate : level.getEntities(EntityTypes.SLIME,
                entity -> entity.entityTags().contains(tag))) {
            if (candidate instanceof Slime slime) {
                if (found == null) {
                    found = slime;
                } else {
                    slime.discard();
                    duplicates++;
                }
            }
        }
        if (duplicates > 0) {
            PvpShotMod.LOGGER.info("[pvpshot] 清理了 {} 个重复的航点实体（标签 {}）", duplicates, tag);
        }
        return found;
    }

    private static Slime createBeacon(ServerLevel level, CapturePoint point, String tag) {
        Slime beacon = new Slime(EntityTypes.SLIME, level);
        // 埋在地面以下（作者方案）：完全看不见，只靠发光轮廓和定位条指示
        beacon.setPos(point.x(), point.y() - BEACON_DEPTH, point.z());
        beacon.setSize(1, false);
        beacon.setNoAi(true);
        beacon.setSilent(true);
        beacon.setInvulnerable(true);
        beacon.setNoGravity(true);
        beacon.setInvisible(true);
        beacon.setPersistenceRequired();
        beacon.addTag(tag);
        // 抗性提升 V（amplifier 4 = 等级 5），双保险防止任何伤害把它弄死
        beacon.addEffect(new MobEffectInstance(MobEffects.RESISTANCE, -1, 4, false, false, false));
        if (!level.addFreshEntity(beacon)) {
            return null;
        }
        sealWithBedrock(level, beacon);
        PvpShotMod.LOGGER.info("[pvpshot] 为点位 {} 创建了定位条航点（隐形史莱姆）", point.id());
        return beacon;
    }

    /** 用 3×3×3 基岩把航点实体包起来：玩家挖不动，也炸不坏。 */
    private static void sealWithBedrock(ServerLevel level, Slime beacon) {
        BlockPos center = beacon.blockPosition();
        for (BlockPos pos : BlockPos.betweenClosed(center.offset(-1, -1, -1),
                center.offset(1, 1, 1))) {
            if (!level.getBlockState(pos).is(Blocks.BEDROCK)) {
                level.setBlock(pos, Blocks.BEDROCK.defaultBlockState(), Block.UPDATE_CLIENTS);
            }
        }
    }

    /** 已经设置过样式的航点，避免每 tick 重复执行命令。 */
    private static final java.util.Set<String> STYLED = new java.util.HashSet<>();

    /**
     * 给航点指定样式（A/B/C/D/E 字母图标）。
     *
     * <p>样式对应的贴图来自资源包（{@code assets/pvpshot/waypoint_style/*.json}）。
     * 客户端没装资源包时会显示成缺失贴图，所以这一条只负责"声明用哪个样式"。
     */
    private static void applyWaypointStyle(ServerLevel level, String tag, CapturePoint point) {
        if (!STYLED.add(point.id())) {
            return;
        }
        String styleId = "pvpshot:" + point.id().toLowerCase(java.util.Locale.ROOT);
        String command = "waypoint modify @e[tag=" + tag + ",limit=1] style set " + styleId;
        try {
            var server = level.getServer();
            server.getCommands().performPrefixedCommand(
                    server.createCommandSourceStack().withSuppressedOutput(), command);
            PvpShotMod.LOGGER.info("[pvpshot] 点位 {} 的航点样式设为 {}", point.id(), styleId);
        } catch (Exception failure) {
            PvpShotMod.LOGGER.warn("[pvpshot] 设置点位 {} 航点样式失败：{}", point.id(), failure.toString());
        }
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

    /**
     * 让信标光柱显示队伍颜色。
     *
     * <p>原版信标的机制是：**光柱颜色 = 信标正上方那块染色玻璃的颜色**（玻璃不存在则用默认白色）。
     * 地图上每个据点本来就是"铁块 + 信标 + 白色玻璃"的结构，所以这里只要把玻璃换成队伍颜色即可，
     * 不需要任何自定义渲染 —— 信标方块每隔一段时间会自己重新计算光柱颜色。
     */
    private static void updateBeaconBeam(ServerLevel level, CapturePoint point, int owner) {
        BlockState wanted = switch (owner) {
            case 1 -> Blocks.STAINED_GLASS.pick(DyeColor.RED).defaultBlockState();
            case 2 -> Blocks.STAINED_GLASS.pick(DyeColor.BLUE).defaultBlockState();
            default -> Blocks.STAINED_GLASS.pick(DyeColor.WHITE).defaultBlockState();
        };
        // 点位中心下方 1~3 格里找信标（地图结构是铁块底座 + 信标 + 玻璃）
        BlockPos center = BlockPos.containing(point.x(), point.y(), point.z());
        for (int dy = 1; dy <= 3; dy++) {
            BlockPos beaconPos = center.below(dy);
            if (!level.getBlockState(beaconPos).is(Blocks.BEACON)) {
                continue;
            }
            BlockPos glassPos = beaconPos.above();
            if (level.getBlockState(glassPos) != wanted) {
                level.setBlock(glassPos, wanted, Block.UPDATE_CLIENTS);
            }
            return;
        }
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
        builder.append("；航点实体 ").append(BEACONS.size()).append(" 个。点位状态：");
        for (CapturePoint point : MatchEngine.points()) {
            builder.append(' ').append(point.id())
                    .append(point.activeIn(mode) ? "(启用," : "(未启用,")
                    .append(point.ownerLabel()).append(')');
        }
        return builder.toString();
    }
}
