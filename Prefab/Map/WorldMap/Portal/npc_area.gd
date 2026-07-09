class_name NpcArea
extends Area2D


@onready var noticeUI = $AnimatedSprite2D
@onready var npcBody = $NpcBody
@export var interactType:int #0 交谈 升级   1 直接交谈 没有其他选项
@export var curDialogID:int

var curUnit:UnitBase

func _ready() -> void:
    self.body_entered.connect(_on_body_entered)
    self.body_exited.connect(_on_body_exited)
# 当有物体进入区域时
func _on_body_entered(object):
    var body = object as UnitBase
    if body == null:
        return
    if body.data.team != 0:
        return
    if curUnit != null and not is_instance_valid(curUnit):
        return
    noticeUI.visible = true
    noticeUI.play()
    curUnit = body
    curUnit.interactingObject = self
    
func _on_body_exited(object):
    var body = object as UnitBase
    if body == null:
        return
    if curUnit != body:
        return
    noticeUI.visible = false
    noticeUI.stop()
    if curUnit != null:
        curUnit.interactingObject = null
        curUnit = null
        #暂时把npc位置归位放在这
        move_body_posx(0)

#执行互动
func interact(unit:UnitBase):
    #startTalk()
    #npcBody朝向单位
    var xDiff = self.global_position.x - unit.global_position.x
    npcBody.flip_h = xDiff > 0
    #拉开一定距离
    var targetGlobalPos = Vector2(unit.global_position.x + 25 * (1 if xDiff > 0 else -1), 0)
    move_body_posx(to_local(targetGlobalPos).x)
    #
    if interactType == 0:
        #GameManager.eventBus.start_interact.emit(curDialogID, unit)
        GameManager.OpenUI(2, {interactID = curDialogID, unit = unit})
    else:
        startTalk()

#开始谈话
func startTalk():
    GameManager.eventBus.start_dialog.emit(curDialogID)
    #TODO:完善对话系统
    #var dialogCfg:DialogueData = ConfigManager.DialogueConfigDic[curDialogID].duplicate(true)
    #if dialogCfg != null:
        #curDialogID = dialogCfg.nextDialogueIds.pick_random()

var bodyTween:Tween
#控制npc图像的位置的tween
func move_body_posx(posX : float):
    if bodyTween != null:
        bodyTween.kill()
        bodyTween = null
    bodyTween = create_tween()
    bodyTween.set_parallel()
    bodyTween.tween_property(self, "npcBody:position:x", posX, 0.5)
