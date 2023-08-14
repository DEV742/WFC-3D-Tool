extends Node3D

@export var size_x : int
@export var size_y : int
@export var size_z : int

var grid_outline = preload("res://Scenes/grid_outline.tscn")

var grid : Dictionary

func _ready():
	create_grid()


func create_grid():
	for x in range(size_x):
		for y in range(size_y):
			for z in range(size_z):
				var key = Vector3(x,y,z)
				var object = grid_outline.instantiate()
				object.position = key
				add_child(object)
				grid[key] = object


func clear_grid():
	for key in grid.keys():
				grid[key].queue_free()


func update_grid():
	clear_grid()
	create_grid()
