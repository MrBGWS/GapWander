#记录历史游戏信息 
class_name HistoryHandler
extends Node

var gameEventStrList:Array[String]

func OnReady():
    #GameManager.eventBus.change_fragment.connect(add_history_fram)
    pass
    
func add_game_event_str(message:String):
    gameEventStrList.append(message)
    #通知ReordUI处理
    
