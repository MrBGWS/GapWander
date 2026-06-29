class_name UnitData

extends Resource

@export var ID:int
@export var UnitName:String
@export var HP:float
@export var MaxHp:float
@export var AttackPower:float
@export var Speed:float = 200
@export var SkillIDList:Array[int]
##单位所属队伍 0野怪 1玩家 2敌人
@export var team:int

#自动化单位需要的部分
##视野半径 警戒半径
@export var radiusEyeSight:float = 10
##开始攻击的距离
@export var radiusAttack = 5

#图片 动画资源 需要只有id 因为unitdata很可能要网络传输
@export var SpriteID:int
