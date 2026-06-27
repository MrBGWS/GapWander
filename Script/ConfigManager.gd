#配置管理器
extends Node

var DialogueConfigDic:Dictionary[int, DialogueResource]#对话配置
var SoundConfigDic:Dictionary[int, AudioStream]#声音配置
var SkillConfigDic:Dictionary[int, SkillData]#技能配置
func _ready() -> void:
    #装载技能数据
    var resource_collection: = load("res://Config/resource_collection.tres")

    for config in resource_collection.tres_resources:
        #对话资源
        var dialogue = config as DialogueResource
        if dialogue != null:
            DialogueConfigDic[dialogue.id] = dialogue
            continue
        #声音资源
        var soundCfg = config as SoundRes
        if soundCfg != null:
            SoundConfigDic = soundCfg.SoundDic
            continue
        #技能资源
        var skillCfg = config as SkillData
        if skillCfg != null:
            SkillConfigDic[skillCfg.id] = skillCfg
            continue

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func load_config_data(dir_path: String) -> Array:
    var skill_resources: Array = []
    
    # 创建目录访问对象
    var dir := DirAccess.open(dir_path)
    if not dir:
        push_error("无法打开目录: " + dir_path)
        return []
    
    # 遍历目录
    dir.list_dir_begin()
    var file_name := dir.get_next()
    
    while file_name != "":
        # 跳过目录
        if dir.current_is_dir():
            file_name = dir.get_next()
            continue
        
        # 检查文件扩展名
        if file_name.get_extension() == "tres":
            var resource_path := dir_path.path_join(file_name)
            var res = load(resource_path)
            skill_resources.append(res)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    return skill_resources
##获取对话数据
func GetDialogueData(id:int) -> DialogueResource:
    var res:DialogueResource = null
    if DialogueConfigDic.has(id):
        res = DialogueConfigDic[id].duplicate(true)
    return res
    
##获取声音數據
func GetSoundData(id:int) -> AudioStream:
    var res:AudioStream = null
    if SoundConfigDic.has(id):
        res = SoundConfigDic[id].duplicate(true)
    return res
    
##获取技能资源
func GetSkillData(id:int) -> SkillData:
    var res:SkillData = null
    if SkillConfigDic.has(id):
        res = SkillConfigDic[id].duplicate(true)
    return res
#func GetFragmentData(id:int) -> FragmentData:
    #var res:FragmentData = null
    #if FragmentConfigDic.has(id):
        #res = FragmentConfigDic[id].duplicate(true)
    #return res
