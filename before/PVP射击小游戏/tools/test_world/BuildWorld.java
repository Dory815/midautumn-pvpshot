import java.util.*;
import com.mojang.authlib.GameProfile;
import io.netty.channel.embedded.EmbeddedChannel;
import net.minecraft.SharedConstants;
import net.minecraft.core.BlockPos;
import net.minecraft.core.Registry;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.resources.Identifier;
import net.minecraft.gametest.framework.GameTestHelper;
import net.minecraft.server.level.*;
import net.minecraft.server.network.CommonListenerCookie;
import net.minecraft.network.Connection;
import net.minecraft.network.protocol.PacketFlow;
import net.minecraft.world.entity.*;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.entity.CommandBlockEntity;
import net.minecraft.world.level.block.entity.ChestBlockEntity;

/** Offline vanilla world builder. Never opens a listener or edits an existing world. */
public class BuildWorld {
    static GameTestHelper h;
    static ServerPlayer visitor;
    static void command(String text) {
        var s = h.getLevel().getServer();
        s.getCommands().performPrefixedCommand(s.createCommandSourceStack().withLevel(h.getLevel()), text);
    }
    static void asPlayer(String text) {
        var s = h.getLevel().getServer();
        s.getCommands().performPrefixedCommand(s.createCommandSourceStack().withLevel(h.getLevel())
            .withEntity(visitor).withPosition(visitor.position()), text);
    }
    static void require(boolean result, String text) {
        h.assertTrue(result, text);
        System.out.println("PASS " + text);
    }
    static void suite(GameTestHelper helper) {
        h = helper;
        // The GameTest runner chooses a remote site. Build the playable map at fixed coordinates.
        for (int x = -4; x <= 3; x++) for (int z = -3; z <= 3; z++) h.getLevel().getChunk(x, z);
        command("forceload add -56 -48 56 48");
        command("function pvp_test:build");
        h.runAtTickTime(10, () -> {
            require(h.getLevel().getBlockState(new BlockPos(0,64,0)).is(Blocks.GOLD_BLOCK), "central capture point");
            require(h.getLevel().getBlockState(new BlockPos(-47,64,0)).is(BuiltInRegistries.BLOCK.getValue(Identifier.parse("minecraft:red_concrete"))), "red spawn");
            require(h.getLevel().getBlockState(new BlockPos(47,64,0)).is(BuiltInRegistries.BLOCK.getValue(Identifier.parse("minecraft:blue_concrete"))), "blue spawn");
            for (int x : new int[]{-30,30}) for (int z : new int[]{-24,24})
                for (int a=x-4;a<=x+4;a++) for(int b=z-4;b<=z+4;b++)
                    h.assertTrue(h.getLevel().getBlockState(new BlockPos(a,65,b)).isAir(), "deployment pad clearance");
            System.out.println("PASS four unobstructed deployment pads");
            require(h.getLevel().getEntities(EntityTypes.MARKER,e->e.entityTags().contains("pvpshot.point")).size()==3,
                "exactly three capture markers");
            require(h.getLevel().getBlockEntity(new BlockPos(-8,66,-46)) instanceof CommandBlockEntity,
                "equipment button command block");
            var chest=(ChestBlockEntity)h.getLevel().getBlockEntity(new BlockPos(-51,65,6));
            require(chest != null && !chest.isEmpty(), "armor chest stocked");
            var profile = new GameProfile(UUID.randomUUID(), "MapValidation");
            visitor = new ServerPlayer(h.getLevel().getServer(), h.getLevel(), profile, ClientInformation.createDefault());
            var connection = new Connection(PacketFlow.SERVERBOUND);
            new EmbeddedChannel(connection);
            h.getLevel().getServer().getPlayerList().placeNewPlayer(connection, visitor,
                CommonListenerCookie.createInitial(profile,false));
            visitor.connection.handleAcceptPlayerLoad(new net.minecraft.network.protocol.game.ServerboundPlayerLoadedPacket());
            visitor.setPos(0.5,65,-41.5);
        });
        h.runAtTickTime(14, () -> {
            visitor.doTick();
            require(visitor.getX()==0.5 && visitor.getY()==65 && visitor.getZ()==-41.5, "new player arrives in lobby");
            require(visitor.getHealth()==20 && visitor.getMaxHealth()==20, "new player has 20 HP");
            require(visitor.getInventory().getItem(0).is(BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:red_dye"))),
                "cannon deployment item in first slot");
            require(visitor.getInventory().getItem(0).getCount()==16, "sixteen deployment charges");
            require(visitor.getInventory().getItem(1).is(BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:orange_dye"))),
                "turret deployment item in second slot");
            require(visitor.getInventory().getItem(2).getCount()==16 && visitor.getInventory().getItem(2).is(BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:snowball"))), "base snowball magazine in third slot");
            require(visitor.getInventory().getItem(3).getCount()==1 && visitor.getInventory().getItem(3).is(BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:slime_ball"))), "one grenade in fourth slot");
            require(visitor.getInventory().getItem(4).is(BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:iron_pickaxe"))), "pickaxe in fifth slot");
            asPlayer("function pvp_test:team_blue");
            require(visitor.getTeam()!=null && visitor.getTeam().getName().equals("pvpshot.blue"), "blue team button");
            require(visitor.getX()==47.5 && visitor.getZ()==0.5, "blue base teleport");
            asPlayer("function pvp_test:team_red");
            require(visitor.getTeam().getName().equals("pvpshot.red"), "red team button");
            asPlayer("tp @s -30.5 65 -24.5 -90 0");
            asPlayer("function pvpshot:deploy/cannon");
            require(h.getLevel().getEntities(EntityTypes.MARKER,e->e.entityTags().contains("pvpshot.cannon")).size()==1,
                "real cannon deploys on arena pad");
            // The core reset must repair blast damage without changing the lobby or bases.
            command("setblock 0 64 0 air");
            command("setblock 20 65 20 tnt");
            command("setblock -50 65 10 emerald_block");
            command("scoreboard players set Red pvpshot.score 30");
            asPlayer("function pvp_test:reset_core");
            require(h.getLevel().getEntities(EntityTypes.MARKER,e->e.entityTags().contains("pvpshot.machine")).isEmpty(),
                "reset removes live machines");
            require(h.getLevel().getBlockState(new BlockPos(0,64,0)).is(Blocks.GOLD_BLOCK), "core reset restores point blocks");
            require(h.getLevel().getBlockState(new BlockPos(20,65,20)).isAir(), "core reset removes placed TNT");
            require(h.getLevel().getBlockState(new BlockPos(-50,65,10)).is(Blocks.EMERALD_BLOCK), "core reset preserves base edits");
            require(h.getLevel().getBlockState(new BlockPos(0,63,0)).is(Blocks.BEDROCK), "native-blast-safe map foundation");
            asPlayer("function pvp_test:reset_core");
            require(h.getLevel().getEntities(EntityTypes.MARKER,e->e.entityTags().contains("pvpshot.point")).size()==3,
                "repeated core reset has exactly three points");
            require(h.getLevel().getServer().getScoreboard().getPlayerScoreInfo(
                net.minecraft.world.scores.ScoreHolder.forNameOnly("Red"),
                h.getLevel().getServer().getScoreboard().getObjective("pvpshot.score")).value()==0,
                "core reset clears team scores");
        });
        h.runAtTickTime(18, () -> {
            command("setblock 20 65 20 tnt");
            command("scoreboard players set #reset.wait pvp_test.init 0");
            asPlayer("effect give @s blindness 30 0 true");
            asPlayer("trigger pvp_reset");
        });
        h.runAtTickTime(22, () -> {
            require(h.getLevel().getBlockState(new BlockPos(20,65,20)).isAir(), "player reset trigger restores core");
            require(!visitor.hasEffect(net.minecraft.world.effect.MobEffects.BLINDNESS), "reset clears previous round status effects");
            require(visitor.getX()==-47.5 && visitor.getZ()==0.5, "reset returns red player to base");
            // Exercise the physical lobby button, including vanilla redstone and the command block.
            visitor.setPos(-7.5,65,-44.5);
            asPlayer("clear @s");
            command("setblock -8 66 -45 minecraft:stone_button[face=wall,facing=south,powered=true]");
        });
        h.runAtTickTime(26, () -> {
            require(visitor.getInventory().getItem(0).getCount()==16, "physical equipment button gives kit");
            asPlayer("function pvp_test:reset");
            h.getLevel().getServer().getPlayerList().remove(visitor);
            command("scoreboard players reset MapValidation");
            // Keep the arena loaded in singleplayer, so capture and spawn markers always exist.
            h.succeed();
        });
    }
    public static void main(String[] args) throws Exception {
        SharedConstants.tryDetectVersion();
        net.minecraft.server.Bootstrap.bootStrap();
        var frozen = net.minecraft.core.MappedRegistry.class.getDeclaredField("frozen");
        frozen.setAccessible(true); frozen.setBoolean(BuiltInRegistries.TEST_FUNCTION,false);
        Registry.register(BuiltInRegistries.TEST_FUNCTION,Identifier.parse("worldbuild:arena"),BuildWorld::suite);
        var tags=net.minecraft.core.MappedRegistry.class.getDeclaredField("allTags");tags.setAccessible(true);
        var unbound=tags.getType().getDeclaredMethod("unbound");unbound.setAccessible(true);
        tags.set(BuiltInRegistries.TEST_FUNCTION,unbound.invoke(null));
        BuiltInRegistries.TEST_FUNCTION.freeze();
        net.minecraft.gametest.Main.main(args);
    }
}
