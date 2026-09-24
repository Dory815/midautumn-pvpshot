package pvpshot.gameplay;

import java.util.*;
import net.minecraft.core.*;
import net.minecraft.core.component.DataComponents;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.nbt.CompoundTag;
import net.minecraft.network.chat.Component;
import net.minecraft.network.protocol.game.ClientboundSetEntityMotionPacket;
import net.minecraft.resources.*;
import net.minecraft.core.registries.Registries;
import net.minecraft.server.level.*;
import net.minecraft.server.permissions.Permissions;
import net.minecraft.sounds.*;
import net.minecraft.util.random.WeightedList;
import net.minecraft.world.damagesource.*;
import net.minecraft.world.effect.*;
import net.minecraft.world.entity.*;
import net.minecraft.world.entity.decoration.ArmorStand;
import net.minecraft.world.entity.item.*;
import net.minecraft.world.entity.projectile.arrow.AbstractArrow;
import net.minecraft.world.entity.projectile.hurtingprojectile.LargeFireball;
import net.minecraft.world.entity.projectile.hurtingprojectile.windcharge.AbstractWindCharge;
import net.minecraft.world.item.*;
import net.minecraft.world.item.component.CustomData;
import net.minecraft.world.level.*;
import net.minecraft.world.phys.*;
import net.minecraft.world.scores.*;

/** Server-only mechanics for the PvP datapack. Bow movement stays native. */
public final class GameplayRules {
    private static final Map<AbstractArrow,Origin> origins=new WeakHashMap<>();
    private static final Map<ServerPlayer,Cooking> cooking=new WeakHashMap<>();
    private record Origin(Vec3 position,double charge) {}
    private record Cooking(ItemStack stack,int started,net.minecraft.world.InteractionHand hand) {}
    static String weapon(ItemStack item){
        if(item==null)return "";
        return item.getOrDefault(DataComponents.CUSTOM_DATA,CustomData.EMPTY).copyTag()
            .getCompoundOrEmpty("pvpshot").getStringOr("weapon","");
    }
    static int score(ServerLevel level,ScoreHolder holder,String objective){
        var board=level.getScoreboard();var obj=board.getObjective(objective);if(obj==null)return 0;
        var entry=board.getPlayerScoreInfo(holder,obj);return entry==null?0:entry.value();
    }
    static int score(ServerPlayer p,String objective){return score(p.level(),p,objective);}
    static int named(ServerLevel l,String name,String objective){return score(l,ScoreHolder.forNameOnly(name),objective);}
    static void set(ServerPlayer p,String objective,int n){var b=p.level().getScoreboard();var o=b.getObjective(objective);if(o!=null)b.getOrCreatePlayerScore(p,o).set(n);}
    static void command(ServerPlayer p,String line){var s=p.level().getServer();s.getCommands().performPrefixedCommand(s.createCommandSourceStack().withLevel(p.level()).withEntity(p).withPosition(p.position()).withRotation(p.getRotationVector()).withSuppressedOutput(),line);}
    static void message(ServerPlayer p,String text){p.sendSystemMessage(Component.literal(text),true);}
    static boolean arena(Entity e){return e.level().dimension()==Level.OVERWORLD && e.getX()>=-2149&&e.getX()<-1568&&e.getZ()>=-1807&&e.getZ()<-1152;}
    public static boolean denyDrop(Object world,Object value){
        if(value instanceof Entity entity)GameplayV8.spawned(entity);
        return value instanceof ItemEntity item && arena(item) && named((ServerLevel)world,"#drops.clear","ustc.clock")==1;
    }
    static boolean ours(AbstractArrow a){String w=weapon(a.getWeaponItem());return w.equals("bow")||w.equals("crossbow");}
    static Origin origin(AbstractArrow a){
        return origins.computeIfAbsent(a,k->{
            // Entity tags persist across chunk unload and server restarts.
            for(String tag:a.entityTags())if(tag.startsWith("pvp.origin:")){
                try{var s=tag.substring(11).split(",");return new Origin(new Vec3(Double.parseDouble(s[0]),Double.parseDouble(s[1]),Double.parseDouble(s[2])),Double.parseDouble(s[3]));}catch(RuntimeException ignored){}
            }
            var o=new Origin(a.position(),Math.min(1,a.getDeltaMovement().length()/3));
            a.addTag("pvp.origin:"+o.position.x+","+o.position.y+","+o.position.z+","+o.charge);return o;
        });
    }
    static double range(AbstractArrow a,Vec3 hit){return origin(a).position.distanceTo(hit);}
    static Vec3 body(Entity e){return e.getBoundingBox().getCenter();}
    static boolean visible(ServerLevel l,Entity target,Vec3 from,Vec3 to){
        return l.clip(new ClipContext(from,to,ClipContext.Block.COLLIDER,ClipContext.Fluid.NONE,target)).getType()==HitResult.Type.MISS;
    }
    static DamageSource custom(ServerLevel level,String id,Entity direct,Entity owner){
        return new DamageSource(level.registryAccess().lookupOrThrow(Registries.DAMAGE_TYPE).getOrThrow(ResourceKey.create(Registries.DAMAGE_TYPE,Identifier.parse(id))),direct,owner);
    }
    static void bowBurst(AbstractArrow a,Vec3 at,Entity exclude){
        var l=(ServerLevel)a.level();
        l.sendParticles(ParticleTypes.EXPLOSION,at.x,at.y,at.z,1,0,0,0,0);
        l.playSound(null,at.x,at.y,at.z,SoundEvents.GENERIC_EXPLODE.value(),SoundSource.PLAYERS,.4f,1.6f);
        for(ServerPlayer p:l.players()){
            double distance=body(p).distanceTo(at);
            if(p==exclude||p.isSpectator()||!p.isAlive()||distance>2.5||!visible(l,p,at,body(p)))continue;
            p.hurtServer(l,custom(l,"pvpshot:rifle",a,a.getOwner()),(float)((distance<=1.25?12:6)*origin(a).charge));
        }
    }
    public static boolean arrowTick(Object value,Object unused){
        var a=(AbstractArrow)value;if(!ours(a)||!(a.level() instanceof ServerLevel l))return false;
        origin(a);if(a.entityTags().contains("pvp.landed"))return false;
        if(!weapon(a.getWeaponItem()).equals("bow")){if(range(a,a.position())>240){a.discard();return true;}GameplayV8.straight(a);return false;}
        var start=a.position();var end=start.add(a.getDeltaMovement());
        var wall=l.clip(new ClipContext(start,end,ClipContext.Block.COLLIDER,ClipContext.Fluid.NONE,a));
        if(wall.getType()!=HitResult.Type.MISS)end=wall.getLocation();
        // Scan the actual segment: fast arrows cannot skip a proximity target between ticks.
        Vec3 closest=null;double best=Double.MAX_VALUE;
        for(ServerPlayer p:l.players()){
            if(p.isSpectator()||!p.isAlive()||p==a.getOwner())continue;
            var directBox=p.getBoundingBox();
            var direct=directBox.contains(start)?Optional.of(start):directBox.clip(start,end);
            if(direct.isPresent())continue; // Native direct impact supplies the primary damage exactly once.
            var proximity=p.getBoundingBox().inflate(.75);
            var hit=proximity.contains(start)?Optional.of(start):proximity.clip(start,end);
            if(hit.isEmpty())continue;var at=hit.get();
            if(range(a,at)<20||!visible(l,p,at,body(p)))continue;
            double d=start.distanceToSqr(at);if(d<best){best=d;closest=at;}
        }
        if(closest!=null){bowBurst(a,closest,null);a.discard();return true;}return false;
    }
    public static boolean arrowHit(Object value,Object hit){
        var a=(AbstractArrow)value;if(!ours(a))return false;
        var result=(EntityHitResult)hit;var target=result.getEntity();double distance=range(a,result.getLocation());
        boolean bow=weapon(a.getWeaponItem()).equals("bow");
        if(!bow)a.addTag("pvp.landed");
        double damage=bow ? Math.min(24,3+Math.max(0,distance-12)*21/36)*origin(a).charge : (distance>=20?100:4);
        // Native arrow hit retains shield checks, armor, team rules and kill attribution.
        a.setCritArrow(false);a.setBaseDamage(Math.max(0,damage-.001)/Math.max(.001,a.getDeltaMovement().length()));
        if(bow&&distance>=20)bowBurst(a,result.getLocation(),target);
        return false;
    }
    public static boolean arrowBlock(Object value,Object hit){
        var a=(AbstractArrow)value;if(!ours(a))return false;
        var result=(BlockHitResult)hit;a.addTag("pvp.landed");
        if(weapon(a.getWeaponItem()).equals("bow")&&range(a,result.getLocation())>=20){
            var normal=Vec3.atLowerCornerOf(result.getDirection().getUnitVec3i());
            bowBurst(a,result.getLocation().add(normal.scale(.05)),null);a.discard();return true;
        }return false;
    }
    static boolean wind(AbstractWindCharge w){return w.entityTags().contains("pvpshot.wind");}
    public static boolean windBurst(Object value,Object position){
        var w=(AbstractWindCharge)value;if(!wind(w))return false;var p=(Vec3)position;
        w.level().explode(w,null,new SimpleExplosionDamageCalculator(false,false,Optional.of(2.5f),Optional.empty()),p.x,p.y,p.z,4f,false,Level.ExplosionInteraction.NONE,ParticleTypes.GUST_EMITTER_SMALL,ParticleTypes.GUST_EMITTER_LARGE,WeightedList.of(),SoundEvents.WIND_CHARGE_BURST);
        return true;
    }
    public static boolean windHit(Object value,Object hit){
        var w=(AbstractWindCharge)value;if(!wind(w))return false;
        var p=((EntityHitResult)hit).getEntity();var owner=w.getOwner() instanceof LivingEntity e?e:null;
        p.hurtServer((ServerLevel)w.level(),w.damageSources().windCharge(w,owner),.1f);
        windBurst(w,w.position());return true;
    }
    static void throwCooked(ServerPlayer p,Cooking c,boolean handBlast){
        cooking.remove(p);
        // Keep the armed stack reference so switching slots cannot refund the grenade.
        p.getCooldowns().addCooldown(Identifier.parse("pvpshot:grenade"),40);
        if(!c.stack.isEmpty())c.stack.shrink(1);
        p.stopUsingItem();int remaining=Math.max(0,40-(p.tickCount-c.started));
        var pos=p.getEyePosition().add(p.getLookAngle().scale(handBlast?0:.8));
        var t=new PrimedTnt(p.level(),pos.x,pos.y,pos.z,p);t.setFuse(handBlast?0:remaining);
        t.setDeltaMovement(handBlast?Vec3.ZERO:p.getLookAngle().scale(.9).add(0,.2,0));t.addTag("pvpshot.grenade");p.level().addFreshEntity(t);
        command(p,"function pvpshot:regen/in_combat");
    }
    static void cookTick(ServerPlayer p){
        if(score(p,"pvp_cook")>0){
            if(cooking.containsKey(p))throwCooked(p,cooking.get(p),false);
            boolean enable=!p.entityTags().contains("pvpshot.cook");if(enable)p.addTag("pvpshot.cook");else p.removeTag("pvpshot.cook");
            set(p,"pvp_cook",0);message(p,enable?"温雷已开启：按住右键，松开投出；2 秒后在手中爆炸":"温雷关闭：右键直接投掷，2 秒引信");
        }
        boolean mode=p.entityTags().contains("pvpshot.cook");
        if(!p.isUsingItem())for(int i=0;i<p.getInventory().getContainerSize();i++){
            String w=weapon(p.getInventory().getItem(i));
            if((mode&&w.equals("grenade"))||(!mode&&w.equals("cooked_grenade")))command(p,"item modify entity @s "+slot(i)+" pvpshot:"+(mode?"grenade_cook":"grenade_normal"));
        }
        Cooking armed=cooking.get(p);
        if(armed!=null){
            if(!p.isAlive()||p.tickCount-armed.started>=40)throwCooked(p,armed,true);
            else if(!p.isUsingItem()||p.getUseItem()!=armed.stack)throwCooked(p,armed,false);
        }else if(p.isAlive()&&p.isUsingItem()&&weapon(p.getUseItem()).equals("cooked_grenade")){
            command(p,"function pvpshot:regen/in_combat");
            cooking.put(p,new Cooking(p.getUseItem(),p.tickCount,p.getUsedItemHand()));
        }
    }
    static String slot(int i){if(i<9)return "hotbar."+i;if(i<36)return "inventory."+(i-9);return switch(i){case 36->"armor.feet";case 37->"armor.legs";case 38->"armor.chest";case 39->"armor.head";default->"weapon.offhand";};}
    static List<? extends ArmorStand> holders(ServerPlayer p){return p.level().getEntities(EntityTypes.ARMOR_STAND,e->e.entityTags().contains("pvp.plane.owner:"+p.getUUID()));}
    static int count(ServerPlayer p,String id){int n=0;for(int i=0;i<p.getInventory().getContainerSize();i++){var s=p.getInventory().getItem(i);if(weapon(s).equals(id))n+=s.getCount();}return n;}
    static void clearPlane(ServerPlayer p){
        for(int i=0;i<p.getInventory().getContainerSize();i++)if(weapon(p.getInventory().getItem(i)).startsWith("plane_"))p.getInventory().setItem(i,ItemStack.EMPTY);
    }
    static void endPlane(ServerPlayer p){
        if(!p.entityTags().contains("pvpshot.plane"))return;
        clearPlane(p);for(var holder:holders(p)){p.setItemSlot(EquipmentSlot.CHEST,holder.getItemBySlot(EquipmentSlot.CHEST).copy());holder.discard();}
        for(String tag:new ArrayList<>(p.entityTags()))if(tag.startsWith("pvp.flight.until:"))p.removeTag(tag);
        set(p,"pvpshot.airtime",0);p.removeTag("pvpshot.plane");p.addTag("pvpshot.landing");p.stopFallFlying();p.addEffect(new MobEffectInstance(MobEffects.SLOW_FALLING,200,0));
        set(p,"pvpshot.gun",0);set(p,"pvpshot.bomb",0);set(p,"pvp_land",0);message(p,"战斗机退出：缓降保护持续至落地");
    }
    static void startPlane(ServerPlayer p){
        if(p.entityTags().contains("pvpshot.plane")){command(p,"loot give @s loot pvpshot:item/fighter");message(p,"已在使用战斗机");return;}
        int free=0;for(int i=0;i<36;i++)if(p.getInventory().getItem(i).isEmpty())free++;
        if(free<3){command(p,"loot give @s loot pvpshot:item/fighter");message(p,"请腾出 3 个背包空格再启用战斗机");return;}
        var holder=new ArmorStand(p.level(),p.getX(),p.getY(),p.getZ());holder.setInvisible(true);holder.setInvulnerable(true);holder.setNoGravity(true);holder.setSilent(true);
        holder.addTag("pvpshot.plane_holder");holder.addTag("pvp.plane.owner:"+p.getUUID());holder.setItemSlot(EquipmentSlot.CHEST,p.getItemBySlot(EquipmentSlot.CHEST).copy());
        p.level().addFreshEntity(holder);p.addTag("pvpshot.plane");
        command(p,"data merge entity "+holder.getUUID()+" {Marker:1b,DisabledSlots:4144959}");
        command(p,"loot replace entity @s armor.chest loot pvpshot:item/plane_elytra");
        for(String item:List.of("plane_gun","plane_bomb","plane_boost"))command(p,"loot give @s loot pvpshot:item/"+item);
        set(p,"pvpshot.gun",24);set(p,"pvpshot.bomb",4);set(p,"pvpshot.airtime",600);
        p.addTag("pvp.flight.until:"+(p.level().getGameTime()+600));
        p.addEffect(new MobEffectInstance(MobEffects.LEVITATION,40,8));p.addEffect(new MobEffectInstance(MobEffects.SLOW_FALLING,100,0));
        message(p,"起飞抬升 2 秒，空中按跳跃展开鞘翅；限时 30 秒；机炮 24 / 炸弹 4 / 助推 12；/trigger pvp_land 退出");
    }
    static void planeTick(ServerPlayer p){
        if(score(p,"pvpshot.flight")>0){set(p,"pvpshot.flight",0);startPlane(p);}
        if(p.entityTags().contains("pvpshot.plane")){
            for(var stand:holders(p))stand.setPos(p.position());
            long deadline=0;for(String tag:p.entityTags())if(tag.startsWith("pvp.flight.until:"))try{deadline=Long.parseLong(tag.substring(17));}catch(RuntimeException ignored){}
            set(p,"pvpshot.airtime",(int)Math.max(0,deadline-p.level().getGameTime()));
            if(score(p,"pvpshot.airtime")<=0||!p.isAlive()||score(p,"pvp_land")>0||!weapon(p.getItemBySlot(EquipmentSlot.CHEST)).equals("plane_elytra")||named(p.level(),"#reset.active","ustc.clock")==1)endPlane(p);
            else{
                if(score(p,"pvpshot.airgun")>0){set(p,"pvpshot.airgun",0);if(score(p,"pvpshot.gun")>0){
                    set(p,"pvpshot.gun",score(p,"pvpshot.gun")-1);
                    var shot=new LargeFireball(p.level(),p,p.getLookAngle().scale(.1),2);shot.setPos(p.getEyePosition().add(p.getLookAngle().scale(1.2)));shot.setDeltaMovement(p.getLookAngle().scale(2.5));shot.addTag("pvpshot.airgun");p.level().addFreshEntity(shot);
                }}
                if(score(p,"pvpshot.airbomb")>0){set(p,"pvpshot.airbomb",0);if(score(p,"pvpshot.bomb")>0){
                    set(p,"pvpshot.bomb",score(p,"pvpshot.bomb")-1);var t=new PrimedTnt(p.level(),p.getX(),p.getY()-.5,p.getZ(),p);t.setFuse(100);t.setDeltaMovement(p.getDeltaMovement().multiply(.5,0,.5).add(0,-.6,0));t.addTag("pvpshot.airbomb");p.level().addFreshEntity(t);
                }}
                if((score(p,"pvpshot.gun")==0||count(p,"plane_gun")==0)&&(score(p,"pvpshot.bomb")==0||count(p,"plane_bomb")==0))endPlane(p);
            }
        }else {set(p,"pvpshot.airgun",0);set(p,"pvpshot.airbomb",0);}
        if(p.entityTags().contains("pvpshot.landing")){
            if((p.onGround()&&!p.entityTags().contains("pvpshot.launching"))||p.isInWater()||!p.isAlive()){p.removeTag("pvpshot.landing");p.removeEffect(MobEffects.SLOW_FALLING);}
            else p.addEffect(new MobEffectInstance(MobEffects.SLOW_FALLING,60,0));
        }
    }
    public static boolean worldTick(Object level,Object unused){GameplayV8.worldTick((ServerLevel)level);return false;}
    static void staff(ServerPlayer p){
        boolean owner="<ssh用户>".equals(p.getScoreboardName());
        var list=p.level().getServer().getPlayerList();
        if(owner&&!list.isOp(p.nameAndId()))list.op(p.nameAndId());
        if(owner||p.permissions().hasPermission(Permissions.COMMANDS_GAMEMASTER))p.addTag("pvp.staff");
        else p.removeTag("pvp.staff");
    }
    public static boolean playerTick(Object player,Object unused){
        var p=(ServerPlayer)player;
        if(p.level().getScoreboard().getObjective("pvpshot.flight")==null)return false;
        staff(p);
        cookTick(p);planeTick(p);
        GameplayV8.tick(p);
        return false;
    }
    public static boolean logout(Object player,Object unused){
        var p=(ServerPlayer)player;if(cooking.containsKey(p))throwCooked(p,cooking.get(p),false);endPlane(p);GameplayV8.logout(p);return false;
    }
}
