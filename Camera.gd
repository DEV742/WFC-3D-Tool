extends Node3D

var camera_pos = Vector3(0.0, 0.0, 5.0)
var camera_rot

var camera_rotation = Vector2(0.0, 0.0)
var camera_shift = Vector3(0.0, 0.0, 0.0)
var free_look_shift = Vector3(0.0, 0.0, 0.0)
var free_look_rotation = Vector2(0.0, 0.0)
var sensitivity = Vector2(0.5, 0.5)
var free_look_speed = 1

var cam_vertical_max = 75.0
var cam_vertical_min = -55.0
var lerp_smoothness = 10
var zoom = 0.0
var free_look = false
var translatedRoot = Vector3(0,0,0)
var freeLookTranslatedRoot = Vector3(0,0,0)

@onready var camera = $h/v/Camera


func translateVector(localNode: Node3D, targetNode: Node3D, shift_vector: Vector3):
	var translatedVector = Vector3.ZERO
	var originA = Vector3(0,0,0)
	var originB = Vector3(0,0,0)
	var diffC = Vector3(0,0,0)
	originA = localNode.transform.origin
	originB = originA + Vector3(shift_vector.x, shift_vector.y, shift_vector.z)
	
	originA = localNode.to_global(originA)
	originB = localNode.to_global(originB)
	
	diffC = originB - originA
	translatedVector = targetNode.transform.translated(diffC).origin
	return translatedVector

func _input(event):
	#Camera rotation around origin
	if event is InputEventMouseMotion and Input.is_action_pressed("Left_Mouse"):
		camera_rotation.x += -event.relative.x * sensitivity.x
		camera_rotation.y += -event.relative.y * sensitivity.y
	
	if Input.is_action_just_pressed("Right_Mouse"):
		camera_pos = $h.to_global(camera.transform.origin)
		camera_rot = camera.get_global_rotation_degrees()
		
		$h.transform.origin = camera_pos
		camera.transform.origin.z = 0
		
		translatedRoot = camera_pos
		free_look = true

	elif Input.is_action_just_released("Right_Mouse"):
		camera_pos = camera.to_global(camera.transform.origin)
		free_look = false
		$h.transform.origin.z = 0
		camera.transform.origin.z = 5
		translatedRoot = camera.transform.origin
		translatedRoot.z = 0


	
	if free_look:
		if event is InputEventMouseMotion:
			camera_rotation.x += -event.relative.x * sensitivity.x
			camera_rotation.y += -event.relative.y * sensitivity.y
		
	#Camera shift on local XY plane
	if event is InputEventMouseMotion and Input.is_action_pressed("Middle_Mouse") and not free_look:
		camera_shift.x = -event.relative.x * sensitivity.x/5
		camera_shift.y = event.relative.y * sensitivity.y/5
		translatedRoot = translateVector(camera, $h, camera_shift)
	
	#Camera zoom
	if Input.is_action_pressed("Mouse_Wheel_Up"):
		zoom += 1
	elif Input.is_action_pressed("Mouse_Wheel_Down"):
		zoom -= 1
	
	#Camera focus (reset of the origin to [0,0,0])
	if Input.is_action_pressed("Focus"):
		translatedRoot = Vector3.ZERO
		$h.transform.origin = Vector3.ZERO
		$h/v.transform.origin = Vector3.ZERO
	

func _physics_process(delta):
	camera_rotation.y = clamp(camera_rotation.y, cam_vertical_min, cam_vertical_max)
	if free_look:
		if Input.is_action_pressed("Forward"):
			free_look_shift.z = -free_look_speed * sensitivity.x/5
		elif Input.is_action_pressed("Backward"):
			free_look_shift.z = free_look_speed * sensitivity.x/5
		elif Input.is_action_just_released("Forward") or Input.is_action_just_released("Backward"):
			free_look_shift.z = 0
		if Input.is_action_pressed("Right"):
			free_look_shift.x = free_look_speed * sensitivity.x/5
		elif Input.is_action_pressed("Left"):
			free_look_shift.x = -free_look_speed * sensitivity.x/5
		elif Input.is_action_just_released("Left") or Input.is_action_just_released("Right"):
			free_look_shift.x = 0
		translatedRoot = translateVector(camera, $h, free_look_shift)
	
	$h.rotation_degrees.y = lerp($h.rotation_degrees.y, camera_rotation.x, delta * lerp_smoothness)
	$h/v.rotation_degrees.x = lerp($h/v.rotation_degrees.x, camera_rotation.y, delta * lerp_smoothness)
	
	$h.transform.origin.x = lerp($h.transform.origin.x, translatedRoot.x, delta * lerp_smoothness)
	$h.transform.origin.y = lerp($h.transform.origin.y, translatedRoot.y, delta * lerp_smoothness)
	$h.transform.origin.z = lerp($h.transform.origin.z, translatedRoot.z, delta * lerp_smoothness)

