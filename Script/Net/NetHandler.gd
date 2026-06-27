#NetHandler 处理网络链接的类
extends Node

var IP_address:String = "localhost"
const port:int = 42206

var peer:ENetMultiplayerPeer

signal start_server_signal #本机作为host信号

signal client_connected_success #客户端链接成功
signal client_connected_fail #客户端链接失败

func _ready() -> void:
    multiplayer.peer_connected.connect(on_connected)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.connected_to_server.connect(_on_connection_succeeded)
    #IP_address = Utils.get_local_ip()
    
#一个对等体链接
func on_connected(id):
    print(multiplayer.get_unique_id(), "一个对等体链接", id)
    #if multiplayer.get_unique_id() == id:
        #self_connected_complete()
    
    #如果是和1 也就是host链接 发送自己的信息
    if id == 1:
        GameManager.AddPlayer.rpc_id(1, UtilsTool.resource_to_dict(GameManager.playerData))
    
    #只在服务器端统一处理链接
    if !multiplayer.is_server(): return


    #服务器保存新玩家的信息
    #设置新客户端的队伍
    #GameManager.sync_selfTeam.rpc_id(id, GameManager.teamAuthorityIDDic.size())
    ##同步随机种子
    #GameManager.sync_mapRandomSeed.rpc(GameManager.mapRandomSeed)

#一个客户端断开链接
func on_disconnected(id):
    #只在服务器端统一处理链接
    if !multiplayer.is_server(): return
    var needRemoveKey
    for key in GameManager.teamAuthorityIDDic:
        if GameManager.teamAuthorityIDDic[key] == id:
            needRemoveKey = key
    if needRemoveKey:
        GameManager.teamAuthorityIDDic.erase(needRemoveKey)
#启动服务器
func StartServer():
    ClearNetWork()
    peer = ENetMultiplayerPeer.new()
    peer.create_server(port)
    multiplayer.multiplayer_peer = peer
    start_server_signal.emit(multiplayer.get_unique_id())
    
    #设置主机的信息
    SetPlayerData(multiplayer.get_unique_id(), 1, true)
    GameManager.AddPlayer(UtilsTool.resource_to_dict(GameManager.playerData))
    
#启动客户端
func StartClient(ip:String, target_port:int):
    ClearNetWork()
    #var IPport = Utils.decode_ip_port(num)
    peer = ENetMultiplayerPeer.new()
    var result = peer.create_client(ip, target_port)
    if result == 0:
        multiplayer.multiplayer_peer = peer
        GameManager.playerData.id = multiplayer.get_unique_id()
        print(multiplayer.get_unique_id(), "客户端链接成功")
        client_connected_success.emit()
    else:
        GameManager.eventBus.show_msg.emit("链接失败 错误码:", result)
        client_connected_fail.emit()
        StartServer()
        
func _on_connection_succeeded():
    #应该等待联机成功信号再开启游戏
    GameManager.eventBus.show_msg.emit("链接成功")
    #等待会导致同步失败 TODO:找一下解决办法
    #await get_tree().create_timer(1).timeout
    
func _on_connection_failed():
    GameManager.eventBus.show_msg.emit("链接失败")
    client_connected_fail.emit()

##消除现存的网络链接、设置
func ClearNetWork():
    # 关闭底层网络对等体
    if peer:
        peer.close()
        peer = null
    # 清空 MultiplayerAPI 中的网络对等体
    if multiplayer.multiplayer_peer:
        multiplayer.multiplayer_peer = null
        
    # 清空玩家信息
    GameManager.PlayerInfoDic.clear()

func SetPlayerData(id, playerSlotIndex, isHost = false):
    GameManager.playerData.id = id
    GameManager.playerData.isHost = isHost
    GameManager.playerData.playerSlotIndex = playerSlotIndex
