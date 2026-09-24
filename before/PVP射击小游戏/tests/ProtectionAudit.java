import java.util.*;
import java.nio.file.*;
import net.minecraft.SharedConstants;
import net.minecraft.core.*;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.gametest.framework.GameTestHelper;
import net.minecraft.resources.Identifier;
import net.minecraft.world.entity.EntityTypes;
import net.minecraft.world.entity.item.PrimedTnt;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.state.properties.BlockStateProperties;
import net.minecraft.world.level.block.piston.PistonBaseBlock;
import net.minecraft.world.item.Items;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.phys.Vec3;

/** Real mining, blast, command, container and deployment checks with the server agent. */
public class ProtectionAudit extends TestMain {
 static void ok(boolean test,String label){h.assertTrue(test,label);System.out.println("PASS "+label);}
 static void edit(boolean yes){command("scoreboard players set #protection.edit ustc.clock "+(yes?1:0));}
 static void at(BlockPos p,String action){command("execute positioned "+p.getX()+" "+p.getY()+" "+p.getZ()+" run "+action);}
 static void put(BlockPos p,BlockState state){edit(true);h.getLevel().setBlock(p,state,3);edit(false);}
 static void blast(BlockPos p){var tnt=new PrimedTnt(h.getLevel(),p.getX()+.5,p.getY()+.5,p.getZ()+.5,red);tnt.setNoGravity(true);tnt.setDeltaMovement(Vec3.ZERO);tnt.setFuse(1);h.getLevel().addFreshEntity(tnt);tnt.tick();}
 static void suite(GameTestHelper helper){
  h=helper;command("function pvpshot:load");command("function ustc_pvp:load");
  command("scoreboard players set #protection.active ustc.clock 1");
  command("scoreboard players set #ammo.enabled pvpshot.cfg 0");
  red=player("GuardRed",5,5);blue=player("GuardBlue",5,10);
  as(red,"team join pvpshot.red @s");as(blue,"team join pvpshot.blue @s");
  h.runAtTickTime(15,()->{
   try {
    int checked=0;
    for(String line:Files.readAllLines(Path.of(System.getProperty("pvpshot.protection.regions")))){
     if(line.isBlank()||line.startsWith("#"))continue;
     String[] f=line.split("\\s+");var p=new BlockPos(Integer.parseInt(f[0]),Integer.parseInt(f[1]),Integer.parseInt(f[2]));
     h.getLevel().getChunk(p.getX()>>4,p.getZ()>>4);put(p,Blocks.STONE.defaultBlockState());
     ok(!red.gameMode.destroyBlock(p)&&h.getLevel().getBlockState(p).is(Blocks.STONE),"survival mining protected "+f[6]);
     ok(!h.getLevel().destroyBlock(p,true,red,0),"native destroy protected "+f[6]);
     at(p,"function pvpshot:protection/check");
     ok(value("#protected","pvpshot.cal")==1,"deployment predicate matches region "+f[6]);checked++;
    }
    ok(checked==181,"all 181 facility regions covered");
   }catch(Exception e){throw new RuntimeException(e);}
   var core=new BlockPos(-1990,27,-1535);var base=new BlockPos(-2110,1,-1490);var cache=new BlockPos(-2015,2,-1510);
   put(core,Blocks.GOLD_BLOCK.defaultBlockState());put(base,BuiltInRegistries.BLOCK.getValue(Identifier.parse("minecraft:red_terracotta")).defaultBlockState());
   put(cache,Blocks.TRAPPED_CHEST.defaultBlockState());
   var inventory=(net.minecraft.world.Container)h.getLevel().getBlockEntity(cache);
   inventory.setItem(0,new ItemStack(Items.DIAMOND,11));
   ok(!red.gameMode.destroyBlock(core)&&!red.gameMode.destroyBlock(base)&&!red.gameMode.destroyBlock(cache),"capture core, spawn floor and chest reject mining");
   at(cache,"setblock ~ ~ ~ air");
   at(cache,"fill ~-1 ~-1 ~-1 ~1 ~1 ~1 air replace #pvpshot:destructible");
   ok(h.getLevel().getBlockState(cache).is(Blocks.TRAPPED_CHEST)&&inventory.countItem(Items.DIAMOND)==11,"setblock/fill cannot destroy or empty protected chest");
   command("scoreboard players set #rocket pvpshot.cal 0");at(core,"function pvpshot:shot/block");
   ok(h.getLevel().getBlockState(core).is(Blocks.GOLD_BLOCK),"rifle cannot destroy capture core");
   var exposed=cache.offset(4,0,0);put(exposed,Blocks.STONE.defaultBlockState());
   at(cache,"function pvpshot:rocket/burst");
   ok(h.getLevel().getBlockState(cache).is(Blocks.TRAPPED_CHEST)&&inventory.countItem(Items.DIAMOND)==11,"demolition rocket preserves chest and contents");
   ok(h.getLevel().getBlockState(exposed).isAir(),"same demolition rocket still removes nearby ordinary terrain");
   put(exposed,Blocks.GLASS.defaultBlockState());
   blast(cache.above());
   ok(h.getLevel().getBlockState(cache).is(Blocks.TRAPPED_CHEST)&&inventory.countItem(Items.DIAMOND)==11,"native TNT preserves chest and contents");
   ok(h.getLevel().getBlockState(exposed).isAir(),"native TNT still destroys ordinary nearby terrain");
   ok(h.getLevel().getEntities(EntityTypes.ITEM,e->e.getItem().is(Items.DIAMOND)).isEmpty(),"protected explosion produces no duplicated chest contents");
   blast(core.above());blast(base.above());
   ok(h.getLevel().getBlockState(core).is(Blocks.GOLD_BLOCK)&&h.getLevel().getBlockState(base).is(BuiltInRegistries.BLOCK.getValue(Identifier.parse("minecraft:red_terracotta"))),"native TNT preserves capture and spawn facilities");
   ok(!PistonBaseBlock.isPushable(h.getLevel().getBlockState(core),h.getLevel(),core,Direction.EAST,false,Direction.EAST),"pistons cannot move protected fixtures");
   var taken=inventory.removeItem(0,3);
   ok(taken.getCount()==3&&inventory.countItem(Items.DIAMOND)==8,"normal chest looting still works");
   red.setPos(cache.getX()+.5,cache.getY(),cache.getZ()+1.5);
   var chest=(net.minecraft.world.level.block.entity.ChestBlockEntity)inventory;
   red.openMenu(chest);ok(red.containerMenu!=red.inventoryMenu,"protected chest still opens its native inventory");red.closeContainer();
   at(cache,"function pvpshot:chest/refill_one");
   ok(inventory.countItem(Items.FIREWORK_STAR)==4,"protected chest still refills rewards");
   var button=new BlockPos(-2115,3,-1494);put(button,Blocks.STONE_BUTTON.defaultBlockState());
   boolean changed=h.getLevel().setBlock(button,h.getLevel().getBlockState(button).setValue(BlockStateProperties.POWERED,true),3);
   ok(changed&&h.getLevel().getBlockState(button).getValue(BlockStateProperties.POWERED),"base button properties can change normally");
   var headroom=cache.above();put(headroom,Blocks.AIR.defaultBlockState());
   ok(!h.getLevel().setBlock(headroom,Blocks.STONE.defaultBlockState(),3),"players cannot obstruct protected chest lid clearance");
   red.setPos(-2110.5,2,-1490.5);red.setYRot(0);red.setXRot(0);command("kill @e[tag=pvpshot.machine]");
   as(red,"function pvpshot:deploy/cannon");ok(machines("cannon").isEmpty(),"cannon is rejected before creating a partial structure in base");
   as(red,"function pvpshot:deploy/turret");ok(machines("turret").isEmpty(),"turret is rejected before creating a partial structure in base");
   var ordinary=new BlockPos(-2050,1,-1450);h.getLevel().getChunk(ordinary.getX()>>4,ordinary.getZ()>>4);put(ordinary,Blocks.STONE.defaultBlockState());
   as(red,"item replace entity @s weapon.mainhand with iron_pickaxe");
   ok(red.gameMode.destroyBlock(ordinary)&&h.getLevel().getBlockState(ordinary).isAir(),"ordinary terrain remains mineable");
   // The existing official reset path must be allowed to restore protected cells.
   command("scoreboard players set #reset.active ustc.clock 1");
   ok(h.getLevel().setBlock(core,Blocks.AIR.defaultBlockState(),3),"terrain reset may modify protected blocks");
   command("scoreboard players set #reset.active ustc.clock 0");put(core,Blocks.GOLD_BLOCK.defaultBlockState());
   ok(!h.getLevel().destroyBlock(core,false,red,0),"protection returns immediately after reset");
   edit(true);ok(h.getLevel().setBlock(core,Blocks.AIR.defaultBlockState(),3),"explicit map maintenance can repair fixtures");
   edit(false);put(core,Blocks.GOLD_BLOCK.defaultBlockState());
   ok(value("#protection.edit","ustc.clock")==0,"maintenance does not leave protection disabled");
   h.succeed();
  });
 }
 static int value(String who,String objective){var sb=h.getLevel().getServer().getScoreboard();var s=sb.getPlayerScoreInfo(net.minecraft.world.scores.ScoreHolder.forNameOnly(who),sb.getObjective(objective));return s==null?0:s.value();}
 public static void main(String[] args)throws Exception{
  SharedConstants.tryDetectVersion();net.minecraft.server.Bootstrap.bootStrap();
  var f=net.minecraft.core.MappedRegistry.class.getDeclaredField("frozen");f.setAccessible(true);f.setBoolean(BuiltInRegistries.TEST_FUNCTION,false);
  Registry.register(BuiltInRegistries.TEST_FUNCTION,Identifier.parse("pvptest:suite"),ProtectionAudit::suite);
  var t=net.minecraft.core.MappedRegistry.class.getDeclaredField("allTags");t.setAccessible(true);var u=t.getType().getDeclaredMethod("unbound");u.setAccessible(true);t.set(BuiltInRegistries.TEST_FUNCTION,u.invoke(null));BuiltInRegistries.TEST_FUNCTION.freeze();net.minecraft.gametest.Main.main(args);
 }
}
