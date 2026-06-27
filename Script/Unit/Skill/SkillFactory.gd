class_name SkillFactory

enum SkillType {
    NormalAttack = 1,
    Dodge = 2,
    Jump = 3
}
# 工厂方法：根据 skill_id 创建技能实例
static func CreatSkill(skill_id: int) -> SkillBase:
    var skillData = ConfigManager.GetSkillData(skill_id)
    var skillBase:SkillBase
    #续写switch
    match skillData.skillType:
        SkillType.NormalAttack:
            skillBase = SkillNormalAttack.new()
        SkillType.Dodge:
            skillBase = SkillDodge.new()
        SkillType.Jump:
            skillBase = SkillJump.new()
        _:
            push_error("Unknown skillType: ", skill_id)
            return null
    skillBase.data = skillData
    
    return skillBase
