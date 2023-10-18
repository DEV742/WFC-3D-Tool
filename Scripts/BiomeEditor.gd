extends Window

@onready var biome_list = $MarginContainer/Panel/ItemList

var target_edit



func init_editor():
	biome_list.add_item("None")
	pass

func _on_save_button_pressed():
	pass # Replace with function body.


func _on_close_requested():
	self.visible = false
