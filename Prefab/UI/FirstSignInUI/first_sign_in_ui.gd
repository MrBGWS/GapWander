#首次登录信息
extends UIBase

signal summit_name(playerName)

@onready var startBtn = $Panel/ConfirmButton
@onready var nameEdit:TextEdit = $Panel/NameEdit

func _ready() -> void:
    #链接事件
    startBtn.pressed.connect(OnPressCommit)
    
func OnPressCommit():
    CloseUI()
    summit_name.emit(nameEdit.text)
