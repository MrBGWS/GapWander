class_name  UtilsTool
extends Node


#region Hole项目新增
#通过玩家槽拿颜色
static func PlayerSlotIndexToColor(index:int):
    var res:Color = Color.WHITE
    match index:
        1:
            res = Color.SKY_BLUE
        2:
            res = Color.SEA_GREEN
        3:
            res = Color.WHITE
    return res
# 将任意 Resource 转为字典（只包含导出属性，可选是否递归转换嵌套的 Resource）
static func resource_to_dict(res: Resource, recursive: bool = true) -> Dictionary:
    var dict = {}
    for prop in res.get_property_list():
        # 只处理导出属性（且不是内部属性）
        if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
            var prop_name = prop.name
            var value = res.get(prop_name)
            if recursive and value is Resource:
                value = resource_to_dict(value, true)
            dict[prop_name] = value
    return dict

# 从字典还原 Resource（需要传入一个空实例或类名）
static func dict_to_resource(dict: Dictionary, resource_class: Script) -> Resource:
    var res = resource_class.new()
    for prop_name in dict:
        if res.has_method("get") and res.get(prop_name) != null:  # 简单检查属性是否存在
            var value = dict[prop_name]
            # 如果值本身也是一个字典，且对应属性是 Resource，尝试递归还原
            if value is Dictionary:
                var prop_type = typeof(res.get(prop_name))
                if prop_type == TYPE_OBJECT:
                    # 需要知道嵌套的 Resource 类型，这里简化：假设是相同类或需要手动处理
                    # 更好的做法是存储一个 "_class" 字段，此处不展开
                    pass
            res.set(prop_name, value)
    return res
#endregion
#region DKA项目
# 使用组搜索
static func find_nearby_nodes_in_group(position: Vector2, radius: float, group: String) -> Array:
    var result = []
    var group_nodes = _get_tree().get_nodes_in_group(group)
    var radius_squared = radius * radius
    
    for node in group_nodes:
        if node is Node2D:
            var distance_squared = position.distance_squared_to(node.global_position)
            if distance_squared <= radius_squared:
                result.append(node)
    
    return result

# 辅助函数：安全获取场景树
static func _get_tree() -> SceneTree:
    return Engine.get_main_loop() as SceneTree

#将总时间秒换成xx:xx:xx的格式
static func get_clock_format_by_second(seconds:int):
    @warning_ignore("integer_division")
    var hours:int = seconds / 3600
    @warning_ignore("integer_division")
    var minutes:int= (seconds % 3600) / 60
    var secs:int= int(seconds) % 60
    return "%02d:%02d:%02d" % [hours, minutes, secs]

##得到项目设置的输入动作对应的按键名
static func get_action_name(action_name: String) -> String:
    var key_name = ""
    # 遍历该动作的所有输入事件
    for event in InputMap.action_get_events(action_name):
        if event is InputEventKey:  # 键盘按键
            key_name = event.as_text()
            var regex = RegEx.new()
            regex.compile("\\s+|\\([^()]*\\)|\\[[^\\[\\]]*\\]|\\{[^{}]*\\}")
            key_name = regex.sub(key_name, "", true)
        elif event is InputEventMouseButton:  # 鼠标按键
            key_name = "Mouse %d" % event.button_index
        elif event is InputEventJoypadButton:  # 手柄按键
            key_name = "Joy Button %d" % event.button_index
        elif event is InputEventJoypadMotion:  # 手柄摇杆/扳机
            var axis = "Axis %d %s" % [event.axis, "+" if event.axis_value > 0 else "-"]
            key_name = axis
    return key_name

#清除列表中不存在和为空的对象
static func filter_out_list_invaild(list:Array):
    return list.filter(func(unit): return unit != null)

# 将IP地址和端口号编码为一个长整数
static func encode_ip_port(ip: String, port: int) -> int:
    var ip_parts = ip.split(".")
    if ip_parts.size() != 4:
        push_error("Invalid IP address format: " + ip)
        return 0
    
    # 将IP地址的四个部分转换为整数
    var ip_num = (int(ip_parts[0]) << 24) + (int(ip_parts[1]) << 16) + (int(ip_parts[2]) << 8) + int(ip_parts[3])
    # 将IP左移16位，然后与端口组合
    return (ip_num << 16) | port

# 将长整数解码回IP地址和端口号
static func decode_ip_port(combined: int) -> Dictionary:
    var port = combined & 0xFFFF  # 获取低16位（端口号）
    var ip_num = combined >> 16   # 获取高32位（IP地址）
    
    # 从32位整数中提取IP的四个部分
    var ip_parts = []
    ip_parts.append((ip_num >> 24) & 0xFF)  # 最高8位
    ip_parts.append((ip_num >> 16) & 0xFF)
    ip_parts.append((ip_num >> 8) & 0xFF)
    ip_parts.append(ip_num & 0xFF)          # 最低8位
    
    var ip_str = ".".join(ip_parts)
    return {"ip": ip_str, "port": port}

# 一个简单的获取本机IPv4地址的函数 注意！这样获取的ip没有多大意义 还得是对应局域网的ip
static func get_local_ip() -> String:
    var addresses = IP.get_local_addresses()
    for ip in addresses:
        # 筛选IPv4地址且非回环地址(127.0.0.1)
        if ip.count(".") == 3 and not ip.begins_with("127."):
            return ip
    # 如果没有找到合适的IP，返回本地回环地址或空字符串
    return "127.0.0.1" # 或者 return ""


#迭代器类型处理相关
#检查一个字典是否都是空
static func is_dic_all_null(dic:Dictionary):
    var res = true
    for index in dic:
        if dic[index] != null:
            res = false
    return res

#endregion
