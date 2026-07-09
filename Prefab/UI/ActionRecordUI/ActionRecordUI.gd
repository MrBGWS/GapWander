#动作记录UI
extends UIBase
@onready var OneRecordPrefab = preload("res://Prefab/UI/ActionRecordUI/one_action_record.tscn")
@onready var HistoryScrollContainer = $HistoryScrollContainer
@onready var RecordListUI = $HistoryScrollContainer/RecordListContain
#@onready var ExitButton = $ExitButton

var RecordGridList:Array[Control] = []

func get_id():
    return 4

func _ready() -> void:
    #ExitButton.pressed.connect(func(): GameManager.UI.CloseUI(get_id()))
    GameManager.eventBus.add_game_event_str.connect(on_add_game_event_str)


func UpdateUI(data):
    super.UpdateUI(data)
    #根據記錄生成record
    var index = 0
    for historyFram in GameManager.History.gameEventStrList:
        if index + 1 > RecordGridList.size():
            var OneRecord = OneRecordPrefab.instantiate()
            RecordListUI.add_child(OneRecord)
            OneRecord.update_render(historyFram)
            RecordGridList.append(OneRecord)
        else:
            RecordGridList[index].update_render(historyFram)
        index = index + 1
    
    #滚动到最后一项
    RollToEnd.call_deferred()

func on_add_game_event_str(messageStr):
    var OneRecord = OneRecordPrefab.instantiate()
    RecordListUI.add_child(OneRecord)
    OneRecord.update_render(messageStr)
    RecordGridList.append(OneRecord)
    
    #滚动到最后一项
    RollToEnd.call_deferred()

func CloseUI():
    super.CloseUI()

#直接抓取ui时间滚动滚轮
func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        # 自定义滚动逻辑
        HistoryScrollContainer.scroll_vertical -= event.relative.y

func RollToEnd():
    #滚动到最后一项
    HistoryScrollContainer.scroll_vertical =  HistoryScrollContainer.get_v_scroll_bar().max_value
