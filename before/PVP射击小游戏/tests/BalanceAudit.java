import java.util.*;
import net.minecraft.SharedConstants;
import net.minecraft.core.*;
import net.minecraft.core.component.DataComponents;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.gametest.framework.GameTestHelper;
import net.minecraft.resources.Identifier;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.entity.*;
import net.minecraft.world.entity.item.*;
import net.minecraft.world.entity.projectile.arrow.*;
import net.minecraft.world.item.*;
import net.minecraft.world.item.component.ChargedProjectiles;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.effect.MobEffects;
import net.minecraft.world.phys.*;

public class BalanceAudit extends TestMain {
 static int passes;
 static void ok(boolean b,String text){h.assertTrue(b,text);System.out.println("PASS "+(++passes)+" "+text);}
 static void resetAll(){
  command("kill @e[type=arrow]");command("kill @e[tag=pvpshot.shot]");command("kill @e[type=tnt]");
  reset();red.setHealth(20);red.invulnerableTime=0;as(red,"effect clear @s");as(red,"clear @s");red.stopUsingItem();
  red.setPos(h.absoluteVec(new Vec3(5.5,1,5.5)));red.setYRot(0);red.setXRot(0);blue.setPos(h.absoluteVec(new Vec3(5.5,1,30.5)));
 }
 static Arrow launch(String type){
  as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/"+type);as(red,"give @s arrow 64");var stack=red.getMainHandItem();
  if(type.equals("bow"))((BowItem)stack.getItem()).releaseUsing(stack,h.getLevel(),red,71980);
  else{stack.set(DataComponents.CHARGED_PROJECTILES,ChargedProjectiles.of(new ItemStackTemplate(Items.ARROW)));((CrossbowItem)stack.getItem()).performShooting(h.getLevel(),red,InteractionHand.MAIN_HAND,stack,3.15f,0f,null);}
  var a=h.getLevel().getEntities(EntityTypes.ARROW,e->e.getOwner()==red).getLast();a.tick();return a;
 }
 static void shotAt(Arrow a,double z){a.setPos(h.absoluteVec(new Vec3(5.5,2,z)));a.setDeltaMovement(0,0,3);a.tick();}
 static void consume(String item){as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/"+item);red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);for(int i=0;i<(item.equals("egg")?2:4);i++)red.doTick();}
 static void suite(GameTestHelper helper){
  h=helper;command("function pvpshot:load");command("scoreboard players set #ammo.enabled pvpshot.cfg 0");command("scoreboard players set #regen.enabled pvpshot.cfg 0");command("scoreboard objectives add ustc.clock dummy");
  red=player("BalanceRed",5,5);blue=player("BalanceBlue",5,30);as(red,"team join pvpshot.red @s");as(blue,"team join pvpshot.blue @s");
  h.runAtTickTime(70,()->{
   resetAll();var a=launch("crossbow");ok(CrossbowItem.getChargeDuration(red.getMainHandItem(),red)==60,"crossbow genuinely takes 60 ticks to load");
   ok(enchant(red.getMainHandItem(),"piercing")==0,"crossbow has no piercing");
   blue.setPos(h.absoluteVec(new Vec3(5.5,1,10.5)));shotAt(a,9.5);health(16,"close crossbow deals four HP");a.discard();
   resetAll();a=launch("crossbow");blue.setPos(h.absoluteVec(new Vec3(5.5,1,24.5)));shotAt(a,23.5);health(16,"crossbow remains weak below twenty blocks");a.discard();
   resetAll();a=launch("crossbow");as(blue,"item replace entity @s armor.chest with diamond_chestplate");blue.doTick();shotAt(a,29.5);ok(blue.isDeadOrDying(),"far crossbow kills an armored full-health player");a.discard();
   h.getLevel().getServer().getPlayerList().remove(blue);blue=player("ShieldBlue",5,30);as(blue,"team join pvpshot.blue @s");
   resetAll();a=launch("crossbow");as(blue,"item replace entity @s weapon.mainhand with shield");blue.setYRot(180);blue.startUsingItem(InteractionHand.MAIN_HAND);for(int i=0;i<7;i++)blue.doTick();shotAt(a,29.5);health(20,"shield blocks distant lethal bolt");a.discard();
   resetAll();a=launch("bow");blue.setPos(h.absoluteVec(new Vec3(5.5,1,10.5)));shotAt(a,9.5);health(17,"close bow deals three HP");a.discard();
   resetAll();a=launch("bow");blue.setPos(h.absoluteVec(new Vec3(6.3,1,30.5)));shotAt(a,29.5);ok(a.isRemoved()&&blue.getHealth()<20,"far bow proximity detects swept near miss");ok(blue.getHealth()>=8,"near explosion damages only once");
   resetAll();a=launch("bow");blue.setPos(h.absoluteVec(new Vec3(7.0,1,30.5)));shotAt(a,29.5);health(20,"bow does not retain old 1.5 block proximity trigger");a.discard();
   resetAll();a=launch("bow");blue.setPos(h.absoluteVec(new Vec3(6.3,1,10.5)));shotAt(a,9.5);health(20,"bow proximity is unarmed at short range");a.discard();
   resetAll();a=launch("bow");var pos=a.position();var motion=a.getDeltaMovement();blue.setPos(h.absoluteVec(new Vec3(40,1,40)));a.tick();ok(a.position().distanceTo(pos.add(motion))<.00001,"bow trajectory movement is exactly native velocity");ok(Math.abs(a.getDeltaMovement().y-(motion.y*.99-.05))<.00001,"bow keeps native drag and gravity");a.discard();
   resetAll();blue.setPos(h.absoluteVec(new Vec3(5.5,1,10.5)));consume("egg");command("function pvpshot:fire/tick");for(int i=0;i<5;i++)command("function pvpshot:fire/tick");health(16,"SMG direct hit is four HP");ok(!blue.isOnFire(),"SMG does not ignite targets");
   resetAll();a=launch("bow");blue.setPos(h.absoluteVec(new Vec3(6.3,1,31.5)));h.setBlock(5,2,31,Blocks.STONE);shotAt(a,29.5);ok(blue.getHealth()<20,"distant bow block impact produces splash");h.assertBlockPresent(Blocks.STONE,5,2,31);h.setBlock(5,2,31,Blocks.AIR);
   resetAll();a=launch("bow");blue.setPos(h.absoluteVec(new Vec3(5.5,1,32.5)));for(int x=4;x<=6;x++)for(int y=1;y<=3;y++)h.setBlock(x,y,31,Blocks.STONE);shotAt(a,29.5);health(20,"solid wall shields bow splash");for(int x=4;x<=6;x++)for(int y=1;y<=3;y++)h.setBlock(x,y,31,Blocks.AIR);
   resetAll();blue.setPos(h.absoluteVec(new Vec3(5.5,1,10.5)));as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/wind");red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);
   var winds=h.getLevel().getEntities(EntityTypes.WIND_CHARGE,e->true);ok(winds.size()==1&&winds.getFirst().entityTags().contains("pvpshot.wind"),"actual wind-charge item marks the custom projectile");var wind=winds.getFirst();wind.setPos(blue.position().add(0,1,-.5));wind.setDeltaMovement(0,0,1);wind.tick();ok(blue.getHealth()>19.8&&blue.getDeltaMovement().length()>1,"wind direct hit has negligible damage and extreme knockback");
   resetAll();consume("fighter");ok(red.getItemBySlot(EquipmentSlot.CHEST).is(Items.ELYTRA)&&count(red,"flint")==24&&count(red,"magma_cream")==4&&count(red,"firework_rocket")==12,"fighter actual consumable gives bounded kit");
   ok(red.hasEffect(MobEffects.LEVITATION),"fighter supplies initial takeoff lift");
   ok(h.getLevel().getEntities(EntityTypes.ARMOR_STAND,e->e.entityTags().contains("pvpshot.plane_holder")).stream().allMatch(e->e.isMarker()),"aircraft armor holder is actually a non-colliding marker");
   red.removeEffect(MobEffects.LEVITATION);red.setOnGround(false);ok(red.tryToStartFallFlying()&&red.isFallFlying(),"equipped fighter supports actual native elytra gliding");
   // Actual cannon/bomb consumables feed the native bounded-ammunition counters.
   consume("plane_gun");ok(score(red,"pvpshot.gun")==23&&h.getLevel().getEntities(EntityTypes.FIREBALL,e->e.entityTags().contains("pvpshot.airgun")).size()==1,"aircraft cannon consumes one bounded round and launches explosive projectile");
   consume("plane_bomb");ok(score(red,"pvpshot.bomb")==3&&h.getLevel().getEntities(EntityTypes.TNT,e->e.entityTags().contains("pvpshot.airbomb")).size()==1,"aircraft bomb consumes one bounded round and drops native TNT");
   var cannon=h.getLevel().getEntities(EntityTypes.FIREBALL,e->e.entityTags().contains("pvpshot.airgun")).getFirst();h.setBlock(30,2,20,Blocks.GLASS);cannon.setPos(h.absoluteVec(new Vec3(30.5,2.5,19.5)));cannon.setDeltaMovement(0,0,1);cannon.tick();ok(h.getLevel().getBlockState(h.absolutePos(new BlockPos(30,2,20))).isAir(),"aircraft cannon explosion destroys ordinary terrain");
   var bomb=h.getLevel().getEntities(EntityTypes.TNT,e->e.entityTags().contains("pvpshot.airbomb")).getFirst();bomb.setPos(h.absoluteVec(new Vec3(30.5,2,20.5)));bomb.setOnGround(true);h.setBlock(30,2,21,Blocks.GLASS);command("function pvpshot:v7/tick");ok(bomb.getFuse()==0,"aircraft bomb detonates on landing");bomb.tick();ok(h.getLevel().getBlockState(h.absolutePos(new BlockPos(30,2,21))).isAir(),"aircraft bomb uses native terrain-destroying TNT explosion");

as(red,"clear @s flint");red.doTick();ok(red.getItemBySlot(EquipmentSlot.CHEST).is(Items.ELYTRA),"exhausting only the cannon does not exit aircraft");
   as(red,"clear @s magma_cream");red.doTick();ok(!red.getItemBySlot(EquipmentSlot.CHEST).is(Items.ELYTRA)&&red.hasEffect(MobEffects.SLOW_FALLING),"both ammo exhausted removes elytra and grants slow falling");
   resetAll();as(red,"item replace entity @s armor.chest with diamond_chestplate");consume("fighter");as(red,"scoreboard players set @s pvp_land 1");red.doTick();ok(red.getItemBySlot(EquipmentSlot.CHEST).is(Items.DIAMOND_CHESTPLATE),"manual exit restores original chest armor");
   resetAll();as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/grenade");as(red,"scoreboard players set @s pvp_cook 1");red.doTick();
   red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);red.doTick();for(int i=0;i<15;i++){red.tickCount++;red.doTick();}red.releaseUsingItem();red.doTick();
   var t=h.getLevel().getEntities(EntityTypes.TNT,e->e.getOwner()==red);ok(t.size()==1&&t.getFirst().getFuse()<=25&&count(red,"slime_ball")==0,"cooking release preserves elapsed fuse and consumes once");
   resetAll();as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/grenade");red.doTick();red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);red.doTick();for(int i=0;i<41;i++){red.tickCount++;red.doTick();}
   t=h.getLevel().getEntities(EntityTypes.TNT,e->e.getOwner()==red);ok(t.size()==1&&t.getFirst().getFuse()==0,"holding too long detonates in hand");
   resetAll();as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/speed");red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);for(int i=0;i<40;i++)red.doTick();ok(red.getEffect(MobEffects.SPEED)!=null&&red.getEffect(MobEffects.SPEED).getAmplifier()==4,"speed potion grants level five");
   System.out.println("BALANCE CHECKS="+passes);h.succeed();
  });
 }
 public static void main(String[] args)throws Exception{
  SharedConstants.tryDetectVersion();net.minecraft.server.Bootstrap.bootStrap();
  var f=net.minecraft.core.MappedRegistry.class.getDeclaredField("frozen");f.setAccessible(true);f.setBoolean(BuiltInRegistries.TEST_FUNCTION,false);
  Registry.register(BuiltInRegistries.TEST_FUNCTION,Identifier.parse("pvptest:suite"),BalanceAudit::suite);
  var t=net.minecraft.core.MappedRegistry.class.getDeclaredField("allTags");t.setAccessible(true);var u=t.getType().getDeclaredMethod("unbound");u.setAccessible(true);t.set(BuiltInRegistries.TEST_FUNCTION,u.invoke(null));BuiltInRegistries.TEST_FUNCTION.freeze();net.minecraft.gametest.Main.main(args);
 }
}
