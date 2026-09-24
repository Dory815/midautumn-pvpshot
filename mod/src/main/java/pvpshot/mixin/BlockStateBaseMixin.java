package pvpshot.mixin;

import java.util.function.BiConsumer;

import net.minecraft.core.BlockPos;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.Explosion;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

import pvpshot.protect.ProtectionRegions;

/**
 * 爆炸对方块的影响。TNT、火箭、炮击等最终都会逐个方块调用到这里，
 * 受保护设施直接跳过——但爆炸对玩家的原版伤害仍然保留（那走的是另一条路径）。
 */
@Mixin(targets = "net.minecraft.world.level.block.state.BlockBehaviour$BlockStateBase")
public abstract class BlockStateBaseMixin {

    @Inject(
            method = "onExplosionHit(Lnet/minecraft/server/level/ServerLevel;Lnet/minecraft/core/BlockPos;Lnet/minecraft/world/level/Explosion;Ljava/util/function/BiConsumer;)V",
            at = @At("HEAD"),
            cancellable = true)
    private void pvpshot$denyProtectedExplosion(ServerLevel level, BlockPos pos, Explosion explosion,
                                                BiConsumer<ItemStack, BlockPos> onHit, CallbackInfo ci) {
        if (ProtectionRegions.protectedAt(level, pos)) {
            ci.cancel();
        }
    }
}
