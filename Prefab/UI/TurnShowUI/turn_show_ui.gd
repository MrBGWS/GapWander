extends UIBase
var TurnPoint = preload("res://Prefab/UI/TurnShowUI/turn_point.tscn")

#时间轴总展示时间
@export var totalShowTime = 15
#每个回合点之间的时间
@export var turnSpaceTime = 2.5
var turnSpaceTimeCount = 0.0

@onready var baseLineUI:TextureRect = $TimeLineParent/BaseLine

var turnPointList:Array[Control] = []

func _ready() -> void:
    GameManager.eventBus.turn_start.connect(func(): SetPuase(true))
    GameManager.eventBus.turn_finish.connect(func(): SetPuase(false))
    
    #开始时在轴上生产满回合点的对象 并记录在一个列表里
    var totalNum:int = floor(totalShowTime / turnSpaceTime)
    
    # 获取 BaseLine 的宽度和位置（相对于 TimeLineParent）
    var baseLineWidth = baseLineUI.size.x

    # 计算间距
    var spacing = baseLineWidth / (totalNum + 0.0)



    for i in range(totalNum):
        # 计算点的 X 坐标（两端留空）
        var x = spacing * (i + 0)
        init_one_turnpoint(x)

var isPause:bool = false

func SetPuase(pause):
    isPause = pause
    turnPointList = turnPointList.filter(func(e): return e != null and e.is_inside_tree())
    for point in turnPointList:
        point.process_mode = Node.PROCESS_MODE_DISABLED if pause else Node.PROCESS_MODE_INHERIT

func init_one_turnpoint(posX):
    var point:TextureRect = TurnPoint.instantiate()
    baseLineUI.add_child(point)
    turnPointList.append(point)
    # 确定点的 Y 坐标（假设点放置在 BaseLine 的上方或中心，这里设为 BaseLine 的中心线）
    var x = posX - point.size.x / 2
    var y = baseLineUI.position.y # + baseLineUI.size.y / 2
    point.position = Vector2(x, y)
    #设置其生存的总时间
    point.lifeTime = totalShowTime - totalShowTime * (posX / baseLineUI.size.x)

func _process(delta: float) -> void:
    if isPause:
        return
        
    turnSpaceTimeCount += delta
    if turnSpaceTimeCount > turnSpaceTime :
        turnSpaceTimeCount = 0
        #生成一个对象在起点
        init_one_turnpoint(0)
        
    turnPointList = turnPointList.filter(func(e): return e != null and e.is_inside_tree())
    #展示新的回合点
    for turnPoint in turnPointList:
        turnPoint.position.x += get_move_speed() * delta
        #if turnPoint.position.x + turnPoint.size.x / 2 > baseLineUI.size.x:
            ##节点可以释放
            #GameManager.eventBus.turn_start.emit()
            #turnPoint.queue_free()

func get_move_speed():
    var move_speed = baseLineUI.size.x / floor(totalShowTime / turnSpaceTime) / turnSpaceTime
    return move_speed
    
