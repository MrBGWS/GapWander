#事件UI
extends UIBase

@onready var selectBotton:TextureButton = $HistoryScrollContainer/HBoxContainer/VBoxContainer/BottonGroup/SelectBotton
@onready var selectBotton2:TextureButton = $HistoryScrollContainer/HBoxContainer/VBoxContainer/BottonGroup/SelectBotton2
@onready var selectBotton3:TextureButton = $HistoryScrollContainer/HBoxContainer/VBoxContainer/BottonGroup/SelectBotton3

func get_id():
    return 3

func _ready() -> void:
    selectBotton.pressed.connect(func(): GameManager.UI.CloseUI(get_id()))
    selectBotton2.pressed.connect(func(): GameManager.UI.CloseUI(get_id()))
    selectBotton3.pressed.connect(func(): GameManager.UI.CloseUI(get_id()))

func UpdateUI(data):
    super.UpdateUI(data)

func CloseUI():
    super.CloseUI()
    GameManager.eventBus.map_player_pause.emit(false)
