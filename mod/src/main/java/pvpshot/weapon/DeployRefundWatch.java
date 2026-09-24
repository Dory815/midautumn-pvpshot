package pvpshot.weapon;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.entity.player.Inventory;
import net.minecraft.world.item.ItemStack;

import pvpshot.PvpShotMod;

/**
 * 部署物"消耗 / 退还"观测器（只写日志，不改玩法）。
 *
 * <p>背景：部署物是"吃掉就放"的道具 —— 玩家吃下 → 原版进度 {@code pvpshot:use_cannon}
 * 触发数据包 {@code pvpshot:deploy/cannon}；**部署失败**时数据包用 {@code loot give}
 * 把物品塞回背包。作者反馈"不管放置成功与否每次都会退还一个"，而数据包那侧的逻辑是
 * "只有失败才退还"，两边对不上。
 *
 * <p>所以这里每 tick 数一次玩家背包里的部署物数量，只要发生变化就写一条日志：
 *
 * <ul>
 *   <li>数量**减少** → 部署物被正常吃掉（对应"部署成功"）；</li>
 *   <li>数量**增加** → 收到退还（对应"部署被判定为失败"）。</li>
 * </ul>
 *
 * <p>日志里带玩家名、数量变化与坐标，便于和 {@code 部署失败} 提示、世界里出现的结构对照。
 */
public final class DeployRefundWatch {

    /** 部署物种类（对应物品组件里的 {@code pvpshot.deploy}）。 */
    private static final String[] KINDS = {"cannon", "turret", "bunker"};

    /** 玩家 UUID → 上一层数。 */
    private static final Map<UUID, Integer> LAST_COUNT = new HashMap<>();

    /**
     * 正在冷却中的"玩家 + 种类"。
     *
     * <p>部署物都带 {@code minecraft:use_cooldown}，而原版是在"吃下那一刻"把冷却打上的
     * （{@code Consumable#onConsume} → {@code UseCooldown#apply}），所以
     * "从不在冷却变成在冷却"就是"刚完成一次部署"的可靠信号，创造模式下同样成立。
     */
    private static final Set<String> COOLING = new HashSet<>();

    /** 每 tick 调用一次（跟随玩家主循环，成本只有 41 次背包槽位读取）。 */
    public static void tick(ServerPlayer player) {
        int count = countDeployables(player.getInventory());
        Integer previous = LAST_COUNT.put(player.getUUID(), count);
        if (previous != null && previous != count) {
            int delta = count - previous;
            PvpShotMod.logVerbose("[pvpshot] 玩家 {}（{}）的部署物 {}{} 件：{} @ {} {} {}",
                    player.getName().getString(), modeName(player), delta > 0 ? "+" : "", delta,
                    delta > 0 ? "收到退还（部署判定为失败）" : "被消耗（部署判定为成功）",
                    (int) player.getX(), (int) player.getY(), (int) player.getZ());
        }
        alignCreativeMode(player);
    }

    /**
     * 把创造模式对齐到生存模式（作者反馈的"部署成功相当于没消耗、失败相当于多一个"）。
     *
     * <p>原因在原版：消耗品是在 {@code Consumable#onConsume} 里扣的，而
     * {@code ItemStack#consume} 对"无限材料"（创造模式）玩家**不扣**。于是创造模式下
     * 部署成功 = 一件不消耗（看起来像退还），部署失败 = 数据包退还一件 = 净赚一件。
     * 这里在"刚用完一次"时补扣一件，让两种模式的账目一致：成功 -1、失败 0。
     */
    private static void alignCreativeMode(ServerPlayer player) {
        if (!player.isCreative()) {
            return;
        }
        for (String kind : KINDS) {
            Inventory inventory = player.getInventory();
            ItemStack sample = firstOfKind(inventory, kind);
            String key = player.getUUID() + "/" + kind;
            if (sample == null) {
                COOLING.remove(key);
                continue;
            }
            if (!player.getCooldowns().isOnCooldown(sample)) {
                COOLING.remove(key);
                continue;
            }
            if (COOLING.add(key)) {
                consumeOne(player, kind);
            }
        }
    }

    /** 玩家退出时清掉记录，避免重复登录时误判。 */
    public static void forget(ServerPlayer player) {
        LAST_COUNT.remove(player.getUUID());
        for (String kind : KINDS) {
            COOLING.remove(player.getUUID() + "/" + kind);
        }
    }

    /** 扣掉一件指定种类的部署物（就地改背包里的那个堆叠）。 */
    private static void consumeOne(ServerPlayer player, String kind) {
        Inventory inventory = player.getInventory();
        for (int i = 0; i < inventory.getContainerSize(); i++) {
            ItemStack stack = inventory.getItem(i);
            if (!stack.isEmpty() && kind.equals(WeaponIds.deployOf(stack))) {
                stack.shrink(1);
                PvpShotMod.logVerbose("[pvpshot] 玩家 {} 在创造模式下部署，补扣 1 件部署物（{}），与生存模式一致",
                        player.getName().getString(), kind);
                return;
            }
        }
    }

    private static ItemStack firstOfKind(Inventory inventory, String kind) {
        for (int i = 0; i < inventory.getContainerSize(); i++) {
            ItemStack stack = inventory.getItem(i);
            if (!stack.isEmpty() && kind.equals(WeaponIds.deployOf(stack))) {
                return stack;
            }
        }
        return null;
    }

    private static String modeName(ServerPlayer player) {
        if (player.isCreative()) {
            return "创造";
        }
        return player.isSpectator() ? "旁观" : "生存";
    }

    private static int countDeployables(Inventory inventory) {
        int total = 0;
        for (int i = 0; i < inventory.getContainerSize(); i++) {
            var stack = inventory.getItem(i);
            if (!WeaponIds.deployOf(stack).isEmpty()) {
                total += stack.getCount();
            }
        }
        return total;
    }

    private DeployRefundWatch() {
    }
}
