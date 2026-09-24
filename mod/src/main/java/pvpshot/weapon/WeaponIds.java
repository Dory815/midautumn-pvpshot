package pvpshot.weapon;

import net.minecraft.core.component.DataComponents;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.component.CustomData;

/**
 * 武器身份识别。
 *
 * <p>本项目的武器都是**原版物品 + {@code custom_data} 标记**（例如普通物品栏里的
 * 火焰弹其实就是火球物品，靠 {@code pvpshot.weapon} 字段区分）。
 * 这样原版客户端不需要任何额外资源就能认。
 */
public final class WeaponIds {

    /** 读取物品上的 {@code pvpshot.weapon} 标识；不是本模组的武器则返回空串。 */
    public static String of(ItemStack item) {
        if (item == null || item.isEmpty()) {
            return "";
        }
        CustomData data = item.get(DataComponents.CUSTOM_DATA);
        if (data == null) {
            return "";
        }
        return data.copyTag().getCompoundOrEmpty("pvpshot").getStringOr("weapon", "");
    }

    /**
     * 读取物品上的 {@code pvpshot.deploy} 标识（部署物：{@code cannon} / {@code turret} / {@code bunker}）；
     * 不是部署物则返回空串。
     *
     * <p>用途：部署物是"吃掉就放"的道具，数据包在部署失败时会用 {@code loot give} 把它塞回背包。
     * 模组用这个标识给玩家的背包做一次前后对比，把"消耗 / 退回"写进日志，
     * 免得再靠肉眼判断"到底有没有退还"。
     */
    public static String deployOf(ItemStack item) {
        if (item == null || item.isEmpty()) {
            return "";
        }
        CustomData data = item.get(DataComponents.CUSTOM_DATA);
        if (data == null) {
            return "";
        }
        return data.copyTag().getCompoundOrEmpty("pvpshot").getStringOr("deploy", "");
    }

    private WeaponIds() {
    }
}
