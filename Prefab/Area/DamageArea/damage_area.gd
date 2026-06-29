#能造成伤害的区域
class_name DamageArea
extends Area2D

##伤害数字
var damageValue:float = 5.0

##伤害区域的阵营
@export var team = 1 #1 玩家 2敌人 0场景

##来源单位，可以未空
var sourceUnit:UnitBase

func _ready() -> void:
    area_entered.connect(_on_area_entered)
    set_orignal_data()

func set_orignal_data():
    # 向上遍历父节点，找到最近的 UnitBase
    var node := get_parent()
    while node != null:
        if node is UnitBase:
            var unit := node as UnitBase
            damageValue = unit.AttackPower
            team = unit.team
            sourceUnit = unit
            return
        node = node.get_parent()

func _on_area_entered(area):
    var unitArea = area as UnitArea
    if unitArea:
        unitArea.OnHitDamageArea(self)
