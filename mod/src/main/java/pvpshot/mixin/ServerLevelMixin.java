package pvpshot.mixin;

import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.entity.Entity;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import pvpshot.weapon.DropGuard;
import pvpshot.weapon.EquipmentSystems;

/**
 * 实体生成的总入口。
 *
 * <p>两件事：
 * <ul>
 *   <li>拦截战场内的掉落物（数据包把 {@code #drops.clear} 置 1 时）；</li>
 *   <li>通知装备系统"有人开火了"（投射物生成即脱战，与原实现一致）。</li>
 * </ul>
 */
@Mixin(ServerLevel.class)
public abstract class ServerLevelMixin {

    @Inject(method = "addFreshEntity(Lnet/minecraft/world/entity/Entity;)Z",
            at = @At("HEAD"), cancellable = true)
    private void pvpshot$onAddFreshEntity(Entity entity, CallbackInfoReturnable<Boolean> cir) {
        EquipmentSystems.onProjectileSpawned(entity);
        if (DropGuard.shouldDeny(entity)) {
            cir.setReturnValue(false);
        }
    }
}
