package pvpshot;

import java.io.InputStream;

import net.fabricmc.api.DedicatedServerModInitializer;
import net.fabricmc.fabric.api.command.v2.CommandRegistrationCallback;
import net.fabricmc.fabric.api.event.lifecycle.v1.ServerLifecycleEvents;
import net.fabricmc.fabric.api.event.lifecycle.v1.ServerTickEvents;
import net.minecraft.commands.Commands;
import net.minecraft.network.chat.Component;
import net.minecraft.server.permissions.Permissions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import pvpshot.protect.ProtectionRegions;
import pvpshot.restore.ArenaRestore;

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

        loadProtectionRegions();

        ServerLifecycleEvents.SERVER_STARTING.register(server ->
                LOGGER.info("[pvpshot] 服务端正在启动，模组已就绪"));

        ServerTickEvents.START_SERVER_TICK.register(server -> {
            TickStats.beginTick();
            // 保护总开关每 tick 刷新一次：记分板是全局状态，读主世界即可。
            ProtectionRegions.refreshActiveState(server.overworld());
        });
        ServerTickEvents.END_SERVER_TICK.register(server -> {
            ArenaRestore.tick(server);
            TickStats.endTick();
        });

        registerCommands();
        LOGGER.info("[pvpshot] 事件注册完成（生命周期 + tick 采样 + 保护 + 复原 + 命令）");
    }

    private static void registerCommands() {
        CommandRegistrationCallback.EVENT.register((dispatcher, registryAccess, environment) ->
                dispatcher.register(Commands.literal("pvpshot")
                        .requires(source -> source.permissions()
                                .hasPermission(Permissions.COMMANDS_GAMEMASTER))
                        .then(Commands.literal("restore").executes(context -> {
                            String message = ArenaRestore.start(context.getSource().getServer());
                            context.getSource().sendSuccess(() -> Component.literal(message), true);
                            return 1;
                        }))
                        .then(Commands.literal("restorestatus").executes(context -> {
                            context.getSource().sendSuccess(
                                    () -> Component.literal(ArenaRestore.progressText()), false);
                            return 1;
                        }))
                        .then(Commands.literal("protect").executes(context -> {
                            context.getSource().sendSuccess(() -> Component.literal(
                                    "设施保护：已载入 " + ProtectionRegions.regionCount() + " 个区域"), false);
                            return 1;
                        }))));
    }

    /** 从模组内置资源读入 181 个保护区域。 */
    private static void loadProtectionRegions() {
        try (InputStream in = PvpShotMod.class.getResourceAsStream("/pvpshot/regions.tsv")) {
            if (in == null) {
                LOGGER.error("[pvpshot] 找不到内置的 regions.tsv，设施保护将不可用");
                return;
            }
            ProtectionRegions.load(in);
        } catch (Exception failure) {
            LOGGER.error("[pvpshot] 载入设施保护区域失败", failure);
        }
    }
}
