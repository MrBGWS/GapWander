class_name SkillDodge
extends SkillBase

func DoSkill():
    super.DoSkill()
    Dodge()

# 动画参数
@export var dash_distance: float = 30.0      # 总位移距离（左右各一半）
@export var dash_duration: float = 0.3        # 总动画时间
@export var afterimage_interval: float = 0.05 # 残影生成间隔
@export var fade_duration: float = 0.3        # 残影淡出时间

var dodgeTween: Tween
var afterimage_timer: Timer
var is_dodging:bool = false
#闪避相关
func Dodge():
    if owner == null:
        return
    # 防止重复触发
    if dodgeTween and dodgeTween.is_running():
        return
    is_dodging = true
    # 创建主 Tween（顺序执行）
    dodgeTween = owner.create_tween()
    var start_x = owner.position.x
    var left_x = start_x - dash_distance / 2
    var right_x = start_x + dash_distance / 2

    # 三段移动：左移 → 右移 → 归位
    dodgeTween.tween_property(owner, "position:x", left_x, dash_duration * 0.4).set_ease(Tween.EASE_IN_OUT)
    dodgeTween.tween_property(owner, "position:x", right_x, dash_duration * 0.3).set_ease(Tween.EASE_IN_OUT)
    dodgeTween.tween_property(owner, "position:x", start_x, dash_duration * 0.3).set_ease(Tween.EASE_IN_OUT)

    # 启动残影计时器
    afterimage_timer = Timer.new()
    afterimage_timer.wait_time = afterimage_interval
    afterimage_timer.timeout.connect(_create_afterimage)
    afterimage_timer.one_shot = false
    owner.add_child(afterimage_timer)
    afterimage_timer.start()

    # 动画结束时清理计时器
    dodgeTween.finished.connect(_on_dash_finished, CONNECT_ONE_SHOT)

#创造幻影图像
func _create_afterimage():
    var parent = owner.get_parent()
    if not parent:
        return

    # 创建残影节点（复制视觉属性）
    var afterimage = Sprite2D.new() 
    afterimage.texture = owner.body_sprite.sprite_frames.get_frame_texture(owner.body_sprite.animation, owner.body_sprite.frame)
    afterimage.centered = owner.body_sprite.centered
    afterimage.offset = owner.body_sprite.offset
    afterimage.scale = owner.body_sprite.scale
    afterimage.rotation = owner.body_sprite.rotation
    afterimage.modulate = owner.body_sprite.modulate  # 初始颜色（可稍作调整使残影更明显）
    afterimage.modulate.a = 0.5

    # 添加到父节点
    parent.add_child(afterimage)
    
    # 使用全局位置固定在当前帧的位置
    afterimage.global_position = owner.body_sprite.global_position

    # 残影淡出并自毁
    var fade_tween = owner.create_tween()
    fade_tween.tween_property(afterimage, "modulate:a", 0.0, fade_duration).set_ease(Tween.EASE_IN)
    fade_tween.finished.connect(afterimage.queue_free, CONNECT_ONE_SHOT)

func _on_dash_finished():
    if afterimage_timer:
        afterimage_timer.stop()
        afterimage_timer.queue_free()
        afterimage_timer = null
    dodgeTween = null
    is_dodging = false
