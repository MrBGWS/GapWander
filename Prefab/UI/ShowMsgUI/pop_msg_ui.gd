extends UIBase

@onready var msgContainer = $VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    GameManager.eventBus.show_msg.connect(show_msg)
    
func show_msg(text):
    var one_lable = Label.new()
    one_lable.text = text
    one_lable.modulate = Color.WHITE_SMOKE
    one_lable.add_theme_color_override("font_color", Color.WHITE_SMOKE)
    one_lable.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    one_lable.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    msgContainer.add_child(one_lable)
    # 2. 延迟2秒后启动淡出动画
    await get_tree().create_timer(2.0).timeout
    
    # 3. 创建并启动淡出动画
    var tween = create_tween()
    tween.tween_property(one_lable, "modulate:a", 0.0, 1.0)  # 1秒内透明度降为0
    tween.tween_callback(one_lable.queue_free)  # 动画完成后删除节点
