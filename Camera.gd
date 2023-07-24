extends Node3D

var camera_rotation_h = 0.0
var camera_rotation_v = 0.0

var camera_shift_h = 0.0
var camera_shift_v = 0.0

var cam_vertical_max = 75.0
var cam_vertical_min = -55.0

var sensitivity_h = 0.3
var sensitivity_v = 0.3

var acceleration_h = 10.0
var acceleration_v = 10.0

var originA = Vector3(0,0,0)
var originB = Vector3(0,0,0)
var diffC = Vector3(0,0,0)
var translatedRoot = Vector3(0,0,0)

#func _ready():
	#$h/v/Camera.add_exception(get_parent()) -- To be implemented

func _input(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("Left_Mouse"):
		camera_rotation_h += -event.relative.x * sensitivity_h
		camera_rotation_v += -event.relative.y * sensitivity_v
		
	if event is InputEventMouseMotion and Input.is_action_pressed("Middle_Mouse"):
		camera_shift_h = -event.relative.x * 0.1
		camera_shift_v = event.relative.y * 0.1
		originA = $h/v/camorigin.transform.origin
		originB = originA + Vector3(camera_shift_h, camera_shift_v, 0)
		
		originA = $h/v/camorigin.to_global(originA)
		originB = $h/v/camorigin.to_global(originB)
		
		diffC = originB - originA
		translatedRoot = transform.translated(diffC).origin

func _physics_process(delta):
	transform.origin.x = lerp(transform.origin.x, translatedRoot.x, delta * acceleration_h)
	transform.origin.y = lerp(transform.origin.y, translatedRoot.y, delta * acceleration_v)
	transform.origin.z = lerp(transform.origin.z, translatedRoot.z, delta * acceleration_h)

	
	camera_rotation_v = clamp(camera_rotation_v, cam_vertical_min, cam_vertical_max)
	
	$h.rotation_degrees.y = lerp($h.rotation_degrees.y, camera_rotation_h, delta * acceleration_h)
	$h/v.rotation_degrees.x = lerp($h/v.rotation_degrees.x, camera_rotation_v, delta * acceleration_v)
	
	#$h/v/camorigin.transform.origin.x = lerp($h/v/camorigin.transform.origin.x, camera_shift_h, delta * acceleration_h)
	#$h/v/camorigin.transform.origin.y = lerp($h/v/camorigin.transform.origin.y, camera_shift_v, delta * acceleration_v)
