#世界根节点 - 管理昼夜循环和游戏流程
extends Node2D

# ============================================
# 时间系统配置（参考GDD 2.2节 时间与月灾系统）
# ============================================
# 月灾：来自月亮的高危能量投射，每天下午开始从地图边缘向中心收缩，
#       圈外区域受到持续能量灼烧伤害。夜晚月灾达到峰值，Boss随之现身。

## 白天探索时长（秒）
@export var day_duration: float = 120.0
## 月灾缩圈时长（秒）
@export var shrink_duration: float = 60.0
## 总天数（默认2天，可通过遗物扩展至3~4天）
@export var total_days: int = 2
## 月灾区每秒伤害百分比
@export var circle_damage_percent: float = 5.0

# ============================================
# 昼夜阶段枚举
# ============================================

enum DayPhase {
    DAY,         # 白天探索期 - 自由探索收集战斗
    SHRINKING,   # 月灾缩圈期 - 月亮能量从边缘向心收缩
    NIGHT,       # 夜晚Boss战 - 月灾达到峰值，Boss现身
    FINAL_BOSS,  # 最终Boss战 - 腐化古树
    ENDGAME      # 终局结算
}

# ============================================
# 当前状态
# ============================================

var current_day: int = 1
var current_phase: DayPhase = DayPhase.DAY
var elapsed_time: float = 0.0
var is_timer_running: bool = false

# ============================================
# 信号
# ============================================

signal day_started(day: int)
signal phase_changed(phase: DayPhase, day: int)
signal time_updated(elapsed: float, phase: DayPhase, day: int)
signal shrinking_started()
signal night_started(day: int)
signal final_boss_started()
signal game_ended()

# ============================================
# 生命周期
# ============================================

func _ready() -> void:
    # 连接战斗结束事件
    GameManager.eventBus.finish_fight.connect(_on_finish_fight)
    # 启动第一天
    StartDay(1)

func _process(delta: float) -> void:
    if not is_timer_running:
        return

    elapsed_time += delta
    time_updated.emit(elapsed_time, current_phase, current_day)

    match current_phase:
        DayPhase.DAY:
            if elapsed_time >= day_duration:
                StartShrinking()

        DayPhase.SHRINKING:
            if elapsed_time >= shrink_duration:
                StartNight()

        # NIGHT 和 FINAL_BOSS 阶段由战斗结束信号驱动，不计时

# ============================================
# 阶段切换
# ============================================

## 开始新的一天
func StartDay(day: int) -> void:
    current_day = day
    current_phase = DayPhase.DAY
    elapsed_time = 0.0
    is_timer_running = true

    day_started.emit(day)
    phase_changed.emit(DayPhase.DAY, day)
    print("☀️ 第 %d 天 白天开始 - 自由探索阶段" % day)

## 下午 - 月灾开始收缩（月亮能量从边缘涌入）
func StartShrinking() -> void:
    current_phase = DayPhase.SHRINKING
    elapsed_time = 0.0

    shrinking_started.emit()
    phase_changed.emit(DayPhase.SHRINKING, current_day)
    GameManager.eventBus.start_event.emit(10)  # 月灾缩圈事件ID
    print("⚠️ 月灾开始收缩！月亮能量从边缘涌入！")

## 夜晚 - Boss战
func StartNight() -> void:
    current_phase = DayPhase.NIGHT
    elapsed_time = 0.0
    is_timer_running = false  # 夜晚暂停计时，等待Boss战结束

    night_started.emit(current_day)
    phase_changed.emit(DayPhase.NIGHT, current_day)
    GameManager.eventBus.start_fight.emit(100 + current_day)  # Boss敌人组ID
    GameManager.eventBus.start_event.emit(20 + current_day)   # 夜晚事件ID
    print("🌙 第 %d 天 夜晚降临 - Boss现身！" % current_day)

## 进入下一天或终局
func StartNextDayOrEndgame() -> void:
    if current_day < total_days:
        # 还有下一天
        StartDay(current_day + 1)
    else:
        # 最后一天结束，进入最终Boss
        StartFinalBoss()

## 最终Boss战
func StartFinalBoss() -> void:
    current_phase = DayPhase.FINAL_BOSS
    elapsed_time = 0.0
    is_timer_running = false

    final_boss_started.emit()
    phase_changed.emit(DayPhase.FINAL_BOSS, current_day)
    GameManager.eventBus.start_fight.emit(999)  # 最终Boss敌人组ID
    GameManager.eventBus.start_event.emit(30)   # 终局事件ID
    print("👑 最终Boss战 - 腐化古树现身！")

## 终局结算
func StartEndgame() -> void:
    current_phase = DayPhase.ENDGAME
    is_timer_running = false

    game_ended.emit()
    phase_changed.emit(DayPhase.ENDGAME, current_day)
    GameManager.eventBus.start_event.emit(40)  # 结算事件ID
    print("🏆 游戏结束 - 进入结算")

# ============================================
# 事件回调
# ============================================

## 战斗结束时的处理
func _on_finish_fight() -> void:
    match current_phase:
        DayPhase.NIGHT:
            print("第 %d 天 Boss 被击败！" % current_day)
            StartNextDayOrEndgame()

        DayPhase.FINAL_BOSS:
            print("最终Boss被击败！")
            StartEndgame()

# ============================================
# 公共查询接口（供UI/HUD使用）
# ============================================

## 获取当前时间信息
func get_time_info() -> Dictionary:
    return {
        "day": current_day,
        "total_days": total_days,
        "phase": current_phase,
        "phase_name": DayPhase.keys()[current_phase],
        "elapsed": elapsed_time,
    }

## 获取当前阶段剩余时间（秒），夜晚/Boss战返回 -1
func get_remaining_time() -> float:
    match current_phase:
        DayPhase.DAY:
            return max(0.0, day_duration - elapsed_time)
        DayPhase.SHRINKING:
            return max(0.0, shrink_duration - elapsed_time)
        _:
            return -1.0

## 获取阶段名称（中文）
func get_phase_display_name() -> String:
    match current_phase:
        DayPhase.DAY:
            return "白天探索"
        DayPhase.SHRINKING:
            return "月灾缩圈"
        DayPhase.NIGHT:
            return "夜晚Boss战"
        DayPhase.FINAL_BOSS:
            return "最终Boss战"
        DayPhase.ENDGAME:
            return "结算"
        _:
            return "???"
        

## 暂停/恢复计时
func set_timer_paused(paused: bool) -> void:
    # 仅在DAY和SHRINKING阶段可暂停
    if current_phase == DayPhase.DAY or current_phase == DayPhase.SHRINKING:
        is_timer_running = not paused
