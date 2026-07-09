#局内设置UI
extends UIBase
@onready var HistoryScrollContainer = $HistoryScrollContainer
@onready var RecordListUI = $HistoryScrollContainer/RecordListContain
@onready var ExitButton = $ExitButton
@onready var SettingResumeButton = $HistoryScrollContainer/RecordListContain/SettingResumeButton
@onready var SettingExitButton = $HistoryScrollContainer/RecordListContain/SettingExitButton

func get_id():
    return 2

func _ready() -> void:
    ExitButton.pressed.connect(func(): GameManager.UI.CloseUI(get_id()))
    SettingResumeButton.pressed.connect(func(): GameManager.UI.CloseUI(get_id()))
    SettingExitButton.pressed.connect(func(): get_tree().quit())

func UpdateUI(data):
    super.UpdateUI(data)

func CloseUI():
    super.CloseUI()
