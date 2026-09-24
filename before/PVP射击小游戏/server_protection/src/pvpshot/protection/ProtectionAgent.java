package pvpshot.protection;

import java.lang.instrument.*;
import java.security.ProtectionDomain;
import java.nio.file.*;
import java.util.jar.JarFile;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.lang.classfile.*;
import java.lang.constant.*;

/** Java 25 / official Minecraft 26.2 only. No game classes are loaded by premain. */
public final class ProtectionAgent implements ClassFileTransformer {
    static final String GUARD = "pvpshot/protection/ProtectionRules";
    static final String POS = "Lnet/minecraft/core/BlockPos;";
    static final String STATE = "Lnet/minecraft/world/level/block/state/BlockState;";

    public static void premain(String arguments, Instrumentation instrumentation) throws Exception {
        Path ownJar=Path.of(ProtectionAgent.class.getProtectionDomain().getCodeSource().getLocation().toURI());
        System.setProperty("pvpshot.gameplay.jar",ownJar.toString());
        // The Mojang bundler's child loader has the platform loader as parent.
        // A tiny, game-independent bootstrap helper is visible from both loaders.
        instrumentation.appendToBootstrapClassLoaderSearch(new JarFile(ownJar.resolveSibling("pvpshot-protection-runtime-26.2.jar").toFile()));
        String server=System.getProperty("pvpshot.protection.server");
        if(server!=null){
            String hash=HexFormat.of().formatHex(MessageDigest.getInstance("SHA-1").digest(Files.readAllBytes(Path.of(server))));
            if(!hash.equals("823e2250d24b3ddac457a60c92a6a941943fcd6a"))throw new IllegalStateException("Protection requires the verified official Minecraft 26.2 server.jar");
        }
        ProtectionRules.load(Path.of(arguments));
        instrumentation.addTransformer(new ProtectionAgent());
        System.out.println("[PVP Protection] Server facility protection installed (Minecraft 26.2 / Java 25).");
    }

    @Override public byte[] transform(ClassLoader loader, String name, Class<?> type,
            ProtectionDomain domain, byte[] bytes) {
        int expected = switch (name) {
            case "net/minecraft/world/entity/projectile/arrow/AbstractArrow" -> 3;
            case "net/minecraft/server/level/ServerLevel" -> 2;
            case
                 "net/minecraft/server/level/ServerPlayer",
                 "net/minecraft/server/players/PlayerList",
                 "net/minecraft/world/entity/projectile/hurtingprojectile/windcharge/WindCharge",
                 "net/minecraft/world/entity/projectile/hurtingprojectile/windcharge/AbstractWindCharge" -> 1;
            case "net/minecraft/world/level/Level" -> 2;
            case "net/minecraft/world/level/block/state/BlockBehaviour$BlockStateBase",
                 "net/minecraft/server/level/ServerPlayerGameMode",
                 "net/minecraft/world/level/block/piston/PistonBaseBlock",
                 "net/minecraft/commands/arguments/blocks/BlockInput" -> 1;
            default -> 0;
        };
        if (expected == 0) return null;
        try {
            ClassFile cf=ClassFile.of(ClassFile.ClassHierarchyResolverOption.of(ClassHierarchyResolver.ofResourceParsing(loader)));
            int[] changed = {0};
            byte[] result=cf.transformClass(cf.parse(bytes),(builder,element)->{
                if(element instanceof MethodModel model){
                    String method=model.methodName().stringValue(),desc=model.methodType().stringValue();
                    String hook = null;
                    if(name.endsWith("/AbstractArrow")){
                        if(method.equals("tick")&&desc.equals("()V"))hook="game:arrowTick";
                        if(method.equals("onHitEntity")&&desc.equals("(Lnet/minecraft/world/phys/EntityHitResult;)V"))hook="game:arrowHit";
                        if(method.equals("onHitBlock")&&desc.equals("(Lnet/minecraft/world/phys/BlockHitResult;)V"))hook="game:arrowBlock";
                    }
                    if(name.endsWith("/ServerLevel")&&method.equals("addFreshEntity")&&desc.equals("(Lnet/minecraft/world/entity/Entity;)Z"))hook="game:denyDrop";
                    if(name.endsWith("/ServerLevel")&&method.equals("tick")&&desc.equals("(Ljava/util/function/BooleanSupplier;)V"))hook="game:worldTick";
                    if(name.endsWith("/ServerPlayer")&&method.equals("doTick")&&desc.equals("()V"))hook="game:playerTick";
                    if(name.endsWith("/PlayerList")&&method.equals("remove")&&desc.equals("(Lnet/minecraft/server/level/ServerPlayer;)V"))hook="game:logout";
                    if(name.endsWith("/WindCharge")&&method.equals("explode")&&desc.equals("(Lnet/minecraft/world/phys/Vec3;)V"))hook="game:windBurst";
                    if(name.endsWith("/AbstractWindCharge")&&method.equals("onHitEntity")&&desc.equals("(Lnet/minecraft/world/phys/EntityHitResult;)V"))hook="game:windHit";
                    if (name.equals("net/minecraft/world/level/Level")) {
                        if (method.equals("setBlock") && desc.equals("("+POS+STATE+"II)Z")) hook="set";
                        if (method.equals("destroyBlock") && desc.equals("("+POS+"ZLnet/minecraft/world/entity/Entity;I)Z")) hook="destroy";
                    } else if (name.endsWith("$BlockStateBase") && method.equals("onExplosionHit")
                            && desc.equals("(Lnet/minecraft/server/level/ServerLevel;"+POS+"Lnet/minecraft/world/level/Explosion;Ljava/util/function/BiConsumer;)V")) hook="explosion";
                    else if (name.endsWith("ServerPlayerGameMode") && method.equals("destroyBlock") && desc.equals("("+POS+")Z")) hook="mine";
                    else if (name.endsWith("PistonBaseBlock") && method.equals("isPushable") && desc.equals("("+STATE+"Lnet/minecraft/world/level/Level;"+POS+"Lnet/minecraft/core/Direction;ZLnet/minecraft/core/Direction;)Z")) hook="piston";
                    else if (name.endsWith("BlockInput") && method.equals("place") && desc.equals("(Lnet/minecraft/server/level/ServerLevel;"+POS+"I)Z")) hook="command";
                    if (hook == null) {builder.with(element);return;}
                    changed[0]++;
                    final String kind = hook;
                    builder.transformMethod(model,(mb,me)->{
                      if(me instanceof CodeModel code)mb.transformCode(code,new CodeTransform(){
                        @Override public void accept(CodeBuilder cb,CodeElement ce){cb.with(ce);}
                        @Override public void atStart(CodeBuilder cb) {
                            if(kind.startsWith("game:")){
                                String action=kind.substring(5);
                                cb.ldc(action);
                                cb.aload(action.equals("logout")?1:0);
                                if(action.equals("arrowTick")||action.equals("playerTick")||action.equals("worldTick")||action.equals("logout"))cb.aconst_null();else cb.aload(1);
                                cb.invokestatic(ClassDesc.of("pvpshot.protection.GameplayBridge"),"call",MethodTypeDesc.ofDescriptor("(Ljava/lang/String;Ljava/lang/Object;Ljava/lang/Object;)Z"));
                                if(action.equals("playerTick")||action.equals("worldTick")||action.equals("logout"))cb.pop();
                                else cb.ifThen(body->{if(action.equals("denyDrop"))body.iconst_0().ireturn();else body.return_();});
                                return;
                            }
                            if (kind.equals("mine")) {
                                cb.aload(0).getfield(ClassDesc.ofInternalName(name),"level",ClassDesc.of("net.minecraft.server.level.ServerLevel")).aload(1);
                            } else if (kind.equals("set") || kind.equals("destroy")) {
                                cb.aload(0).aload(1);
                            } else {
                                cb.aload(1).aload(2);
                            }
                            if (kind.equals("set")) cb.aload(2);
                            cb.invokestatic(ClassDesc.ofInternalName(GUARD),
                                kind.equals("set") ? "denySet" : "protectedAt",
                                MethodTypeDesc.ofDescriptor(kind.equals("set") ? "(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)Z" : "(Ljava/lang/Object;Ljava/lang/Object;)Z"));
                            cb.ifThen(body->{if(kind.equals("explosion"))body.return_();else body.iconst_0().ireturn();});
                        }
                      });else mb.with(me);
                    });
                }else builder.with(element);
            });
            if (changed[0] != expected) throw new IllegalStateException("Expected "+expected+" hooks, found "+changed[0]+" in "+name);
            System.out.println("[PVP Protection] Patched "+name+" ("+changed[0]+" hooks)");
            return result;
        } catch (Throwable failure) {
            // Never silently run with partial protection after a version mismatch.
            failure.printStackTrace();
            Runtime.getRuntime().halt(78);
            return null;
        }
    }
}
