class_name EventBus
extends Node

# 全局事件
signal save_game
signal load_game

signal set_main_camera_to(parent_node)

signal one_ui_open(id)#一个ui被打开
signal one_ui_close(id)#一个ui被关闭

signal start_dialog(dialogID)#开启一段对话
signal pressing_skip()#玩家按着跳过
signal show_off_pause_game_ui()#停止游戏界面

signal show_msg(text) #弹窗通知

signal play_UIAudio(audioID) #播放音频
signal play_BGM(audioID)#播放背景音乐

signal shake_main_camera(force) #晃动摄像头

signal add_role(roleID) #添加角色

signal change_stage(stageID) #转换舞台
signal change_fragment(fragmentData) #转换对话片段

signal map_player_pause(pause) #地图角色暂停
signal start_fight(enemyGroupId) #开启对战 敌人组id
signal finish_fight() #战斗结束进入结算
signal start_event(eventId) #事件id
signal choose_one_reward(itemId) #选择一个物品作为奖励

signal one_unit_die(unitData) #一个单位死亡

signal add_game_event_str(messageStr) #增加游戏信息

signal turn_start()#回合开始turn
signal turn_finish()#演出结束turnFinish
signal player_input_arrow()#玩家输入箭头
signal player_input_clear_arrow()#玩家取消箭头输入

signal player_info_list_update()#玩家组信息更新
