#展示箭头提示的UI

extends Control
var ArrowRecordPrefab = preload("res://Prefab/UI/ArrowShowUI/arrow_record.tscn")
@onready var ArrowParent = $ArrowParent

var Recording:bool = false

var arrowList:Array[Control] = []

func _ready() -> void:
    GameManager.eventBus.start_fight.connect(OnFightStart)
    GameManager.eventBus.finish_fight.connect(ClearArrowList)
    GameManager.eventBus.turn_start.connect(OnStop)
    GameManager.eventBus.turn_finish.connect(OnStart)
    
    GameManager.eventBus.player_input_arrow.connect(init_arrow)
    GameManager.eventBus.player_input_clear_arrow.connect(ClearArrowList)

func OnStart():
    Recording = true

func OnStop():
    Recording = false
    ClearArrowList()
func OnFightStart(EnemyGroupID):
    OnStart()

func _process(delta: float) -> void:
    pass
#func _input(event):
    #if event.is_action_pressed("ui_up"):
        #init_arrow(1)
    #elif event.is_action_pressed("ui_down"):
        #init_arrow(2)
    #elif event.is_action_pressed("ui_left"):
        #init_arrow(3)
    #elif event.is_action_pressed("ui_right"):
        #init_arrow(4)
        

func init_arrow(toward):
    if !Recording:
        return
    var arrow:Control = ArrowRecordPrefab.instantiate()
    ArrowParent.add_child(arrow)
    arrowList.append(arrow)
    arrow.set_direction(toward)

func ClearArrowList():
    for arrow in arrowList:
        arrow.Finish()
    arrowList.clear()

func GetCurrntArrowGroupDirs():
    var Dirs:Array[int] = []
    for arrow in arrowList:
        Dirs.append(arrow.dic)
    return Dirs
