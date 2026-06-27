class_name M_Camera
extends Camera2D

@export var followTarget:Node2D
@onready var UIAudioPlayer:AudioStreamPlayer2D = $UIAudioPlayer
@onready var BgmPlayer:AudioStreamPlayer2D = $BgmPlayer

var UIAudioPlayerPool:Array[AudioStreamPlayer2D] = []

func _ready() -> void:
    GameManager.eventBus.set_main_camera_to.connect(set_main_camera_to)
    GameManager.eventBus.shake_main_camera.connect(shake)
    GameManager.eventBus.play_UIAudio.connect(play_UIAudio)
    GameManager.m_camera = self
    UIAudioPlayerPool.append(UIAudioPlayer)

func set_main_camera_to(node:Node2D, keep_global_transform = false):
    print("set_main_camera_to  ", node.name)
    followTarget = node
    #self.reparent.call_deferred(node, keep_global_transform)

func _process(delta: float) -> void:
    if followTarget != null:
        self.position = followTarget.position

func shake(strength: float, duration: float = 0.3):
    var tween = create_tween()
    # 在duration秒内，振幅从strength衰减到0
    tween.tween_method(_apply_shake, strength, 0.0, duration)

func _apply_shake(amp: float):
    # 随机生成偏移量模拟震动
    offset = Vector2(
        randf_range(-amp, amp),
        randf_range(-amp, amp)
    )

func play_UIAudio(id):
    
    var haveFreePlayer = false
    var index = 1
    for player:AudioStreamPlayer2D in UIAudioPlayerPool:
        if not player.playing :
            player.stream = GameManager.SoundResource.SoundDic[id].duplicate(true)
            player.playing = true
            haveFreePlayer = true
            print("ui音效播放 老节点:", id, "序号", index)
            break
        index += 1
    if not haveFreePlayer:
        # 基本复制
        var new_player = UIAudioPlayer.duplicate(true)
        add_child(new_player)
        new_player.stream = GameManager.SoundResource.SoundDic[id].duplicate(true)
        new_player.playing = true
        UIAudioPlayerPool.append(new_player)
        print("ui音效播放 新节点:", id, "序号", index)
        
