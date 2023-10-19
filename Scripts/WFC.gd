extends Node

class_name WFC

const CONSTRAINT_BOTTOM = "Bottom"
const CONSTRAINT_TOP = "Top"


var stack = []
var prototypes = []
var grid = []

var total_blocks : int
var progress = 0.0
var collapsed = 0.0
var progress_bar : ProgressBar
var export_button : Button
var generate_button : Button


var biomes = {}

var grid_x
var grid_y
var grid_z

var biomes_enabled : bool

var generation_finished = false

var voronoi : Voronoi
var solve_thread : Thread

const OPPOSITE_DIRECTIONS = {"+X":"-X", "+Y":"-Y", "+Z":"-Z", "-X":"+X", "-Y":"+Y", "-Z":"+Z"}

var rng = RandomNumberGenerator.new()


var objects = []
var enable = false
var grid_root
var assets = {}
var created_objects_pos = []
func clear_meshes():
	created_objects_pos.clear()
	for mesh in objects:
		grid_root.call_deferred("remove_child", mesh)
		mesh.queue_free()
	objects = []

func visualize():
	collapsed = 0
	for x in range(grid_x):
			for y in range(grid_y):
				for z in range(grid_z):
					var asset_name
					var obj
					var cell = grid[x][y][z]
					
					if cell.collapsed:
						collapsed += 1
					if cell.chosen_block != null and cell.collapsed and cell.chosen_block.asset_name != "Empty block" and not created_objects_pos.has(cell.pos):
						asset_name = cell.chosen_block.asset_name
						obj = assets[asset_name].scene.duplicate()
						objects.append(obj)
						obj.position = cell.pos
						obj.rotate_y(deg_to_rad(90*cell.rotation))
						if not created_objects_pos.has(cell.pos):
							created_objects_pos.append(cell.pos)
						grid_root.call_deferred("add_child", obj)
	progress = float((float(collapsed)/float(total_blocks)) * 100.0)
	progress_bar.call_deferred("set_value", progress)
	await grid_root.get_tree().process_frame

#Constrain prototypes so there are for example no
#tops of the models on the bottom layer
#no bottom blocks above y=0
#no middle blocks on edges of the grid
func apply_custom_constraints():
	
	for x in range(grid_x):
		for y in range(grid_y):
			for z in range(grid_z):
				var coords = Vector3(x, y, z)
				var protos = grid[x][y][z].possibilities
				if y == grid_y - 1:  # constrain top layer to not contain any uncapped prototypes
					for proto in protos.duplicate():
						if not proto.sockets["+Y"] == "-1":
							constrain(grid[x][y][z], proto)
							if not coords in stack:
								stack.append(coords)
				if y > 0:  # everything other than the bottom
					for proto in protos.duplicate():
						var custom_constraint = proto.constrain_to
						if custom_constraint == WFC.CONSTRAINT_BOTTOM:
							constrain(grid[x][y][z], proto)
							if not coords in stack:
								stack.append(coords)
				if y < grid_y - 1:  # everything other than the top
					for proto in protos.duplicate():
						var custom_constraint = proto.constrain_to
						if custom_constraint == WFC.CONSTRAINT_TOP:
							constrain(grid[x][y][z], proto)
							if not coords in stack:
								stack.append(coords)
				if y == 0:  # constrain bottom layer so we don't start with any top-cliff parts at the bottom
					for proto in protos.duplicate():
						var custom_constraint = proto.constrain_from
						if proto.sockets["+Y"] != "-1" or (custom_constraint == WFC.CONSTRAINT_BOTTOM):
							constrain(grid[x][y][z], proto)
							if not coords in stack:
								stack.append(coords)
				if x == grid_x - 1: # constrain +x
					for proto in protos.duplicate():
						if not proto.sockets["+X"] == "-1":
							constrain(grid[x][y][z], proto)
							if not coords in stack:
								stack.append(coords)
				if x == 0: # constrain -x
					for proto in protos.duplicate():
						if not proto.sockets["-X"] == "-1":
							constrain(grid[x][y][z], proto)
							if not coords in stack:
								stack.append(coords)
				if z == grid_z - 1: # constrain +z
					for proto in protos.duplicate():
						if not proto.sockets["+Z"] == "-1":
							constrain(grid[x][y][z], proto)
							if not coords in stack:
								stack.append(coords)
				if z == 0: # constrain -z
					for proto in protos.duplicate():
						if not proto.sockets["-Z"] == "-1":
							constrain(grid[x][y][z], proto)
							if not coords in stack:
								stack.append(coords)
	propagate(false)

func solve():
	clear_meshes()
	generation_finished = false
	solve_thread = Thread.new()
	solve_thread.start(solve_multithreaded)


func solve_multithreaded():
	apply_custom_constraints()
	if biomes_enabled:
		voronoi = Voronoi.new()
		voronoi.init(grid, biomes, grid_x, grid_y, grid_z)
		grid = voronoi.solve()
	
	while not is_collapsed():
		iterate()
		visualize()
	solve_thread.call_deferred("wait_to_finish")
	print("Done!")
	progress_bar.call_deferred("set_visible", false)
	export_button.call_deferred("set_visible", true)
	generate_button.call_deferred("set_disabled", false)
	generation_finished = true

func iterate():
	var min_ent_cell = get_min_entropy_cell()
	collapse(min_ent_cell)
	propagate(min_ent_cell.pos)

func propagate(co_ords):
	if co_ords:
		stack.append(co_ords)
	while len(stack) > 0:
		var cell = stack.pop_back()
		var n = neighbors(grid[cell.x][cell.y][cell.z])
		for neighbor_key in n.keys():
			propagate_to(grid[cell.x][cell.y][cell.z], n[neighbor_key], neighbor_key)

func constrain(cell : Cell, prototype : Prototype):
	cell.possibilities.erase(prototype)
	cell.evaluate_entropy()
	cell.update_sockets()


func check_rules(current_cell : Cell, proto : Prototype, direction_key):
	var opposite = {"L" : "R", "R" : "L"}
	var proto_socket = str(proto.sockets[OPPOSITE_DIRECTIONS[direction_key]])
	if (str(proto_socket[len(proto_socket)-1]).to_upper() == "L" or str(proto_socket[len(proto_socket)-1]).to_upper() == "R"):
			var p_socket = proto_socket.substr(0, len(proto_socket)-1)
			var p_letter = proto_socket.substr(len(proto_socket)-1, len(proto_socket)).to_upper()
			var opposite_socket = p_socket + opposite[p_letter].to_lower()
			if current_cell.sockets[direction_key].has(opposite_socket):
				return false
			if current_cell.sockets[direction_key].has(proto_socket):
				return true
	if not current_cell.sockets[direction_key].has(proto.sockets[OPPOSITE_DIRECTIONS[direction_key]]):
		return true
	
	
func propagate_to(current_cell : Cell, target_cell : Cell, direction_key : String):
	if current_cell.pos != target_cell.pos:
		var pool = target_cell.possibilities.duplicate()
		for possibility in pool:
			if not target_cell.collapsed and check_rules(current_cell, possibility, direction_key):
				constrain(target_cell, possibility)
				if not target_cell.pos in stack and not target_cell.collapsed:
					stack.append(target_cell.pos)


func pick_random_cell_weighted(probabilities : Array) -> Prototype:
	rng.randomize()	
	var total_weight = 0.0
	
	for prob in probabilities:
		total_weight += prob.weight
		prob.acc_weight = total_weight
	
	var pick : float = rng.randf_range(0.0, total_weight)
	
	for prob in probabilities:
		if pick < prob.acc_weight:
			return prob
	return null


func collapse(cell : Cell):
	var proto
	proto = pick_random_cell_weighted(cell.possibilities)
	while proto == null and len(cell.possibilities) > 0:
		proto = pick_random_cell_weighted(cell.possibilities)
	cell.collapse(proto)
	if not stack.has(cell.pos):
		stack.append(cell.pos)

func get_random_cell() -> Vector3:
	var pos = random_vector()
	while grid[pos.x][pos.y][pos.z].collapsed:
		pos = random_vector()
	return pos

func random_vector() -> Vector3:
	rng.randomize()
	var x = rng.randi_range(0, grid_x-1)
	var y = rng.randi_range(0, grid_y-1)
	var z = rng.randi_range(0, grid_z-1)
	
	return Vector3(x,y,z)
	
func get_min_entropy_cell():
	var pos = get_random_cell()
	var min_ent_cell = grid[pos.x][pos.y][pos.z]
	var min_ent = INF
	for x in range(grid_x):
		for y in range(grid_y):
			for z in range(grid_z):
				if grid[x][y][z].entropy < min_ent and not grid[x][y][z].collapsed:
					min_ent_cell = grid[x][y][z]
					min_ent = min_ent_cell.entropy
	return min_ent_cell

func is_collapsed() -> bool:
	for x in range(grid_x):
		for y in range(grid_y):
			for z in range(grid_z):
				if not grid[x][y][z].collapsed:
					return false
	return true

func neighbors(cell : Cell):
	var n = {}
	var pos = cell.pos
	
	if pos.y + 1 < grid_y:
		n["+Y"] = grid[pos.x][pos.y+1][pos.z]
	if pos.y - 1 >= 0:
		n["-Y"] = grid[pos.x][pos.y-1][pos.z]
	
	if pos.x + 1 < grid_x:
		n["+X"] = grid[pos.x+1][pos.y][pos.z]
	if pos.x - 1 >= 0:
		n["-X"] = grid[pos.x-1][pos.y][pos.z]
	
	
	if pos.z + 1 < grid_z:
		n["+Z"] = grid[pos.x][pos.y][pos.z+1]
	if pos.z - 1 >= 0:
		n["-Z"] = grid[pos.x][pos.y][pos.z-1]
	return n
	
func initialize(pool : Dictionary):
	total_blocks = grid_x * grid_y * grid_z
	prototypes.clear()
	grid.clear()
	prototypes = []
	progress = 0
	collapsed = 0.0
	progress_bar.call_deferred("set_value", 0)
	grid = []
	stack = []
	for key in pool.keys():
		prototypes.append_array(Prototype.generate_from_asset(pool[key]))
	prototypes.append(Prototype.generate_empty())
	grid.resize(grid_x)
	for x in range(grid_x):
		grid[x] = []
		grid[x].resize(grid_y)
		for y in range(grid_y):
			grid[x][y] = []
			grid[x][y].resize(grid_z)
			for z in range(grid_z):
				grid[x][y][z] = Cell.new()
				grid[x][y][z].pos = Vector3(x,y,z)
				grid[x][y][z].possibilities = prototypes.duplicate()
				grid[x][y][z].entropy = len(prototypes)
				grid[x][y][z].update_sockets()
	return grid
