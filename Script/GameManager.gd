#游戏全局控制中心
extends Node

var eventBus:EventBus = EventBus.new()

var UI:UIHandler = UIHandler.new()
var History:HistoryHandler = HistoryHandler.new()

var m_camera:M_Camera #主相机

##对话现实的基础速度
var perSecondCharacter:float = 10

var playerUnit:PlayerUnit

#当前玩家的信息
var playerData:PlayerInfoData

func _ready() -> void:
    UI.OnReady()
    History.OnReady()
    #读取玩家信息
    initPlayerData()
##从文件读取玩家信息
func initPlayerData():
    load_player_data()
    #初始化玩家信息
    playerData = PlayerInfoData.new()
    playerData.name = getPlayerName()
    playerData.playerSlotIndex = 1
    playerData.isHost = true

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("TestGesture"):
        eventBus.start_dialog.emit(1)
        #eventBus.change_stage.emit(1)
        #eventBus.change_stage.emit(randi_range(1,3))
    if Input.is_action_pressed("skip"):
        eventBus.pressing_skip.emit()

func _physics_process(delta: float) -> void:
    var input_vector: Vector2 = Input.get_vector(
        "move_left", "move_right", 
        "move_up", "move_down"
    )
    var attack = Input.is_action_just_pressed("attack")
    #var jump = Input.is_action_just_pressed("jump")
    var dodge = Input.is_action_just_pressed("dodge")
    #var short_skill = Input.is_action_just_pressed("short_skill")
    #var finish_skill = Input.is_action_just_pressed("finish_skill")
    #测试触发键
    if dodge:
        ShowSelfPlayerInfoList()
        

    if playerUnit != null:
        if attack:
            playerUnit.Attack()
        playerUnit.input_vector = input_vector
        if Input.is_action_just_pressed("ui_up"):
            playerInputArrow(1)
        elif Input.is_action_just_pressed("ui_down"):
            playerInputArrow(2)
        elif Input.is_action_just_pressed("ui_left"):
            playerInputArrow(3)
        elif Input.is_action_just_pressed("ui_right"):
            playerInputArrow(4)
        elif Input.is_action_just_pressed("quit"):
            playerUnit.ClearInputArrow()
            GameManager.eventBus.player_input_clear_arrow.emit()
            
            
func playerInputArrow(dir:int):
    if playerUnit != null:
        playerUnit.InputArrow(dir)
        GameManager.eventBus.player_input_arrow.emit(dir)
#region 持久化设置
# 存档存储路径
const ConfigPath = "user://gwPlayerData01.cfg"
var PlayerConfig:ConfigFile = ConfigFile.new()

# 从本地文件加载玩家数据
func load_player_data():
    # 尝试加载文件，如果文件不存在，err 的值不会是 OK
    var err = PlayerConfig.load(ConfigPath)
    if err != OK:
        #没有文件就创造一个文件
        PlayerConfig.set_value("PlayerData", "hello", true)
        PlayerConfig.save(ConfigPath)
    



func getPlayerName():
    var player_name = PlayerConfig.get_value("PlayerData", "name", "null")
    return player_name
    
## 保存玩家数据到本地文件
func save_player_data(name_to_save: String):
    # 将名字存入指定的节和键中
    PlayerConfig.set_value("PlayerData", "name", name_to_save)
    # 保存文件
    var err = PlayerConfig.save(ConfigPath)
    if err == OK:
        print("名字 '", name_to_save, "' 已成功保存！")
    else:
        print("保存名字时出错。")
#endregion

#region 网络多人
##主机保留的所有玩家的信息
var PlayerInfoDic:Dictionary[int, PlayerInfoData] = {}

@rpc("any_peer")
func AddPlayer(data:Dictionary):
    var playerInfoData:PlayerInfoData = UtilsTool.dict_to_resource(data, PlayerInfoData)
    playerInfoData.playerSlotIndex = PlayerInfoDic.size() + 1
    
    PlayerInfoDic[playerInfoData.id] = playerInfoData
    print(multiplayer.get_unique_id(), " AddPlayer ", data)
    #如果是本人的data 就更新自己的data
    if multiplayer.get_unique_id() == playerInfoData.id :
        playerData = playerInfoData
    #通知更新ui
    eventBus.player_info_list_update.emit()

    if !multiplayer.is_server(): return
    #若是主机处理 同步所有对等体的玩家信息
    sync_PlayerInfoDic()
    
##同步玩家信息 只有主机调用
func sync_PlayerInfoDic():
    if !multiplayer.is_server(): return 
    #清空对等体上的PlayerInfoDic
    ClearPlayerInfoList.rpc()
    #添加逐一玩家信息
    for playerDataIndex in PlayerInfoDic:
        var pData = PlayerInfoDic[playerDataIndex]
        AddPlayer.rpc(UtilsTool.resource_to_dict(pData))

@rpc("any_peer")
func ClearPlayerInfoList():
    PlayerInfoDic.clear()
    
func ShowSelfPlayerInfoList():
    #print(multiplayer.get_unique_id()," ShowSelfPlayerInfoList ",PlayerInfoDic)
    pass
#endregion
