class_name ArrowRecord
extends Control

@onready var ArrowShow:TextureRect = $ArrowShow

# 纹理资源路径（请根据实际路径修改）
const TEXTURE_UP = "res://Asset/Art/Icon/arrow_up.png"
const TEXTURE_DOWN = "res://Asset/Art/Icon/arrow_down.png"
const TEXTURE_LEFT = "res://Asset/Art/Icon/arrow_left.png"
const TEXTURE_RIGHT = "res://Asset/Art/Icon/arrow_right.png"

# 存储预加载的纹理
var textures := {}

#方向 上下左右 1234
var dic:int = 1

func _ready():
    # 预加载所有纹理，避免运行时重复加载
    textures[1] = load(TEXTURE_UP)
    textures[2] = load(TEXTURE_DOWN)
    textures[3] = load(TEXTURE_LEFT)
    textures[4] = load(TEXTURE_RIGHT)
    
    # 可选：设置一个默认方向
    set_direction(3)
    
    #出现时动画
    appear_animation(ArrowShow)

# 公开方法：根据方向切换图片
func set_direction(direction):
    if textures.has(direction):
        ArrowShow.texture = textures[direction]
        dic = direction
    else:
        push_error("未知方向: ", direction)

func Finish():
    #切换父节点到父节点的父节点 且空间位置不变
    self.reparent(self.get_parent().get_parent())
    disappear_animation(ArrowShow)

#出现动画
func appear_animation(node: CanvasItem, duration: float = 0.2, start_scale: float = 1.5) -> void:
    # 记录原始缩放和颜色（便于恢复）
    var original_scale = node.scale
    var original_modulate = node.modulate

    # 设置起始状态：放大 + 透明
    node.scale = original_scale * start_scale
    node.modulate.a = 0.0

    # 创建 Tween，并设置为并行模式
    var tween = create_tween()
    tween.set_parallel(true)

    # 透明度恢复至原始 alpha（通常为 1）
    tween.tween_property(node, "modulate:a", original_modulate.a, duration)
    # 缩放恢复至原始大小
    tween.tween_property(node, "scale", original_scale, duration)

    # 可选：动画结束后的回调
    #tween.finished.connect(func(): print("Appear animation finished"))

#消失动画
# 消失动画：向上冲击 + 随机水平偏移 + 重力下落 + 淡出
# node: 要播放动画的节点（需继承 CanvasItem）
# duration: 总动画时长（秒）
# up_amplitude: 向上冲击的幅度（像素）
# horizontal_amplitude: 水平偏移的最大幅度（像素），方向随机
# gravity_distance: 重力下落的总距离（从冲击顶点开始向下）
func disappear_animation(node: CanvasItem, duration: float = 0.6, up_amplitude: float = 25.0, horizontal_amplitude: float = 10.0, gravity_distance: float = 100.0) -> void:
    var original_pos = node.position

    # 随机水平偏移方向（左或右）
    var horizontal_dir = 1 if randf() > 0.5 else -1
    var horizontal_offset = horizontal_dir * horizontal_amplitude * randf()

    # 冲击结束时的位置（向上 + 水平偏移）
    up_amplitude = randf_range(up_amplitude * 0.8, up_amplitude)
    gravity_distance = randf_range(gravity_distance * 0.8, gravity_distance)
    var impact_pos = original_pos + Vector2(horizontal_offset, -up_amplitude)
    # 最终下落结束时的位置（从冲击点向下移动 gravity_distance）
    var final_pos = impact_pos + Vector2(horizontal_offset, gravity_distance)

    var tween = create_tween()

    # 全程淡出（与位置动画并行）
    tween.tween_property(node, "modulate:a", 0.0, duration)

    # 位置动画：先冲击（短时向上+水平），后下落（重力加速）
    # 使用 parallel 和 delay 模拟顺序执行
    tween.parallel().tween_property(node, "position", impact_pos, duration * 0.3) \
        .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
    tween.parallel().tween_property(node, "position", final_pos, duration * 0.7) \
        .set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE) \
        .set_delay(duration * 0.3)   # 延迟到冲击结束后开始

    # 动画结束后恢复透明度并隐藏节点（可选）
    tween.finished.connect(func(): queue_free())
    
