#地图房间的根节点
extends Node2D

#房间资源索引
var maproomPrefab:PackedScene = preload("res://Prefab/Map/WorldMap/Mushroom/map_room.tscn")
#10*10的房间索引
var maproomList:Array[MapRoom] = []

#房间网格配置
@export var grid_width: int = 10
@export var grid_height: int = 10
#房间默认尺寸（当无法从TileMap获取时使用）
@export var default_room_size: Vector2 = Vector2(256, 256)

##房间初始化结束
signal room_init_finish

func _ready() -> void:
    init_room()
    
    GameManager.eventBus.change_world_room.connect(ChangeRoom)

##玩家转换房间
func ChangeRoom(room_offset:Vector2i, room_protal_id:int):
    var targetRoom = get_room_at(room_offset.x, room_offset.y)
    if targetRoom != null:
        var protalindex = targetRoom.protalList.find_custom(func(protal): return protal.protalID == room_protal_id)
        if protalindex >= 0:
            GameManager.playerUnit.global_position = targetRoom.protalList[protalindex].global_position 
        

#初始化所有房间
func init_room():
    # 清除已有房间
    _clear_all_rooms()

    # 先实例化一个样板房间来获取实际房间尺寸
    var sample_room: MapRoom = maproomPrefab.instantiate()
    add_child(sample_room)
    # 等待一帧确保TileMap就绪
    await get_tree().process_frame

    var room_size: Vector2 = _get_room_size(sample_room) * 2
    sample_room.queue_free()

    # 创建10x10房间网格
    for y in range(grid_height):
        for x in range(grid_width):
            var room: MapRoom = maproomPrefab.instantiate()
            room.position = Vector2(x * room_size.x, y * room_size.y)
            room.roomOffset = Vector2i(x, y)
            add_child(room)
            maproomList.append(room)
    
    #清除所有房间中没能联通的传送门
    remove_unuse_protal()
    
    room_init_finish.emit()
    print("房间初始化完成：%dx%d 网格，房间尺寸 %s" % [grid_width, grid_height, room_size])
    
##清除所有房间中没能联通的传送门
func remove_unuse_protal():
    for room:MapRoom in maproomList:
        for oneProtal:Protal in room.protalList:
            var roffset = oneProtal.targetOffset + room.roomOffset
            var targetRoom = get_room_at(roffset.x, roffset.y)
            if targetRoom == null:
                room.RemoveOneProtal(oneProtal)
                #oneProtal.queue_free()
            else:
                var targetProtalIndex = targetRoom.protalList.find_custom(func(prot): return oneProtal.targetProtalID == prot.protalID)
                if targetProtalIndex < 0:
                    room.RemoveOneProtal(oneProtal)

# 获取指定坐标的房间（x, y为网格坐标）
func get_room_at(grid_x: int, grid_y: int) -> MapRoom:
    if grid_x < 0 or grid_x >= grid_width or grid_y < 0 or grid_y >= grid_height:
        return null
    var index: int = grid_y * grid_width + grid_x
    if index < maproomList.size():
        return maproomList[index]
    return null

# 清除所有房间
func _clear_all_rooms():
    for child in get_children():
        if child is MapRoom:
            child.queue_free()
    maproomList.clear()

# 获取房间的像素尺寸
func _get_room_size(room: MapRoom) -> Vector2:
    var tilemap: TileMapLayer = room.get_node_or_null("Ground")
    if tilemap and tilemap.tile_set:
        var used_rect: Rect2i = tilemap.get_used_rect()
        var tile_size: Vector2i = tilemap.tile_set.tile_size
        if used_rect.size.x > 0 and used_rect.size.y > 0:
            return Vector2(used_rect.size.x * tile_size.x, used_rect.size.y * tile_size.y)
    return default_room_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
