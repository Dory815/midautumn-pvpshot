import java.util.*;
import net.minecraft.SharedConstants;
import net.minecraft.core.*;
import net.minecraft.core.component.DataComponents;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.gametest.framework.GameTestHelper;
import net.minecraft.resources.Identifier;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.entity.*;
import net.minecraft.world.entity.projectile.arrow.*;
import net.minecraft.world.item.*;
import net.minecraft.world.item.component.ChargedProjectiles;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.effect.*;
import net.minecraft.world.phys.*;

/** Real-tick tests: cooldowns and timed ordnance must not be simulated at frozen gameTime. */
public class Revision8Audit extends TestMain {
 static int passes;static boolean ticking,tapping;static int eggsBefore;static long flightStart;
 static void ok(boolean b,String t){h.assertTrue(b,t);System.out.println("PASS "+(++passes)+" "+t);}
 static void fresh(){reset();red.stopUsingItem();as(red,"clear @s");as(red,"effect clear @s");red.setHealth(20);red.invulnerableTime=0;red.setPos(h.absoluteVec(new Vec3(5.5,1,5.5)));red.setYRot(0);red.setXRot(0);command("kill @e[type=arrow]");command("kill @e[tag=pvpshot.shot]");}
 static void equip(String id){as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/"+id);}
 static void use(String id){equip(id);red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);for(int i=0;i<4;i++)red.doTick();}
 static void healthBlue(float max){as(blue,"attribute @s minecraft:max_health base set "+max);blue.setHealth(max);blue.invulnerableTime=0;}
 static Arrow arrow(String id){equip(id);as(red,"give @s arrow 1");var stack=red.getMainHandItem();if(id.equals("bow"))((BowItem)stack.getItem()).releaseUsing(stack,h.getLevel(),red,71980);else{stack.set(DataComponents.CHARGED_PROJECTILES,ChargedProjectiles.of(new ItemStackTemplate(Items.ARROW)));((CrossbowItem)stack.getItem()).performShooting(h.getLevel(),red,InteractionHand.MAIN_HAND,stack,3.15f,0f,null);}var a=h.getLevel().getEntities(EntityTypes.ARROW,e->e.getOwner()==red).getLast();a.tick();return a;}
 static void buffs(){as(red,"effect give @s speed 45 4 true");as(red,"effect give @s jump_boost 45 4 true");as(red,"effect give @s slow_falling 45 0 true");as(red,"effect give @s slowness 45 3 true");}
 static void bombSite(String id){fresh();red.setPos(h.absoluteVec(new Vec3(30.5,8,30.5)));red.setXRot(90);for(int x=28;x<=32;x++)for(int z=28;z<=32;z++)h.setBlock(x,1,z,Blocks.GLASS);use(id);red.setPos(h.absoluteVec(new Vec3(2,8,2)));blue.setPos(h.absoluteVec(new Vec3(2,8,45)));}
 static void suite(GameTestHelper helper){
  h=helper;command("function pvpshot:load");command("scoreboard players set #ammo.enabled pvpshot.cfg 0");command("scoreboard players set #regen.enabled pvpshot.cfg 0");command("scoreboard objectives add ustc.clock dummy");
  red=player("V8Red",5,5);blue=player("V8Blue",5,9);as(red,"team join pvpshot.red @s");as(blue,"team join pvpshot.blue @s");
  h.runAtTickTime(70,()->{
   fresh();as(red,"item replace entity @s weapon.offhand with shield[unbreakable={}]");red.doTick();ok(!red.getOffhandItem().has(DataComponents.UNBREAKABLE)&&red.getOffhandItem().getMaxDamage()==96,"previous-release unbreakable shield migrates on player tick");as(red,"clear @s");healthBlue(100);blue.setPos(h.absoluteVec(new Vec3(5.5,1,8.5)));use("shotgun");ok(blue.getHealth()==70,"shotgun aggregates ten close pellets into exactly 30 HP");ok(count(red,"nether_brick")==11,"shotgun consumes exactly one shell");
   fresh();healthBlue(100);blue.setPos(h.absoluteVec(new Vec3(5.5,1,25.5)));use("shotgun");ok(blue.getHealth()>=94&&blue.getHealth()<100,"shotgun spread and distance falloff sharply reduce long-range damage");
   fresh();healthBlue(100);blue.setPos(h.absoluteVec(new Vec3(5.5,1,35.5)));use("shotgun");ok(blue.getHealth()==100,"shotgun cannot hit beyond 24 blocks");
   fresh();healthBlue(100);for(int x=4;x<=6;x++)for(int y=1;y<=3;y++)h.setBlock(x,y,8,Blocks.STONE);use("shotgun");ok(blue.getHealth()==100,"solid wall stops every shotgun pellet");h.assertBlockPresent(Blocks.STONE,5,2,8);for(int x=4;x<=6;x++)for(int y=1;y<=3;y++)h.setBlock(x,y,8,Blocks.AIR);
   fresh();healthBlue(100);as(blue,"loot replace entity @s weapon.mainhand loot pvpshot:item/shield");blue.setYRot(180);blue.startUsingItem(InteractionHand.MAIN_HAND);for(int i=0;i<10;i++)blue.doTick();blue.setPos(h.absoluteVec(new Vec3(5.5,1,8.5)));use("shotgun");ok(blue.getHealth()==85,"new shield absorbs half of a 30 HP frontal shot");ok(blue.getMainHandItem().getMaxDamage()==96&&blue.getMainHandItem().getDamageValue()>0,"shield has finite 96 durability and wears when blocking");
   fresh();healthBlue(100);blue.setPos(h.absoluteVec(new Vec3(40,1,40)));var a=arrow("crossbow");var pos=a.position();var dir=a.getDeltaMovement().normalize();for(int i=0;i<6;i++)a.tick();var travel=a.position().subtract(pos);ok(travel.normalize().distanceTo(dir)<1e-6&&Math.abs(travel.y)<.001,"crossbow flies straight without gravity or curved drag");a.discard();
   as(red,"loot give @s loot pvpshot:item/crossbow");as(red,"loot replace entity @s weapon.offhand loot pvpshot:item/crossbow");red.containerMenu.setCarried(red.getMainHandItem().copy());red.doTick();ok(count(red,"crossbow")==1&&red.containerMenu.getCarried().isEmpty(),"one crossbow across inventory, offhand and menu cursor");
   fresh();healthBlue(100);a=arrow("bow");blue.setPos(h.absoluteVec(new Vec3(5.95,1,32.5)));a.setPos(h.absoluteVec(new Vec3(5.5,2,31.5)));a.setDeltaMovement(0,0,3);a.tick();ok(a.isRemoved()&&blue.getHealth()<=94&&blue.getHealth()>=88,"bow graze cannot fall between direct and proximity collision checks");
   fresh();healthBlue(100);a=arrow("bow");blue.setPos(h.absoluteVec(new Vec3(5.5,1,40.5)));a.setPos(h.absoluteVec(new Vec3(5.5,2,39.5)));a.setDeltaMovement(0,0,3);a.tick();ok(blue.getHealth()<=83&&blue.getHealth()>=80,"distant direct bow damage strengthened without double splash");a.discard();
   fresh();buffs();use("fire_charge");ok(!red.hasEffect(MobEffects.SPEED)&&!red.hasEffect(MobEffects.JUMP_BOOST),"opening fire removes movement buffs immediately");ok(red.hasEffect(MobEffects.SLOW_FALLING)&&red.hasEffect(MobEffects.SLOWNESS),"combat keeps safety slow falling and negative effects");
   fresh();buffs();equip("snowball");red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);ok(!red.hasEffect(MobEffects.SPEED),"native snowball throwing also removes buffs");
   fresh();buffs();red.hurtServer(h.getLevel(),h.getLevel().damageSources().playerAttack(blue),1);ok(!red.hasEffect(MobEffects.SPEED)&&red.hasEffect(MobEffects.SLOW_FALLING),"taking player damage clears buffs but keeps safe landing");
   fresh();equip("speed");red.getMainHandItem().finishUsingItem(h.getLevel(),red);ok(red.hasEffect(MobEffects.SPEED)&&red.getEffect(MobEffects.SPEED).getAmplifier()==4,"drinking a beneficial potion does not cancel itself");
   for(String id:List.of("harming","slow","blind","linger")){equip(id);var contents=red.getMainHandItem().get(DataComponents.POTION_CONTENTS);ok(contents!=null&&contents.getAllEffects().iterator().hasNext(),"stronger negative potion parses and supplies effects: "+id);}
   fresh();red.setPos(h.absoluteVec(new Vec3(15.5,1,15.5)));red.setYRot(0);as(red,"function pvpshot:deploy/bunker");h.assertBlockPresent(Blocks.DEEPSLATE_BRICKS,14,1,18);h.assertBlockPresent(Blocks.AIR,14,2,22);h.assertBlockPresent(Blocks.DEEPSLATE_BRICKS,24,5,26);ok(true,"large bunker template has 11x5x9 body and walkable side doorway");
   command("kill @e[tag=pvpshot.shot]");
  });
  h.runAtTickTime(100,()->{fresh();healthBlue(100);blue.setPos(h.absoluteVec(new Vec3(40,1,40)));equip("egg");ok(red.getMainHandItem().is(Items.BRICK),"SMG carrier has no seed-planting action that can steal held right-click");red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);ticking=true;});
  h.runAtTickTime(120,()->{ok(count(red,"brick")==41,"holding SMG for 20 real server ticks fires seven rounds without jamming");red.releaseUsingItem();eggsBefore=count(red,"brick");});
  h.runAtTickTime(129,()->{ok(count(red,"brick")==eggsBefore,"SMG stops after release");tapping=true;});
  h.runAtTickTime(149,()->{tapping=false;red.releaseUsingItem();ok(count(red,"brick")==eggsBefore-7,"rapid release/repress cannot bypass independent three-tick cooldown");});
  h.runAtTickTime(155,()->{as(red,"clear @s");as(red,"loot replace entity @s weapon.offhand loot pvpshot:item/egg");red.getOffhandItem().setCount(1);red.getOffhandItem().use(h.getLevel(),red,InteractionHand.OFF_HAND);});
  h.runAtTickTime(160,()->{ok(count(red,"brick")==0&&!red.isUsingItem(),"last offhand SMG round consumes once and stops cleanly");int shots=h.getLevel().getEntities(EntityTypes.ITEM_DISPLAY,e->e.entityTags().contains("pvpshot.smg_shot")).size();red.doTick();red.doTick();ok(h.getLevel().getEntities(EntityTypes.ITEM_DISPLAY,e->e.entityTags().contains("pvpshot.smg_shot")).size()==shots,"empty magazine cannot spawn free rounds");ticking=false;});
  h.runAtTickTime(170,()->{fresh();healthBlue(100);blue.setPos(h.absoluteVec(new Vec3(6.3,1,10.5)));h.setBlock(5,2,10,Blocks.STONE);use("egg");for(int i=0;i<10;i++)command("function pvpshot:fire/tick");ok(blue.getHealth()==100,"SMG impact has no area damage");h.assertBlockPresent(Blocks.STONE,5,2,10);h.setBlock(5,2,10,Blocks.AIR);red.stopUsingItem();});
  h.runAtTickTime(200,()->{fresh();use("fighter");flightStart=h.getLevel().getGameTime();ticking=true;red.removeEffect(MobEffects.LEVITATION);red.setOnGround(false);ok(score(red,"pvpshot.airtime")==600,"fighter starts a 600-tick lifetime");});
  h.runAtTickTime(250,()->{red.stopUsingItem();as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/eagle500");red.setPos(h.absoluteVec(new Vec3(30.5,8,30.5)));red.setXRot(90);for(int x=28;x<=32;x++)for(int z=28;z<=32;z++)h.setBlock(x,1,z,Blocks.GLASS);red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);});
  h.runAtTickTime(255,()->{red.setPos(h.absoluteVec(new Vec3(2,8,2)));blue.setPos(h.absoluteVec(new Vec3(2,8,45)));ok(count(red,"nether_star")==0,"eagle is genuinely single-use");h.assertBlockPresent(Blocks.GLASS,30,1,30);});
  h.runAtTickTime(320,()->{h.assertBlockPresent(Blocks.GLASS,30,1,30);ok(true,"eagle respects its four-second warning delay");});
  h.runAtTickTime(340,()->{ok(h.getLevel().getBlockState(h.absolutePos(new BlockPos(30,1,30))).isAir(),"large eagle explosion destroys target terrain");});
  h.runAtTickTime(350,()->{red.setPos(h.absoluteVec(new Vec3(30.5,8,30.5)));red.setXRot(90);for(int x=18;x<=42;x++)for(int z=18;z<=42;z++)h.setBlock(x,1,z,Blocks.GLASS);use("orbital380");red.setPos(h.absoluteVec(new Vec3(2,8,2)));});
  h.runAtTickTime(400,()->{h.assertBlockPresent(Blocks.GLASS,30,1,30);ok(count(red,"echo_shard")==0,"orbital designation consumes once and does not detonate before warning");});
  h.runAtTickTime(540,()->{int empty=0;for(int x=18;x<=42;x++)for(int z=18;z<=42;z++)if(h.getLevel().getBlockState(h.absolutePos(new BlockPos(x,1,z))).isAir())empty++;ok(empty>100,"orbital sequence destroys a broad region over multiple timed shells: "+empty);});
  h.runAtTickTime(550,()->{red.setPos(h.absoluteVec(new Vec3(5.5,4,5.5)));red.setYRot(0);red.setXRot(0);blue.setPos(h.absoluteVec(new Vec3(40,8,40)));h.setBlock(5,5,15,Blocks.GLASS);use("airburst");});
  h.runAtTickTime(560,()->{ok(count(red,"prismarine_shard")==0&&h.getLevel().getBlockState(h.absolutePos(new BlockPos(5,5,15))).isAir(),"single-use airburst rocket detonates against a nearby obstruction");});
  h.runAtTickTime(570,()->{red.setPos(h.absoluteVec(new Vec3(5.5,1,5.5)));red.setYRot(0);red.setXRot(0);healthBlue(100);blue.setPos(h.absoluteVec(new Vec3(6.8,1,30.5)));h.setBlock(8,2,30,Blocks.GLASS);use("airburst");});
  h.runAtTickTime(590,()->{ok(blue.getHealth()<100&&h.getLevel().getBlockState(h.absolutePos(new BlockPos(8,2,30))).isAir(),"airburst proximity catches an enemy off the flight line and destroys terrain");});
  h.runAtTickTime(600,()->{blue.setPos(h.absoluteVec(new Vec3(45,8,45)));red.setPos(h.absoluteVec(new Vec3(5.5,8,5.5)));red.setXRot(0);for(int z=6;z<=100;z++)h.setBlock(5,9,z,Blocks.AIR);h.setBlock(6,9,97,Blocks.GLASS);use("airburst");});
  h.runAtTickTime(635,()->{ok(h.getLevel().getBlockState(h.absolutePos(new BlockPos(6,9,97))).isAir(),"airburst detonates at maximum range without an enemy or wall");});
  h.runAtTickTime(640,()->{red.setPos(h.absoluteVec(new Vec3(30.5,8,30.5)));red.setXRot(90);for(int x=28;x<=32;x++)for(int z=28;z<=32;z++)h.setBlock(x,1,z,Blocks.GLASS);use("eagle500");red.setPos(h.absoluteVec(new Vec3(2,8,2)));command("function pvpshot:match/restart");});
  h.runAtTickTime(740,()->{h.assertBlockPresent(Blocks.GLASS,30,1,30);ok(true,"starting a new round cancels pending heavy strikes");});
  h.runAtTickTime(799,()->{ok(red.getItemBySlot(EquipmentSlot.CHEST).is(Items.ELYTRA)&&score(red,"pvpshot.airtime")>0,"unused fighter ammunition does not extend or shorten the 30-second timer");});
  h.runAtTickTime(802,()->{ok(!red.getItemBySlot(EquipmentSlot.CHEST).is(Items.ELYTRA)&&red.hasEffect(MobEffects.SLOW_FALLING),"30-second deadline removes elytra and grants safe descent despite unused ammunition");ok(count(red,"flint")==0&&count(red,"magma_cream")==0&&count(red,"firework_rocket")==0,"forced expiry clears remaining aircraft equipment");System.out.println("REVISION8 CHECKS="+passes);h.succeed();});
  h.onEachTick(()->{if(ticking){if(tapping){red.releaseUsingItem();red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);}red.doTick();}});
 }
 public static void main(String[] args)throws Exception{
  SharedConstants.tryDetectVersion();net.minecraft.server.Bootstrap.bootStrap();var f=net.minecraft.core.MappedRegistry.class.getDeclaredField("frozen");f.setAccessible(true);f.setBoolean(BuiltInRegistries.TEST_FUNCTION,false);Registry.register(BuiltInRegistries.TEST_FUNCTION,Identifier.parse("pvptest:suite"),Revision8Audit::suite);var t=net.minecraft.core.MappedRegistry.class.getDeclaredField("allTags");t.setAccessible(true);var u=t.getType().getDeclaredMethod("unbound");u.setAccessible(true);t.set(BuiltInRegistries.TEST_FUNCTION,u.invoke(null));BuiltInRegistries.TEST_FUNCTION.freeze();net.minecraft.gametest.Main.main(args);
 }
}
