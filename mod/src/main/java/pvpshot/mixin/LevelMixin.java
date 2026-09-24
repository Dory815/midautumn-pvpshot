package pvpshot.mixin;

import net.minecraft.core.BlockPos;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.state.BlockState;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import pvpshot.protect.ProtectionRegions;

/**
 * 保护的两个总闸口：所有方块写入与方块破坏最终都会经过 Level 的这两个方法，
 * 在这里拦一次就能覆盖大多数来源（爆炸、活塞、命令、生物行为等）。
 */
@Mixin(Level.class)
public abstract class LevelMixin {

    @Inject(
            method = "setBlock(Lnet/minecraft/core/BlockPos;Lnet/minecraft/world/level/block/state/BlockState;II)Z",
            at = @At("HEAD"),
            cancellable = true)
    private void pvpshot$denyProtectedSet(BlockPos pos, BlockState state, int flags, int recursionLeft,
                                          CallbackInfoReturnable<Boolean> cir) {
        if (ProtectionRegions.denySet((Level) (Object) this, pos, state)) {
            cir.setReturnValue(false);
        }
    }

    @Inject(
            method = "destroyBlock(Lnet/minecraft/core/BlockPos;ZLnet/minecraft/world/entity/Entity;I)Z",
            at = @At("HEAD"),
            cancellable = true)
    private void pvpshot$denyProtectedDestroy(BlockPos pos, boolean drop, Entity entity, int recursionLeft,
                                              CallbackInfoReturnable<Boolean> cir) {
        if (ProtectionRegions.protectedAt((Level) (Object) this, pos)) {
            cir.setReturnValue(false);
        }
    }
}
