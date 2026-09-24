import java.util.*;
import net.minecraft.SharedConstants;
import net.minecraft.core.*;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.gametest.framework.GameTestHelper;
import net.minecraft.resources.Identifier;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.entity.*;
import net.minecraft.world.entity.projectile.Projectile;
import net.minecraft.world.entity.projectile.throwableitemprojectile.Snowball;
import net.minecraft.world.effect.MobEffects;
import net.minecraft.world.item.*;
import net.minecraft.world.level.GameType;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.phys.Vec3;

/** End-to-end native projectile, area lifetime, ownership and inventory checks. */
public class FieldAudit extends TestMain {
 static void ok(boolean v,String label){h.assertTrue(v,label);System.out.println("PASS "+label);}
 static List<Marker> fields(){return new ArrayList<>(h.getLevel().getEntities(EntityTypes.MARKER,e->e.entityTags().contains("pvpshot.field")));}
 static void moveBlue(double x,double y,double z){blue.setPos(h.absoluteVec(new Vec3(x,y,z)));}
 static void fresh(){
  command("function pvpshot:field/clear");command("kill @e[type=snowball]");command("scoreboard players reset @a pvpshot.field_next");
  reset();blue.setGameMode(GameType.SURVIVAL);as(blue,"team join pvpshot.blue @s");
  as(red,"clear @s");as(red,"effect clear @s");red.doTick();red.setHealth(20);red.invulnerableTime=0;red.setDeltaMovement(Vec3.ZERO);red.clearFire();
  red.setPos(h.absoluteVec(new Vec3(5.5,1,5.5)));red.setYRot(0);red.setXRot(0);
 }
 static void field(int x,int y,int z){
  var pos=h.absolutePos(new BlockPos(x,y,z));as(red,"tag @s add pvpshot.damage_source");
  as(red,"execute positioned "+pos.getX()+" "+pos.getY()+" "+pos.getZ()+" run function pvpshot:field/create");
  as(red,"tag @s remove pvpshot.damage_source");
 }
 static void ticks(int n){for(int i=0;i<n;i++)command("function pvpshot:field/tick");}
 static void weights(String only){for(String n:List.of("snowball","egg","trident","bow","crossbow"))command("scoreboard players set #w."+n+" pvpshot.cfg "+(only==null||n.equals(only)?20:0));}
 static void suite(GameTestHelper helper){
  h=helper;command("function pvpshot:load");command("scoreboard players set #regen.enabled pvpshot.cfg 0");command("scoreboard players set #ammo.enabled pvpshot.cfg 0");
  red=player("FieldRed",5,5);blue=player("FieldBlue",5,9);as(red,"team join pvpshot.red @s");as(blue,"team join pvpshot.blue @s");
  h.runAtTickTime(70,()->{
   for(String n:List.of("snowball","egg","trident")){
    weights(n);as(red,"function pvpshot:player/kit");
    ok(count(red,n.equals("egg")?"brick":n)==(n.equals("snowball")?4:n.equals("egg")?48:1),"spawn supports "+n+" with intended quantity");
    ok(count(red,"bow")==0&&count(red,"crossbow")==0&&count(red,"firework_star")==1,"spawn excludes bow/crossbow and retains one rocket");
   }
   var chestPos=h.absolutePos(new BlockPos(40,1,40));h.setBlock(40,1,40,Blocks.TRAPPED_CHEST);
   for(String n:List.of("bow","crossbow")){
    weights(n);command("execute positioned "+chestPos.getX()+" "+chestPos.getY()+" "+chestPos.getZ()+" run function pvpshot:chest/refill_one");
    var chest=(net.minecraft.world.Container)h.getLevel().getBlockEntity(chestPos);
    ok(chest.countItem(n.equals("bow")?Items.BOW:Items.CROSSBOW)==2,"crate retains "+n+" in its two weapon rolls");
   }
   weights(null);fresh();red.setYRot(90);as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/snowball");
   red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);
   var balls=h.getLevel().getEntities(EntityTypes.SNOWBALL,e->e.getOwner()==red);ok(balls.size()==1&&count(red,"snowball")==3,"actual native snowball use consumes one of four");
   var ball=balls.getFirst();var v=ball.getDeltaMovement();command("function pvpshot:combat/proj_tick");
   ok(ball.getDeltaMovement().equals(v)&&fields().isEmpty(),"sweep does not alter native velocity or create an airborne field");
   var plain=new Snowball(h.getLevel(),red,new ItemStack(Items.SNOWBALL));plain.setPos(ball.position().add(10,0,0));plain.setDeltaMovement(v);h.getLevel().addFreshEntity(plain);
   ball.tick();plain.tick();ok(ball.getDeltaMovement().distanceTo(plain.getDeltaMovement())<1e-9,"native drag and gravity match a plain snowball");ball.discard();plain.discard();
   fresh();moveBlue(40.5,1,35.5);as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/snowball");
   var ground=new Snowball(h.getLevel(),red,red.getMainHandItem().copy());ground.setPos(h.absoluteVec(new Vec3(15.5,1.4,15.5)));ground.setDeltaMovement(0,-.4,0);
   Projectile.spawnProjectile(ground,h.getLevel(),red.getMainHandItem());
   ok(fields().size()==1,"native downward snowball creates one field on floor impact");h.assertBlockPresent(Blocks.SMOOTH_STONE,15,0,15);ok(true,"impact leaves terrain intact");
   fresh();hit("snowball",true);health(18,"direct snowball hit produces one area pulse, not old six damage");
   ok(fields().size()==1&&blue.getEffect(MobEffects.SLOWNESS).getAmplifier()==3,"impact creates one field with Slowness IV");
   ok(blue.hasEffect(MobEffects.GLOWING)&&blue.getDeltaMovement().length()<.001,"enemy area damage marks target without knockback");
   ticks(19);health(18,"no second pulse before one second");ticks(1);health(16,"next pulse at twenty ticks");ticks(60);health(10,"five pulses total over a full field lifetime");ticks(20);
   ok(fields().isEmpty()&&blue.getHealth()==10,"field expires at five seconds without a sixth pulse");
   for(int i=0;i<20;i++)blue.doTick();ok(!blue.hasEffect(MobEffects.SLOWNESS),"slow expires within one second after area disappears");
   fresh();moveBlue(15.5,1,15.5);field(15,1,15);field(15,1,15);health(18,"overlapping areas do not double initial damage");
   ticks(20);health(16,"overlapping areas share a one-second damage limit");
   ok(blue.getEffect(MobEffects.SLOWNESS).getAmplifier()==3,"overlap does not amplify slow");
   fresh();moveBlue(15.5,1,15.5);field(15,1,15);moveBlue(30.5,1,30.5);ticks(40);health(18,"leaving area stops further damage immediately");
   for(int i=0;i<20;i++)blue.doTick();ok(!blue.hasEffect(MobEffects.SLOWNESS),"leaving area releases slow within one second");
   fresh();moveBlue(15.5,1,15.5);field(15,1,15);moveBlue(30.5,1,30.5);ticks(10);moveBlue(15.5,1,15.5);ticks(9);health(18,"rapid reentry cannot bypass pulse cooldown");ticks(1);health(16,"reentry resumes next scheduled damage pulse");
   fresh();moveBlue(18.5,1,15.5);field(15,1,15);health(18,"three-block horizontal radius includes its boundary");
   fresh();moveBlue(18.51,1,15.5);field(15,1,15);health(20,"outside three-block radius is unaffected");
   fresh();moveBlue(15.5,4,15.5);field(15,1,15);health(20,"separate upper floor is not affected");
   fresh();moveBlue(17.5,1,15.5);for(int z=13;z<=18;z++)for(int y=1;y<=4;y++)h.setBlock(16,y,z,Blocks.STONE);
   field(15,1,15);ticks(20);health(20,"complete wall blocks area damage");ok(!blue.hasEffect(MobEffects.SLOWNESS),"complete wall also blocks slow");
   for(int z=13;z<=18;z++)for(int y=1;y<=4;y++){h.assertBlockPresent(Blocks.STONE,16,y,z);h.setBlock(16,y,z,Blocks.AIR);}
   fresh();moveBlue(16.5,1,15.5);red.setPos(h.absoluteVec(new Vec3(15.5,1,15.5)));as(blue,"team join pvpshot.red @s");field(15,1,15);
   ok(blue.getHealth()==18&&red.getHealth()==18,"area damages teammates and its own thrower");
   ok(blue.hasEffect(MobEffects.SLOWNESS)&&red.hasEffect(MobEffects.SLOWNESS),"area slows teammates and its own thrower");
   ok(!blue.hasEffect(MobEffects.GLOWING)&&!red.hasEffect(MobEffects.GLOWING),"friendly and self pulses do not mark");
   fresh();moveBlue(16.5,1,15.5);as(blue,"team join pvpshot.red @s");command("scoreboard players set #friendlyfire pvpshot.cfg 0");command("team modify pvpshot.red friendlyFire false");field(15,1,15);
   ok(blue.getHealth()==20&&!blue.hasEffect(MobEffects.SLOWNESS),"optional friendly-fire-off configuration protects teammate from field");
   command("scoreboard players set #friendlyfire pvpshot.cfg 1");command("team modify pvpshot.red friendlyFire true");
   fresh();moveBlue(15.5,1,15.5);as(blue,"effect give @s resistance 10 4 true");field(15,1,15);health(20,"native resistance protects against field damage");
   fresh();moveBlue(15.5,1,15.5);as(blue,"item replace entity @s armor.chest with diamond_chestplate");blue.doTick();field(15,1,15);ok(blue.getHealth()>18&&blue.getHealth()<20,"native armor reduces two-HP field pulse");
   fresh();moveBlue(15.5,1,15.5);blue.setGameMode(GameType.CREATIVE);field(15,1,15);ok(blue.getHealth()==20&&!blue.hasEffect(MobEffects.SLOWNESS),"creative observer is excluded");
   fresh();moveBlue(15.5,1,15.5);blue.setGameMode(GameType.SPECTATOR);field(15,1,15);ok(!blue.hasEffect(MobEffects.SLOWNESS),"spectator is excluded");
   fresh();moveBlue(30.5,1,30.5);field(15,1,15);var hidden=fields().getFirst();hidden.removeTag("pvpshot.field");ticks(101);hidden.addTag("pvpshot.field");moveBlue(15.5,1,15.5);ticks(1);
   ok(fields().isEmpty()&&blue.getHealth()==20,"elapsed lifetime is not paused when a field stops being processed");
   field(15,1,15);command("function pvpshot:match/restart");ok(fields().isEmpty(),"new round clears active areas");
   fresh();moveBlue(15.5,1,15.5);blue.setHealth(1);field(15,1,15);ok(blue.isDeadOrDying()&&score(red,"pvpshot.kill_blue")==1,"lethal field pulse credits its original thrower");
   h.succeed();
  });
 }
 public static void main(String[] args)throws Exception{
  SharedConstants.tryDetectVersion();net.minecraft.server.Bootstrap.bootStrap();
  var f=net.minecraft.core.MappedRegistry.class.getDeclaredField("frozen");f.setAccessible(true);f.setBoolean(BuiltInRegistries.TEST_FUNCTION,false);
  Registry.register(BuiltInRegistries.TEST_FUNCTION,Identifier.parse("pvptest:suite"),FieldAudit::suite);
  var t=net.minecraft.core.MappedRegistry.class.getDeclaredField("allTags");t.setAccessible(true);var u=t.getType().getDeclaredMethod("unbound");u.setAccessible(true);t.set(BuiltInRegistries.TEST_FUNCTION,u.invoke(null));BuiltInRegistries.TEST_FUNCTION.freeze();net.minecraft.gametest.Main.main(args);
 }
}
