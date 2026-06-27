class_name AutoUnit

extends UnitBase

@onready var stateChart:StateChart = $StateChart



var coldDown:float = 5.0
var coldDownCount:float = 5.0

func _ready() -> void:
    super._ready()
    
    SetStateChartValue()
    PrepareNextTurnAction()
    
    GameManager.eventBus.turn_finish.connect(PrepareNextTurnAction)

func _process(delta: float) -> void:
    super._process(delta)
    coldDownCount -= delta
    if coldDownCount < 0:
        coldDownCount = coldDown
        #ReadyToAttack()

#决定下回合的动作
func PrepareNextTurnAction():
    var targetUnit = GetOneEnemy()
    turnAction = func():
        Attack(targetUnit)
#func ReadyToAttack():
    ##攻击需要一段提示时间才会生效
    ##寻找一个目标进行攻击
    #var targetUnit = GetOneEnemy()
    ##提示
    #targetUnit.ShowWarning(1)
    #GameManager.eventBus.add_game_event_str.emit("autounit准备攻击")
    #await get_tree().create_timer(1).timeout
    #Attack(targetUnit)
    

func Attack(targetUnit:UnitBase):
    super.Attack(targetUnit)
    
    
func TakeDamage(damage, damageSource = 0,damageType = 0):
    super.TakeDamage(damage, damageSource , damageType)
    SetStateChartValue()

func SetStateChartValue():
    stateChart.set_expression_property("Hp", Hp)
    stateChart.set_expression_property("MaxHp", MaxHp)
