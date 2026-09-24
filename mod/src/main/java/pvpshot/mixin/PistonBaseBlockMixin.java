package pvpshot.mixin;

import net.minecraft.core.BlockPos;
import net.minecraft.core.Direction;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.piston.PistonBaseBlock;
import net.minecraft.world.level.block.state.BlockState;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import pvpshot.protect.ProtectionRegions;

/**
 * 活塞推动：不许用活塞把保护区里的方块推走或把方块推进去。
 * 注意 isPushable 是静态方法，注入的处理函数也必须是 static。
 */
@Mixin(PistonBaseBlock.class)
public abstract class PistonBaseBlockMixin {

    @Inject(
            method = "isPushable(Lnet/minecraft/world/level/block/state/BlockState;Lnet/minecraft/world/level/Level;Lnet/minecraft/core/BlockPos;Lnet/minecraft/core/Direction;ZLnet/minecraft/core/Direction;)Z",
            at = @At("HEAD"),
            cancellable = true)
    private static void pvpshot$denyProtectedPiston(BlockState state, Level level, BlockPos pos, Direction direction,
                                                    boolean allowDestroy, Direction pistonDirection,
                                                    CallbackInfoReturnable<Boolean> cir) {
        if (ProtectionRegions.protectedAt(level, pos)) {
            cir.setReturnValue(false);
        }
    }
}
