class_name SkillBase

#隶属于的单位
var owner:UnitBase

# 代理 id
var id: int:
    get:
        return data.ID
    set(value):
        data.ID = value
# 代理 skillType
var skillType: int:
    get:
        return data.skillType
    set(value):
        data.skillType = value
# 代理 skillName
var skillName: String:
    get:
        return data.skillName
    set(value):
        data.skillName = value

# 代理 ArrowOrderList
var ArrowOrderList: Array[int]:
    get:
        return data.ArrowOrderList
    set(value):
        data.ArrowOrderList = value

# 代理 ParameterList
var ParameterList: Array[float]:
    get:
        return data.ParameterList
    set(value):
        data.ParameterList = value

# 代理 SpriteID
var spriteID: int:
    get:
        return data.spriteID
    set(value):
        data.spriteID = value
@export var data:SkillData = SkillData.new()



func DoSkill():
    pass
