# 编辑器脚本 (res://editor/build_resource_list.gd)
#收集所有脚本到一个资源文件里 这样方便configmanager检索 并且打包也会将资源自动打包入包体
@tool
extends EditorScript
var folder_path = "res://Config"
func _run():
    var coll = ResourceCollection.new()
    
    collect_tres_resources(folder_path, coll, ".tres")

    ResourceSaver.save(coll, "res://Config/resource_collection.tres")
    print("资源集合已更新!")

# 递归收集所有 .tres 资源（排除特定文件）
func collect_tres_resources(path: String, collection: ResourceCollection, nameType:String) -> void:
    # 创建目录访问对象
    var dir = DirAccess.open(path)
    if not dir:
        push_error("无法打开目录: " + path)
        return
    
    # 开始遍历目录
    dir.list_dir_begin()  # Godot 4 使用 list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        # 跳过隐藏文件和当前/上级目录
        if file_name.begins_with("."):
            file_name = dir.get_next()
            continue
        
        var full_path = path.path_join(file_name)
        
        # 如果是子目录，递归遍历
        if dir.current_is_dir():
            collect_tres_resources(full_path, collection, nameType)  # 递归调用
        # 如果是 .tres 文件且不包含排除名称
        elif not dir.current_is_dir() and file_name.ends_with(nameType) and not file_name.contains("resource_collection"):
            # 加载资源并添加到集合
            var res = load(full_path)
            if res:
                collection.tres_resources.append(res)
            else:
                push_warning("加载资源失败: " + full_path)
        
        file_name = dir.get_next()
    
    # 结束遍历（Godot 4 需要）
    dir.list_dir_end()
