class_name SkillFactory

enum SkillType {
    Dodge = 1,
}
# 工厂方法：根据 skill_id 创建技能实例
static func CreatSkill(skill_id: int) -> SkillBase:
    var skillData = ConfigManager.GetSkillData(skill_id)
    var skillBase:SkillBase
    #续写switch
    match skillData.skillType:
        SkillType.Dodge:
            skillBase = SkillDodge.new()
        _:
            push_error("Unknown skillType: ", skill_id)
            return null
    skillBase.data = skillData
    
    return skillBase
