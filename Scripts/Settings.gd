extends Control
class_name Settings
var tab_container

var biomes = false
var display_entropy = true

var animation_delay = 0.0

@onready var animation_delay_slider = $AnimationDelaySlider
@onready var animation_delay_value = $AnimationDelayValue

func _ready():
	tab_container = get_node("../../TabContainer")
	if tab_container != null:
		print("Found Tab Container!")
		tab_container.set_tab_hidden(3, true)
func _on_biomes_toggle_toggled(button_pressed):
	if tab_container != null:
		if button_pressed:
			biomes = true
			tab_container.set_tab_hidden(3, false)
		else:
			biomes = false
			tab_container.set_tab_hidden(3, true)
		


func _on_entropy_toggle_toggled(button_pressed):
	display_entropy = button_pressed


func _on_animation_delay_slider_drag_ended(value_changed):
	if value_changed:
		animation_delay = animation_delay_slider.value
		animation_delay_value.text = str(animation_delay_slider.value/1000) + "s"
