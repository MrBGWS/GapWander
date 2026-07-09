#一个地图房间
class_name MapRoom
extends Node2D

##该房间的逻辑位置
var roomOffset:Vector2i

##拥有的传送门列表
var protalList:Array = []

##移除一个传送门
func RemoveOneProtal(protal:Protal):
    protalList.remove_at(protalList.find(protal))
    protal.queue_free()
