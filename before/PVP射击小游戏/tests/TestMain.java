import java.util.*;
import com.mojang.authlib.GameProfile;
import io.netty.channel.embedded.EmbeddedChannel;
import net.minecraft.SharedConstants;
import net.minecraft.core.Registry;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.resources.Identifier;
import net.minecraft.gametest.framework.GameTestHelper;
import net.minecraft.server.level.*;
import net.minecraft.server.network.CommonListenerCookie;
import net.minecraft.network.Connection;
import net.minecraft.network.protocol.PacketFlow;
import net.minecraft.world.level.GameType;
import net.minecraft.world.entity.*;
import net.minecraft.world.entity.projectile.throwableitemprojectile.*;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.entity.item.PrimedTnt;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.entity.DispenserBlockEntity;
import net.minecraft.core.BlockPos;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.phys.*;

public class TestMain {
    static GameTestHelper h;
    static ServerPlayer red, blue;
    static void command(String s) {
        var server = h.getLevel().getServer();
        server.getCommands().performPrefixedCommand(server.createCommandSourceStack().withLevel(h.getLevel()), s);
    }
    static void as(ServerPlayer p, String s) {
        var server = h.getLevel().getServer();
        server.getCommands().performPrefixedCommand(server.createCommandSourceStack().withLevel(h.getLevel()).withEntity(p).withPosition(p.position()), s);
    }
    static ServerPlayer player(String name, int x, int z) {
        var profile = new GameProfile(UUID.randomUUID(), name);
        var p = new ServerPlayer(h.getLevel().getServer(), h.getLevel(), profile, ClientInformation.createDefault());
        var connection = new Connection(PacketFlow.SERVERBOUND);
        new EmbeddedChannel(connection);
        h.getLevel().getServer().getPlayerList().placeNewPlayer(connection, p, CommonListenerCookie.createInitial(profile, false));
        p.connection.handleAcceptPlayerLoad(new net.minecraft.network.protocol.game.ServerboundPlayerLoadedPacket());
        p.setGameMode(GameType.SURVIVAL);
        p.setPos(h.absoluteVec(new Vec3(x + .5, 1, z + .5)));
        p.setNoGravity(true);
        as(p, "scoreboard players set @s pvpshot.init 1");
        as(p, "scoreboard players set @s pvpshot.deaths 0");
        as(p, "scoreboard players set @s pvpshot.deaths_old 0");
        as(p, "scoreboard players set @s pvpshot.kills 0");
        as(p, "scoreboard players set @s pvpshot.kills_old 0");
        return p;
    }
    static void reset() {
        blue.setHealth(20); blue.invulnerableTime = 0; blue.clearFire();
        blue.stopUsingItem();
        blue.setDeltaMovement(Vec3.ZERO);
        as(blue, "effect clear @s");
        as(blue, "clear @s");
        blue.doTick();
        blue.setPos(h.absoluteVec(new Vec3(5.5,1,9.5)));
    }
    static void hit(String weapon, boolean custom) {
        hit(weapon,custom,1.6);
    }
    static void hit(String weapon, boolean custom,double height) {
        as(red, "item replace entity @s weapon.mainhand with minecraft:" + weapon + (custom ? "[minecraft:custom_data={pvpshot:{weapon:\"" + weapon + "\"}}]" : ""));
        var b = weapon.equals("snowball") ? new Snowball(h.getLevel(), red, red.getMainHandItem().copy()) : new ThrownEgg(h.getLevel(), red, red.getMainHandItem().copy());
        b.setPos(blue.position().add(0,height,-1)); b.setDeltaMovement(0,0,1.5); h.getLevel().addFreshEntity(b);
        command("function pvpshot:combat/proj_tick");
        b.discard();
    }
    static void spawnWeapon(String weapon,double distance) {
        as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/"+weapon);
        if(weapon.equals("egg"))as(red,"item replace entity @s weapon.mainhand with egg[custom_data={pvpshot:{weapon:\"egg\"}},enchantments={\"pvpshot:egg_hit\":1}]");
        var item=red.getMainHandItem().copy();
        var b=weapon.equals("snowball") ? new Snowball(h.getLevel(),red,item) : new ThrownEgg(h.getLevel(),red,item);
        b.setPos(blue.position().add(0,1.6,-distance));b.setDeltaMovement(0,0,1.5);
        net.minecraft.world.entity.projectile.Projectile.spawnProjectile(b,h.getLevel(),item);
    }
    static int enchant(ItemStack item,String id) {
        var e=item.getEnchantments();
        return e.keySet().stream().filter(k->k.is(Identifier.parse("minecraft:"+id))).findFirst().map(e::getLevel).orElse(0);
    }
    static void health(float expected, String label) {
        h.assertTrue(Math.abs(blue.getHealth() - expected) < .001, label + ": expected=" + expected + " actual=" + blue.getHealth());
        System.out.println("PASS " + label + " health=" + blue.getHealth());
    }
    static float nativeOpenDamage;
    static void nativeBlast(ServerPlayer owner) {
        Vec3 v=blue.position().add(0,0,5);
        var tnt=new PrimedTnt(h.getLevel(),v.x,v.y,v.z,owner);
        tnt.setNoGravity(true);tnt.setDeltaMovement(Vec3.ZERO);tnt.setFuse(2);h.getLevel().addFreshEntity(tnt);
    }
    static void nativeReset() {
        reset();as(blue,"attribute @s minecraft:max_health base set 200");blue.doTick();blue.setHealth(200);
        blue.setPos(h.absoluteVec(new Vec3(5,1,9.5)));
    }
    static void upwardThrow(String weapon) {
        as(blue,"loot replace entity @s weapon.mainhand loot pvpshot:item/"+weapon);
        var item=blue.getMainHandItem().copy();
        var b=weapon.equals("snowball") ? new Snowball(h.getLevel(),blue,item) : new ThrownEgg(h.getLevel(),blue,item);
        b.setPos(blue.position().add(0,1.5,0));b.setDeltaMovement(0,1,0);
        net.minecraft.world.entity.projectile.Projectile.spawnProjectile(b,h.getLevel(),item);
        health(20,"fresh "+weapon+" does not hit its launcher immediately");
        h.assertTrue(b.getDeltaMovement().equals(new Vec3(0,1,0)),"throwable velocity unchanged by custom effects");
    }
    static List<net.minecraft.world.entity.Marker> machines(String kind) {
        return new ArrayList<>(h.getLevel().getEntities(EntityTypes.MARKER,e->e.entityTags().contains("pvpshot."+kind)));
    }
    static List<net.minecraft.world.entity.Marker> deployed=new ArrayList<>();
    static List<net.minecraft.world.entity.Marker> turrets=new ArrayList<>();
    static Vec3 offset(Entity marker, double x,double y,double z) {
        double a=Math.toRadians(marker.getYRot());
        return marker.position().add(x*Math.cos(a)-z*Math.sin(a),y,x*Math.sin(a)+z*Math.cos(a));
    }
    static void deploy(String kind, float yaw, int x,int z) {
        red.setPos(h.absoluteVec(new Vec3(x+.5,1,z+.5)));
        red.setYRot(yaw);red.setXRot(75);
        as(red,"function pvpshot:deploy/"+kind);
    }
    static int count(ServerPlayer player,String item) {
        var type=BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:"+item));
        int n=0;for(int i=0;i<player.getInventory().getContainerSize();i++) {var stack=player.getInventory().getItem(i);if(stack.is(type))n+=stack.getCount();}return n;
    }
    static int score(ServerPlayer player,String objective) {
        var sb=h.getLevel().getServer().getScoreboard();var v=sb.getPlayerScoreInfo(player,sb.getObjective(objective));return v==null?0:v.value();
    }
    static int droppedSnowballs() {
        return h.getLevel().getEntities(EntityTypes.ITEM,e->e.getItem().is(BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:blaze_powder")))).size();
    }
    static PrimedTnt grenade;
    static float hurtHealth;
    static int droppedBefore;
    static void drainMagazine() {
        for(int i=0;i<16;i++) {
            h.assertTrue(red.getMainHandItem().is(BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:blaze_powder"))),"base rifle uses a non-igniting carrier");
            red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);
            red.doTick();red.doTick();red.doTick();
        }
        command("kill @e[tag=pvpshot.shot]");
        h.assertTrue(count(red,"blaze_powder")==0,"sixteen actual uses empty magazine");
    }
    static void suite(GameTestHelper helper) {
        h = helper;
        command("function pvpshot:load");
        command("scoreboard players set #mode pvpshot.cfg 0");
        command("scoreboard players set #regen.enabled pvpshot.cfg 0");
        command("scoreboard players set #ammo.enabled pvpshot.cfg 0");
        red = player("PvpTestRed", 5, 5); blue = player("PvpTestBlue", 5, 9);
        as(red, "team join pvpshot.red @s"); as(blue, "team join pvpshot.blue @s");
        h.runAtTickTime(69, () -> {
            as(blue,"attribute @s minecraft:max_health base set 10");blue.setHealth(10);
            as(blue,"scoreboard players reset @s pvpshot.hp_set");
        });
        h.runAtTickTime(70, () -> {
            blue.doTick();
            h.assertTrue(blue.getMaxHealth()==20 && blue.getHealth()==20,"returning old 10 HP player migrates to 20 HP max="+blue.getMaxHealth()+" hp="+blue.getHealth());
            System.out.println("PASS existing player health migrates to 20 HP");
            as(red,"clear @s");as(red,"loot give @s loot pvpshot:item/bow");as(red,"loot give @s loot pvpshot:item/crossbow");
            ItemStack bow=null,crossbow=null;
            for(int i=0;i<red.getInventory().getContainerSize();i++) {
                var item=red.getInventory().getItem(i);
                if(item.is(BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:bow"))))bow=item;
                if(item.is(BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:crossbow"))))crossbow=item;
            }
            h.assertTrue(bow!=null && enchant(bow,"power")==0,"bow uses distance damage without Power double counting");
            h.assertTrue(crossbow!=null && enchant(crossbow,"quick_charge")==0 && enchant(crossbow,"piercing")==0,"crossbow has no quick charge or piercing");
            h.assertTrue(net.minecraft.world.item.CrossbowItem.getChargeDuration(crossbow,red)==60,"crossbow native charge duration 60 ticks");
            System.out.println("PASS bow/crossbow enchantments and native 3 second charge");
            reset(); hit("egg", true); health(17, "egg 3 swept head hit");
            hit("egg",true);health(14,"successive hits are not eaten by hurt cooldown");
            reset(); hit("snowball", false); health(20, "vanilla snowball unchanged");
            reset(); hit("egg", false); health(20, "vanilla egg unchanged");
            command("scoreboard players set #dmg.egg pvpshot.cfg 7");
            reset(); hit("egg", true); health(13, "configured damage 7");
            command("scoreboard players set #dmg.egg pvpshot.cfg 3");
            reset(); as(blue,"team join pvpshot.red @s"); hit("egg",true); health(17,"friendly fire enabled");
            command("team modify pvpshot.red friendlyFire false");reset();hit("egg",true);health(20,"optional friendly-fire protection");command("team modify pvpshot.red friendlyFire true");
            as(blue,"team join pvpshot.blue @s");
            reset(); as(blue,"effect give @s minecraft:resistance 2 4 true"); hit("egg",true); health(20,"spawn resistance");
            reset(); as(blue,"item replace entity @s armor.chest with minecraft:diamond_chestplate");blue.doTick();
        });
        h.runAtTickTime(72,()->{
            hit("egg",true);
            h.assertTrue(blue.getHealth()>17 && blue.getHealth()<20,"armor reduces base damage actual="+blue.getHealth());
            System.out.println("PASS armor health="+blue.getHealth());
            reset();
spawnWeapon("egg",.4);health(17,"point-blank egg spawn hook");
            reset();blue.setSwimming(true);blue.setPose(Pose.SWIMMING);
            hit("egg",true);health(20,"shot above swimming player misses");
            hit("egg",true,.3);health(17,"swimming hitbox");
            blue.setSwimming(false);blue.setPose(Pose.STANDING);reset();
        });
        h.runAtTickTime(73,()->{
            reset();spawnWeapon("egg",5);
        });
        h.runAtTickTime(79,()->{
            health(17,"moving projectile ticks hit exactly once");
            reset();
            as(blue,"item replace entity @s weapon.mainhand with minecraft:shield");
            blue.setYRot(180);blue.startUsingItem(InteractionHand.MAIN_HAND);for(int i=0;i<6;i++)blue.doTick();
        });
        h.runAtTickTime(85,()->{
            hit("egg",true);health(20,"shield blocks projectile");
            reset();
            h.setBlock(5,2,8,Blocks.STONE);hit("egg",true);health(20,"projectile wall occlusion");h.setBlock(5,2,8,Blocks.AIR);
            reset();blue.setHealth(3);hit("egg",true);health(0,"lethal projectile");
        });
        h.runAtTickTime(87,()->{
            var sb=h.getLevel().getServer().getScoreboard();
            h.assertTrue(sb.getPlayerScoreInfo(red,sb.getObjective("pvpshot.kills")).value()==1,"killer attribution");
            System.out.println("PASS kill attributed to thrower");
            h.assertTrue(sb.getPlayerScoreInfo(net.minecraft.world.scores.ScoreHolder.forNameOnly("Red"),sb.getObjective("pvpshot.score")).value()==1,"enemy projectile kill adds one team point");
            h.assertTrue(sb.getPlayerScoreInfo(blue,sb.getObjective("pvpshot.respawn")).value()==1,"dead player has pending respawn");
            blue=h.getLevel().getServer().getPlayerList().respawn(blue,false,Entity.RemovalReason.KILLED);
            blue.connection.handleAcceptPlayerLoad(new net.minecraft.network.protocol.game.ServerboundPlayerLoadedPacket());
            blue.setPos(h.absoluteVec(new Vec3(5.5,1,9.5)));
            h.setBlock(23,1,27,Blocks.BEDROCK);
            deploy("cannon",0,24,24);
            h.assertTrue(machines("cannon").isEmpty(),"deployment cannot overwrite immutable floor");
            h.assertBlockPresent(Blocks.BEDROCK,23,1,27);
            h.setBlock(23,1,27,Blocks.AIR);
            for(float yaw:new float[]{0,90,180,-90})deploy("cannon",yaw,24,24);
            h.assertTrue(machines("cannon").size()==4,"four cannon deployments: "+machines("cannon").size());
            deployed.addAll(machines("cannon"));
            for(var m:deployed) {
                var p=BlockPos.containing(offset(m,1,1,3));
                h.assertTrue(h.getLevel().getBlockEntity(p) instanceof DispenserBlockEntity,"rotated cannon dispenser "+m.getYRot());
                var d=(DispenserBlockEntity)h.getLevel().getBlockEntity(p);
                h.assertTrue(d.getItem(0).getCount()==9,"cannon ammunition");
            }
            deploy("cannon",0,24,24);
            h.assertTrue(machines("cannon").size()==5,"overlapping placement is allowed at player risk");
            for(var m:machines("cannon"))if(!deployed.contains(m))m.discard();
            h.assertTrue(red.getInventory().contains(s->s.is(BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:red_dye")))),"failed placement refund");
            for(float yaw:new float[]{0,90,180,-90})deploy("turret",yaw,10,30);
            h.assertTrue(machines("turret").size()==4,"four turret deployments");
            turrets.addAll(machines("turret"));
            System.out.println("PASS four orientations, loaded structures, allowed overlap and immutable-floor refund");
            red.setPos(h.absoluteVec(new Vec3(2.5,1,2.5)));
        });
        h.runAtTickTime(90,()->{
            blue.doTick(); // Embedded clients have no network listener ticking the player.
            h.assertTrue(blue.getMaxHealth()==20 && blue.getHealth()==20,"20 HP equipment applied after actual respawn max="+blue.getMaxHealth()+" health="+blue.getHealth());
            h.assertTrue(!blue.getInventory().isEmpty(),"respawn equipment retained");
            System.out.println("PASS actual respawn has 20 HP and equipment");
            h.getLevel().getServer().getPlayerList().remove(blue);
        });
        h.runAtTickTime(112,()->{
            var shells=h.getLevel().getEntities(EntityTypes.TNT,e->e.entityTags().contains("pvpshot.cannon_shell"));
            h.assertTrue(shells.size()==4,"four dispenser shells captured: "+shells.size());
            for(var m:deployed) {
                var expect=offset(m,1,1,4);
                var shell=shells.stream().min(Comparator.comparingDouble(e->e.position().distanceToSqr(expect))).orElseThrow();
                var v=shell.getDeltaMovement();double a=Math.toRadians(m.getYRot());
                h.assertTrue(v.x*(-Math.sin(a))+v.z*Math.cos(a)>.5,"cannon velocity follows yaw "+m.getYRot()+" "+v);
                h.assertTrue(shell.getOwner()==red,"cannon shell owner");
            }
            var arrows=h.getLevel().getEntities(EntityTypes.ARROW,e->e.entityTags().contains("pvpshot.turret_arrow"));
            h.assertTrue(arrows.size()==12,"four turrets each fire three arrows: "+arrows.size());
            h.assertTrue(arrows.stream().allMatch(e->e.getOwner()==red),"turret owner attribution");
            for(float yaw:new float[]{0,90,180,-90})for(double lateral:new double[]{-.2,0,.2}) {
                double a=Math.toRadians(yaw);
                Vec3 expected=new Vec3(lateral*Math.cos(a)-1.95*Math.sin(a),0,lateral*Math.sin(a)+1.95*Math.cos(a)).normalize();
                h.assertTrue(arrows.stream().anyMatch(e->{var v=e.getDeltaMovement();return new Vec3(v.x,0,v.z).normalize().distanceTo(expected)<.001;}),"symmetric turret fan yaw="+yaw+" lateral="+lateral);
            }
            System.out.println("PASS symmetric three-arrow fans in all four orientations");
            blue=player("PvpTestTarget",5,9);as(blue,"team join pvpshot.blue @s");
            reset();var arrow=arrows.getFirst();arrow.setPos(blue.position().add(0,1.6,-1));arrow.setDeltaMovement(0,0,1.5);
            command("function pvpshot:combat/proj_tick");health(13,"actual turret arrow base damage 7");
            h.getLevel().getServer().getPlayerList().remove(blue);
            System.out.println("PASS native dispenser firing, four launch vectors, four turrets and owners");
        });
        h.runAtTickTime(469,()->{
            h.assertTrue(machines("machine").isEmpty(),"completed machines cleaned up");
            for(var m:deployed) {
                var d=(DispenserBlockEntity)h.getLevel().getBlockEntity(BlockPos.containing(offset(m,1,1,3)));
                h.assertTrue(d.isEmpty(),"all nine cannon rounds used");
                h.assertTrue(h.getLevel().getBlockState(BlockPos.containing(offset(m,1,1,2))).isAir(),"cannon unpowered");
            }
            for(var m:turrets)for(int x=0;x<3;x++) {
                var d=(DispenserBlockEntity)h.getLevel().getBlockEntity(BlockPos.containing(offset(m,x,1,x==1?1:0)));
                h.assertTrue(d.isEmpty(),"eighteen rounds consumed at every turret barrel");
                h.assertTrue(h.getLevel().getBlockState(BlockPos.containing(offset(m,1,1,0))).isAir(),"turret unpowered");
            }
            System.out.println("PASS finite ammunition and cleanup");
        });
        h.runAtTickTime(240,()->{
            blue=player("PvpSelfTest",5,9);as(blue,"team join pvpshot.blue @s");
        });
        h.runAtTickTime(310,()->{
            reset();
            var arrow=new net.minecraft.world.entity.projectile.arrow.Arrow(EntityTypes.ARROW,h.getLevel());
            arrow.setOwner(blue);arrow.setPos(blue.position().add(0,1.6,-1));arrow.setDeltaMovement(0,0,1.5);
            h.getLevel().addFreshEntity(arrow);
            command("tag "+arrow.getUUID()+" add pvpshot.turret_arrow");
            command("data merge entity "+arrow.getUUID()+" {LeftOwner:1b,damage:0.0d}");
            command("function pvpshot:combat/proj_tick");health(13,"own turret arrow deals 7");
            reset();upwardThrow("egg");
        });
        h.runAtTickTime(470,()->{
            health(17,"egg flies upward and falls back onto its owner for 3");
        });
        h.runAtTickTime(471,()->{
            reset();red.setHealth(20);red.invulnerableTime=0;as(red,"clear @s");as(red,"effect clear @s");red.doTick();
            red.setPos(blue.position().add(1,0,0));
            hit("egg",true);health(17,"egg direct victim is not double hit by fragments");
            h.assertTrue(Math.abs(red.getHealth()-20)<.001,"legacy eggs no longer splash nearby owner: "+red.getHealth());
            h.assertTrue(h.getLevel().getEntities(EntityTypes.MARKER,e->e.entityTags().contains("pvpshot.fragment_origin")).isEmpty(),"fragment markers cleaned");
            System.out.println("PASS legacy eggs lose splash and retain direct compatibility");
            reset();red.setPos(h.absoluteVec(new Vec3(2.5,1,2.5)));
            command("scoreboard players set #egg.splash_radius pvpshot.cfg 3");
            for(int y=1;y<=3;y++)h.setBlock(5,y,8,Blocks.STONE);
            spawnWeapon("egg",2);health(20,"egg fragments cannot pass through cover");
            for(int y=1;y<=3;y++)h.setBlock(5,y,8,Blocks.AIR);
            command("scoreboard players set #egg.splash_radius pvpshot.cfg 2");
        });
        h.runAtTickTime(474,()->{
            reset();red.setPos(h.absoluteVec(new Vec3(5.5,1,5.5)));red.setYRot(0);red.setXRot(0);
            as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/fire_charge");
            red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);
            red.doTick();red.doTick();red.doTick();
            var balls=h.getLevel().getEntities(EntityTypes.ITEM_DISPLAY,e->e.entityTags().contains("pvpshot.fire_shot"));
            h.assertTrue(balls.size()==1,"consuming rifle item launches exactly one visual projectile");
            h.assertTrue(red.getMainHandItem().getCount()==15,"rifle consumes one of sixteen");
            System.out.println("PASS actual rifle consumption and projectile creation");
        });
        h.runAtTickTime(480,()->{
            health(14,"rifle direct victim takes six HP without repeated splash");
            h.assertTrue(!blue.isOnFire(),"rifle never ignites its target");
            h.assertTrue(h.getLevel().getEntities(EntityTypes.ITEM_DISPLAY,e->e.entityTags().contains("pvpshot.fire_shot")).isEmpty(),"rifle ends on impact");
            System.out.println("PASS rifle direct impact and no burning");
            // Fire from this new weapon must not contaminate the separate TNT cover fixture.
            for(int x=0;x<=10;x++)for(int y=1;y<=4;y++)for(int z=4;z<=16;z++) {
                var state=h.getLevel().getBlockState(h.absolutePos(new BlockPos(x,y,z)));
                if(state.is(Blocks.FIRE)||state.is(Blocks.SOUL_FIRE))h.setBlock(x,y,z,Blocks.AIR);
            }
            blue.clearFire();
        });
        h.runAtTickTime(490,()->{
            nativeReset();h.setBlock(6,1,14,Blocks.OAK_PLANKS);nativeBlast(red);
        });
        h.runAtTickTime(493,()->{
            nativeOpenDamage=200-blue.getHealth();
            h.assertTrue(nativeOpenDamage>8,"native TNT is not clamped to 8: "+nativeOpenDamage);
            h.assertBlockPresent(Blocks.AIR,6,1,14);
            System.out.println("PASS vanilla TNT damage="+nativeOpenDamage+" and native terrain destruction");
            nativeReset();nativeBlast(blue);
        });
        h.runAtTickTime(496,()->{
            h.assertTrue(Math.abs((200-blue.getHealth())-nativeOpenDamage)<.01,"native TNT self damage equals enemy damage: open="+nativeOpenDamage+" self="+(200-blue.getHealth()));
            System.out.println("PASS native TNT self damage and owner attribution retained");
            nativeReset();
            for(int x=4;x<=5;x++)for(int y=1;y<=3;y++)h.setBlock(x,y,12,Blocks.OBSIDIAN);
            nativeBlast(red);
        });
        h.runAtTickTime(499,()->{
            h.assertTrue(200-blue.getHealth()<nativeOpenDamage,"native cover reduces TNT damage");
            System.out.println("PASS full cover native damage="+(200-blue.getHealth()));
            nativeReset();for(int y=1;y<=3;y++)h.setBlock(4,y,12,Blocks.AIR);nativeBlast(red);
        });
        h.runAtTickTime(502,()->{
            float partial=200-blue.getHealth();
            h.assertTrue(partial>1 && partial<nativeOpenDamage,"partial cover gives partial reduction: "+partial);
            System.out.println("PASS partial cover native damage="+partial);
            for(int y=1;y<=3;y++)h.setBlock(5,y,12,Blocks.AIR);
            nativeReset();blue.setHealth(1);nativeBlast(red);
        });
        h.runAtTickTime(505,()->{
            var sb=h.getLevel().getServer().getScoreboard();
            h.assertTrue(blue.isDeadOrDying(),"native TNT lethal");
            h.assertTrue(sb.getPlayerScoreInfo(red,sb.getObjective("pvpshot.kills")).value()>=2,"native TNT kill credit");
            System.out.println("PASS native TNT kill credited to owner");
            h.assertTrue(sb.getPlayerScoreInfo(net.minecraft.world.scores.ScoreHolder.forNameOnly("Red"),sb.getObjective("pvpshot.score")).value()==2,"native TNT enemy kill adds team point");
            h.getLevel().getServer().getPlayerList().remove(blue);
            blue=player("PvpFriendTest",5,9);
            as(blue,"team join pvpshot.red @s");
        });
        h.runAtTickTime(575,()->{
            // Tick the embedded client before the separate friendly-kill fixture.
            for(int i=0;i<65;i++)blue.doTick();
            reset();blue.setHealth(1);hit("egg",true);health(0,"friendly fire can be lethal");
        });
        h.runAtTickTime(578,()->{
            var sb=h.getLevel().getServer().getScoreboard();
            h.assertTrue(sb.getPlayerScoreInfo(net.minecraft.world.scores.ScoreHolder.forNameOnly("Red"),sb.getObjective("pvpshot.score")).value()==2,"friendly kill does not reward team points");
            h.assertTrue(sb.getPlayerScoreInfo(red,sb.getObjective("pvpshot.kills")).value()==3,"friendly kill retains native attribution");
            System.out.println("PASS enemy kills score, friendly kills retain attribution without score reward");
            h.getLevel().getServer().getPlayerList().remove(blue);
            blue=player("PvpSystemsTest",35,25);as(blue,"team join pvpshot.blue @s");
        });
        h.runAtTickTime(590,()->{
            for(int i=0;i<20;i++) {
                as(red,"function pvpshot:player/kit");
                h.assertTrue(count(red,"blaze_powder")==16,"every random kit includes a full base magazine");
                h.assertTrue(count(red,"slime_ball")==1,"every kit includes one grenade");
                h.assertTrue(count(red,"firework_star")==1,"every kit includes one demolition rocket");
                h.assertTrue(count(red,"iron_pickaxe")==1,"every kit includes one pickaxe");
                h.assertTrue(count(red,"red_terracotta")==64 && count(red,"blue_terracotta")==0,"red player gets one stack of team building blocks");
                int secondary=count(red,"snowball")/4+count(red,"brick")/48+count(red,"trident");
                h.assertTrue(count(red,"bow")==0 && count(red,"crossbow")==0,"bows are supply-only weapons");
                h.assertTrue(secondary==1,"fixed base gear plus exactly one random secondary");
            }
            System.out.println("PASS twenty randomized kits include base gear and 64 red terracotta");
            as(blue,"function pvpshot:player/kit");
            h.assertTrue(count(blue,"blue_terracotta")==64 && count(blue,"red_terracotta")==0,"blue player gets 64 blue terracotta");
            System.out.println("PASS blue kit includes 64 blue terracotta");
        });
        h.runAtTickTime(600,()->{
            as(red,"clear @s");as(red,"effect clear @s");red.setPos(h.absoluteVec(new Vec3(30.5,1,10.5)));red.setYRot(0);red.setXRot(0);
            as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/grenade");
            red.getMainHandItem().use(h.getLevel(),red,InteractionHand.MAIN_HAND);red.doTick();red.doTick();red.doTick();
            var grenades=h.getLevel().getEntities(EntityTypes.TNT,e->e.entityTags().contains("pvpshot.grenade"));
            h.assertTrue(grenades.size()==1,"one consumed grenade creates one primed TNT");grenade=grenades.getFirst();
            h.assertTrue(grenade.getOwner()==red,"grenade retains thrower attribution");
            h.assertTrue(grenade.getFuse()==40,"grenade starts with two second fuse");
            h.assertTrue(grenade.getDeltaMovement().distanceTo(new Vec3(0,.2,.9))<.001,"grenade throw has forward and upward velocity");
            h.assertTrue(count(red,"slime_ball")==0,"grenade consumed once");
            // Isolate explosion behaviour from random bounce/terrain at the landing site.
            as(blue,"attribute @s minecraft:max_health base set 200");blue.setHealth(200);blue.invulnerableTime=0;
            blue.setPos(h.absoluteVec(new Vec3(35,1,25)));
            grenade.setPos(blue.position().add(0,0,5));grenade.setNoGravity(true);grenade.setDeltaMovement(Vec3.ZERO);
            System.out.println("PASS actual grenade use, count, fuse, launch and native owner");
        });
        h.runAtTickTime(638,()->h.assertTrue(!grenade.isRemoved(),"grenade does not detonate before fuse"));
        h.runAtTickTime(642,()->{
            h.assertTrue(grenade.isRemoved(),"grenade detonates after its fuse");
            h.assertTrue(blue.getHealth()<192,"grenade deals full native TNT damage");
            System.out.println("PASS thrown grenade detonates with native damage="+(200-blue.getHealth()));
        });
        h.runAtTickTime(650,()->{
            command("scoreboard players set #ammo.enabled pvpshot.cfg 1");
            as(red,"clear @s");red.setPos(h.absoluteVec(new Vec3(2.5,1,2.5)));red.setYRot(180);red.setXRot(0);
            as(red,"loot replace entity @s weapon.mainhand loot pvpshot:item/fire_charge");as(red,"function pvpshot:ammo/reset");
            drainMagazine();as(red,"function pvpshot:ammo/player");
            h.assertTrue(score(red,"pvpshot.reload")==40,"empty magazine starts 40 tick reload");
        });
        h.runAtTickTime(669,()->h.assertTrue(count(red,"blaze_powder")==0,"no shots available halfway through reload"));
        h.runAtTickTime(691,()->{
            h.assertTrue(count(red,"blaze_powder")==16,"first empty magazine refills from infinite reserve");
            drainMagazine();as(red,"function pvpshot:ammo/player");
        });
        h.runAtTickTime(732,()->{
            h.assertTrue(count(red,"blaze_powder")==16,"second magazine refills without reserve consumption");
            red.getMainHandItem().setCount(3);as(red,"trigger pvp_reload");
            System.out.println("PASS two real 16-shot magazines, timed empty interval and infinite resupply");
        });
        h.runAtTickTime(734,()->h.assertTrue(count(red,"blaze_powder")==0,"manual reload discards partial magazine during delay"));
        h.runAtTickTime(775,()->{
            h.assertTrue(count(red,"blaze_powder")==16,"manual reload returns full magazine");
            as(red,"clear @s");
            for(int i=0;i<36;i++)red.getInventory().setItem(i,new ItemStack(BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:stone")),64));
            droppedBefore=droppedSnowballs();as(red,"function pvpshot:ammo/reset");as(red,"function pvpshot:ammo/player");
            System.out.println("PASS manual reload completes with infinite reserve");
        });
        h.runAtTickTime(818,()->{
            h.assertTrue(count(red,"blaze_powder")==0,"full inventory waits for an empty slot");
            h.assertTrue(droppedSnowballs()==droppedBefore,"reload never floods ground when inventory is full");
            red.getInventory().setItem(4,ItemStack.EMPTY);
        });
        h.runAtTickTime(841,()->{
            h.assertTrue(count(red,"blaze_powder")==16,"reload finishes when one inventory slot opens");
            h.assertTrue(droppedSnowballs()==droppedBefore,"resupply stays in inventory");
            command("scoreboard players set #ammo.enabled pvpshot.cfg 0");
            System.out.println("PASS full-inventory reload safely waits and recovers");
        });
        h.onEachTick(()->{if(h.getTick()>=850){blue.doTick();red.doTick();}});
        h.runAtTickTime(850,()->{
            as(blue,"attribute @s minecraft:max_health base set 20");reset();blue.setHealth(1);
            as(red,"clear @s");as(red,"effect clear @s");red.setPos(h.absoluteVec(new Vec3(2.5,1,2.5)));red.setHealth(10);
            command("scoreboard players set #regen.enabled pvpshot.cfg 1");
            as(blue,"function pvpshot:regen/in_combat");as(red,"function pvpshot:regen/in_combat");
        });
        h.runAtTickTime(948,()->health(1,"no regeneration during five-second combat delay"));
        h.runAtTickTime(963,()->{
            h.assertTrue(blue.getHealth()>1 && blue.getHealth()<20,"fast recovery starts after combat delay");
            System.out.println("PASS delayed recovery has started health="+blue.getHealth());
        });
        h.runAtTickTime(974,()->red.setHealth(10));
        h.runAtTickTime(975,()->{
            h.assertTrue(blue.getHealth()>6,"fixture has enough recovered HP for interruption");
            float before=blue.getHealth();hit("egg",true);hurtHealth=blue.getHealth();
            h.assertTrue(Math.abs(before-hurtHealth-3)<.01,"damage interrupts healing without being absorbed");
            h.assertTrue(!blue.hasEffect(net.minecraft.world.effect.MobEffects.REGENERATION),"taking damage immediately stops recovery");
            h.assertTrue(!red.hasEffect(net.minecraft.world.effect.MobEffects.REGENERATION),"dealing damage immediately stops recovery");
            h.assertTrue(score(red,"pvpshot.quiet")==0 && score(blue,"pvpshot.quiet")==0,"both combat clocks restart");
            System.out.println("PASS damage dealt and received immediately interrupt recovery");
        });
        h.runAtTickTime(1060,()->{
            health(hurtHealth,"recovery stays off during renewed combat delay");
            blue.invulnerableTime=0;as(blue,"damage @s 1 minecraft:generic");hurtHealth=blue.getHealth();
            h.assertTrue(score(blue,"pvpshot.quiet")==0,"environmental damage restarts combat delay");
        });
        h.runAtTickTime(1158,()->health(hurtHealth,"environmental damage also postpones recovery five seconds"));
        h.runAtTickTime(1219,()->{
            health(20,"fast recovery reaches full health within three seconds after delay");
            h.assertTrue(blue.getHealth()<=blue.getMaxHealth(),"recovery never overheals");
            System.out.println("PASS automatic recovery reaches 20 HP and respects environmental damage");
            h.succeed();
        });
    }
    public static void main(String[] args) throws Exception {
        SharedConstants.tryDetectVersion();
        net.minecraft.server.Bootstrap.bootStrap();
        // Test-only entry-point registration; the shipped datapack needs no mod.
        var frozen = net.minecraft.core.MappedRegistry.class.getDeclaredField("frozen");
        frozen.setAccessible(true);
        frozen.setBoolean(BuiltInRegistries.TEST_FUNCTION, false);
        Registry.register(BuiltInRegistries.TEST_FUNCTION, Identifier.parse("pvptest:suite"), TestMain::suite);
        var tags = net.minecraft.core.MappedRegistry.class.getDeclaredField("allTags");
        tags.setAccessible(true);
        var unbound = tags.getType().getDeclaredMethod("unbound");
        unbound.setAccessible(true);
        tags.set(BuiltInRegistries.TEST_FUNCTION, unbound.invoke(null));
        BuiltInRegistries.TEST_FUNCTION.freeze();
        net.minecraft.gametest.Main.main(args);
    }
}
