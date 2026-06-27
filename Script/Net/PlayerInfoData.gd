#多人玩家信息
class_name PlayerInfoData

extends Resource

@export var id:int #网络id
@export var name:String #玩家名字
@export var isHost:bool #是否是房主
@export var playerSlotIndex:int #1蓝色玩家 2绿色玩家 3红色玩家
