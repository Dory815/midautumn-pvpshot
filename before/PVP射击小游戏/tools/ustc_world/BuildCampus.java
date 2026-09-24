import java.util.*;
import java.nio.file.*;
import net.minecraft.SharedConstants;
import net.minecraft.core.BlockPos;
import net.minecraft.core.Registry;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.resources.Identifier;
import net.minecraft.gametest.framework.GameTestHelper;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.entity.EntityTypes;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.entity.ChestBlockEntity;
import net.minecraft.world.level.storage.LevelResource;
import net.minecraft.world.scores.ScoreHolder;
import net.minecraft.world.entity.ai.attributes.Attributes;
import net.minecraft.world.phys.Vec3;

/** Builds only a dedicated disposable GameTest world from read-only region copies. */
public class BuildCampus extends TestMain {
    static final int[][] points={{-1990,28,-1535},{-1857,2,-1541},{-1710,29,-1535},{-1676,2,-1660},{-2080,2,-1378}};
    static final int[][] gym={{-1930,2,-1310},{-1865,2,-1300},{-1790,2,-1300},{-1760,2,-1260},{-1760,2,-1190},{-1835,2,-1180},{-1910,2,-1190},{-1955,2,-1260}};
    static ServerPlayer visitor;
    static boolean finished;
    static int initialPreset;
    static float originalSpeed;
    static void require(boolean ok,String text) {h.assertTrue(ok,text);System.out.println("PASS "+text);}
    static int value(String who,String objective) {
        var sb=h.getLevel().getServer().getScoreboard();var s=sb.getPlayerScoreInfo(ScoreHolder.forNameOnly(who),sb.getObjective(objective));return s==null?0:s.value();
    }
    static int markerCount(String tag) {return h.getLevel().getEntities(EntityTypes.MARKER,e->e.entityTags().contains(tag)).size();}
    static boolean block(int x,int y,int z,String id) {return h.getLevel().getBlockState(new BlockPos(x,y,z)).is(BuiltInRegistries.BLOCK.getValue(Identifier.parse("minecraft:"+id)));}
    static void importedRegions() throws Exception {
        Path source=Path.of(System.getProperty("ustc.source")).toRealPath();
        Path world=h.getLevel().getServer().getWorldPath(LevelResource.ROOT).toAbsolutePath().normalize();
        require(!world.startsWith(source) && !source.startsWith(world),"source and temporary output are disjoint");
        for(String sub:List.of("region","entities","poi"))for(int rx=-5;rx<=-4;rx++)for(int rz=-4;rz<=-3;rz++){
            String name="r."+rx+"."+rz+".mca";Path from=source.resolve("dimensions/minecraft/overworld/"+sub+"/"+name);
            if(!Files.isRegularFile(from))continue;
            Path to=world.resolve("dimensions/minecraft/overworld/"+sub+"/"+name);Files.createDirectories(to.getParent());Files.copy(from,to,StandardCopyOption.REPLACE_EXISTING);
            if(sub.equals("region")){
                Path snapshot=world.resolve("dimensions/ustc_pvp/template/region/"+name);Files.createDirectories(snapshot.getParent());Files.copy(from,snapshot,StandardCopyOption.REPLACE_EXISTING);
            }
        }
        System.out.println("IMPORTED CAMPUS INTO "+world);
    }
    static void suite(GameTestHelper helper) {
        h=helper;
        try {importedRegions();}catch(Exception e){throw new RuntimeException(e);}
        System.out.println("LEVELS "+h.getLevel().getServer().levelKeys());
        try {for(String line:Files.readAllLines(Path.of(System.getProperty("ustc.pack")).resolve("data/ustc_pvp/function/anchors.mcfunction"))){
            var parts=line.split(" ");h.getLevel().getChunk(Integer.parseInt(parts[2])>>4,Integer.parseInt(parts[3])>>4);
        }}catch(Exception e){throw new RuntimeException(e);}
        for(int[] p:points)h.getLevel().getChunk(p[0]>>4,p[2]>>4);
        for(int[] p:gym)h.getLevel().getChunk(p[0]>>4,p[2]>>4);
        for(int[] p:new int[][]{{-2110,2,-1490},{-1590,2,-1525},{-2130,9,-1800}})h.getLevel().getChunk(p[0]>>4,p[2]>>4);
        require(block(-2035,1,-1545,"exposed_cut_copper"),"actual campus geometry imported before build");
        command("function ustc_pvp:load");command("function ustc_pvp:build");
        h.runAtTickTime(15,()->{
            require(markerCount("ustc.point")==5 && markerCount("pvpshot.point")==5,"five physical points and five active scoring markers");
            require(markerCount("pvpshot.spawn.red")==3 && markerCount("pvpshot.spawn.blue")==3,"both bases have three safe spawn positions");
            require(markerCount("ustc.gym")==8 && markerCount("pvpshot.chest")==80,"eight gym caches plus seventy-two field caches");
            for(int[] p:gym){
                var pos=new BlockPos(p[0],p[1],p[2]);
                require(h.getLevel().getBlockEntity(pos) instanceof ChestBlockEntity chest && !chest.isEmpty(),"stocked gym chest "+pos);
                require(h.getLevel().getBlockState(pos.above()).isAir(),"gym chest lid clearance "+pos);
            }
            for(var marker:machines("chest")){
                var chest=(net.minecraft.world.Container)h.getLevel().getBlockEntity(marker.blockPosition());
                int rockets=marker.entityTags().contains("ustc.gym")?6:4;
                require(chest!=null && chest.countItem(net.minecraft.world.item.Items.FIREWORK_STAR)==rockets,"supply rockets="+rockets+" at "+marker.blockPosition());
                require(h.getLevel().getBlockState(marker.blockPosition().above()).isAir(),"all 80 cache lids can open "+marker.blockPosition());
            }
            require(value("#arena.auto","pvpshot.cfg")==0 && value("#discover.enabled","pvpshot.cfg")==0,"campus disables automatic structures and block discovery");
            require(value("#cap.max","pvpshot.cfg")==1000,"five-point victory target 1000");
            for(int[] p:points)require(block(p[0],p[1]-1,p[2],"beacon"),"physical flag core "+Arrays.toString(p));
            visitor=player("CampusTest",5,5);
        });
        h.runAtTickTime(20,()->{
            require(Math.abs(visitor.getX()+2129.5)<.01 && visitor.getY()==9,"new arrival is routed to staging lobby");
            as(visitor,"trigger ustc.join set 1");
        });
        h.runAtTickTime(23,()->{
            require(visitor.getTeam()!=null && visitor.getTeam().getName().equals("pvpshot.red"),"ordinary join trigger selects red team");
            require(Math.abs(visitor.getX()+2109.5)<.01 && visitor.getY()==2,"red join places player at base");
            require(h.getLevel().noCollision(visitor,visitor.getBoundingBox()),"red spawn has player clearance");
            require(count(visitor,"red_terracotta")==64 && count(visitor,"blaze_powder")==16 && count(visitor,"slime_ball")==1 && count(visitor,"firework_star")==1,"campus life includes clay, base weapon, grenade and one rocket");
            require(!visitor.hasEffect(net.minecraft.world.effect.MobEffects.JUMP_BOOST) && !visitor.hasEffect(net.minecraft.world.effect.MobEffects.SPEED),"joining grants neither free jump nor speed");
            as(visitor,"function ustc_pvp:kit");
            require(count(visitor,"red_dye")==16 && count(visitor,"orange_dye")==16 && count(visitor,"red_terracotta")==64,"test resupply provides both deployables and team blocks");
            as(visitor,"function ustc_pvp:join_blue");
            require(visitor.getTeam().getName().equals("pvpshot.blue") && count(visitor,"blue_terracotta")==64,"blue join recolors the building stack");
            require(h.getLevel().noCollision(visitor,visitor.getBoundingBox()),"blue spawn has player clearance");
            command("function ustc_pvp:preset/three");
            require(markerCount("pvpshot.point")==3 && value("#cap.max","pvpshot.cfg")==600,"three-point preset activates only ABC and uses 600 target");
            command("function ustc_pvp:preset/deathmatch");
            require(markerCount("pvpshot.point")==0 && value("#mode","pvpshot.cfg")==0,"deathmatch has no active capture points");
            command("function ustc_pvp:preset/five");
            require(markerCount("pvpshot.point")==5 && value("#match.state","pvpshot.cal")==1,"five-point preset restarts independently");
            command("function ustc_pvp:preset/three");
            for(int index:new int[]{0,2}){
                int[] point=points[index];String key=index==0?"A":"C";
                as(visitor,"team join pvpshot.red @s");visitor.setPos(point[0]+2.5,2,point[2]+.5);
                for(int i=0;i<105;i++)command("function pvpshot:point/tick_all");
                var flag=h.getLevel().getEntities(EntityTypes.MARKER,e->e.entityTags().contains("ustc.point."+key)).getFirst();
                var board=h.getLevel().getScoreboard();require(board.getPlayerScoreInfo(flag,board.getObjective("pvpshot.owner")).value()==0,"ground floor cannot capture rooftop "+key);
                visitor.setPos(point[0]+2.5,point[1],point[2]+.5);for(int i=0;i<100;i++)command("function pvpshot:point/tick_all");
                require(board.getPlayerScoreInfo(flag,board.getObjective("pvpshot.owner")).value()==1,"actual roof surface captures "+key);
                as(visitor,"function pvpshot:player/respawn");require(visitor.getY()==point[1]&&h.getLevel().noCollision(visitor,visitor.getBoundingBox()),"owned roof gives clear safe respawn "+key);
                command("execute as @e[tag=ustc.point."+key+"] at @s run function pvpshot:point/reset");
                var rider=player("Launch"+key,5,5);
                rider.setPos(point[0]+.5,2,-1567.5);rider.setOnGround(true);rider.doTick();
                require(rider.getDeltaMovement().y>=3&&rider.hasEffect(net.minecraft.world.effect.MobEffects.SLOW_FALLING),"native launcher sends upward impulse and safety slow falling "+key);
                rider.setPos(point[0]+.5,point[1]+2.1,-1567.5);rider.setOnGround(false);rider.doTick();
                require(rider.getDeltaMovement().z>2,"launcher pushes toward roof after clearing the facade "+key);
                require(block(point[0],-1,-1560,"bedrock")&&block(point[0],0,-1560,"water")&&block(point[0],1,-1560,"water"),"two-block-deep landing pool exists "+key);
                rider.setDeltaMovement(Vec3.ZERO);
                h.getLevel().getServer().getPlayerList().remove(rider);
            }
            for(var cache:h.getLevel().getEntities(EntityTypes.MARKER,e->e.entityTags().contains("ustc.advanced"))){
                double r=cache.position().distanceTo(new Vec3(-2110,2,-1490)),bDist=cache.position().distanceTo(new Vec3(-1590,2,-1525));
                require(Math.abs(r-bDist)<2,"independent advanced crate has near-equal base distance "+cache.blockPosition());
                require(h.getLevel().getEntities(EntityTypes.MARKER,e->e.entityTags().contains("ustc.point")&&e.distanceTo(cache)<50).isEmpty(),"advanced crate is outside every capture location");
            }
            // At B on the ground the player captures; six blocks above must not.
            as(visitor,"team join pvpshot.red @s");visitor.setPos(-1856.5,8,-1540.5);
            for(int i=0;i<110;i++)command("function pvpshot:point/tick_all");
            var b=h.getLevel().getEntities(EntityTypes.MARKER,e->e.entityTags().contains("ustc.point.B")).getFirst();
            var sb=h.getLevel().getServer().getScoreboard();
            require(sb.getPlayerScoreInfo(b,sb.getObjective("pvpshot.capture")).value()==0,"upstairs player cannot capture ground-level point");
            visitor.setPos(-1856.5,2,-1540.5);
            for(int i=0;i<100;i++)command("function pvpshot:point/tick_all");
            require(sb.getPlayerScoreInfo(b,sb.getObjective("pvpshot.owner")).value()==1,"ground-level player captures real campus B");
            as(visitor,"function pvpshot:player/respawn");
            require(visitor.position().distanceTo(new Vec3(-1856.5,2,-1540.5))<12,"owned B offers a safe forward respawn");
            var enemy=player("SpawnEnemy",5,5);as(enemy,"team join pvpshot.blue @s");enemy.setPos(-1856.5,2,-1540.5);
            as(visitor,"function pvpshot:player/respawn");require(Math.abs(visitor.getX()+2109.5)<.01,"enemy near owned point forces base fallback");
            h.getLevel().getServer().getPlayerList().remove(enemy);
            command("scoreboard players set @e[tag=ustc.point.B] pvpshot.owner 2");as(visitor,"function pvpshot:player/respawn");require(Math.abs(visitor.getX()+2109.5)<.01,"captured enemy point cannot be used to respawn");
            command("function ustc_pvp:preset/deathmatch");as(visitor,"function pvpshot:player/respawn");require(Math.abs(visitor.getX()+2109.5)>.01,"deathmatch uses dispersed fixed respawns");
            command("function ustc_pvp:preset/three");
            require(markerCount("ustc.forward")==30 && markerCount("ustc.advanced")==2,"30 spawn candidates and two separate advanced caches");
            command("scoreboard players set #advanced.timer ustc.clock 10");command("function ustc_pvp:refill");require(value("#advanced.timer","ustc.clock")==10,"ordinary refill does not reset advanced-cache timer");
            command("scoreboard players set #advanced.timer ustc.clock 299");command("function ustc_pvp:advanced/second");require(value("#advanced.timer","ustc.clock")==0,"advanced crates refill every 300 seconds");
            var dropped=new net.minecraft.world.entity.item.ItemEntity(h.getLevel(),-1857,3,-1541,new net.minecraft.world.item.ItemStack(net.minecraft.world.item.Items.DIRT));
            require(!h.getLevel().addFreshEntity(dropped),"battlefield drops are rejected before entity insertion");

            command("function ustc_pvp:hud");
            require(h.getLevel().getServer().getCustomBossEvents().get(Identifier.parse("ustc_pvp:points")).getPlayers().contains(visitor),"top point status bar is visible");
            as(visitor,"clear @s");
            as(visitor,"function ustc_pvp:kit");
            as(visitor,"function ustc_pvp:control/five");
            require(!visitor.getInventory().isEmpty() && value("#test.controls","pvpshot.cfg")==1 && value("#preset","ustc.clock")==5,"public controls allow ordinary resupply and mode selection");
            as(visitor,"function ustc_pvp:control/three");
            command("scoreboard players set #reset.cooldown ustc.clock 5");
            as(visitor,"function ustc_pvp:reset/request");
            require(value("#reset.active","ustc.clock")==0,"public reset respects cooldown");
            command("scoreboard players set #reset.cooldown ustc.clock 0");
            command("function ustc_pvp:mobility/profile_0");visitor.setSprinting(true);visitor.doTick();
            double normal=visitor.getAttributeValue(Attributes.MOVEMENT_SPEED);
            command("function ustc_pvp:mobility/profile_1");visitor.doTick();double speed=visitor.getAttributeValue(Attributes.MOVEMENT_SPEED);
            require(Math.abs(speed/normal-1.0)<.001,"default movement leaves native running speed unchanged");
            System.out.println("MOVEMENT native sprint attribute normal="+normal+" default="+speed);
            as(visitor,"loot replace entity @s weapon.mainhand loot pvpshot:item/speed");
            visitor.getMainHandItem().finishUsingItem(h.getLevel(),visitor);
            require(visitor.getEffect(net.minecraft.world.effect.MobEffects.SPEED).getAmplifier()==4 && visitor.getEffect(net.minecraft.world.effect.MobEffects.SPEED).getDuration()==900,"reward potion grants Speed V for 45 seconds");
            as(visitor,"function ustc_pvp:mobility/apply");
            require(visitor.hasEffect(net.minecraft.world.effect.MobEffects.SPEED),"jump refresh does not remove earned speed");
            as(visitor,"effect clear @s minecraft:speed");
            visitor.setSprinting(false);
            for(int profile=0;profile<=2;profile++){
                as(visitor,"effect clear @s minecraft:jump_boost");
                if(profile>0)as(visitor,"effect give @s minecraft:jump_boost 10 "+(profile-1)+" true");
                visitor.setDeltaMovement(Vec3.ZERO);visitor.setOnGround(true);visitor.jumpFromGround();
                System.out.println("MOVEMENT jump amplifier level="+profile+" initialY="+visitor.getDeltaMovement().y);
            }
            as(visitor,"effect clear @s");visitor.setDeltaMovement(Vec3.ZERO);
            require(!visitor.hasEffect(net.minecraft.world.effect.MobEffects.SPEED)&&!visitor.hasEffect(net.minecraft.world.effect.MobEffects.JUMP_BOOST),"comparison controls return to standard movement");
            command("function ustc_pvp:mobility/profile_1");
            as(visitor,"kill @s");
        });
        h.runAtTickTime(26,()->{
            require(visitor.isDeadOrDying(),"mobility test performs real player death");
            visitor=h.getLevel().getServer().getPlayerList().respawn(visitor,false,net.minecraft.world.entity.Entity.RemovalReason.KILLED);
            visitor.connection.handleAcceptPlayerLoad(new net.minecraft.network.protocol.game.ServerboundPlayerLoadedPacket());
        });
        h.runAtTickTime(100,()->{
            for(int[] point:points){
                var beacon=(net.minecraft.world.level.block.entity.BeaconBlockEntity)h.getLevel().getBlockEntity(new BlockPos(point[0],point[1]-1,point[2]));
                require(beacon!=null&&!beacon.getBeamSections().isEmpty(),"native beacon produces visible sky beam "+Arrays.toString(point));
            }
        });
        h.runAtTickTime(128,()->{
            require(!visitor.hasEffect(net.minecraft.world.effect.MobEffects.JUMP_BOOST),"actual respawn does not restore removed default jump");
            require(!visitor.hasEffect(net.minecraft.world.effect.MobEffects.SPEED),"no free speed after actual respawn");
            // Reset must restore native campus blocks and remove placed building material.
            command("scoreboard players set #protection.edit ustc.clock 1");
            command("setblock -1857 1 -1541 air");command("setblock -2050 3 -1400 red_terracotta");
            command("setblock -1930 2 -1310 air");command("scoreboard players set Red pvpshot.score 50");
            command("scoreboard players set #protection.edit ustc.clock 0");
            command("execute positioned -1856.5 2 -1540.5 run function pvpshot:field/create");
            require(markerCount("pvpshot.field")==1,"active frost field exists before reset");
            as(visitor,"trigger pvp_reset");
        });
        h.runAtTickTime(131,()->{
            require(value("#reset.active","ustc.clock")==1 && value("#test.controls","pvpshot.cfg")==1,"ordinary player trigger starts restoration with public controls");
            require(markerCount("pvpshot.field")==0,"terrain reset immediately clears frost fields");
            int batch=value("#reset.index","ustc.clock");
            as(visitor,"function ustc_pvp:reset/request");command("function ustc_pvp:reset/start");
            require(value("#reset.index","ustc.clock")==batch,"repeated reset requests preserve in-progress batch");
        });
        h.onEachTick(()->{
            if(h.getTick()<131 || finished)return;
            if(h.getTick()%100==0)System.out.println("RESET PROGRESS "+value("#reset.index","ustc.clock")+"/176 tick="+h.getTick());
            if(value("#reset.active","ustc.clock")==0 && value("#reset.index","ustc.clock")>=176){
                finished=true;
                require(block(-1857,-1,-1541,"bedrock") && block(-2050,-1,-1400,"bedrock"),"reset lays and preserves immutable foundation under combat terrain");
                require(value("#reset.errors","ustc.clock")==0,"all native cross-dimension clone batches completed");
                require(block(-1857,1,-1541,"beacon"),"core reset rebuilds the damaged capture core");
                require(block(-2050,3,-1400,"air"),"core reset removes player-placed building blocks");
                require(block(-1930,2,-1310,"trapped_chest"),"core reset restores the destroyed gym cache");
                require(markerCount("ustc.point")==5 && markerCount("pvpshot.point")==3,"reset preserves chosen three-point preset without duplicate points");
                require(markerCount("pvpshot.chest")==80,"reset has exactly 80 supply markers, actual="+markerCount("pvpshot.chest"));
                require(markerCount("ustc.launch")==2&&block(-1990,1,-1560,"water")&&block(-1710,1,-1560,"water"),"reset restores launch pads and landing pools");
                require(markerCount("ustc.forward")==30&&markerCount("ustc.advanced")==2,"reset restores forward spawns and special crates without duplicates");
                require(value("Red","pvpshot.score")==0 && value("Blue","pvpshot.score")==0,"reset clears scores");
                require(count(visitor,"red_terracotta")==64 && visitor.getHealth()==20,"reset returns player equipped and healed");
                require(value("#match.state","pvpshot.cal")==1,"reset reopens match scoring");
                require(value("#test.controls","pvpshot.cfg")==1,"reset preserves public control access");
                as(visitor,"function ustc_pvp:reset/request");
                require(value("#reset.active","ustc.clock")==0 && value("#reset.index","ustc.clock")==176,"completed reset cooldown prevents an immediate second reset");
                command("function ustc_pvp:preset/five");
                command("function ustc_pvp:mobility/profile_1");
                require(!visitor.hasEffect(net.minecraft.world.effect.MobEffects.JUMP_BOOST),"default spawn does not grant jump boost");
                command("team leave CampusTest");h.getLevel().getServer().getPlayerList().remove(visitor);command("scoreboard players reset CampusTest");
                require(value("#mobility.speed","pvpshot.cfg")==0 && value("#mobility.jump","pvpshot.cfg")==0,"release starts without default mobility buffs");
                h.succeed();
            }
        });
    }
    public static void main(String[] args)throws Exception{
        SharedConstants.tryDetectVersion();net.minecraft.server.Bootstrap.bootStrap();
        var frozen=net.minecraft.core.MappedRegistry.class.getDeclaredField("frozen");frozen.setAccessible(true);frozen.setBoolean(BuiltInRegistries.TEST_FUNCTION,false);
        Registry.register(BuiltInRegistries.TEST_FUNCTION,Identifier.parse("campusbuild:suite"),BuildCampus::suite);
        var tags=net.minecraft.core.MappedRegistry.class.getDeclaredField("allTags");tags.setAccessible(true);var unbound=tags.getType().getDeclaredMethod("unbound");unbound.setAccessible(true);tags.set(BuiltInRegistries.TEST_FUNCTION,unbound.invoke(null));BuiltInRegistries.TEST_FUNCTION.freeze();net.minecraft.gametest.Main.main(args);
    }
}
