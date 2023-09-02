extends Node

class_name WFC
var stack = []
var prototypes = []
var grid = []

var grid_x
var grid_y
var grid_z

var rng = RandomNumberGenerator.new()

func solve():
	var start = Time.get_ticks_usec()
	while not is_collapsed():
		iterate()
	var end = Time.get_ticks_usec()
	var func_time = (end-start)/1000000.0
	print("Solved in: " + str(func_time))
	return grid
	
func iterate():
	var min_ent_cell = get_min_entropy_cell()
	collapse(min_ent_cell)
	propagate()

func propagate():
	while not stack.is_empty():
		var cell = stack.pop_front()
		var n = neighbors(cell)
		for neighbor_key in n.keys():
			propagate_to(cell, n[neighbor_key], neighbor_key)

func propagate_to(current_cell : Cell, target_cell : Cell, direction_key : String):
	if current_cell.pos != target_cell.pos:
		var to_remove = []
		for possibility in target_cell.possibilities:
			if not current_cell.sockets[direction_key].has(possibility.asset_name) and current_cell.possibilities.size() > 0 and not target_cell.collapsed:
				#print("Removing " + possibility.asset_name + " from " + str(target_cell.pos))
				to_remove.append(possibility)
		for item in to_remove:
			if target_cell.possibilities.size() == 1:
				print("Removing last socket " + item.asset_name + " from " + str(target_cell.pos))
			target_cell.possibilities.erase(item)
			target_cell.update_sockets()
			target_cell.entropy = target_cell.possibilities.size()
			stack.push_back(target_cell)
			
			if target_cell.entropy == 1:
				target_cell.collapsed = true
			elif target_cell.entropy == 0:
				print(str(target_cell.pos) + " is empty")
	else:
		print("Cycle detected")

func pick_random_cell_weighted(probabilities : Array) -> Prototype:
	var total_weight = 0.0
	
	for prob in probabilities:
		total_weight += prob.weight
		prob.acc_weight = total_weight
	
	var pick : float = randf_range(0.0, total_weight)
	
	for prob in probabilities:
		if pick < prob.acc_weight:
			return prob
	return null

func collapse(cell : Cell):
	rng.randomize()
	if cell.possibilities.size() > 0:
		var proto = pick_random_cell_weighted(cell.possibilities)
		while proto == null:
			proto = pick_random_cell_weighted(cell.possibilities)
		cell.possibilities.clear()
		cell.possibilities.append(proto)
		print("Collapsing " + str(cell.pos) + " to " + proto.asset_name)
	cell.entropy = 10.
	cell.collapsed = true
	cell.update_sockets()
	stack.push_back(cell)

func get_random_cell() -> Vector3:
	var pos = random_vector()
	while grid[pos.x][pos.y][pos.z].collapsed:
		pos = random_vector()
	return pos

func random_vector() -> Vector3:
	rng.randomize()
	var x = randi_range(0, grid_x-1)
	var y = randi_range(0, grid_y-1)
	var z = randi_range(0, grid_z-1)
	
	return Vector3(x,y,z)
	
func get_min_entropy_cell():
	var pos = get_random_cell()
	var min_ent_cell = grid[pos.x][pos.y][pos.z]
	var random_needed = false
	var random_pool = []
	
	for x in range(grid_x):
		for y in range(grid_y):
			for z in range(grid_z):
				if grid[x][y][z].entropy < min_ent_cell.entropy and not grid[x][y][z].collapsed:
					min_ent_cell = grid[x][y][z]
				elif grid[x][y][z].entropy == min_ent_cell.entropy and not grid[x][y][z].collapsed:
					random_needed = true
					if not random_pool.has(min_ent_cell):
						random_pool.append(min_ent_cell)
					random_pool.append(grid[x][y][z])
	print(str(min_ent_cell.pos))
	return min_ent_cell

func is_collapsed() -> bool:
	var solved = true
	for x in range(grid_x):
		for y in range(grid_y):
			for z in range(grid_z):
				if not grid[x][y][z].collapsed:
					#print ("x : " + str(x) + " y : " + str(y) + " z : " + str(z))
					solved = false
	return solved

func neighbors(cell : Cell):
	var n = {}
	var pos = cell.pos
	if pos.y + 1 < grid_y:
		n["-Y"] = grid[pos.x][pos.y+1][pos.z]
	if pos.y - 1 >= 0:
		n["+Y"] = grid[pos.x][pos.y-1][pos.z]
	
	if pos.x + 1 < grid_x:
		n["+X"] = grid[pos.x+1][pos.y][pos.z]
	if pos.x - 1 >= 0:
		n["-X"] = grid[pos.x-1][pos.y][pos.z]
	
	
	if pos.z + 1 < grid_z:
		n["+Z"] = grid[pos.x][pos.y][pos.z+1]
	if pos.z - 1 >= 0:
		n["-Z"] = grid[pos.x][pos.y][pos.z-1]
	return n
	
func initialize(assets : Dictionary):
	for key in assets.keys():
		prototypes.append_array(Prototype.generate_from_asset(assets[key]))
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
				grid[x][y][z].entropy = prototypes.size()
				grid[x][y][z].update_sockets()
