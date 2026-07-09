#月灾区域 - 月灾圈外区域，持续对范围内的玩家单位造成伤害
extends Node2D

## 每秒最大生命值伤害百分比
@export var damage_percent_per_second: float = 5.0
## 是否激活伤害
@export var is_active: bool = true:
    set(value):
        is_active = value
        visible = is_active
        if value:
            _damage_timer.start()
        else:
            _damage_timer.stop()

@onready var area_2d: Area2D = $Area2D

# 当前在区域内的单位集合
var _units_inside: Array[UnitBase] = []
# 每秒触发的伤害计时器
var _damage_timer: Timer


func _ready() -> void:
    if area_2d:
        area_2d.body_entered.connect(_on_body_entered)
        area_2d.body_exited.connect(_on_body_exited)
    else:
        push_error("MoonDisaster：找不到 Area2D 子节点")

    # 创建每秒触发的计时器
    _damage_timer = Timer.new()
    _damage_timer.wait_time = 1.0
    _damage_timer.one_shot = false
    _damage_timer.timeout.connect(_apply_damage_to_units)
    add_child(_damage_timer)
    _damage_timer.start()

    #初始不可见
    is_active = false


# 单位进入区域
func _on_body_entered(body: Node2D) -> void:
    var unit := body as UnitBase
    if unit == null:
        return
    # 只追踪玩家队伍
    if unit.team != 0:
        return
    if not _units_inside.has(unit):
        _units_inside.append(unit)


# 单位离开区域
func _on_body_exited(body: Node2D) -> void:
    var unit := body as UnitBase
    if unit == null:
        return
    _units_inside.erase(unit)


# 对所有范围内的单位施加伤害（每秒调用一次）
func _apply_damage_to_units() -> void:
    # 清理已释放的无效单位
    _units_inside = _units_inside.filter(func(u): return is_instance_valid(u))

    for unit in _units_inside:
        var damage: float = unit.MaxHp * (damage_percent_per_second / 100.0)
        unit.TakeDamage(damage, 0, 0)


# 设置月灾是否激活
func set_active(active: bool) -> void:
    is_active = active
