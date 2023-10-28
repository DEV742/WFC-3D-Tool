extends Node3D

@export var size_x : int
@export var size_y : int
@export var size_z : int
var grid_outline = preload("res://Scenes/grid_outline.tscn")
@onready var gradient : Gradient = preload("res://Util/entropy_label_gradient.tres")
var grid : Dictionary
var grid_container

var labels = {}

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

func init_labels(entropy : int):
	for y in range(size_y):
		for x in range(size_x):
			for z in range(size_z):
				labels[Vector3(x,y,z)] = Label3D.new()
				labels[Vector3(x,y,z)].text = str(entropy)
				#labels[Vector3(x,y,z)].fixed_size = true
				labels[Vector3(x,y,z)].billboard = BaseMaterial3D.BILLBOARD_ENABLED
				labels[Vector3(x,y,z)].no_depth_test = true
				labels[Vector3(x,y,z)].position = Vector3(x,y,z)
				labels[Vector3(x,y,z)].double_sided = false
				labels[Vector3(x,y,z)].font_size = 64
				labels[Vector3(x,y,z)].set_alpha_antialiasing(BaseMaterial3D.ALPHA_ANTIALIASING_OFF)
				labels[Vector3(x,y,z)].set_modulate(gradient.sample(1))
				grid_container.add_child(labels[Vector3(x,y,z)])

func update_label(x,y,z, entropy, gradient_value):
	labels[Vector3(x,y,z)].text = entropy
	labels[Vector3(x,y,z)].set_modulate(gradient.sample(gradient_value))

func clear_labels():
	for label in labels.keys():
		labels[label].queue_free()
	labels.clear()
