package pvpshot.visual;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.UUID;

import net.minecraft.core.component.DataComponents;
import net.minecraft.network.chat.Component;
import net.minecraft.network.chat.Style;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.entity.Display;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.EntityTypes;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.decoration.Mannequin;
import net.minecraft.world.item.component.ResolvableProfile;

import pvpshot.PvpShotMod;

/**
 * 战斗视觉（M7 服务端侧实现）：**伤害数字 / 头顶血条 / 尸体**。
 *
 * <p>三样都只用原版实体（{@code text_display} 与 {@code mannequin}），
 * 所以**原版客户端就能看到**，不需要任何人装客户端模组 —— 这与项目"纯服务端优先"的原则一致。
 * 客户端模组要做的只是把这些做得更漂亮（平滑动画、暴击提示音等）。
 *
 * <ul>
 *   <li><b>伤害数字</b>：受击时在目标头顶生成一个 text_display，往上飘 ~0.6 格后消失，
 *       颜色按伤害大小分档（白 / 黄 / 红）。</li>
 *   <li><b>头顶血条</b>：每个玩家头顶一个 text_display，显示 10 格进度条 + 当前血量，
 *       只在血量变化时更新文本（避免每 tick 发包）。</li>
 *   <li><b>尸体</b>：玩家死亡时在原地放一个 {@code mannequin}（26.2 的"人偶"实体），
 *       带死者皮肤（从 LyerSkin 的 textures 属性来），20 秒后自动消失。</li>
 * </ul>
 */
public final class CombatVisuals {

    /** 伤害数字飘多久（tick）。 */
    private static final int DAMAGE_NUMBER_TICKS = 16;
    /** 伤害数字每 tick 往上飘多少格。 */
    private static final double DAMAGE_NUMBER_RISE = 0.045;
    /** 尸体停留多久（tick）：20 秒。 */
    private static final int CORPSE_TICKS = 400;

    private static final byte FLAG_SHADOW = 1;
    private static final byte FLAG_SEE_THROUGH = 2;

    private static final String DAMAGE_TAG = "pvpshot.damagenum";
    private static final String CORPSE_TAG = "pvpshot.corpse";

    /** 飘字实体 → 剩余 tick。 */
    private static final Map<Display.TextDisplay, Integer> FLOATING = new HashMap<>();
    /** 血条实体：玩家 UUID → display。 */
    private static final Map<UUID, Display.TextDisplay> BARS = new HashMap<>();
    /** 血条上一次的文本（避免重复发包）。 */
    private static final Map<UUID, String> BAR_TEXT = new HashMap<>();
    /** 尸体实体 → 剩余 tick。 */
    private static final Map<Entity, Integer> CORPSES = new HashMap<>();

    private CombatVisuals() {
    }

    // ------------------------------------------------------------ 伤害数字

    /** 由伤害事件调用：在目标头顶丢一个伤害数字。 */
    public static void onDamage(LivingEntity victim, float amount) {
        if (!(victim.level() instanceof ServerLevel level) || amount < 0.5F) {
            return;
        }
        Display.TextDisplay display = new Display.TextDisplay(EntityTypes.TEXT_DISPLAY, level);
        int rounded = Math.max(1, Math.round(amount));
        display.setText(Component.literal(String.valueOf(rounded))
                .withStyle(Style.EMPTY.withColor(damageColor(rounded))));
        display.setBillboardConstraints(Display.BillboardConstraints.CENTER);
        display.setFlags((byte) (FLAG_SHADOW | FLAG_SEE_THROUGH));
        display.setLineWidth(80);
        display.setPos(victim.getX(),
                victim.getY() + victim.getBbHeight() + 0.35, victim.getZ());
        display.addTag(DAMAGE_TAG);
        level.addFreshEntity(display);
        FLOATING.put(display, DAMAGE_NUMBER_TICKS);
    }

    private static int damageColor(int amount) {
        if (amount >= 8) {
            return 0xFF5555;   // 重击：红
        }
        if (amount >= 4) {
            return 0xFFAA00;   // 中等：橙黄
        }
        return 0xFFFFFF;       // 轻击：白
    }

    // -------------------------------------------------------------- 尸体

    /** 由死亡事件调用：在死亡地点留下一个带皮肤的"人偶"。 */
    public static void onDeath(ServerPlayer player) {
        if (!(player.level() instanceof ServerLevel level)) {
            PvpShotMod.LOGGER.info("[pvpshot] 尸体：{} 不在服务端世界，跳过", player.getName().getString());
            return;
        }
        try {
            Mannequin corpse = new Mannequin(EntityTypes.MANNEQUIN, level);
            corpse.setPos(player.getX(), player.getY(), player.getZ());
            corpse.setYRot(player.getYRot());
            corpse.setXRot(0.0F);
            corpse.addTag(CORPSE_TAG);
            // 皮肤：直接用玩家自己的 GameProfile（含 LyerSkin 签名的 textures 属性），
            // 用了同一个外置登录的客户端都能正常显示。
            corpse.setComponent(DataComponents.PROFILE,
                    ResolvableProfile.createResolved(player.getGameProfile()));
            // 随身装备也照搬一份，看起来更像"尸体"。
            for (var slot : new net.minecraft.world.entity.EquipmentSlot[]{
                    net.minecraft.world.entity.EquipmentSlot.HEAD,
                    net.minecraft.world.entity.EquipmentSlot.CHEST,
                    net.minecraft.world.entity.EquipmentSlot.LEGS,
                    net.minecraft.world.entity.EquipmentSlot.FEET,
                    net.minecraft.world.entity.EquipmentSlot.MAINHAND}) {
                corpse.setItemSlot(slot, player.getItemBySlot(slot).copy());
            }
            boolean added = level.addFreshEntity(corpse);
            if (added) {
                CORPSES.put(corpse, CORPSE_TICKS);
            }
            PvpShotMod.LOGGER.info("[pvpshot] 尸体：为 {} 生成人偶 @ {} {} {}（已加入世界={}）",
                    player.getName().getString(),
                    (int) player.getX(), (int) player.getY(), (int) player.getZ(), added);
        } catch (Exception failure) {
            PvpShotMod.LOGGER.warn("[pvpshot] 尸体生成失败：{}", failure.toString());
            for (StackTraceElement element : failure.getStackTrace()) {
                PvpShotMod.LOGGER.warn("[pvpshot]   at {}", element);
            }
        }
    }

    // ------------------------------------------------------------ 每 tick

    public static void tick(MinecraftServer server) {
        if (!enabled) {
            return;
        }
        ServerLevel level = server.overworld();
        tickFloating();
        tickCorpses();
        tickBars(server, level);
    }

    private static void tickFloating() {
        Iterator<Map.Entry<Display.TextDisplay, Integer>> it = FLOATING.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<Display.TextDisplay, Integer> entry = it.next();
            Display.TextDisplay display = entry.getKey();
            int left = entry.getValue() - 1;
            if (left <= 0 || display.isRemoved()) {
                if (!display.isRemoved()) {
                    display.discard();
                }
                it.remove();
                continue;
            }
            entry.setValue(left);
            display.setPos(display.getX(), display.getY() + DAMAGE_NUMBER_RISE, display.getZ());
            // 最后 6 tick 逐渐变淡
            display.setTextOpacity((byte) (left >= 6 ? -1 : left * 42));
        }
    }

    private static void tickCorpses() {
        Iterator<Map.Entry<Entity, Integer>> it = CORPSES.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<Entity, Integer> entry = it.next();
            Entity corpse = entry.getKey();
            int left = entry.getValue() - 1;
            if (left <= 0 || corpse.isRemoved()) {
                if (!corpse.isRemoved()) {
                    corpse.discard();
                }
                it.remove();
                continue;
            }
            entry.setValue(left);
        }
    }

    private static void tickBars(MinecraftServer server, ServerLevel level) {
        for (ServerPlayer player : server.getPlayerList().getPlayers()) {
            if (!player.isAlive() || player.isSpectator()) {
                removeBar(player.getUUID());
                continue;
            }
            UUID id = player.getUUID();
            Display.TextDisplay bar = BARS.get(id);
            if (bar == null || bar.isRemoved()) {
                bar = new Display.TextDisplay(EntityTypes.TEXT_DISPLAY, level);
                bar.setBillboardConstraints(Display.BillboardConstraints.CENTER);
                bar.setFlags(FLAG_SHADOW);
                bar.setLineWidth(120);
                bar.addTag("pvpshot.healthbar");
                level.addFreshEntity(bar);
                BARS.put(id, bar);
                BAR_TEXT.remove(id);
            }
            bar.setPos(player.getX(), player.getY() + 2.35, player.getZ());
            String text = barText(player);
            if (!text.equals(BAR_TEXT.get(id))) {
                BAR_TEXT.put(id, text);
                bar.setText(Component.literal(text));
            }
        }
    }

    /** 10 格进度条 + 血量数字，颜色随血量从绿到红。 */
    private static String barText(ServerPlayer player) {
        float ratio = player.getMaxHealth() <= 0 ? 0 : player.getHealth() / player.getMaxHealth();
        int filled = Math.max(0, Math.min(10, Math.round(ratio * 10)));
        StringBuilder builder = new StringBuilder(16);
        for (int i = 0; i < 10; i++) {
            builder.append(i < filled ? '█' : '░');
        }
        builder.append(' ').append(Math.round(player.getHealth()));
        return builder.toString();
    }

    private static void removeBar(UUID id) {
        Display.TextDisplay bar = BARS.remove(id);
        BAR_TEXT.remove(id);
        if (bar != null && !bar.isRemoved()) {
            bar.discard();
        }
    }

    /** 玩家离线时清掉血条，避免留下孤儿实体。 */
    public static void forget(ServerPlayer player) {
        removeBar(player.getUUID());
    }

    /** 开关（/pvpshot visual off 时全部隐藏）。 */
    private static boolean enabled = true;

    public static boolean isEnabled() {
        return enabled;
    }

    public static String setEnabled(boolean value) {
        enabled = value;
        if (!value) {
            for (Display.TextDisplay bar : BARS.values()) {
                if (!bar.isRemoved()) {
                    bar.discard();
                }
            }
            BARS.clear();
            BAR_TEXT.clear();
            for (Display.TextDisplay floating : FLOATING.keySet()) {
                if (!floating.isRemoved()) {
                    floating.discard();
                }
            }
            FLOATING.clear();
        }
        return value ? "战斗视觉已开启（伤害数字 / 头顶血条 / 尸体）"
                : "战斗视觉已关闭（伤害数字 / 头顶血条 / 尸体都已隐藏）";
    }
}
