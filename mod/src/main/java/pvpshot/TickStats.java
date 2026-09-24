package pvpshot;

/**
 * 极简 tick 采样器。
 *
 * 只用 System.nanoTime()，不触碰任何 Minecraft 类，因此与版本无关、不会成为
 * 升级时的负担。目的是给后续的性能对比提供一个基线：M1 记录现状，M2 之后
 * 用来证明"重构后每 tick 的开销"确实降下来了。
 */
public final class TickStats {
    private static final long REPORT_INTERVAL_TICKS = 100L; // 5 秒

    private static long tickStartNanos;
    private static long ticks;
    private static long worstNanos;
    private static long windowTicks;
    private static long windowTotalNanos;

    /** 逐 tick 记录模式：> 0 时每个 tick 都单独写一行日志，供事后画曲线用。 */
    private static int recordRemaining;
    private static int recordIndex;

    private TickStats() {
    }

    /**
     * 开始逐 tick 记录（压测用）。
     *
     * <p>每行日志形如 {@code [pvpshot][tickrec] 17 6.482}（序号 + 该 tick 的毫秒数），
     * 结束后再写一行 {@code done}，直接 grep 就能出数据。
     */
    public static void record(int ticks) {
        recordRemaining = Math.max(1, ticks);
        recordIndex = 0;
        PvpShotMod.LOGGER.info("[pvpshot] 开始逐 tick 采样：{} tick（日志前缀 [tickrec]）", recordRemaining);
    }

    public static void beginTick() {
        tickStartNanos = System.nanoTime();
    }

    public static void endTick() {
        if (tickStartNanos == 0L) {
            return;
        }
        long elapsed = System.nanoTime() - tickStartNanos;
        tickStartNanos = 0L;

        if (recordRemaining > 0) {
            recordIndex++;
            recordRemaining--;
            PvpShotMod.LOGGER.info(String.format("[pvpshot][tickrec] %d %.3f",
                    recordIndex, elapsed / 1_000_000.0));
            if (recordRemaining == 0) {
                PvpShotMod.LOGGER.info("[pvpshot][tickrec] done");
            }
        }

        ticks++;
        windowTicks++;
        windowTotalNanos += elapsed;
        if (elapsed > worstNanos) {
            worstNanos = elapsed;
        }

        if (windowTicks >= REPORT_INTERVAL_TICKS) {
            double avgMs = windowTotalNanos / 1_000_000.0 / windowTicks;
            double worstMs = worstNanos / 1_000_000.0;
            // 每 100 tick 的 MSPT 摘要属于高频播报，默认关闭（/pvpshot log on 可开）
            PvpShotMod.logVerbose(String.format(
                    "[pvpshot] tick 采样：最近 %d tick 平均 %.2f ms，最差 %.2f ms，累计 %d tick",
                    windowTicks, avgMs, worstMs, ticks));
            windowTicks = 0;
            windowTotalNanos = 0L;
            worstNanos = 0L;
        }
    }
}
