class_name MapGrid
extends Node2D

@onready var GroundRoot = $".."

@export var lineIdList:Array[int]

func _ready() -> void:
    pass

@onready var signalPrefab = preload("res://Prefab/map/map_thing/signal.tscn")

##地图被点击了
func MapClicked(pos: Vector2):
    GroundRoot.CreateIcon.rpc(pos)
