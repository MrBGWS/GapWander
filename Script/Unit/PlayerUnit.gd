class_name PlayerUnit

extends UnitBase

var input_vector:Vector2
@onready var body_sprite:AnimatedSprite2D = $BodyShow
##箭头输入处理类
#var arrowInputHandler:InputArrowHandler = InputArrowHandler.new()
var dirList:Array[int]

var mainTargetUnit:UnitBase:
    get:
        if mainTargetUnit == null:
            mainTargetUnit = GetOneEnemy()
        return mainTargetUnit

func _ready() -> void:
    super._ready()

    turnAction = func(): handlerArrowInput()

#func _input(event):
    #if event.is_action_pressed("ui_up"):
        #InputArrow(1)
    #elif event.is_action_pressed("ui_down"):
        #InputArrow(2)
    #elif event.is_action_pressed("ui_left"):
        #InputArrow(3)
    #elif event.is_action_pressed("ui_right"):
        #InputArrow(4)
    #elif event.is_action_pressed("quit"):
        #ClearInputArrow()
 
       
func InputArrow(dir):
    dirList.append(dir)
    #GameManager.eventBus.player_input_arrow.emit(dir)
    
func ClearInputArrow():
    dirList.clear()
    #GameManager.eventBus.player_input_clear_arrow.emit()
        
func TurnStart():
    super.TurnStart()
    
func TurnFinish():
    super.TurnFinish()
    dirList.clear()
    
#处理箭头事件
func handlerArrowInput():
    #遍历整个Effective列表 看看有没有有效的
    print("目前输入组", dirList)
    for skill in SkillList:
        if skill.ArrowOrderList == dirList:
            print("找到输入组")
            skill.DoSkill()
            return
    #没找到
    Shake()
    
func Attack(targetUnit:UnitBase):
    if targetUnit == null:
        targetUnit = mainTargetUnit
    super.Attack(targetUnit)
func TakeDamage(damage, damageSource = 0,damageType = 0):
    super.TakeDamage(damage, damageSource, damageType)


@onready var NameLabel:RichTextLabel = $PlayerName
##设置玩家信息
func SetPlayerData(playData:PlayerInfoData):
    NameLabel.text = playData.name
    set_multiplayer_authority(playData.id)
    
    ##如果是自己的 则设为主要角色
    if playData.id == multiplayer.get_unique_id():
        GameManager.playerUnit = self
##跳跃相关
#@export var jump_height: float = 10.0      # 跳跃高度（像素）
#@export var jump_duration: float = 0.3      # 跳跃总时长（秒）
#var jump_tween:Tween
#var is_jumping:bool = false
#func Jump():
    #if is_jumping:
        #return
    #is_jumping = true
    #
    ## 创建一个新的 Tween（自动管理生命周期）
    #jump_tween = create_tween()
    #
    ## 获取起始 Y 坐标
    #var start_y = position.y
    #var target_y = start_y - jump_height   # 向上移动为负值
    #
    ## 动画序列：先上升，后下降
    ## 上升阶段（Ease Out 让起跳更自然）
    #jump_tween.tween_property(self, "position:y", target_y, jump_duration * 0.5) \
         #.set_ease(Tween.EASE_OUT) \
         #.set_trans(Tween.TRANS_QUAD)
    ##await get_tree().create_timer(jump_duration * 0.5).timeout
    ## 下降阶段（Ease In 让落地有加速感）
    #jump_tween.tween_property(self, "position:y", start_y, jump_duration * 0.5) \
         #.set_ease(Tween.EASE_IN) \
         #.set_trans(Tween.TRANS_QUAD)
    #jump_tween.finished.connect(func(): is_jumping = false)
#
## 动画参数
#@export var dash_distance: float = 50.0      # 总位移距离（左右各一半）
#@export var dash_duration: float = 0.3        # 总动画时间
#@export var afterimage_interval: float = 0.05 # 残影生成间隔
#@export var fade_duration: float = 0.3        # 残影淡出时间
#
#var dodgeTween: Tween
#var afterimage_timer: Timer
#var is_dodging:bool = false
##闪避相关
#func Dodge():
    ## 防止重复触发
    #if dodgeTween and dodgeTween.is_running():
        #return
    #is_dodging = true
    ## 创建主 Tween（顺序执行）
    #dodgeTween = create_tween()
    #var start_x = position.x
    #var left_x = start_x - dash_distance / 2
    #var right_x = start_x + dash_distance / 2
#
    ## 三段移动：左移 → 右移 → 归位
    #dodgeTween.tween_property(self, "position:x", left_x, dash_duration * 0.4).set_ease(Tween.EASE_IN_OUT)
    #dodgeTween.tween_property(self, "position:x", right_x, dash_duration * 0.3).set_ease(Tween.EASE_IN_OUT)
    #dodgeTween.tween_property(self, "position:x", start_x, dash_duration * 0.3).set_ease(Tween.EASE_IN_OUT)
#
    ## 启动残影计时器
    #afterimage_timer = Timer.new()
    #afterimage_timer.wait_time = afterimage_interval
    #afterimage_timer.timeout.connect(_create_afterimage)
    #afterimage_timer.one_shot = false
    #add_child(afterimage_timer)
    #afterimage_timer.start()
#
    ## 动画结束时清理计时器
    #dodgeTween.finished.connect(_on_dash_finished, CONNECT_ONE_SHOT)
#
##创造幻影图像
#func _create_afterimage():
    #var parent = get_parent()
    #if not parent:
        #return
#
    ## 创建残影节点（复制视觉属性）
    #var afterimage = Sprite2D.new() 
    #afterimage.texture = body_sprite.sprite_frames.get_frame_texture(body_sprite.animation, body_sprite.frame)
    #afterimage.centered = body_sprite.centered
    #afterimage.offset = body_sprite.offset
    #afterimage.scale = body_sprite.scale
    #afterimage.rotation = body_sprite.rotation
    #afterimage.modulate = body_sprite.modulate  # 初始颜色（可稍作调整使残影更明显）
    #afterimage.modulate.a = 0.5
#
    ## 添加到父节点
    #parent.add_child(afterimage)
    #
    ## 使用全局位置固定在当前帧的位置
    #afterimage.global_position = body_sprite.global_position
#
    ## 残影淡出并自毁
    #var fade_tween = create_tween()
    #fade_tween.tween_property(afterimage, "modulate:a", 0.0, fade_duration).set_ease(Tween.EASE_IN)
    #fade_tween.finished.connect(afterimage.queue_free, CONNECT_ONE_SHOT)
#
#func _on_dash_finished():
    #if afterimage_timer:
        #afterimage_timer.stop()
        #afterimage_timer.queue_free()
        #afterimage_timer = null
    #dodgeTween = null
    #is_dodging = false
