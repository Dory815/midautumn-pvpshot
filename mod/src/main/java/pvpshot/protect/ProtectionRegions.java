package pvpshot.protect;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import net.minecraft.core.BlockPos;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.scores.Objective;
import net.minecraft.world.scores.ReadOnlyScoreInfo;
import net.minecraft.world.scores.ScoreHolder;
import net.minecraft.world.scores.Scoreboard;

import pvpshot.PvpShotMod;

/**
 * 设施保护：把 181 个受保护区域（大厅、基地、据点核心/旗杆/地面标记、补给箱、
 * 楼顶设施）做成一张"按区块分桶"的表，供各类方块改动入口做 O(1) 判断。
 *
 * <p>数据来源：{@code resources/pvpshot/regions.tsv}，格式与旧插桩模块一致：
 * {@code x0 y0 z0 x1 y1 z1 label}（坐标为闭区间，按方块坐标）。
 *
 * <p>生效条件（与旧实现保持一致，便于与旧数据包共存过渡）：
 * 只在主世界、且记分板 {@code ustc.clock} 上
 * {@code #protection.active == 1} 且 {@code #protection.edit != 1}
 * 且 {@code #reset.active != 1} 时才保护。
 * 也就是"比赛进行中才保护，编辑与整场复原期间不保护"。
 */
public final class ProtectionRegions {

    /** 受保护区域（闭区间）。 */
    public record Region(int x0, int y0, int z0, int x1, int y1, int z1, String label) {
        public boolean contains(int x, int y, int z) {
            return x >= x0 && x <= x1 && y >= y0 && y <= y1 && z >= z0 && z <= z1;
        }
    }

    /** 区块坐标 -> 该区块可能命中的区域列表。 */
    private static final Map<Long, List<Region>> CHUNKS = new HashMap<>();
    private static int regionCount;

    /**
     * 保护是否处于生效状态。由 {@link #refreshActiveState} 每 tick 刷新一次，
     * 避免每个方块更新都去查记分板。
     */
    private static volatile boolean active;

    /** 复原等内部批处理期间的临时让路开关。 */
    private static volatile boolean bypass;

    private ProtectionRegions() {
    }

    private static long chunkKey(int blockX, int blockZ) {
        return ((long) (blockX >> 4) << 32) ^ ((blockZ >> 4) & 0xffffffffL);
    }

    /** 从资源文件中读取区域定义（模组初始化时调用一次）。 */
    public static void load(InputStream in) throws IOException {
        CHUNKS.clear();
        int count = 0;
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.isBlank() || line.startsWith("#")) {
                    continue;
                }
                String[] fields = line.trim().split("\\s+");
                if (fields.length < 6) {
                    throw new IOException("保护区域格式不正确: " + line);
                }
                int x0 = Integer.parseInt(fields[0]);
                int y0 = Integer.parseInt(fields[1]);
                int z0 = Integer.parseInt(fields[2]);
                int x1 = Integer.parseInt(fields[3]);
                int y1 = Integer.parseInt(fields[4]);
                int z1 = Integer.parseInt(fields[5]);
                String label = fields.length > 6 ? fields[6] : "";
                if (x0 > x1 || y0 > y1 || z0 > z1) {
                    throw new IOException("保护区域坐标颠倒: " + line);
                }
                Region region = new Region(x0, y0, z0, x1, y1, z1, label);
                // 按区块分桶：一个区域可能横跨多个区块，逐区块登记。
                for (int cx = x0 >> 4; cx <= x1 >> 4; cx++) {
                    for (int cz = z0 >> 4; cz <= z1 >> 4; cz++) {
                        CHUNKS.computeIfAbsent(chunkKey(cx << 4, cz << 4), k -> new ArrayList<>()).add(region);
                    }
                }
                count++;
            }
        }
        if (count == 0) {
            throw new IOException("保护区域文件为空");
        }
        regionCount = count;
        PvpShotMod.LOGGER.info("[pvpshot] 设施保护：已载入 {} 个区域，分布在 {} 个区块桶中",
                count, CHUNKS.size());
    }

    public static int regionCount() {
        return regionCount;
    }

    /**
     * 每 tick 刷新一次保护总开关。记分板是服务器级别的全局状态，
     * 所以只需要在主世界读一次。
     */
    public static void refreshActiveState(ServerLevel overworld) {
        active = computeActive(overworld);
    }

    private static boolean computeActive(ServerLevel level) {
        Scoreboard board = level.getScoreboard();
        Objective clock = board.getObjective("ustc.clock");
        if (clock == null) {
            return false;
        }
        return score(board, clock, "#protection.active") == 1
                && score(board, clock, "#protection.edit") != 1
                && score(board, clock, "#reset.active") != 1;
    }

    private static int score(Scoreboard board, Objective objective, String name) {
        ReadOnlyScoreInfo info = board.getPlayerScoreInfo(ScoreHolder.forNameOnly(name), objective);
        return info == null ? 0 : info.value();
    }

    /** 该坐标是否落在受保护区域内（且当前处于保护生效状态）。 */
    public static boolean protectedAt(Level level, BlockPos pos) {
        if (bypass || !active || !level.dimension().equals(Level.OVERWORLD)) {
            return false;
        }
        List<Region> nearby = CHUNKS.get(chunkKey(pos.getX(), pos.getZ()));
        if (nearby == null) {
            return false;
        }
        int x = pos.getX();
        int y = pos.getY();
        int z = pos.getZ();
        for (int i = 0; i < nearby.size(); i++) {
            if (nearby.get(i).contains(x, y, z)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 判断一次方块写入是否应当被拒绝。
     *
     * <p>关键细节（沿用旧实现）：<b>只有"换成另一种方块"时才拒绝</b>。
     * 按钮按下、箱子开盖、门开关、红石更新这类"同一个方块的状态变化"必须放行，
     * 否则设施会失去交互能力。
     */
    public static boolean denySet(Level level, BlockPos pos, BlockState replacement) {
        if (!protectedAt(level, pos)) {
            return false;
        }
        BlockState current = level.getBlockState(pos);
        return current.getBlock() != replacement.getBlock();
    }

    /**
     * 临时让保护失效。整场复原期间必须打开，否则模组自己写回去的方块
     * 会被自己的保护逻辑拦下来（复原是"规则内的整体替换"，不该受保护限制）。
     */
    public static void setBypass(boolean value) {
        bypass = value;
    }
}
