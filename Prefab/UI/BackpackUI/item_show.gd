extends TextureRect

@export var id:int = 1

#是否可以移动
@export var canDrag = true

# 状态标志
var dragging := false          # 是否正在拖动
var hovered := false           # 鼠标是否悬停（用于释放后恢复状态）

# 拖动偏移：鼠标点击位置相对于控件左上角的偏移
var drag_offset := Vector2.ZERO

# 缩放系数
var normal_scale := Vector2.ONE
var hover_scale := Vector2(1.1, 1.1)    # 悬停时放大1.1倍
var press_scale := Vector2(1.2, 1.2)    # 按下时放大1.2倍

func _ready():
    # 连接鼠标进入/退出信号
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    scale = normal_scale

func _on_mouse_entered():
    hovered = true
    if not dragging:
        scale = hover_scale

func _on_mouse_exited():
    hovered = false
    if not dragging:
        scale = normal_scale

# 处理发生在控件自身区域内的输入事件
func _gui_input(event):
    #选择逻辑
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        self.reparent(GameManager.UI)
        GameManager.eventBus.choose_one_reward.emit()
        

    #移动逻辑
    if canDrag:
        if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                # 左键按下：开始拖动
                dragging = true
                # 记录鼠标相对于控件左上角的偏移，保证拖动时视觉上不跳跃
                drag_offset = event.global_position - global_position
                scale = press_scale
                accept_event()  # 阻止事件继续传播，避免干扰其他控件
            else:
                # 左键释放（且发生在控件区域内）
                if dragging:
                    dragging = false
                    # 根据鼠标是否仍悬停恢复对应缩放
                    scale = hover_scale if hovered else normal_scale
                    accept_event()

# 全局输入监听，用于处理拖动过程中鼠标移出控件后的移动和释放
func _input(event):
    if not dragging:
        return

    if event is InputEventMouseMotion:
        # 鼠标移动：更新控件位置
        global_position = event.global_position - drag_offset
        # 可选：将控件限制在父容器或视口范围内
        # var viewport_rect = get_viewport().get_visible_rect()
        # global_position = global_position.clamp(viewport_rect.position, viewport_rect.end - size)

    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
        # 左键释放（可能发生在控件外）：停止拖动
        dragging = false
        scale = hover_scale if hovered else normal_scale
        # 此处不调用 accept_event()，以免影响其他控件接收释放事件
