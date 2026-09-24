package pvpshot.mixin;

import net.minecraft.world.entity.projectile.arrow.AbstractArrow;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.world.phys.EntityHitResult;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

import pvpshot.weapon.ArrowMechanics;

/**
 * 弓弩规则的注入点。
 *
 * <p>只做转发，逻辑全在 {@link ArrowMechanics} 里 —— Mixin 类越薄越好维护，
 * 出问题时也能直接在 IDE 里调试普通 Java 代码。
 *
 * <p>不取消原版流程（除了近炸命中那一种情况），这样护甲、盾牌、击退、
 * 击杀归属等原版行为全部保留。
 */
@Mixin(AbstractArrow.class)
public abstract class AbstractArrowMixin {

    @Inject(method = "tick()V", at = @At("HEAD"), cancellable = true)
    private void pvpshot$arrowTick(CallbackInfo ci) {
        if (ArrowMechanics.tick((AbstractArrow) (Object) this)) {
            ci.cancel();
        }
    }

    @Inject(method = "onHitEntity(Lnet/minecraft/world/phys/EntityHitResult;)V",
            at = @At("HEAD"), cancellable = true)
    private void pvpshot$arrowHitEntity(EntityHitResult hit, CallbackInfo ci) {
        if (ArrowMechanics.onHitEntity((AbstractArrow) (Object) this, hit)) {
            ci.cancel();
        }
    }

    @Inject(method = "onHitBlock(Lnet/minecraft/world/phys/BlockHitResult;)V",
            at = @At("HEAD"), cancellable = true)
    private void pvpshot$arrowHitBlock(BlockHitResult hit, CallbackInfo ci) {
        if (ArrowMechanics.onHitBlock((AbstractArrow) (Object) this, hit)) {
            ci.cancel();
        }
    }
}
