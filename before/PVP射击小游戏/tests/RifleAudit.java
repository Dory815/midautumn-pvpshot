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
import net.minecraft.world.item.context.UseOnContext;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.phys.*;

/** Actual item-use, collision and native arrow balance checks. */
public class RifleAudit extends TestMain {
 static void ok(boolean yes,String text){h.assertTrue(yes,text);System.out.println("PASS "+text);}
 static void resetRifle(){
  command("kill @e[tag=pvpshot.shot]");reset();
  red.setPos(h.absoluteVec(new Vec3(5.5,1,5.5)));red.setYRot(0);red.setXRot(0);
  blue.setPos(h.absoluteVec(new Vec3(5.5,1,10.5)));blue.setDeltaMovement(Vec3.ZERO);
  as(red,"effect clear @s");as(red,"clear @s");
 }
 static void use(String name){as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/"+name);red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);for(int i=0;i<3;i++)red.doTick();}
 static void moveShots(int n){for(int i=0;i<n;i++)command("function pvpshot:fire/tick");}
 static Arrow nativeArrow(String weapon){
  command("kill @e[type=arrow]");as(red,"clear @s");as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/"+weapon);
  var stack=red.getMainHandItem();as(red,"give @s arrow 64");
  if(weapon.equals("bow"))((BowItem)stack.getItem()).releaseUsing(stack,h.getLevel(),red,71980);
  else {stack.set(DataComponents.CHARGED_PROJECTILES,ChargedProjectiles.of(new ItemStackTemplate(Items.ARROW)));((CrossbowItem)stack.getItem()).performShooting(h.getLevel(),red,InteractionHand.MAIN_HAND,stack,3.15f,0f,null);}
  var arrows=h.getLevel().getEntities(EntityTypes.ARROW,e->e.getOwner()==red);ok(arrows.size()==1,weapon+" actual item launches an arrow");return arrows.getFirst();
 }
 static void suite(GameTestHelper helper){
  h=helper;command("function pvpshot:load");command("scoreboard players set #mode pvpshot.cfg 0");command("scoreboard players set #ammo.enabled pvpshot.cfg 0");command("scoreboard players set #regen.enabled pvpshot.cfg 0");
  red=player("RifleRed",5,5);blue=player("RifleBlue",5,10);as(red,"team join pvpshot.red @s");as(blue,"team join pvpshot.blue @s");
  h.runAtTickTime(70,()->{
   resetRifle();use("fire_charge");
   var shots=h.getLevel().getEntities(EntityTypes.ITEM_DISPLAY,e->e.entityTags().contains("pvpshot.fire_shot"));ok(shots.size()==1,"rifle creates one harmless display carrier");
   var shot=shots.getFirst();var start=shot.position();moveShots(1);
   ok(Math.abs(shot.getZ()-start.z-1.8525)<.002 && Math.abs(shot.getY()-start.y)<.0001,"rifle increases fireball first-step speed by 50 percent and straight path");
   moveShots(5);health(14,"six HP direct hit");ok(blue.getDeltaMovement().length()<.001,"rifle has no knockback");ok(!blue.isOnFire()&&blue.getActiveEffects().stream().allMatch(e->e.is(net.minecraft.world.effect.MobEffects.GLOWING)),"rifle adds no burning or negative status beyond hit mark");
   ok(blue.hasEffect(net.minecraft.world.effect.MobEffects.GLOWING),"enemy rifle hit marks the victim");
   resetRifle();blue.setPos(h.absoluteVec(new Vec3(5.5,1,10.5)));use("fire_charge");
   // A bystander beyond the small splash radius remains safe.
   var spectator=player("RifleBystander",7,10);as(spectator,"team join pvpshot.blue @s");moveShots(6);ok(spectator.getHealth()==20,"rifle splash does not reach outside 1.5 blocks");h.getLevel().getServer().getPlayerList().remove(spectator);
   // Near-miss at chest height detonates on the wall beside the target.
   resetRifle();red.setPos(h.absoluteVec(new Vec3(6.3,1,5.5)));red.setXRot(8);blue.setPos(h.absoluteVec(new Vec3(5.5,1,10.2)));
   h.setBlock(6,1,10,Blocks.STONE);use("fire_charge");moveShots(7);health(17,"wall near-miss splashes three HP within one block");
   ok(!blue.isOnFire()&&blue.getDeltaMovement().length()<.001,"rifle splash has no fire or knockback");h.setBlock(6,1,10,Blocks.AIR);
   resetRifle();red.setPos(h.absoluteVec(new Vec3(6.7,1,5.5)));red.setXRot(8);blue.setPos(h.absoluteVec(new Vec3(5.5,1,9.7)));
   h.setBlock(6,1,10,Blocks.STONE);use("fire_charge");moveShots(7);health(19,"outer splash deals one HP inside 1.5 blocks");h.setBlock(6,1,10,Blocks.AIR);
   resetRifle();red.setXRot(8);blue.setPos(h.absoluteVec(new Vec3(5.5,1,11.1)));
   h.setBlock(5,1,10,Blocks.STONE);h.setBlock(5,2,10,Blocks.STONE);use("fire_charge");moveShots(7);health(20,"wall blocks splash before the impact block is removed");
   h.setBlock(5,1,10,Blocks.AIR);h.setBlock(5,2,10,Blocks.AIR);
   resetRifle();as(blue,"item replace entity @s weapon.mainhand with shield");blue.setYRot(180);blue.startUsingItem(InteractionHand.MAIN_HAND);for(int i=0;i<7;i++)blue.doTick();use("fire_charge");moveShots(6);health(20,"shield blocks rifle");ok(!blue.hasEffect(net.minecraft.world.effect.MobEffects.GLOWING),"fully shielded hit does not mark");
   resetRifle();as(blue,"item replace entity @s armor.chest with diamond_chestplate");blue.doTick();use("fire_charge");moveShots(6);ok(blue.getHealth()>14&&blue.getHealth()<20,"armor reduces rifle damage health="+blue.getHealth());
   resetRifle();as(blue,"team join pvpshot.red @s");use("fire_charge");moveShots(6);health(14,"rifle respects enabled friendly fire");ok(!blue.hasEffect(net.minecraft.world.effect.MobEffects.GLOWING),"friendly fire does not mark");as(blue,"team join pvpshot.blue @s");
   resetRifle();blue.setPos(h.absoluteVec(new Vec3(25.5,1,25.5)));
   for(int x=4;x<=6;x++)for(int y=1;y<=3;y++)for(int z=10;z<=11;z++)h.setBlock(x,y,z,Blocks.STONE);
   use("fire_charge");moveShots(10);int remaining=0;
   for(int x=4;x<=6;x++)for(int y=1;y<=3;y++)for(int z=10;z<=11;z++)if(h.getLevel().getBlockState(h.absolutePos(new BlockPos(x,y,z))).is(Blocks.STONE))remaining++;
   ok(remaining==17,"rifle removes exactly one block from a two-layer stone wall");
   for(int x=4;x<=6;x++)for(int y=1;y<=3;y++)for(int z=10;z<=11;z++)h.setBlock(x,y,z,Blocks.AIR);
   h.setBlock(5,2,10,Blocks.BEDROCK);use("fire_charge");moveShots(10);h.assertBlockPresent(Blocks.BEDROCK,5,2,10);ok(true,"rifle cannot remove bedrock");h.setBlock(5,2,10,Blocks.AIR);
   var pos=h.absolutePos(new BlockPos(4,0,4));as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/fire_charge");
   red.getMainHandItem().useOn(new UseOnContext(red,InteractionHand.MAIN_HAND,new BlockHitResult(Vec3.atCenterOf(pos),Direction.UP,pos,false)));
   ok(h.getLevel().getBlockState(pos.above()).isAir(),"clicking terrain with rifle item cannot ignite it");
   resetRifle();blue.setPos(h.absoluteVec(new Vec3(5.5,1,10.5)));
   for(int x=0;x<=12;x++)for(int y=1;y<=7;y++)h.setBlock(x,y,14,Blocks.STONE);
   h.setBlock(5,0,14,Blocks.BEDROCK);use("rocket");moveShots(8);
   ok(blue.getHealth()==18,"demolition direct hit is capped at two HP");ok(!blue.isOnFire()&&blue.getDeltaMovement().length()<.001,"demolition has no burning or knockback");
   ok(h.getLevel().getBlockState(h.absolutePos(new BlockPos(5,2,14))).isAir(),"rocket demolishes stone wall several blocks behind impact");h.assertBlockPresent(Blocks.BEDROCK,5,0,14);
   ok(h.getLevel().getEntities(EntityTypes.TNT,e->true).isEmpty()&&h.getLevel().getEntities(EntityTypes.FIREBALL,e->true).isEmpty(),"demolition does not summon a damaging native explosion");
   // Native arrow damage from the actual enchanted items, with critical randomness disabled for comparison.
   for(String weapon:List.of("bow","crossbow")){
    resetRifle();var a=nativeArrow(weapon);a.setCritArrow(false);a.setPos(blue.position().add(0,1,-1));a.setDeltaMovement(0,0,3);a.tick();
    float damage=20-blue.getHealth();ok(damage==(weapon.equals("bow")?3:4),weapon+" close-range native arrow damage="+damage);ok(blue.hasEffect(net.minecraft.world.effect.MobEffects.GLOWING),weapon+" native arrow triggers enemy mark");a.discard();
   }
   // Free deployment may replace ordinary obstructions and does not require a floor.
   command("kill @e[tag=pvpshot.machine]");red.setPos(h.absoluteVec(new Vec3(30.5,7,30.5)));red.setYRot(0);as(red,"function pvpshot:deploy/turret");ok(machines("turret").size()==1,"turret can be deployed in midair");
   command("kill @e[tag=pvpshot.machine]");red.setPos(h.absoluteVec(new Vec3(30.5,1,30.5)));for(int x=29;x<=31;x++)for(int y=1;y<=3;y++)for(int z=33;z<=37;z++)h.setBlock(x,y,z,Blocks.STONE);
   as(red,"function pvpshot:deploy/cannon");ok(machines("cannon").size()==1,"cannon replaces ordinary wall obstructions");
   resetRifle();blue.setHealth(6);use("fire_charge");moveShots(6);
   ok(blue.isDeadOrDying() && score(red,"pvpshot.kill_blue")==1,"lethal rifle hit retains enemy-team kill attribution");
   h.getLevel().getServer().getPlayerList().remove(blue);blue=player("MarkBlue",5,10);as(blue,"team join pvpshot.blue @s");resetRifle();
   // A large hunger drain and exhaustion must never disable sprinting or heal health for free.
   blue.setHealth(10);
   for(int i=0;i<100;i++){blue.getFoodData().setFoodLevel(1);blue.getFoodData().setSaturation(0);blue.getFoodData().addExhaustion(10);as(blue,"function pvpshot:player/feed");blue.doTick();}
   ok(blue.getFoodData().getFoodLevel()==20 && blue.getFoodData().getSaturationLevel()>=19,"food stays full under repeated exhaustion: food="+blue.getFoodData().getFoodLevel()+" saturation="+blue.getFoodData().getSaturationLevel());
   ok(blue.getHealth()==10,"full hunger does not bypass combat regeneration delay");
   as(blue,"effect clear @s");blue.invulnerableTime=0;blue.hurtServer(h.getLevel(),h.getLevel().damageSources().fall(),1);
   ok(!blue.hasEffect(net.minecraft.world.effect.MobEffects.GLOWING),"environmental damage does not mark");
   blue.invulnerableTime=0;blue.hurtServer(h.getLevel(),h.getLevel().damageSources().playerAttack(blue),1);
   ok(!blue.hasEffect(net.minecraft.world.effect.MobEffects.GLOWING),"self damage does not mark");
   red.invulnerableTime=0;red.hurtServer(h.getLevel(),h.getLevel().damageSources().playerAttack(blue),1);ok(red.hasEffect(net.minecraft.world.effect.MobEffects.GLOWING),"blue attacking red also applies mark");
   resetRifle();
   // Stress repeated chest rolls so guaranteed items never overflow the container.
   var chestPos=h.absolutePos(new BlockPos(35,1,35));h.setBlock(35,1,35,Blocks.TRAPPED_CHEST);
   for(int i=0;i<30;i++){
    command("execute positioned "+chestPos.getX()+" "+chestPos.getY()+" "+chestPos.getZ()+" run function pvpshot:chest/refill_one");
    var chest=(net.minecraft.world.Container)h.getLevel().getBlockEntity(chestPos);
    ok(chest.countItem(Items.FIREWORK_STAR)==4 && chest.countItem(Items.SLIME_BALL)==2 && chest.countItem(Items.ARROW)>=32,"ordinary supply guarantees four rockets, two grenades and arrows roll="+i);
    int occupied=0;for(int slot=0;slot<chest.getContainerSize();slot++)if(!chest.getItem(slot).isEmpty())occupied++;
    h.assertTrue(occupied>=10 && occupied<27,"rich contents fit in chest, occupied="+occupied);
   }
   command("execute positioned "+chestPos.getX()+" "+chestPos.getY()+" "+chestPos.getZ()+" run summon marker ~ ~ ~ {Tags:['pvpshot.chest','pvpshot.chest.rich']}");
   command("scoreboard players set #chest.timer pvpshot.chest 1199");command("scoreboard players set #chest.interval pvpshot.cfg 1200");command("function pvpshot:chest/tick");var chest=(net.minecraft.world.Container)h.getLevel().getBlockEntity(chestPos);
   ok(chest.countItem(Items.FIREWORK_STAR)==6 && chest.countItem(Items.SLIME_BALL)==3 && chest.countItem(Items.ARROW)>=64,"periodic refill preserves rich cache extras: rockets="+chest.countItem(Items.FIREWORK_STAR)+" grenades="+chest.countItem(Items.SLIME_BALL)+" arrows="+chest.countItem(Items.ARROW));
   command("kill @e[tag=pvpshot.chest.rich]");

  });
  h.onEachTick(()->{if(h.getTick()>=80){blue.doTick();red.doTick();}});
  h.runAtTickTime(80,()->{resetRifle();as(blue,"attribute @s minecraft:max_health base set 200");blue.doTick();blue.setHealth(200);nativeBlast(red);});
  h.runAtTickTime(84,()->{ok(blue.hasEffect(net.minecraft.world.effect.MobEffects.GLOWING),"native TNT enemy damage marks the victim");});
  h.runAtTickTime(100,()->{blue.invulnerableTime=0;blue.hurtServer(h.getLevel(),h.getLevel().damageSources().playerAttack(red),1);ok(blue.getEffect(net.minecraft.world.effect.MobEffects.GLOWING).getDuration()==40,"repeated enemy damage refreshes mark to two seconds");});
  h.runAtTickTime(138,()->ok(blue.hasEffect(net.minecraft.world.effect.MobEffects.GLOWING),"mark remains for nearly two seconds after latest hit"));
  h.runAtTickTime(141,()->{ok(!blue.hasEffect(net.minecraft.world.effect.MobEffects.GLOWING),"mark expires after two seconds");h.succeed();});
 }
 public static void main(String[] args)throws Exception{
  SharedConstants.tryDetectVersion();net.minecraft.server.Bootstrap.bootStrap();
  var f=net.minecraft.core.MappedRegistry.class.getDeclaredField("frozen");f.setAccessible(true);f.setBoolean(BuiltInRegistries.TEST_FUNCTION,false);
  Registry.register(BuiltInRegistries.TEST_FUNCTION,Identifier.parse("pvptest:suite"),RifleAudit::suite);
  var t=net.minecraft.core.MappedRegistry.class.getDeclaredField("allTags");t.setAccessible(true);var u=t.getType().getDeclaredMethod("unbound");u.setAccessible(true);t.set(BuiltInRegistries.TEST_FUNCTION,u.invoke(null));BuiltInRegistries.TEST_FUNCTION.freeze();net.minecraft.gametest.Main.main(args);
 }
}
