extends Node

@onready var grid = $SubViewportContainer/SubViewport/ModelContainer/Grid
@onready var demo_model_container = $SubViewportContainer/SubViewport/ModelContainer/DemoModelContainer
@onready var blur_layer = $SubViewportContainer/BlurLayer
@onready var file_flag = $Control/MainMenu/Panel/TabContainer/Assets 
@onready var thumbnail_camera = $SubViewportContainer/SubViewport/ModelContainer/DemoModelContainer/Thumbnail/ThumbnailCamera


#This variable enables the model import preview
var model_demo_mode = false
var demo_model : Node3D

func _enter_demo_mode():
	model_demo_mode = true
	grid.visible = false
	blur_layer.visible = true

func _set_demo_model(model : Node3D):
	demo_model = model
	if model != null:
		demo_model_container.visible = true
		demo_model_container.add_child(model)
		model.visible = true

func _exit_demo_mode():
	demo_model_container.visible = false
	model_demo_mode = false
	demo_model_container.remove_child(demo_model)
	grid.visible = true
	blur_layer.visible = false
	
