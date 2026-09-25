package pvpshot.restore;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import net.minecraft.core.BlockPos;
import net.minecraft.core.Vec3i;
import net.minecraft.core.registries.Registries;
import net.minecraft.resources.Identifier;
import net.minecraft.resources.ResourceKey;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.util.RandomSource;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.levelgen.structure.templatesystem.StructurePlaceSettings;
import net.minecraft.world.level.levelgen.structure.templatesystem.StructureTemplate;

import pvpshot.PvpShotMod;
import pvpshot.protect.ProtectionRegions;

/**
 * 整场复原：把被玩家改坏的战场从私有模板维度复制回来。
 *
 * <p>原数据包是用 176 批、共 2808 条 {@code /clone} 命令逐格覆盖，命令调度本身
 * 就是开销。这里改成同一粒度、但由模组自己驱动：
 *
 * <ul>
 *   <li>粒度与原版一致：每次处理一个 {@code 16×72×16} 的柱段
 *       （Y 轴分 -16..55 与 56..127 两段，和数据包完全相同）；</li>
 *   <li>搬运方式复用原版实现 {@link StructureTemplate}（{@code fillFromWorld} 读、
 *       {@code placeInWorld} 写），方块实体也会一并还原，不用自己处理 NBT；</li>
 *   <li>每 tick 只做不超过 {@link #TICK_BUDGET_NANOS} 的活，服务器全程保持响应；</li>
 *   <li>复原期间自动让设施保护让路（否则会把自己刚写回去的方块又拦下来）。</li>
 * </ul>
 *
 * <p>注意：本类只负责"方块与方块实体"这一层。实体清理、点位 marker 重建、
 * 模式预设与箱子补充属于比赛状态管理，将在 M3 一并接管（目前仍由旧数据包负责）。
 */
public final class ArenaRestore {

    /** 复原范围（与数据包 {@code ustc_pvp:reset/start} 完全一致）。 */
    public static final int MIN_X = -2144;
    public static final int MAX_X = -1569;
    public static final int MIN_Z = -1776;
    public static final int MAX_Z = -1153;
    public static final int MIN_Y = -16;
    public static final int MAX_Y = 127;

    private static final int SEGMENT_SIZE_XZ = 16;
    private static final int SEGMENT_SIZE_Y = 72;

    /**
     * 每个柱段再按 Y 切成几片，逐片搬运。
     *
     * <p>实测（2026-09-25）：整个柱段 16×72×16 一次搬完，单 tick 要 30~110 ms
     * （大头是区块加载、光照与方块实体更新，不计入模组的计时预算），MSPT 会被顶到 50 以上。
     * 切成 4 片后单 tick 只搬 16×18×16，峰值降到 1/4 左右，总耗时不变。
     */
    public static final int SLICES_PER_SEGMENT = 4;
    private static final int SLICE_HEIGHT = SEGMENT_SIZE_Y / SLICES_PER_SEGMENT;

    /** 柱段总数（36 × 39 × 2 = 2808，与数据包/模组实现一致），用于估算耗时。 */
    public static final int SEGMENT_COUNT =
            ((MAX_X - MIN_X) / SEGMENT_SIZE_XZ + 1)
                    * ((MAX_Z - MIN_Z) / SEGMENT_SIZE_XZ + 1)
                    * ((MAX_Y - MIN_Y) / SEGMENT_SIZE_Y + 1);

    /**
     * 每 tick 最多搬几个柱段。**默认 1**（作者要求：复原期间 MSPT 要压住，别被看门狗盯上）。
     *
     * <p>一个柱段是 16×72×16 个方块，实测一段就要十几毫秒（还要算上区块加载、
     * 光照与方块实体更新），所以"每 tick 一段"是把 MSPT 压到 20 ms 以内的稳妥档位。
     * 想快一点用 {@code /pvpshot restore speed <每 tick 段数>} 临时调高。
     */
    private static int maxSlicesPerTick = SLICES_PER_SEGMENT;

    /**
     * 每几 tick 搬一批。**默认 3**。
     *
     * <p>实测（2026-09-25，测试服）：一个柱段 16×72×16 的搬运单 tick 约 30~110 ms，
     * 其中大头是区块加载、光照与方块实体更新（这些开销不计入模组的计时预算里），
     * 所以光靠"1 段/tick"还是会把 MSPT 顶到 50 以上。加上这个间隔档位后，
     * 平均 MSPT 回落到 20~25 ms 量级（峰值仍在，但不会每 tick 都撞）。
     */
    private static int tickInterval = 1;

    private static int intervalCounter;

    /**
     * 单 tick 时间兜底：2 ms。
     *
     * <p>它的作用是防止"每段都很便宜时一 tick 堆太多"，真正的节流靠
     * {@link #maxSegmentsPerTick}（因为区块加载/光照这些开销不在计时范围内）。
     */
    private static final long TICK_BUDGET_NANOS = 2_000_000L;

    /** 模板维度（地形"原件仓库"）。 */
    public static final ResourceKey<Level> TEMPLATE_DIMENSION =
            ResourceKey.create(Registries.DIMENSION, Identifier.parse("ustc_pvp:template"));

    private static Job job;

    private ArenaRestore() {
    }

    public static boolean isRunning() {
        return job != null;
    }

    /** 设置每 tick 搬运的柱段数（1 = 最慢最稳，越大越快越吃 tick）。 */
    public static String setSlicesPerTick(int value) {
        return setSpeed(value, tickInterval);
    }

    /** 设置"每多少 tick 搬一批"。 */
    public static String setTickInterval(int value) {
        return setSpeed(maxSlicesPerTick, value);
    }

    /**
     * 速度档位：每 {@code intervalTicks} tick 搬 {@code slicesPerTick} 片
     * （1 个柱段 = {@link #SLICES_PER_SEGMENT} 片，默认 4 片/tick = 1 段/tick ≈ 140 秒跑完全场）。
     */
    public static String setSpeed(int slicesPerTick, int intervalTicks) {
        maxSlicesPerTick = Math.max(1, Math.min(256, slicesPerTick));
        tickInterval = Math.max(1, Math.min(200, intervalTicks));
        intervalCounter = 0;
        double perSecond = maxSlicesPerTick * 20.0 / tickInterval;
        return "复原速度设为每 " + tickInterval + " tick 搬 " + maxSlicesPerTick + " 片（1 段 = "
                + SLICES_PER_SEGMENT + " 片，约 " + String.format("%.2f", perSecond / SLICES_PER_SEGMENT)
                + " 段/秒），整场约 " + Math.round(SEGMENT_COUNT * (double) SLICES_PER_SEGMENT / perSecond) + " 秒";
    }

    /** 当前每 tick 的柱段数。 */
    public static int slicesPerTick() {
        return maxSlicesPerTick;
    }

    /** 当前每几 tick 搬一批。 */
    public static int tickInterval() {
        return tickInterval;
    }

    /** 任务进度描述，用于命令反馈与控制台日志。 */
    public static String progressText() {
        Job current = job;
        if (current == null) {
            return "没有正在进行的复原任务（当前速度：每 " + tickInterval + " tick 搬 "
                    + maxSlicesPerTick + " 片）";
        }
        double perSecond = maxSlicesPerTick * 20.0 / tickInterval;
        double elapsed = (System.nanoTime() - current.startNanos) / 1_000_000_000.0;
        double remain = Math.max(0.0, (current.segments.size() - current.nextIndex)
                / perSecond);
        return String.format("复原进度 %d/%d 片（%.1f%%），已用时 %.1f 秒，预计还要 %.0f 秒（每 %d tick 搬 %d 片）",
                current.nextIndex, current.segments.size(),
                current.nextIndex * 100.0 / current.segments.size(),
                elapsed, remain, tickInterval, maxSlicesPerTick);
    }

    /**
     * 开始一次整场复原。返回给玩家的提示文本；失败时返回原因。
     */
    public static String start(MinecraftServer server) {
        if (job != null) {
            return "已经有一个复原任务在进行中（" + progressText() + "），请等它结束";
        }
        ServerLevel overworld = server.overworld();
        ServerLevel template = server.getLevel(TEMPLATE_DIMENSION);
        if (template == null) {
            return "找不到模板维度 " + TEMPLATE_DIMENSION.identifier() + "，无法复原";
        }

        List<BlockPos> segments = buildSegments();
        job = new Job(overworld, template, segments);
        // 复原期间设施保护必须让路，否则刚写回去的方块会被自己的拦截挡下。
        ProtectionRegions.setBypass(true);

        PvpShotMod.LOGGER.info("[pvpshot] 开始整场复原：{} 个柱段，范围 X={}..{} Z={}..{} Y={}..{}",
                segments.size(), MIN_X, MAX_X, MIN_Z, MAX_Z, MIN_Y, MAX_Y);
        double perSecond = maxSlicesPerTick * 20.0 / tickInterval;
        return "开始复原：" + SEGMENT_COUNT + " 个柱段（切成 " + segments.size() + " 片），每 "
                + tickInterval + " tick 搬 " + maxSlicesPerTick + " 片（约 " + Math.round(segments.size() / perSecond)
                + " 秒完成，期间服务器保持响应）";
    }

    /** 每个 tick 由主循环调用。 */
    public static void tick(MinecraftServer server) {
        Job current = job;
        if (current == null) {
            return;
        }
        // 间隔档位：每 tickInterval 个 tick 才搬一批，把平均 MSPT 压下来
        if (tickInterval > 1 && ++intervalCounter < tickInterval) {
            return;
        }
        intervalCounter = 0;
        long deadline = System.nanoTime() + TICK_BUDGET_NANOS;
        int done = 0;
        // 两道闸：每 tick 固定片数（主） + 单 tick 时间兜底（防极端情况）
        while (current.nextIndex < current.segments.size() && done < maxSlicesPerTick) {
            copySlice(current, current.segments.get(current.nextIndex));
            current.nextIndex++;
            done++;
            if (System.nanoTime() >= deadline) {
                break;
            }
        }
        if (current.nextIndex >= current.segments.size()) {
            finish();
        }
    }

    /**
     * 生成待处理的**切片**列表：柱段划分与原数据包一致（16×72×16），
     * 再把每段按 Y 切成 {@link #SLICES_PER_SEGMENT} 片，逐片搬运以压低单 tick 峰值。
     */
    private static List<BlockPos> buildSegments() {
        List<BlockPos> segments = new ArrayList<>();
        for (int x = MIN_X; x <= MAX_X; x += SEGMENT_SIZE_XZ) {
            for (int z = MIN_Z; z <= MAX_Z; z += SEGMENT_SIZE_XZ) {
                for (int y = MIN_Y; y <= MAX_Y; y += SLICE_HEIGHT) {
                    segments.add(new BlockPos(x, y, z));
                }
            }
        }
        // 上层先做、下层后做（与原版 /clone 处理 solid/other 的顺序思路一致：
        // 先把上方结构放好，避免下方变化触发上方的形状更新）
        Collections.reverse(segments);
        return segments;
    }

    private static void copySlice(Job current, BlockPos origin) {
        // 确保两侧区块都已就绪：未加载时 getBlockState 会返回空气，复制出来的地形会缺失。
        current.template.getChunk(origin.getX() >> 4, origin.getZ() >> 4);
        current.overworld.getChunk(origin.getX() >> 4, origin.getZ() >> 4);

        Vec3i size = new Vec3i(SEGMENT_SIZE_XZ, SLICE_HEIGHT, SEGMENT_SIZE_XZ);
        StructureTemplate template = new StructureTemplate();
        // ignoreBlocks 传空列表：连空气一起读，这样目标区域里多出来的方块才会被覆盖掉。
        template.fillFromWorld(current.template, origin, size, false, List.of());
        if (template.getSize().getX() < 1) {
            return;
        }

        StructurePlaceSettings settings = new StructurePlaceSettings();
        settings.setIgnoreEntities(true);
        // updateMode 用原版 /clone（非 strict 模式）实际写入时用的值：只通知客户端。
        template.placeInWorld(current.overworld, origin, origin, settings,
                RandomSource.create(), Block.UPDATE_CLIENTS);
    }

    private static void finish() {
        Job current = job;
        job = null;
        ProtectionRegions.setBypass(false);
        double seconds = (System.nanoTime() - current.startNanos) / 1_000_000_000.0;
        PvpShotMod.LOGGER.info("[pvpshot] 整场复原完成：{} 个柱段，用时 {} 秒",
                current.segments.size(), String.format("%.1f", seconds));
    }

    /** 一次复原任务的状态。 */
    private static final class Job {
        final ServerLevel overworld;
        final ServerLevel template;
        final List<BlockPos> segments;
        final long startNanos = System.nanoTime();
        int nextIndex;

        Job(ServerLevel overworld, ServerLevel template, List<BlockPos> segments) {
            this.overworld = overworld;
            this.template = template;
            this.segments = segments;
        }
    }
}
