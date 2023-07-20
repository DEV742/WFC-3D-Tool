extends Node3D

var camera_rotation_h = 0.0
var camera_rotation_v = 0.0

var cam_vertical_max = 75
var cam_vertical_min = -55

var sensitivity_h = 0.3
var sensitivity_v = 0.3

var acceleration_h = 10.0
var acceleration_v = 10.0

#func _ready():
	#$h/v/Camera.add_exception(get_parent()) -- To be implemented

func _input(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("Left_Mouse"):
		camera_rotation_h += -event.relative.x * sensitivity_h
		camera_rotation_v += -event.relative.y * sensitivity_v

func _physics_process(delta):
	camera_rotation_v = clamp(camera_rotation_v, cam_vertical_min, cam_vertical_max)
	
	$h.rotation_degrees.y = lerp($h.rotation_degrees.y, camera_rotation_h, delta * acceleration_h)
	$h/v.rotation_degrees.x = lerp($h/v.rotation_degrees.x, camera_rotation_v, delta * acceleration_v)
