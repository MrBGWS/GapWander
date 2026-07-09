extends TextureRect

var lifeTime:float = 999

var fade_duration = 0.5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #出生动画
    var fade_tween = create_tween()
    modulate.a = 0.0
    fade_tween.tween_property(self, "modulate:a", 1.0, fade_duration).set_ease(Tween.EASE_IN)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    lifeTime -= delta
    if lifeTime < 0:
        queue_free()
        GameManager.eventBus.turn_start.emit()
    
