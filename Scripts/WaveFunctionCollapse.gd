extends Node

class_name WaveFunctionCollapse
#===================================================
#	Asset structure:
#	> Name
#	> Weight
#	> Sockets = {"Socket_Token":"Socket_Value (String JSON)"}
#	> Scene
#===================================================


static func initialize(grid_size_x : int, grid_size_y : int, grid_size_z : int, grid : Dictionary) -> void:
	for x in range(grid_size_x):
		for y in range(grid_size_y):
			for z in range(grid_size_z):
				var key = Vector3(x,y,z)
				if grid[key] != null:
					grid[key].queue_free()
				grid[key] = null

static func pick_random(assets) -> AssetBlock:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var id = randi_range(0, assets.size()-1)
	return assets[id]

static func place_random(assets, x : int, y : int, z : int, grid : Dictionary, parent : Node3D) -> void:
	var obj = pick_random(assets)
	var instance = obj.scene.duplicate()
	instance.position = Vector3(x,y,z)
	grid[Vector3(x,y,z)] = instance
	parent.add_child(instance)

