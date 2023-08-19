extends Control

signal _update_grid(x : int, y : int, z : int)

var grid_x = 0
var grid_y = 0
var grid_z = 0

func _ready():
	var root_node = get_tree().get_root().get_child(0)
	var grid_controller = root_node.find_child("Grid")
	self._update_grid.connect(grid_controller.update_grid)


func _on_grid_size_x_text_changed(new_text):
	grid_x = int(new_text)
	_update_grid.emit(grid_x, grid_y, grid_z)

func _on_grid_size_y_text_changed(new_text):
	grid_y = int(new_text)
	_update_grid.emit(grid_x, grid_y, grid_z)

func _on_grid_size_z_text_changed(new_text):
	grid_z = int(new_text)
	_update_grid.emit(grid_x, grid_y, grid_z)
