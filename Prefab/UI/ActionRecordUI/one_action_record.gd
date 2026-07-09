#class_name  HistoryOneRecordUI
extends HBoxContainer

#@onready var speakName:Label = $SpeakName
@onready var wordText:RichTextLabel = $WordText
func update_render(data:String):
    #speakName.text = data.speakerName
    wordText.text = data
