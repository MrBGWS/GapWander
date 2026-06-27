class_name UnitBase

extends Node2D
#单位数据
@export var data:UnitData = UnitData.new()
# 输入的运动方向，可能是玩家输入也可能是脚本输入，一视同仁
var input_vector:Vector2
#var AttendPackedScene = preload("res://Prefab/Unit/attend_show.tscn")
@onready var unitRender = $Render
@onready var bodySprite = $Render/Body
@onready var hitParticles = $Render/HitParticles
@onready var HpProgressBar = $PlayerUnitUI/HpProgressBar
@onready var NameLabel:RichTextLabel = $PlayerUnitUI/PlayerName
var turnAction:Callable
var isTurnAcionFinish:bool = true

## 当前实际移动速度（受buff/debuff影响）
var current_move_speed: float:
    get:
        return data.Speed

@export var team:int = 1
var Hp:float:
    get:
        return data.HP
    set(value):
        data.HP = value
        OnHpChange()
        if data.HP <= 0:
            Death()
            
var MaxHp:float:
    get:
        return data.MaxHp
    set(value):
        data.MaxHp = value

var AttackPower:float:
    get:
        return data.AttackPower
    set(value):
        data.AttackPower = value

var SpriteID:int:
    get:
        return data.SpriteID
    set(value):
        data.SpriteID = value

var SkillIDList:Array[int]:
    get:
        return data.SkillIDList
    set(value):
        data.SkillIDList = value

##技能列表
var SkillList:Array[SkillBase] = []
##物品列表
#var Items:Array[ItemData] = []

var is_jumping:bool = false
var is_dodging:bool = false

func _ready() -> void:
    if data == null:
        push_error("有单位初始数据为空！！")
        return
    #自动归一化data
    data = data.duplicate(true)
    GameManager.eventBus.turn_start.connect(TurnStart)
    GameManager.eventBus.turn_finish.connect(TurnFinish)
    
    
    #初始化技能列表
    for skillID in SkillIDList:
        var skill = SkillFactory.CreatSkill(skillID)
        if skill != null:
            skill.owner = self
            SkillList.append(skill)

    #设置着色器
    var shader = preload("res://Asset/Shaders/Unit.gdshader")
    self.bodySprite.material = ShaderMaterial.new()
    self.bodySprite.material.shader = shader

func _process(delta: float) -> void:
    _process_movement(delta)

## 处理基于 input_vector 的多向移动
func _process_movement(delta: float) -> void:
    # 跳跃/闪避期间不响应移动输入
    if is_jumping or is_dodging:
        return

    # input_vector 为外部设置，可能来自玩家输入或AI脚本
    if input_vector == Vector2.ZERO:
        return

    # 归一化方向向量，确保对角线移动速度一致
    var direction: Vector2 = input_vector.normalized()

    # 应用移动
    position += direction * current_move_speed * delta

    # 根据水平方向翻转精灵（左负右正）
    _update_sprite_facing(direction)

## 根据移动方向翻转精灵
func _update_sprite_facing(direction: Vector2) -> void:
    if unitRender == null:
        return
    if direction.x < -0.01:
        unitRender.scale.x = -abs(unitRender.scale.x)  # 面向左
    elif direction.x > 0.01:
        unitRender.scale.x = abs(unitRender.scale.x)    # 面向右
    # 水平分量极小（纯上下移动）时保持当前朝向

func TurnStart():
    isTurnAcionFinish = false
    if turnAction != null:
        turnAction.call()
    else:
        #没有动作
        Shake()
    
    isTurnAcionFinish = true
    
func TurnFinish():
    #处理输入
    pass
    

const AttackMSG = "{attacker}对{target}[color=red]进行了{damage}点攻击[/color]"

func PrepareAttack(targetUnit:UnitBase):
    turnAction = func():
        Attack(targetUnit)

func Attack(targetUnit:UnitBase):
    if targetUnit == null :
        return
    #攻击需要一段提示时间才会生效
    targetUnit.TakeDamage(AttackPower)
    #设置通知信息
    var messageStr = AttackMSG.format({"attacker": data.UnitName,"target": targetUnit.data.UnitName,"damage": AttackPower})
    GameManager.eventBus.add_game_event_str.emit(messageStr)
            
#逻辑 拿到一个敌人单位的索引
func GetOneEnemy() -> UnitBase:
    var allUnit = get_tree().get_nodes_in_group("unit")
    for unitNode in allUnit:
        var targetUnit = unitNode as UnitBase
        if targetUnit != null and targetUnit.team != team:
            return targetUnit
    return null
var hpTween:Tween

func TakeDamage(damage, damageSource = 0,damageType = 0):
    if damageSource == 1 and is_jumping:
        return
    if damageSource == 0 and is_dodging:
        return
    Hp -= damage
    #击中效果
    self.bodySprite.material.set_shader_parameter("is_damaging", true)
    self.bodySprite.material.set_shader_parameter("blink_color", Color.WHITE)
    var tween = get_tree().create_tween()
    tween.tween_method(SetShader_BlinkIntensity, 1.0, 0.0, 0.2).finished.connect(func():self.bodySprite.material.set_shader_parameter("is_damaging", false))
    
    hitParticles.restart()
    hitParticles.emitting = true
    
    #血条显隐
    if hpTween != null:
        hpTween.kill()
        hpTween = null
    hpTween = create_tween()
    hpTween.tween_property(HpProgressBar, "modulate:a", 1, 0.25)
    hpTween.tween_interval(1.0)
    hpTween.tween_property(HpProgressBar, "modulate:a", 0.5, 3.0)
func SetShader_BlinkIntensity(value:float):
    self.bodySprite.material.set_shader_parameter("blink_intensity", value)
    

func Death():
    self.queue_free()

###显示一个提示图标在头顶
#func ShowWarning(time:float, spriteID:int):
    #var prefab:AttendShow = AttendPackedScene.instantiate()
    #add_child(prefab)
    #prefab.position.y -= 30
    #prefab.Show(time)

#做错动作或没做动作 抖动一下
func Shake():
    var duration = 0.2
    var max_offset = 3
    var shakes = 5
    
    var original_pos = self.position
    var tween = create_tween()
    tween.set_parallel(false)
    
    for i in range(shakes):
        var offset = Vector2(randf_range(-max_offset, max_offset), 0)
        tween.tween_property(self, "position", original_pos + offset, duration / shakes / 2)
        tween.tween_property(self, "position", original_pos, duration / shakes / 2)
    
    #ShowWarning(duration, 1)

func OnHpChange():
    if HpProgressBar != null:
        HpProgressBar.value = 100 * (float(Hp) / data.MaxHp)
