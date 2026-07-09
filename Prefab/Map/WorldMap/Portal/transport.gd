#传送门
class_name Protal
extends Node2D
##该传送门id
@export var protalID:int = 1
##指向的房间的相对位置
@export var targetOffset:Vector2i = Vector2i(1, 0)
##对应的目标房间的传送门id
@export var targetProtalID:int = 1
##所属房间
var room:MapRoom

@onready var SecondCore = $BackGround/SecondCore
@onready var TransportCore = $BackGround/TransportCore
@onready var Ring1 = $BackGround/ring1
@onready var Ring2 = $BackGround/ring2
@onready var light = $PointLight2D
# 导出曲线资源（用于控制强度变化）
@export var intensity_curve: Curve
var originEnergy:float = 1.0 #设置的原始光强度
var baseEnergy:float #基础光强度

var _timer:float = 0.0
var _coreScale:float = 1

var rotationSpeed:float = 0.4

#传送检查
@onready var checkArea = $CheakArea

var canInteract = false

@export var isHide = false
var curUnit:UnitBase
var alphaTween:Tween


func _ready() -> void:
    if light != null :
        originEnergy = light.energy
        baseEnergy = light.energy
    checkArea.body_entered.connect(_on_body_entered)
    checkArea.body_exited.connect(_on_body_exited)
    if isHide:
        visible = false
        modulate.a = 0
        
    #向房间注册自己
    var parent = get_parent()
    if parent is MapRoom:
        parent.protalList.append(self)
        room = parent
    else:
        print("有传送门在房间外！")
    
# 当有物体进入区域时
func _on_body_entered(object):
    var body = object as UnitBase
    if body == null:
        return
    if body.data.team != 0 and not body.data.isHero:
        return
    if curUnit != null and not is_instance_valid(curUnit):
        return
    #for item in body.data.inventory:
        #if item.id == 0:
    GameManager.eventBus.show_msg.emit("按下" + UtilsTool.get_action_name("interact") + "键交互")
    canInteract = true
    if isHide:
        show_hide(true)
        #希望有个逐渐出现的效果

    curUnit = body
# 当有物体离开区域时
func _on_body_exited(object):
    var body = object as UnitBase
    if body == null:
        return
    if curUnit != body:
        return

    #for item in body.data.inventory:
        #if item.id == 0:
    canInteract = false
    if isHide:
        show_hide(false)
    
    if curUnit != null:
        curUnit = null
func _process(delta: float) -> void:
    if canInteract and Input.is_action_just_pressed("interact"):
        print("进入 ... 房间")
        #把主控单位移入目标房间变化场景
        if room != null:
            GameManager.eventBus.change_world_room.emit(room.roomOffset + targetOffset, targetProtalID)
    if not intensity_curve or light == null:
        return
    
    refresh_timer(delta)
    
func refresh_timer(delta):
    # 更新计时器（循环周期）
    _timer = fmod(_timer + delta, intensity_curve.get_domain_range())
    var _timer1 = fmod(_timer + delta + 1, intensity_curve.get_domain_range())
    var _timer2 = fmod(_timer + delta + 2, intensity_curve.get_domain_range())
    var _timer3 = fmod(_timer + delta + 3, intensity_curve.get_domain_range())
    # 从曲线获取强度值并应用
    var lightEnergy = intensity_curve.sample(_timer) * baseEnergy
    light.energy = lightEnergy
    
    var scale0 = intensity_curve.sample(_timer1) * _coreScale / 2 + 0.5
    SecondCore.scale = Vector2.ONE * scale0
    
    var scale1 = intensity_curve.sample(_timer2) * _coreScale / 2 + 0.5
    TransportCore.scale = Vector2.ONE * scale1
    
    var scale2 = intensity_curve.sample(_timer3) * _coreScale / 2 + 0.5
    Ring1.scale = Vector2.ONE * scale2
    
    rotation += delta * 0.4 * (intensity_curve.sample(_timer) - 1)

func show_hide(needShow : bool):
    if needShow:
        visible = true
    if alphaTween != null:
        alphaTween.kill()
        alphaTween = null
    alphaTween = create_tween()
    var targetA = 0.2 if needShow else 0.0
    var targetEnergy = originEnergy if needShow else 0.0
    alphaTween.set_parallel()
    alphaTween.tween_property(self, "modulate:a", targetA, 1)
    alphaTween.tween_property(self, "baseEnergy", targetEnergy, 1)
