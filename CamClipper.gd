extends Node3D


@onready var cam_col = $v/camcollider
@onready var camera = $v/Camera

func _process(delta):
	if cam_col.is_colliding():
		camera.global_transform.origin = lerp(camera.global_transform.origin, cam_col.get_collision_point(), 0.2)
	else:
		camera.global_transform.origin = $v/camorigin.global_transform.origin
