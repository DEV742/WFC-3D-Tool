extends Node
class_name Voronoi
var grid = []
var biomes = {} #the biomes have to be previously checked to ensure that there is no "empty" ones
var rng = RandomNumberGenerator.new()

var generators = {} #biome_name -> vector3

var grid_x
var grid_y
var grid_z

func init(wfc_grid : Array, biomes_dict : Dictionary, grid_size_x : int, grid_size_y : int, grid_size_z : int):
	grid = wfc_grid
	biomes = biomes_dict
	
	grid_x = grid_size_x
	grid_y = grid_size_y
	grid_z = grid_size_z

func create_generators():
	for biome in biomes.keys():
		var g = random_vector()
		if not generators.values().has(g):
			generators[biome] = g
	

func random_vector():
	rng.randomize()
	var x = rng.randi_range(0, grid_x-1)
	var y = rng.randi_range(0, grid_y-1)
	var z = rng.randi_range(0, grid_z-1)
	
	return Vector3(x,y,z)

func fill():
	for x in range(grid_x):
		for y in range(grid_y):
			for z in range(grid_z):
				if grid[x][y][z].biome.is_empty():
					var min_dist = INF
					var min_dist_gen = null
					for g in generators.keys():
						var dist = distance(Vector3(x,y,z), generators[g])
						if dist <= min_dist:
							min_dist = dist
							min_dist_gen = g
					grid[x][y][z].biome = min_dist_gen

func solve():
	create_generators()
	fill()
	restrict()
	return grid

func restrict():
	var to_remove = []
	for x in range(grid_x):
		for y in range(grid_y):
			for z in range(grid_z):
				to_remove.clear()
				for proto in grid[x][y][z].possibilities:
					if not proto.biomes.has(grid[x][y][z].biome):
						to_remove.append(proto)
				for item in to_remove:
					grid[x][y][z].possibilities.erase(item)

func distance(a : Vector3, b : Vector3):
	#Euclidean metric
	var dist : float
	dist= sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2) + pow(a.z - b.z, 2))
	return dist
