#UI根节点
extends CanvasLayer


func _ready() -> void:
    GameManager.UI.UIRoot = self
    #清空原来UI的索引
    GameManager.UI.RefreshUIDic()
    
    ##打开消息提示ui
    GameManager.UI.OpenUI(1)

func _unhandled_input(event: InputEvent) -> void:
    ##打开消息记录面板
    if event.is_action("EnterPress") and event.is_pressed():
        GameManager.UI.OpenOrCloseUI(3)
    
