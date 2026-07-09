class_name UIBase
extends Control



func UpdateUI(data):
    visible = true
    process_mode = Node.PROCESS_MODE_INHERIT
func CloseUI():
    visible = false
    process_mode = Node.PROCESS_MODE_DISABLED
