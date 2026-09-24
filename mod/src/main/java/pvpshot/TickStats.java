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

    private TickStats() {
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

        ticks++;
        windowTicks++;
        windowTotalNanos += elapsed;
        if (elapsed > worstNanos) {
            worstNanos = elapsed;
        }

        if (windowTicks >= REPORT_INTERVAL_TICKS) {
            double avgMs = windowTotalNanos / 1_000_000.0 / windowTicks;
            double worstMs = worstNanos / 1_000_000.0;
            PvpShotMod.LOGGER.info(String.format(
                    "[pvpshot] tick 采样：最近 %d tick 平均 %.2f ms，最差 %.2f ms，累计 %d tick",
                    windowTicks, avgMs, worstMs, ticks));
            windowTicks = 0;
            windowTotalNanos = 0L;
            worstNanos = 0L;
        }
    }
}
