package pvpshot.mixin;

import net.minecraft.commands.arguments.blocks.BlockInput;
import net.minecraft.core.BlockPos;
import net.minecraft.server.level.ServerLevel;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import pvpshot.protect.ProtectionRegions;

/**
 * 命令放置方块（/setblock、/fill 等）。这些调用不经过玩家的方块交互路径，
 * 需要单独拦一次，否则管理员或命令方块能绕过保护。
 */
@Mixin(BlockInput.class)
public abstract class BlockInputMixin {

    @Inject(
            method = "place(Lnet/minecraft/server/level/ServerLevel;Lnet/minecraft/core/BlockPos;I)Z",
            at = @At("HEAD"),
            cancellable = true)
    private void pvpshot$denyProtectedCommand(ServerLevel level, BlockPos pos, int update,
                                              CallbackInfoReturnable<Boolean> cir) {
        if (ProtectionRegions.protectedAt(level, pos)) {
            cir.setReturnValue(false);
        }
    }
}
