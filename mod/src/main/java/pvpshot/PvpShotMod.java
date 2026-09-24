package pvpshot;

import net.fabricmc.api.DedicatedServerModInitializer;
import net.fabricmc.fabric.api.event.lifecycle.v1.ServerLifecycleEvents;
import net.fabricmc.fabric.api.event.lifecycle.v1.ServerTickEvents;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * PVP Shot —— 枪战小游戏的服务端模组。
 *
 * M1 阶段目标：确认模组能在 Minecraft 26.2 的 Fabric 服务端上加载，
 * 事件系统（生命周期 + 每 tick）正常工作。玩法逻辑从 M2 开始逐块移植。
 */
public final class PvpShotMod implements DedicatedServerModInitializer {
    public static final String MOD_ID = "pvpshot";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitializeServer() {
        LOGGER.info("[pvpshot] 模组初始化：Minecraft 26.2 服务端专用（M1 骨架）");

        ServerLifecycleEvents.SERVER_STARTING.register(server ->
                LOGGER.info("[pvpshot] 服务端正在启动，模组已就绪"));

        ServerTickEvents.START_SERVER_TICK.register(server -> TickStats.beginTick());
        ServerTickEvents.END_SERVER_TICK.register(server -> TickStats.endTick());

        LOGGER.info("[pvpshot] 事件注册完成（生命周期 + tick 采样）");
    }
}
