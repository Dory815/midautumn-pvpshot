package pvpshot.match;

/**
 * 比赛参数。数值来源是现状数据包：默认值见 {@code pvpshot:cfg/default}，
 * 校园地图的覆盖值见 {@code ustc_pvp:configure}（本类记录的是**校园包生效后的值**）。
 *
 * <p>之所以先用常量而不是配置文件：数据包原本也是"生成器写死 + 少量覆盖"，
 * 先保证行为一致；等 M3 收尾时再统一抽成 JSON 配置（见 SPEC 5.5 的单一数据来源目标）。
 */
public final class MatchConfig {

    /** 占领判定半径（格），校园包覆盖为 9。 */
    public static final int POINT_RADIUS = 9;

    /** 脚部高度容差（格）：与点位中心高度差超过它就不算在点内。 */
    public static final int POINT_HEIGHT = 3;

    /** 占领进度满值：每 tick ±1，因此 100 对应 5 秒占领。 */
    public static final int CAPTURE_FULL = 100;

    /** 计分脉冲间隔（tick）：20 tick = 1 秒计一次分。 */
    public static final int POINT_INTERVAL_TICKS = 20;

    /** 每个已占领点每秒给多少分。 */
    public static final int POINT_SCORE = 1;

    /** 三点模式目标分。 */
    public static final int GOAL_THREE_POINT = 600;

    /** 五点模式目标分（校园包 #cap.max）。 */
    public static final int GOAL_FIVE_POINT = 1000;

    /** 团队死斗目标分（#tdm.max）。 */
    public static final int GOAL_DEATHMATCH = 60;

    private MatchConfig() {
    }
}
