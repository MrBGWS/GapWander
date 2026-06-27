#间隙房间

extends Node2D

func _ready() -> void:
    GameManager.eventBus.start_event.connect(StartGame)
    
#从间隙房间进入局内游戏
func StartGame():
    print("游戏开始")
    #TODO 去下一个场景
