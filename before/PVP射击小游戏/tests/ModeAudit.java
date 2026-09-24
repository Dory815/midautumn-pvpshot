import java.util.*;
import com.mojang.authlib.GameProfile;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.embedded.EmbeddedChannel;
import net.minecraft.SharedConstants;
import net.minecraft.core.Registry;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.resources.Identifier;
import net.minecraft.gametest.framework.GameTestHelper;
import net.minecraft.server.level.*;
import net.minecraft.server.network.CommonListenerCookie;
import net.minecraft.network.Connection;
import net.minecraft.network.protocol.Packet;
import net.minecraft.network.protocol.PacketFlow;
import net.minecraft.network.protocol.game.ClientboundSetTitleTextPacket;
import net.minecraft.world.level.GameType;
import net.minecraft.world.entity.*;
import net.minecraft.world.phys.Vec3;
import net.minecraft.world.scores.ScoreHolder;

/** Independent audit of the shipped rules; failed requirements stay failed.
 * Runs in a disposable world without changing the production datapack.
 */
public class ModeAudit extends TestMain {
    static final List<String> failures = new ArrayList<>();
    static final List<String> titles = new ArrayList<>();
    static final List<ServerPlayer> players = new ArrayList<>();
    static int passed;
    static ServerPlayer red2, red3, neutral;

    static class ObservedConnection extends Connection {
        final boolean observe;
        ObservedConnection(boolean observe) { super(PacketFlow.SERVERBOUND); this.observe = observe; }
        @Override public void send(Packet<?> packet, ChannelFutureListener listener, boolean flush) {
            if (observe && packet instanceof ClientboundSetTitleTextPacket title) titles.add(title.text().getString());
            super.send(packet, listener, flush);
        }
    }
    static ServerPlayer participant(String name, String team, boolean observe) {
        var profile = new GameProfile(UUID.randomUUID(), name);
        var p = new ServerPlayer(h.getLevel().getServer(), h.getLevel(), profile, ClientInformation.createDefault());
        var connection = new ObservedConnection(observe);
        new EmbeddedChannel(connection);
        h.getLevel().getServer().getPlayerList().placeNewPlayer(connection, p, CommonListenerCookie.createInitial(profile, false));
        p.connection.handleAcceptPlayerLoad(new net.minecraft.network.protocol.game.ServerboundPlayerLoadedPacket());
        p.setGameMode(GameType.SURVIVAL); p.setNoGravity(true); p.setDeltaMovement(Vec3.ZERO);
        as(p, "scoreboard players set @s pvpshot.init 1");
        for (String obj : List.of("deaths", "deaths_old", "kills", "kills_old"))
            as(p, "scoreboard players set @s pvpshot." + obj + " 0");
        as(p, "function pvpshot:player/score_init");
        as(p, "function pvpshot:player/refresh_hp");
        as(p, "effect clear @s"); as(p, "clear @s");
        if (team != null) as(p, "team join pvpshot." + team + " @s");
        players.add(p); park(p); return p;
    }
    static int value(String holder, String objective) {
        var sb = h.getLevel().getServer().getScoreboard();
        var score = sb.getPlayerScoreInfo(ScoreHolder.forNameOnly(holder), sb.getObjective(objective));
        return score == null ? 0 : score.value();
    }
    static int points(String team) { return value(team, "pvpshot.score"); }
    static void check(String name, boolean ok, String actual) {
        System.out.println("AUDIT " + (ok ? "PASS " : "FAIL ") + name + " | " + actual);
        if (ok) passed++; else failures.add(name);
    }
    static void scores(String name, int r, int b) {
        check(name, points("Red") == r && points("Blue") == b,
            "expected=" + r + ":" + b + " actual=" + points("Red") + ":" + points("Blue"));
    }
    static void move(ServerPlayer p, double x, double z) { p.setPos(h.absoluteVec(new Vec3(x, 1, z))); }
    static void park(ServerPlayer p) { move(p, 24.5, 40.5); }
    static void atPoint(ServerPlayer p, int index) { move(p, 8.5 + index * 16, 8.5); }
    static void clearScores() {
        command("scoreboard players set Red pvpshot.score 0");
        command("scoreboard players set Blue pvpshot.score 0");
        command("scoreboard players set #point.clock pvpshot.cal 0");
        titles.clear();
    }
    static void captureFixture() {
        for (var p : players) { park(p); p.setGameMode(GameType.SURVIVAL); }
        command("scoreboard players set #cap.max pvpshot.cfg 60");
        command("function pvpshot:mode/conquest");
        titles.clear();
    }
    static void pulse() {
        command("scoreboard players set #point.clock pvpshot.cal 19");
        command("function pvpshot:point/tick_all");
    }
    static int owner(int i) { return scoreOfPoint(i, "pvpshot.owner"); }
    static int progress(int i) { return scoreOfPoint(i, "pvpshot.capture"); }
    static int scoreOfPoint(int i, String objective) {
        var position = h.absoluteVec(new Vec3(8.5 + i * 16, 1, 8.5));
        var marker = machines("point").stream().filter(e -> e.position().distanceTo(position) < .01).findFirst().orElseThrow();
        var sb = h.getLevel().getServer().getScoreboard();
        var score = sb.getPlayerScoreInfo(marker, sb.getObjective(objective));
        return score == null ? 0 : score.value();
    }
    static void ticks(int n) {
        for (int i = 0; i < n; i++) {
            command("function pvpshot:point/tick_all"); command("function pvpshot:match/check_win");
        }
    }
    static void enemyKill(String name, String team) {
        blue = participant(name, team, false);
        as(blue, "damage @s 1000 minecraft:player_attack by @a[name=ModeRed,limit=1]");
        h.assertTrue(blue.isDeadOrDying(), "actual native player kill: " + name);
        command("function pvpshot:player/tick");
    }
    static void selectItem(ServerPlayer p,String name) {
        var type=BuiltInRegistries.ITEM.getValue(Identifier.parse("minecraft:"+name));
        for(int slot=0;slot<9;slot++)if(p.getInventory().getItem(slot).is(type)){p.getInventory().setSelectedSlot(slot);return;}
        h.fail("Missing hotbar item: "+name);
    }
    static void suite(GameTestHelper helper) {
        h = helper;
        command("function pvpshot:load");
        command("scoreboard players set #regen.enabled pvpshot.cfg 0");
        command("scoreboard players set #ammo.enabled pvpshot.cfg 0");
        red = participant("ModeRed", "red", true);
        red2 = participant("ModeRedTwo", "red", false);
        red3 = participant("ModeRedThree", "red", false);
        blue = participant("ModeBlue", "blue", false);
        neutral = participant("ModeNeutral", null, false);
        command("kill @e[type=minecraft:marker,tag=pvpshot.point]");
        for (int i = 0; i < 3; i++) {
            atPoint(red, i); as(red, "execute at @s run function pvpshot:setup/point");
        }
        captureFixture();
        h.runAtTickTime(70, () -> { captureFixture(); atPoint(red, 0); });
        h.runAtTickTime(169, () -> {
            scores("capture_waits_99_real_ticks", 0, 0);
            check("point_not_owned_before_capture_completes", owner(0) == 0 && progress(0) == 99, "owner=" + owner(0) + " progress=" + progress(0));
        });
        h.runAtTickTime(170, () -> {
            check("capture_completes_at_100_real_ticks", owner(0) == 1, "owner=" + owner(0));
            scores("first_score_at_capture_completion", 1, 0); park(red);
        });
        h.runAtTickTime(189, () -> scores("point_income_waits_19_ticks", 1, 0));
        h.runAtTickTime(190, () -> scores("owned_empty_point_scores_after_20_ticks", 2, 0));
        h.runAtTickTime(220, () -> {
            h.assertTrue(machines("point").size() == 3, "fixture has exactly three point markers");
            captureFixture(); ticks(100); scores("empty_neutral_points_do_not_score", 0, 0);
            atPoint(red, 0); atPoint(red2, 1); atPoint(blue, 2);
            ticks(100); scores("three_points_score_independently", 2, 1);
            for (var p : players) park(p);
            ticks(20); scores("all_three_owned_points_keep_scoring_when_empty", 4, 2);
            atPoint(red, 0); as(red, "execute at @s store success score #forced pvpshot.cal run forceload query ~ ~");
            check("point_chunk_is_forced_loaded", value("#forced", "pvpshot.cal") == 1, "forced=" + value("#forced", "pvpshot.cal"));
            captureFixture(); atPoint(red, 0); atPoint(blue, 0); ticks(100);
            check("equal_contest_freezes_capture", owner(0) == 0 && progress(0) == 0, "progress=" + progress(0));
            scores("equal_contest_stops_scoring", 0, 0);
            atPoint(red2, 0); ticks(100);
            check("numerical_majority_captures_point", owner(0) == 1, "owner=" + owner(0));
            scores("enemy_presence_blocks_owned_point_income", 0, 0);
            park(blue); ticks(20); scores("income_resumes_when_enemy_leaves", 1, 0);
            captureFixture(); atPoint(red, 0); atPoint(red2, 0); atPoint(red3, 0);
            ticks(100); scores("one_point_awards_one_not_three", 1, 0);
            park(red); park(red2); park(red3); atPoint(blue, 0); ticks(99);
            check("hostile_point_requires_neutralization", owner(0) == 1 && progress(0) == 1, "owner=" + owner(0) + " progress=" + progress(0));
            scores("hostile_attack_stops_previous_owner_income", 1, 0);
            ticks(1); check("neutralized_after_five_seconds", owner(0) == 0 && progress(0) == 0, "owner=" + owner(0));
            ticks(100); check("enemy_captures_after_second_five_seconds", owner(0) == 2, "owner=" + owner(0));
            scores("captured_enemy_point_scores_for_new_owner", 1, 1);
            captureFixture(); move(red, 12.5, 8.5); ticks(100); scores("four_block_radius_includes_boundary", 1, 0);
            captureFixture(); move(red, 12.51, 8.5); ticks(100); scores("outside_radius_excluded", 0, 0);
            captureFixture(); atPoint(neutral, 0); ticks(100); scores("unassigned_player_excluded", 0, 0);
            captureFixture(); atPoint(red, 0); red.setGameMode(GameType.SPECTATOR); ticks(100); scores("spectator_cannot_capture", 0, 0);
            captureFixture(); atPoint(red, 0); red.setGameMode(GameType.CREATIVE); ticks(100); scores("creative_observer_cannot_capture", 0, 0);
            captureFixture(); atPoint(red, 0); red.setGameMode(GameType.ADVENTURE); ticks(100); scores("adventure_player_can_capture", 1, 0);
            captureFixture(); atPoint(red3, 0); as(red3, "kill @s");
            h.assertTrue(red3.getHealth() == 0 && red3.isDeadOrDying(), "fixture is really dead");
            ticks(100); scores("dead_player_cannot_capture", 0, 0);
            captureFixture(); atPoint(red, 0); ticks(100);
            command("scoreboard players set Red pvpshot.score 59"); titles.clear(); ticks(20);
            check("capture_red_win_announcement", titles.equals(List.of("红队获胜")), "titles=" + titles);
            scores("final_scores_preserved", 60, 0);
            ticks(40); scores("finished_round_stops_scoring", 60, 0);
            check("finished_state_recorded", value("#match.state", "pvpshot.cal") == 2, "state=" + value("#match.state", "pvpshot.cal"));
            captureFixture(); atPoint(blue, 0); ticks(100);
            command("scoreboard players set Blue pvpshot.score 59"); titles.clear(); ticks(20);
            check("capture_blue_win_announcement", titles.equals(List.of("蓝队获胜")), "titles=" + titles);
            captureFixture(); atPoint(red, 0); atPoint(blue, 1); ticks(100);
            command("scoreboard players set Red pvpshot.score 59"); command("scoreboard players set Blue pvpshot.score 59"); titles.clear(); ticks(20);
            check("simultaneous_equal_limit_is_draw", titles.equals(List.of("平局")) && value("#match.result", "pvpshot.cal") == 3, "titles=" + titles);
            command("function pvpshot:mode/deathmatch");
            scores("switching_mode_clears_scores", 0, 0);
            check("switching_mode_clears_point_ownership", owner(0) == 0 && owner(1) == 0 && progress(0) == 0, "owners=" + owner(0) + ":" + owner(1));
            ticks(120); scores("deathmatch_disables_point_scoring", 0, 0);
            check("deathmatch_disables_capture_progress", progress(0) == 0, "progress=" + progress(0));
            command("scoreboard players set Red pvpshot.score 17"); command("scoreboard players set #point.clock pvpshot.cal 19");
            command("scoreboard players set #mode pvpshot.cfg 1"); command("function pvpshot:match/prepare");
            scores("raw_mode_switch_clears_scores", 0, 0);
            check("raw_mode_switch_clears_clock", value("#point.clock", "pvpshot.cal") == 0, "clock=" + value("#point.clock", "pvpshot.cal"));
            captureFixture(); enemyKill("ModeCapVictim", "blue");
            scores("capture_enemy_kill_never_adds_points", 0, 0);
            command("function pvpshot:mode/deathmatch"); enemyKill("ModeDmVictim", "blue");
            scores("deathmatch_enemy_kill_adds_one", 1, 0);
            enemyKill("ModeFriendly", "red"); scores("deathmatch_friendly_kill_not_rewarded", 1, 0);
            command("scoreboard players set #tdm.max pvpshot.cfg 2"); enemyKill("ModeLimitVictim", "blue");
            titles.clear(); command("function pvpshot:match/check_win");
            check("deathmatch_uses_own_limit_and_announces_winner", titles.equals(List.of("红队获胜")), "Red=" + points("Red") + " titles=" + titles);
            enemyKill("ModeAfterEnd", "blue"); scores("kills_after_round_end_do_not_score", 2, 0);
            command("function pvpshot:match/restart"); command("function pvpshot:player/tick");
            scores("restart_does_not_replay_old_kills", 0, 0);
            check("restart_reopens_scoring", value("#match.state", "pvpshot.cal") == 1, "state=" + value("#match.state", "pvpshot.cal"));
            command("scoreboard players set #point.clock pvpshot.cal 19"); command("function pvpshot:load");
            check("reload_restarts_with_default_mode_and_clear_clock", value("#mode", "pvpshot.cfg") == 1 && value("#point.clock", "pvpshot.cal") == 0, "mode=" + value("#mode", "pvpshot.cfg") + " clock=" + value("#point.clock", "pvpshot.cal"));
            as(red, "function pvpshot:player/kit"); selectItem(red,"red_terracotta");
            check("red_life_gets_64_building_blocks", count(red, "red_terracotta") == 64, "count=" + count(red, "red_terracotta"));
            var floor = h.absolutePos(new net.minecraft.core.BlockPos(6, 0, 35));
            move(red, 6.5, 34.5);
            var hit = new net.minecraft.world.phys.BlockHitResult(Vec3.atCenterOf(floor).add(0,.5,0), net.minecraft.core.Direction.UP, floor, false);
            red.gameMode.useItemOn(red, h.getLevel(), red.getMainHandItem(), net.minecraft.world.InteractionHand.MAIN_HAND, hit);
            check("team_blocks_place_and_consume_normally", count(red, "red_terracotta") == 63 && h.getLevel().getBlockState(floor.above()).is(BuiltInRegistries.BLOCK.getValue(Identifier.parse("minecraft:red_terracotta"))), "remaining=" + count(red, "red_terracotta"));
            selectItem(red,"iron_pickaxe");
            check("team_block_breaks_with_pickaxe", red.gameMode.destroyBlock(floor.above()) && h.getLevel().getBlockState(floor.above()).isAir(), "native survival destroyBlock");
            as(red, "function pvpshot:player/kit"); check("new_life_replaces_stack_without_accumulation", count(red, "red_terracotta") == 64, "count=" + count(red, "red_terracotta"));
            as(red, "team join pvpshot.blue @s"); as(red, "function pvpshot:player/kit");
            check("blue_life_gets_blue_building_blocks", count(red, "blue_terracotta") == 64 && count(red, "red_terracotta") == 0, "blue=" + count(red, "blue_terracotta"));
            command("scoreboard players set Red pvpshot.score 23");
            command("scoreboard players set Blue pvpshot.score 17");
            command("function pvpshot:match/ui");
            var bars = h.getLevel().getServer().getCustomBossEvents();
            var redBar = bars.get(Identifier.parse("pvpshot:red"));
            var blueBar = bars.get(Identifier.parse("pvpshot:blue"));
            check("top_bossbars_match_scores_and_target", redBar.value() == 23 && blueBar.value() == 17 && redBar.max() == 60 && blueBar.max() == 60,
                "red=" + redBar.value() + "/" + redBar.max() + " blue=" + blueBar.value() + "/" + blueBar.max());
            check("top_bossbars_visible_to_players", redBar.getPlayers().contains(red) && blueBar.getPlayers().contains(red) && redBar.isVisible() && blueBar.isVisible(), "native bossbar visibility");
            check("bossbar_labels_include_mode_and_scores", redBar.getName().getString().contains("多点占领") && redBar.getName().getString().contains("23") && blueBar.getName().getString().contains("17"), redBar.getName().getString());
            command("function pvpshot:mode/deathmatch");
            command("scoreboard players set #tdm.max pvpshot.cfg 80"); command("function pvpshot:match/ui");
            check("top_bars_switch_mode_and_target", redBar.max() == 80 && redBar.value() == 0 && redBar.getName().getString().contains("团队死斗"), redBar.getName().getString());
            System.out.println("AUDIT SUMMARY passed=" + passed + " failed=" + failures.size() + " failures=" + failures);
            if (failures.isEmpty()) h.succeed(); else h.fail("Mode readiness requirements failed: " + String.join(", ", failures));
        });
    }
    public static void main(String[] args) throws Exception {
        SharedConstants.tryDetectVersion(); net.minecraft.server.Bootstrap.bootStrap();
        var frozen = net.minecraft.core.MappedRegistry.class.getDeclaredField("frozen");
        frozen.setAccessible(true); frozen.setBoolean(BuiltInRegistries.TEST_FUNCTION, false);
        Registry.register(BuiltInRegistries.TEST_FUNCTION, Identifier.parse("pvptest:suite"), ModeAudit::suite);
        var tags = net.minecraft.core.MappedRegistry.class.getDeclaredField("allTags"); tags.setAccessible(true);
        var unbound = tags.getType().getDeclaredMethod("unbound"); unbound.setAccessible(true);
        tags.set(BuiltInRegistries.TEST_FUNCTION, unbound.invoke(null)); BuiltInRegistries.TEST_FUNCTION.freeze();
        net.minecraft.gametest.Main.main(args);
    }
}
