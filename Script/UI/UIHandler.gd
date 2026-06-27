class_name UIHandler
extends Node

var UIRoot
#UI资源
var UIResDic:UIConfig

#func _ready() -> void:
    #GameManager.eventBus.one_ui_open.connect(OpenUI)
    #GameManager.eventBus.one_ui_close.connect(CloseUI)

func OnReady():
    UIResDic = preload("res://Prefab/UI/UIConfig/UIConfig.tres")
    
#UI部分
var UIDic = {}
func OpenUI(id, data = null):
    RefreshUIDic()
    var ui
    if UIDic.has(id):
        ui = UIDic[id]
    else :
        var UIPackedSence = UIResDic.UIDic[id]
        ui = UIPackedSence.instantiate()
        UIRoot.add_child(ui)
        UIDic[id] = ui
    ui.UpdateUI.call_deferred(data) #初始化
    GameManager.eventBus.one_ui_open.emit(id)
    
    return ui
    
func CloseUI(id):
    RefreshUIDic()
    if UIDic.has(id) :
        UIDic[id].CloseUI()
    GameManager.eventBus.one_ui_close.emit(id)

##将索引为空的UI都清理了
func RefreshUIDic():
    var needEraseId:Array[int] = []
    for key in UIDic:
        var ui = UIDic[key]
        if ui == null or not is_instance_valid(ui):
            needEraseId.append(key)
    
    for id in needEraseId:
        UIDic.erase(id)
