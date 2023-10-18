extends Control
class_name Settings
var tab_container

var biomes = false

func _ready():
	tab_container = get_node("../../TabContainer")
	if tab_container != null:
		print("Found Tab Container!")
		tab_container.set_tab_hidden(2, true)
func _on_biomes_toggle_toggled(button_pressed):
	if tab_container != null:
		if button_pressed:
			biomes = true
			tab_container.set_tab_hidden(2, false)
		else:
			biomes = false
			tab_container.set_tab_hidden(2, true)
		
