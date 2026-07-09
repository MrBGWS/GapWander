#打开設置的按钮
extends Button


func _ready() -> void:
    pressed.connect(onPressed)
    
func onPressed():
    GameManager.UI.OpenUI(2)
