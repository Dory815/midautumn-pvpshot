package pvpshot.gameplay;

import static pvpshot.gameplay.GameplayRules.*;
import java.util.*;
import net.minecraft.core.*;
import net.minecraft.core.component.DataComponents;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.network.protocol.game.ClientboundSetEntityMotionPacket;
import net.minecraft.server.level.*;
import net.minecraft.sounds.*;
import net.minecraft.world.damagesource.*;
import net.minecraft.world.effect.*;
import net.minecraft.world.entity.*;
import net.minecraft.world.entity.item.PrimedTnt;
import net.minecraft.world.entity.projectile.Projectile;
import net.minecraft.world.entity.projectile.arrow.AbstractArrow;
import net.minecraft.world.item.*;
import net.minecraft.world.level.*;
import net.minecraft.world.phys.*;

/** Bounded, server-authoritative v8 weapons. Only owned game equipment is modified. */
final class GameplayV8 {
    private static final Map<ServerPlayer,Long> smgNext=new WeakHashMap<>();
    private static final Map<ServerPlayer,Long> launchNext=new WeakHashMap<>();
    private static final Map<ServerLevel,List<Strike>> strikes=new WeakHashMap<>();
    private static final Map<ServerLevel,Long> worldTime=new WeakHashMap<>();
    private static final Map<AbstractArrow,Vec3> bolts=new WeakHashMap<>();
    private static class Strike {
        final ServerPlayer owner; final ServerLevel level; final int epoch; final int kind; final long start; final Vec3 origin,direction;
        Vec3 position; int fired; double travel;
        Strike(ServerPlayer p,int k,Vec3 at,Vec3 dir){owner=p;level=p.level();epoch=named(level,"#ordnance.epoch","pvpshot.cal");kind=k;position=at;origin=at;direction=dir;start=p.level().getGameTime();}
    }
    static void clearBuffs(ServerPlayer p){
        for(var e:new ArrayList<>(p.getActiveEffects()))
            if(e.getEffect().value().getCategory()==MobEffectCategory.BENEFICIAL&&!e.getEffect().equals(MobEffects.SLOW_FALLING))p.removeEffect(e.getEffect());
    }
    static void spawned(Entity entity){
        if(entity instanceof Projectile shot&&shot.getOwner() instanceof ServerPlayer p&&p.level().getScoreboard().getObjective("pvpshot.flight")!=null){
            clearBuffs(p);command(p,"function pvpshot:regen/in_combat");
        }
    }
    static void straight(AbstractArrow a){
        a.setNoGravity(true);
        Vec3 motion=bolts.computeIfAbsent(a,k->{
            for(String tag:a.entityTags())if(tag.startsWith("pvp.straight:"))try{var s=tag.substring(13).split(",");return new Vec3(Double.parseDouble(s[0]),Double.parseDouble(s[1]),Double.parseDouble(s[2]));}catch(RuntimeException ignored){}
            var v=a.getDeltaMovement();a.addTag("pvp.straight:"+v.x+","+v.y+","+v.z);return v;
        });
        a.setDeltaMovement(motion);
    }
    static void limitCrossbows(ServerPlayer p){
        // Prefer the active hand, then the first inventory slot. Cursor counts too,
        // so a loaded spare cannot be swapped in through an open chest screen.
        ItemStack keep=p.getMainHandItem().is(Items.CROSSBOW)?p.getMainHandItem():p.getOffhandItem().is(Items.CROSSBOW)?p.getOffhandItem():null;
        int removed=0;
        for(int i=0;i<p.getInventory().getContainerSize();i++){
            var s=p.getInventory().getItem(i);
            // Migrate the unbreakable shields distributed by previous game releases.
            if(s.is(Items.SHIELD)&&s.has(DataComponents.UNBREAKABLE)){
                var old=s.get(DataComponents.BLOCKS_ATTACKS);
                s.set(DataComponents.BLOCKS_ATTACKS,new net.minecraft.world.item.component.BlocksAttacks(.35f,1.5f,List.of(new net.minecraft.world.item.component.BlocksAttacks.DamageReduction(90,Optional.empty(),0,.5f)),new net.minecraft.world.item.component.BlocksAttacks.ItemDamageFunction(0,1,1),old.bypassedBy(),old.blockSound(),old.disableSound()));
                s.remove(DataComponents.UNBREAKABLE);s.set(DataComponents.MAX_DAMAGE,96);s.set(DataComponents.DAMAGE,Math.min(95,s.getDamageValue()));
            }
            if(!s.is(Items.CROSSBOW))continue;
            if(keep==null)keep=s;
            if(s!=keep){removed+=s.getCount();p.getInventory().setItem(i,ItemStack.EMPTY);}
            else if(s.getCount()>1){removed+=s.getCount()-1;s.setCount(1);}
        }
        var cursor=p.containerMenu.getCarried();
        if(cursor.is(Items.CROSSBOW)){
            if(keep!=null&&keep!=cursor){removed+=cursor.getCount();p.containerMenu.setCarried(ItemStack.EMPTY);}
            else if(cursor.getCount()>1){removed+=cursor.getCount()-1;cursor.setCount(1);}
        }
        if(removed>0){p.containerMenu.broadcastChanges();message(p,"每人仅可携带 1 把弩，多余的弩已移除");}
    }
    static void smg(ServerPlayer p){
        if(!p.isAlive()||p.isSpectator()||!p.isUsingItem())return;
        var stack=p.getUseItem();if(!weapon(stack).equals("egg")||stack.isEmpty())return;
        long now=p.level().getGameTime();if(now<smgNext.getOrDefault(p,Long.MIN_VALUE))return;
        smgNext.put(p,now+3);
        // Hold the original stack throughout dispatch; callbacks may change selected items.
        command(p,"function pvpshot:smg/launch");stack.shrink(1);
        if(stack.isEmpty())p.stopUsingItem();
        p.getInventory().setChanged();
    }
    static void shotgun(ServerPlayer p){
        var l=p.level();var from=p.getEyePosition();var forward=p.getLookAngle().normalize();
        var right=forward.cross(new Vec3(0,1,0)).normalize();if(right.lengthSqr()<.01)right=new Vec3(1,0,0);
        var up=right.cross(forward).normalize();Map<LivingEntity,Float> damage=new HashMap<>();
        for(int i=0;i<10;i++){
            double radius=i==0?0:(i<=3?.025:.065),angle=i*2.399963229728653;
            var direction=forward.add(right.scale(Math.cos(angle)*radius)).add(up.scale(Math.sin(angle)*radius)).normalize();
            Vec3 end=from.add(direction.scale(24));var wall=l.clip(new ClipContext(from,end,ClipContext.Block.COLLIDER,ClipContext.Fluid.NONE,p));if(wall.getType()!=HitResult.Type.MISS)end=wall.getLocation();
            LivingEntity target=null;Vec3 hit=end;double nearest=from.distanceToSqr(end);
            for(var e:l.getEntitiesOfClass(LivingEntity.class,new AABB(from,end).inflate(.5),e->e!=p&&e.isAlive()&&!e.isSpectator())){
                var box=e.getBoundingBox().inflate(.1);var crossing=box.contains(from)?Optional.of(from):box.clip(from,end);
                if(crossing.isPresent()&&from.distanceToSqr(crossing.get())<nearest){target=e;hit=crossing.get();nearest=from.distanceToSqr(hit);}
            }
            if(target!=null){double range=Math.sqrt(nearest);damage.merge(target,range<=8?3f:range<=16?2f:1f,Float::sum);}
            for(double t=1;t<from.distanceTo(hit);t+=2){var at=from.add(direction.scale(t));l.sendParticles(ParticleTypes.CRIT,at.x,at.y,at.z,1,0,0,0,0);}
        }
        // Aggregate pellets into one hit so vanilla hurt cooldown cannot swallow pellets.
        for(var e:damage.entrySet())e.getKey().hurtServer(l,custom(l,"pvpshot:rifle",p,p),e.getValue());
        l.playSound(null,p.blockPosition(),SoundEvents.GENERIC_EXPLODE.value(),SoundSource.PLAYERS,.6f,1.6f);
        command(p,"function pvpshot:regen/in_combat");
    }
    static Vec3 aim(ServerPlayer p){
        var start=p.getEyePosition();var end=start.add(p.getLookAngle().scale(120));
        var hit=p.level().clip(new ClipContext(start,end,ClipContext.Block.COLLIDER,ClipContext.Fluid.NONE,p));
        if(hit.getType()!=HitResult.Type.MISS)return hit.getLocation().add(0,.2,0);
        // Misses mark ground below the maximum-range cursor; no tracking after designation.
        var down=p.level().clip(new ClipContext(end,end.add(0,-160,0),ClipContext.Block.COLLIDER,ClipContext.Fluid.NONE,p));
        return down.getType()==HitResult.Type.MISS?end:down.getLocation().add(0,.2,0);
    }
    static void heavy(ServerPlayer p,int kind){
        Vec3 at=kind==3?p.getEyePosition().add(p.getLookAngle().scale(1.2)):aim(p);
        strikes.computeIfAbsent(p.level(),k->new ArrayList<>()).add(new Strike(p,kind,at,p.getLookAngle().normalize()));
        if(kind!=3){int count=kind==2?200:60;double spread=kind==2?10:2;p.level().sendParticles(ParticleTypes.FLAME,at.x,at.y,at.z,count,spread,.6,spread,.02);message(p,(kind==1?"轨道 380：3 秒后炮击 ":"飞鹰 500：4 秒后轰炸 ")+Math.round(at.x)+" / "+Math.round(at.y)+" / "+Math.round(at.z));}
        command(p,"function pvpshot:regen/in_combat");
    }
    static Vec3 openAir(ServerLevel l,Vec3 at){
        BlockPos pos=BlockPos.containing(at);
        if(!l.getBlockState(pos).isAir()){
            for(int dy=1;dy<=8;dy++){
                BlockPos up=pos.above(dy);
                if(l.getBlockState(up).isAir())return Vec3.atCenterOf(up);
            }
            return at.add(0,1.5,0);
        }
        return at.add(0,.8,0);
    }
    static void hurtBlast(Strike s,Vec3 at,double radius,float maxDmg){
        var l=s.owner.level();
        for(var e:l.getEntitiesOfClass(LivingEntity.class,new AABB(at,at).inflate(radius),ent->ent.isAlive()&&!ent.isSpectator())){
            double dist=Math.sqrt(e.distanceToSqr(at));
            if(dist>radius)continue;
            float dmg=Math.max(6f,maxDmg*(float)(1-dist/radius));
            e.hurtServer(l,l.damageSources().explosion(s.owner,s.owner),dmg);
        }
    }
    static void explosion(Strike s,Vec3 at,float power){
        var l=s.owner.level();Vec3 p=openAir(l,at);
        l.explode(s.owner,l.damageSources().explosion(s.owner,s.owner),null,p.x,p.y,p.z,power,false,Level.ExplosionInteraction.TNT);
    }
    static void scatterTnt(Strike s,Vec3 at){
        var l=s.owner.level();var rng=s.owner.getRandom();
        int n=6+rng.nextInt(3);Vec3 p=openAir(l,at);
        for(int i=0;i<n;i++){
            double angle=i*Math.PI*2/n+rng.nextDouble()*.6;
            var t=new PrimedTnt(l,p.x,p.y+.5,p.z,s.owner);
            t.setFuse(28+rng.nextInt(24));
            double speed=.7+rng.nextDouble()*.5;
            t.setDeltaMovement(Math.cos(angle)*speed,.45+rng.nextDouble()*.45,Math.sin(angle)*speed);
            t.addTag("pvpshot.airburst_frag");
            l.addFreshEntity(t);
        }
    }
    static void heavyBlast(Strike s,Vec3 at,float power,double radius,float maxDmg){
        Vec3 p=openAir(s.owner.level(),at);
        hurtBlast(s,p,radius,maxDmg);
        explosion(s,p,power);
    }
    static boolean update(Strike s,long now){
        var l=s.owner.level();long age=now-s.start;
        if(s.owner.hasDisconnected()||s.owner.level()!=s.level||s.epoch!=named(l,"#ordnance.epoch","pvpshot.cal")||named(l,"#reset.active","ustc.clock")==1)return true;
        if(s.kind==3){
            var start=s.position;var end=start.add(s.direction.scale(3));var wall=l.clip(new ClipContext(start,end,ClipContext.Block.COLLIDER,ClipContext.Fluid.NONE,s.owner));
            boolean hit=wall.getType()!=HitResult.Type.MISS;if(hit)end=wall.getLocation();
            if(s.travel>=12)for(ServerPlayer p:l.players()){
                if(p==s.owner||!p.isAlive()||p.isSpectator()||p.getTeam()!=null&&p.getTeam()==s.owner.getTeam())continue;
                var box=p.getBoundingBox().inflate(2.5);var crossing=box.contains(start)?Optional.of(start):box.clip(start,end);
                if(crossing.isPresent()&&visible(l,p,crossing.get(),body(p))){end=crossing.get();hit=true;break;}
            }
            s.travel+=start.distanceTo(end);s.position=end;
            l.sendParticles(ParticleTypes.FLAME,end.x,end.y,end.z,4,.08,.08,.08,0);
            l.sendParticles(ParticleTypes.SMOKE,end.x,end.y,end.z,4,.12,.12,.12,0);
            if(Boolean.getBoolean("pvpshot.audit")&&(age<=1||hit||s.travel>=90))System.out.println("[PVP trajectory] age="+age+" range="+s.travel+" end="+end+" wall="+hit);
            if(hit||s.travel>=90){explosion(s,end,5);scatterTnt(s,end);return true;}return age>80;
        }
        if(age%10==0){int n=s.kind==1?24:48;double ring=s.kind==1?32:42;for(int i=0;i<n;i++){double a=i*Math.PI*2/n;l.sendParticles(ParticleTypes.FLAME,s.origin.x+Math.cos(a)*ring,s.origin.y+.2,s.origin.z+Math.sin(a)*ring,1,0,0,0,0);if(s.kind==2)l.sendParticles(ParticleTypes.LARGE_SMOKE,s.origin.x+Math.cos(a)*ring,s.origin.y+1,s.origin.z+Math.sin(a)*ring,1,.2,.4,.2,0);}l.playSound(null,BlockPos.containing(s.origin),SoundEvents.NOTE_BLOCK_BELL.value(),SoundSource.PLAYERS,1f,s.kind==1?.7f:1.2f);}
        if(s.kind==2){
            if(age>=60&&age<80){double height=(80-age)*2.4;l.sendParticles(ParticleTypes.CAMPFIRE_COSY_SMOKE,s.origin.x,s.origin.y+height,s.origin.z,48,8,2,8,0);l.sendParticles(ParticleTypes.FLAME,s.origin.x,s.origin.y+height,s.origin.z,32,6,1.2,6,.02);}
            if(age>=80){l.sendParticles(ParticleTypes.EXPLOSION_EMITTER,s.origin.x,s.origin.y+1,s.origin.z,8,6,1,6,0);heavyBlast(s,s.origin,22,42,48);return true;}
        }else if(age>=60+s.fired*10){
            double angle=s.fired*2.399963229728653,r=s.fired%4==0?0:10+(s.fired%3)*11;
            Vec3 top=s.origin.add(Math.cos(angle)*r,48,Math.sin(angle)*r);
            var ground=l.clip(new ClipContext(top,top.add(0,-96,0),ClipContext.Block.COLLIDER,ClipContext.Fluid.NONE,s.owner));
            var impact=ground.getType()==HitResult.Type.MISS?s.origin.add(Math.cos(angle)*r,1,Math.sin(angle)*r):ground.getLocation();
            l.sendParticles(ParticleTypes.FLAME,impact.x,impact.y+10,impact.z,25,.1,6,.1,0);heavyBlast(s,impact,10,16,28);return ++s.fired>=24;
        }
        return age>360;
    }
    static void worldTick(ServerLevel l){
        long now=l.getGameTime();if(Objects.equals(worldTime.put(l,now),now))return;
        var list=strikes.get(l);if(list!=null)list.removeIf(s->update(s,now));
        launchPads(l);
    }
    private static final List<Entity> pads=new ArrayList<>();
    static void launchPads(ServerLevel l){
        if((l.getGameTime()&31)==0){
            pads.clear();
            for(var marker:l.getEntities(EntityTypes.MARKER,e->e.entityTags().contains("ustc.launch")))pads.add(marker);
        }
        if(pads.isEmpty())return;
        for(Entity marker:pads){
            if(!marker.isAlive())continue;
            ServerPlayer near=null;
            for(ServerPlayer p:l.players()){
                if(!p.isAlive()||p.isSpectator()||!p.onGround()||l.getGameTime()<launchNext.getOrDefault(p,0L))continue;
                if(marker.distanceToSqr(p)<4){near=p;break;}
            }
            if(near==null)continue;
            Vec3 target=null;
            for(String tag:marker.entityTags())if(tag.startsWith("pvp.launch:"))try{var v=tag.substring(11).split(",");target=new Vec3(Double.parseDouble(v[0]),Double.parseDouble(v[1]),Double.parseDouble(v[2]));}catch(RuntimeException ignored){}
            if(target==null)continue;
            near.addTag("pvpshot.launching");near.addTag("pvp.roof:"+target.x+","+target.y+","+target.z);
            near.addTag("pvpshot.landing");near.addEffect(new MobEffectInstance(MobEffects.SLOW_FALLING,200,0));
            near.setDeltaMovement(0,3.2,0);near.connection.send(new ClientboundSetEntityMotionPacket(near));
            launchNext.put(near,l.getGameTime()+140);message(near,"楼顶弹射器：自动抬升，落地前保留缓降");
        }
    }
    static void launchMotion(ServerPlayer p){
        if(!p.entityTags().contains("pvpshot.launching"))return;
        for(String tag:new ArrayList<>(p.entityTags()))if(tag.startsWith("pvp.roof:")){
            var v=tag.substring(9).split(",");var target=new Vec3(Double.parseDouble(v[0]),Double.parseDouble(v[1]),Double.parseDouble(v[2]));
            if(!p.isAlive()||p.level().getGameTime()>=launchNext.getOrDefault(p,0L)){p.removeTag(tag);p.removeTag("pvpshot.launching");continue;}
            if(p.getY()>=target.y+2){var delta=target.subtract(p.position());p.setDeltaMovement(new Vec3(delta.x,0,delta.z).normalize().scale(2.2).add(0,.3,0));p.connection.send(new ClientboundSetEntityMotionPacket(p));p.removeTag(tag);p.removeTag("pvpshot.launching");}
        }
    }
    static void tick(ServerPlayer p){
        if(((p.tickCount+p.getId())&15)==0)limitCrossbows(p);
        smg(p);launchMotion(p);
        int shotgun=score(p,"pvpshot.shotgun");if(shotgun>0){set(p,"pvpshot.shotgun",0);if(p.isAlive())shotgun(p);}
        int heavy=score(p,"pvpshot.heavy");if(heavy>0){set(p,"pvpshot.heavy",0);if(p.isAlive())heavy(p,heavy);}
    }
    static void logout(ServerPlayer p){var list=strikes.get(p.level());if(list!=null)list.removeIf(s->s.owner==p);smgNext.remove(p);launchNext.remove(p);}
}
