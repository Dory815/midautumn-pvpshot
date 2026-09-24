package pvpshot.mixin;

import net.minecraft.core.BlockPos;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayerGameMode;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import pvpshot.protect.ProtectionRegions;

/**
 * 玩家挖掘的入口。Level#destroyBlock 已经拦了一层，这里再拦一次是为了避免
 * 出现"方块没掉但工具耐久/统计/音效照样走一遍"的怪异表现。
 */
@Mixin(ServerPlayerGameMode.class)
public abstract class ServerPlayerGameModeMixin {

    @Shadow
    private ServerLevel level;

    @Inject(method = "destroyBlock(Lnet/minecraft/core/BlockPos;)Z", at = @At("HEAD"), cancellable = true)
    private void pvpshot$denyProtectedMine(BlockPos pos, CallbackInfoReturnable<Boolean> cir) {
        if (ProtectionRegions.protectedAt(this.level, pos)) {
            cir.setReturnValue(false);
        }
    }
}
