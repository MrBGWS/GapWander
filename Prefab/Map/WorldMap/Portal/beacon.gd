#多人游戏准备点
extends Node2D

@onready var Core = $Core
@onready var Ring1 = $Ring
@onready var light = $PointLight2D
# 导出曲线资源（用于控制强度变化）
@export var intensity_curve: Curve
var originEnergy:float = 1.0 #设置的原始光强度
var baseEnergy:float #基础光强度

var _timer:float = 0.0
var _coreScale:float = 0.1

var rotationSpeed:float = 0.4

#传送检查
@onready var checkArea = $CheakArea
@export var toSceneName:String = "res://Scene/map/elan.tscn"
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
# 当有物体进入区域时
func _on_body_entered(object):
    var body = object as UnitBase
    if body == null:
        return
    if body.data.team != GameManager.playerTeam or not body.data.isHero:
        return
    if curUnit != null and not is_instance_valid(curUnit):
        return
    #for item in body.data.inventory:
        #if item.id == 0:
    GameManager.eventBus.show_msg.emit("(按下" + UtilsTool.get_action_name("interact")+ "准备)")
    canInteract = true

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
    
    if curUnit != null:
        curUnit.interactingObject = null
        curUnit = null
func _process(delta: float) -> void:
    if canInteract and Input.is_action_just_pressed("interact"):
        pass
        #准备
        #set_player_ready.rpc_id(1, multiplayer.get_unique_id(), curUnit.data.id)
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
    
    var scale1 = intensity_curve.sample(_timer2) * _coreScale + (1 - _coreScale)
    Core.scale = Vector2.ONE * scale1
    
    var scale2 = intensity_curve.sample(_timer3) / 2 + 0.5
    Ring1.scale = Vector2.ONE * scale2
    
    #rotation += delta * 0.4 * (intensity_curve.sample(_timer) - 1)



##点击准备
#@rpc("any_peer","call_local")
#func set_player_ready(playerID, unitID):
    ##GameManager.teamAuthorityIDDic
    ##只在服务器端统一处理准备
    #if !multiplayer.is_server(): return
    #
    #print(playerID,":按下准备")
    #if not GameManager.readyPlayerList.has(playerID):
        #GameManager.readyPlayerList.append(playerID)
        #var showStr = "%d/%d" % [GameManager.readyPlayerList.size(), GameManager.teamAuthorityIDDic.size()] + "玩家准备"
        #show_ready_state.rpc(showStr)
        ##记录一个玩家选择的unit id
        #GameManager.playerID_unitId_Dic[playerID] = unitID
        #
        #
        #if GameManager.teamAuthorityIDDic.size() <= GameManager.readyPlayerList.size():
            ##准备完成 转化场景
            ##GameManager.change_scene("原点")
            #print("所有人准备完毕")
            #GameManager.change_scene_to_main.rpc()
            #change_to_main_scene.rpc()
    #
#
##通知全场准备状态
#@rpc("any_peer","call_local")
#func show_ready_state(showStr):
    #GameManager.eventBus.show_msg.emit(showStr)
    #
##通知全体转化场景
#@rpc("any_peer","call_local")
#func change_to_main_scene():
    #pass
    #
