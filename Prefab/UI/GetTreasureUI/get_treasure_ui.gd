#宝物获得UI
extends UIBase
@onready var GiveUpBtn = $GiveUpBtn

func get_id():
    return 6

func _ready() -> void:
    GiveUpBtn.pressed.connect(func(): GameManager.UI.CloseUI(get_id()))
    GameManager.eventBus.choose_one_reward.connect(func(): GameManager.UI.CloseUI(get_id()))
    #SettingResumeButton.pressed.connect(func(): GameManager.UI.CloseUI(get_id()))
    #SettingExitButton.pressed.connect(func(): get_tree().quit())

func UpdateUI(data):
    super.UpdateUI(data)

func CloseUI():
    super.CloseUI()
    GameManager.eventBus.map_player_pause.emit(false)
