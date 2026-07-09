#背包UI
extends UIBase
#@onready var HistoryScrollContainer = $HistoryScrollContainer

func get_id():
    return 5

func _ready() -> void:
    #ExitButton.pressed.connect(func(): GameManager.UI.CloseUI(get_id()))
    #SettingResumeButton.pressed.connect(func(): GameManager.UI.CloseUI(get_id()))
    #SettingExitButton.pressed.connect(func(): get_tree().quit())
    pass

func UpdateUI(data):
    super.UpdateUI(data)

func CloseUI():
    super.CloseUI()
