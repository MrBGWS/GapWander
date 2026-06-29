class_name AutoUnit

extends UnitBase

@onready var stateChart:StateChart = $StateChart

## 攻击冷却时间
@export var coldDown:float = 2.0
var coldDownCount:float = 0.0

func _ready() -> void:
    super._ready()
    SetStateChartValue()


func _process(delta: float) -> void:
    super._process(delta)
    _process_ai(delta)


## 实时 AI：视野内追逐，攻击距离内攻击
func _process_ai(delta: float) -> void:
    var target := GetOneEnemy()
    if target == null:
        input_vector = Vector2.ZERO
        return

    var distance := global_position.distance_to(target.global_position)

    if distance <= data.radiusAttack:
        # 在攻击范围内：停住，冷却好了就攻击
        input_vector = Vector2.ZERO
        coldDownCount -= delta
        if coldDownCount <= 0:
            coldDownCount = coldDown
            Attack(target)

    elif distance <= data.radiusEyeSight:
        # 在视野内但不在攻击范围：追逐目标
        var direction := (target.global_position - global_position).normalized()
        input_vector = direction
        coldDownCount = 0  # 重置冷却，贴身后可以立刻攻击

    else:
        # 超出视野：待机
        input_vector = Vector2.ZERO
        coldDownCount = 0


func Attack(targetUnit:UnitBase = null):
    super.Attack(targetUnit)


func TakeDamage(damage, damageSource = 0, damageType = 0):
    super.TakeDamage(damage, damageSource, damageType)
    SetStateChartValue()


func SetStateChartValue():
    stateChart.set_expression_property("Hp", Hp)
    stateChart.set_expression_property("MaxHp", MaxHp)
