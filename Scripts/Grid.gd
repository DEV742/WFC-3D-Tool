extends Node3D

@export var size_x : int
@export var size_y : int
@export var size_z : int
var grid_outline = preload("res://Scenes/grid_outline.tscn")

var grid : Dictionary
var grid_container
func _ready():
	grid_container = get_node("../GridContainer")
func create_grid():
	for y in range(size_y):
		for x in range(size_x):
			for z in range(size_z):
				var key = Vector3(x,y,z)
				var object = grid_outline.instantiate()
				object.position = key
				grid_container.add_child(object)
				grid[key] = object
				

func clear_grid():
	for key in grid.keys():
		grid[key].queue_free()
	grid.clear()

func update_grid(x : int, y : int, z : int):
	size_x = x
	size_y = y
	size_z = z
	clear_grid()
	create_grid()

