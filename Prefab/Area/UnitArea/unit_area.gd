#代表单位的区域
class_name UnitArea
extends Area2D

signal take_damage

##来源单位，可以未空
var sourceUnit:UnitBase

func _ready() -> void:
    set_orignal_data()

func OnHitDamageArea(damageArea:DamageArea):
    if sourceUnit == null:
        return
    if damageArea.team == sourceUnit.team:
        return
    TakeDamage(damageArea.damageValue)
    
func TakeDamage(value:float):
    take_damage.emit(value)

func set_orignal_data():
    # 向上遍历父节点，找到最近的 UnitBase
    var node := get_parent()
    while node != null:
        if node is UnitBase:
            var unit := node as UnitBase
            sourceUnit = unit
            return
        node = node.get_parent()
