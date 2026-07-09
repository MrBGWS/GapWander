#地图房间的根节点
extends Node2D

#房间资源索引
var maproomPrefab:PackedScene = preload("res://Prefab/Map/WorldMap/Mushroom/map_room.tscn")
#10*10的房间索引
var maproomList:MapRoom



func _ready() -> void:
    pass # Replace with function body.

#初始化所有房间
func init_room():
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
