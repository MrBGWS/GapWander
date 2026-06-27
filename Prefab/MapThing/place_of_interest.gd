#兴趣点
#兴趣点用于触发地图事件 如作战
class_name PlaceOfInterest
extends Node2D

@export var enemyGroupID:int
@export var eventID:int

@onready var area:Area2D = $Area2D

var isFinished:bool = false:
    get:
        return isFinished
    set(value):
        isFinished = value
        if value:
            # 变成灰色
            modulate = Color.GRAY  # 或者 Color(0.5,0.5,0.5)
        else:
            # 恢复原色，比如白色
            modulate = Color.WHITE

func _ready() -> void:
    area.area_entered.connect(thing_enter)

func _process(delta: float) -> void:
    pass

#检测玩家进入区域
func thing_enter(targetArea:Area2D):
#    暂时屏蔽
    #if isFinished:
        #return
    print(targetArea.name)
    #通知worldHost开启
    
    isFinished = true
    
    if enemyGroupID > 0:
        GameManager.eventBus.start_fight.emit(enemyGroupID)
    elif eventID > 0:
        GameManager.eventBus.start_event.emit(eventID)
        
    GameManager.eventBus.map_player_pause.emit(true)
    
    
