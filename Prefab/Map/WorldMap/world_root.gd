#世界根节点 - 管理昼夜循环和游戏流程
extends Node2D


#所有房间的根节点
@onready var RoomRoot:Node2D = $RoomRoot
# ============================================
# 时间系统配置（参考GDD 2.2节 时间与月灾系统）
# ============================================
# 月灾：来自月亮的高危能量投射，每天下午开始从地图边缘向中心收缩，
#       圈外区域受到持续能量灼烧伤害。夜晚月灾达到峰值，Boss随之现身。

## 白天探索时长（秒）
@export var day_duration: float = 10.0
## 每次缩圈时长（秒）
@export var shrink_duration: float = 20.0
## 两段缩圈之间的稳定时长（秒）
@export var stable_duration: float = 30.0
## 总天数（默认2天，可通过遗物扩展至3~4天）
@export var total_days: int = 2
## 月灾区每秒伤害百分比
@export var circle_damage_percent: float = 5.0
## 第一缩圈的安全距离（最终房间周围多少步内不受月灾影响）
@export var first_shrink_safe_distance: int = 2

# ============================================
# 昼夜阶段枚举
# ============================================

enum DayPhase {
    DAY,           # 白天探索期 - 自由探索收集战斗
    SHRINKING_1,   # 第一缩圈期 - 从边缘缩到距离最终房间N步之外
    STABLE,        # 稳定期 - 缩圈暂停，给玩家缓冲时间
    SHRINKING_2,   # 第二缩圈期 - 缩到仅剩最终房间安全
    NIGHT,         # 夜晚Boss战 - 月灾达到峰值，Boss现身
    FINAL_BOSS,    # 最终Boss战 - 腐化古树
    ENDGAME        # 终局结算
}

# ============================================
# 当前状态
# ============================================

var current_day: int = 1
var current_phase: DayPhase = DayPhase.DAY
var elapsed_time: float = 0.0
var is_timer_running: bool = false

# ============================================
# 月灾缩圈状态
# ============================================

## 最终安全房间的网格坐标
var final_room_offset: Vector2i = Vector2i(-1, -1)
## 所有房间按距离分组（key: 曼哈顿距离, value: 房间数组）
var _rooms_by_distance: Dictionary = {}
## 当前缩圈正在处理的半径
var _current_shrink_radius: int = 0
## 缩圈目标半径（缩到此半径后停止）
var _target_shrink_radius: int = 0
## 缩圈每步间隔（秒）
var _shrink_step_interval: float = 1.0
## 缩圈步进计时器
var _shrink_step_timer: float = 0.0
## 已被月灾激活的房间集合（用于避免重复激活）
var _activated_rooms: Array[MapRoom] = []

# ============================================
# 信号
# ============================================

signal day_started(day: int)
signal phase_changed(phase: DayPhase, day: int)
signal time_updated(elapsed: float, phase: DayPhase, day: int)
signal shrinking_started()
signal shrinking_phase2_started()
signal stable_started()
signal night_started(day: int)
signal final_boss_started()
signal game_ended()
signal moon_disaster_activated(room: MapRoom)
signal final_room_chosen(room_offset: Vector2i)

# ============================================
# 生命周期
# ============================================

func _ready() -> void:
    # 连接战斗结束事件
    GameManager.eventBus.finish_fight.connect(_on_finish_fight)
    #TODO 等待房间初始化完成
    RoomRoot.room_init_finish.connect(
        func():
            # 启动第一天
            StartDay(1)
            )
    

func _process(delta: float) -> void:
    if not is_timer_running:
        return

    elapsed_time += delta
    time_updated.emit(elapsed_time, current_phase, current_day)

    match current_phase:
        DayPhase.DAY:
            if elapsed_time >= day_duration:
                StartShrinking1()

        DayPhase.SHRINKING_1:
            _process_shrink(delta)
            if elapsed_time >= shrink_duration:
                StartStable()

        DayPhase.STABLE:
            if elapsed_time >= stable_duration:
                StartShrinking2()

        DayPhase.SHRINKING_2:
            _process_shrink(delta)
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

    # 如果最终房间还没选，随机选一个
    if final_room_offset == Vector2i(-1, -1):
        _pick_final_room()

    day_started.emit(day)
    phase_changed.emit(DayPhase.DAY, day)
    print("☀️ 第 %d 天 白天开始 - 自由探索阶段" % day)

## 第一缩圈期 - 从最外层逐步缩到安全距离
func StartShrinking1() -> void:
    current_phase = DayPhase.SHRINKING_1
    elapsed_time = 0.0

    # 确保最终房间已选定
    if final_room_offset == Vector2i(-1, -1):
        _pick_final_room()

    # 构建距离分组
    _build_distance_groups()

    # 目标：激活所有距离 > first_shrink_safe_distance 的房间
    _target_shrink_radius = first_shrink_safe_distance + 1
    _current_shrink_radius = _rooms_by_distance.keys().max() if _rooms_by_distance.size() > 0 else 0
    _setup_shrink_step()

    shrinking_started.emit()
    phase_changed.emit(DayPhase.SHRINKING_1, current_day)
    GameManager.eventBus.start_event.emit(10)  # 月灾缩圈事件ID
    print("⚠️ 第一缩圈开始！从边缘缩到安全距离 %d 步" % first_shrink_safe_distance)

## 稳定期 - 缩圈暂停
func StartStable() -> void:
    current_phase = DayPhase.STABLE
    elapsed_time = 0.0

    stable_started.emit()
    phase_changed.emit(DayPhase.STABLE, current_day)
    print("⏸️ 稳定期开始，持续 %.0f 秒" % stable_duration)

## 第二缩圈期 - 从安全距离缩到只剩最终房间
func StartShrinking2() -> void:
    current_phase = DayPhase.SHRINKING_2
    elapsed_time = 0.0

    # 目标：激活所有距离 > 0 的房间（即除了最终房间之外的所有房间）
    _target_shrink_radius = 1
    _current_shrink_radius = first_shrink_safe_distance
    _setup_shrink_step()

    shrinking_phase2_started.emit()
    phase_changed.emit(DayPhase.SHRINKING_2, current_day)
    GameManager.eventBus.start_event.emit(11)  # 第二缩圈事件ID
    print("⚠️ 第二缩圈开始！缩到仅剩最终房间安全")

## 夜晚 - Boss战
func StartNight() -> void:
    current_phase = DayPhase.NIGHT
    elapsed_time = 0.0
    is_timer_running = false  # 夜晚暂停计时，等待Boss战结束

    night_started.emit(current_day)
    phase_changed.emit(DayPhase.NIGHT, current_day)
    GameManager.eventBus.start_fight.emit(100 + current_day)  # Boss敌人组ID
    GameManager.eventBus.start_event.emit(20 + current_day)   # 夜晚事件ID
    print("🌙 第 %d 天 夜晚降临 - Boss现身！最终房间：%s" % [current_day, final_room_offset])

## 进入下一天或终局
func StartNextDayOrEndgame() -> void:
    if current_day < total_days:
        # 还有下一天，重置月灾状态
        _reset_moon_disaster()
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
# 月灾缩圈逻辑
# ============================================

## 随机选择一个房间作为最终安全房间
func _pick_final_room() -> void:
    if RoomRoot == null or RoomRoot.maproomList.is_empty():
        push_error("world_root：RoomRoot 或房间列表为空，无法选择最终房间")
        return

    var room_count = RoomRoot.maproomList.size()
    var random_index = randi_range(0, room_count - 1)
    var room: MapRoom = RoomRoot.maproomList[random_index]
    final_room_offset = room.roomOffset

    final_room_chosen.emit(final_room_offset)
    print("🎯 最终安全房间选定：%s" % final_room_offset)

## 按曼哈顿距离将所有房间分组
func _build_distance_groups() -> void:
    _rooms_by_distance.clear()

    for room: MapRoom in RoomRoot.maproomList:
        var dist = _manhattan_distance(room.roomOffset, final_room_offset)
        if not _rooms_by_distance.has(dist):
            _rooms_by_distance[dist] = []
        _rooms_by_distance[dist].append(room)

## 计算两个网格坐标的曼哈顿距离
func _manhattan_distance(a: Vector2i, b: Vector2i) -> int:
    return abs(a.x - b.x) + abs(a.y - b.y)

## 设置缩圈步进参数
func _setup_shrink_step() -> void:
    var ring_count = _current_shrink_radius - _target_shrink_radius + 1
    if ring_count <= 0:
        _shrink_step_interval = 0.0
        return
    _shrink_step_interval = shrink_duration / float(ring_count)
    _shrink_step_timer = 0.0

## 每帧处理缩圈步进
func _process_shrink(delta: float) -> void:
    if _current_shrink_radius < _target_shrink_radius:
        return  # 已经缩到目标

    _shrink_step_timer += delta
    if _shrink_step_timer < _shrink_step_interval:
        return

    # 激活当前半径的所有房间
    _shrink_step_timer -= _shrink_step_interval
    _activate_rooms_at_radius(_current_shrink_radius)
    _current_shrink_radius -= 1

    if _current_shrink_radius < _target_shrink_radius:
        print("缩圈完成，当前安全距离：%d" % (_current_shrink_radius + 1))

## 激活指定距离的所有房间的月灾
func _activate_rooms_at_radius(radius: int) -> void:
    if not _rooms_by_distance.has(radius):
        return

    for room: MapRoom in _rooms_by_distance[radius]:
        _activate_room_disaster(room)

## 激活单个房间的月灾
func _activate_room_disaster(room: MapRoom) -> void:
    if room == null or _activated_rooms.has(room):
        return

    var moon_disaster = room.get_node_or_null("MoonDisaster")
    if moon_disaster and moon_disaster.has_method("set_active"):
        moon_disaster.set_active(true)

    _activated_rooms.append(room)
    moon_disaster_activated.emit(room)

## 重置所有月灾状态（进入新的一天时调用）
func _reset_moon_disaster() -> void:
    for room: MapRoom in _activated_rooms:
        if room == null:
            continue
        var moon_disaster = room.get_node_or_null("MoonDisaster")
        if moon_disaster and moon_disaster.has_method("set_active"):
            moon_disaster.set_active(false)
    _activated_rooms.clear()
    _rooms_by_distance.clear()
    _current_shrink_radius = 0
    _target_shrink_radius = 0
    _shrink_step_timer = 0.0

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
        DayPhase.SHRINKING_1:
            return max(0.0, shrink_duration - elapsed_time)
        DayPhase.STABLE:
            return max(0.0, stable_duration - elapsed_time)
        DayPhase.SHRINKING_2:
            return max(0.0, shrink_duration - elapsed_time)
        _:
            return -1.0

## 获取阶段名称（中文）
func get_phase_display_name() -> String:
    match current_phase:
        DayPhase.DAY:
            return "白天探索"
        DayPhase.SHRINKING_1:
            return "第一缩圈"
        DayPhase.STABLE:
            return "稳定期"
        DayPhase.SHRINKING_2:
            return "第二缩圈"
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
    # 仅在计时阶段可暂停
    if current_phase != DayPhase.NIGHT and current_phase != DayPhase.FINAL_BOSS and current_phase != DayPhase.ENDGAME:
        is_timer_running = not paused
