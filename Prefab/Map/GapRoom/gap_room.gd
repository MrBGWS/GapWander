#间隙房间

extends Node2D

@export var SceneChangeOption:SceneChangeOptionSetting

func _ready() -> void:
    GameManager.eventBus.start_event.connect(StartGame)
    
    #切换场景特效
    var fade_in_first_scene_options = SceneManager.create_options(1, "fade")
    var first_scene_general_options = SceneManager.create_general_options(Color(0.0, 0.0, 0.0, 1.0), 1, false)
    SceneManager.show_first_scene(fade_in_first_scene_options, first_scene_general_options)
    
#从间隙房间进入局内游戏
func StartGame(eventID):
    if eventID == 1:
        print("游戏开始")
        #去下一个场景
        SceneManager.change_scene(SceneChangeOption.scene, SceneChangeOption.GetFadeOutOption(), SceneChangeOption.GetFadeInOption(), SceneChangeOption.GetGeneralOption())
