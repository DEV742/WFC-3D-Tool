
class_name Cell
var possibilities = []
var chosen_block = null
var clean_up_possibilities = []
var collapsed = false
var pos : Vector3
var entropy = INF
var valid_neighbours = {"+X": [], "-X": [], "+Y": [], "-Y": [], "+Z": [], "-Z": []}
var rotation = 0
var biome : String
	

#needs debugging
func update_sockets():
	self.valid_neighbours = {"+X": [], "-X": [], "+Y": [], "-Y": [], "+Z": [], "-Z": []}
	for proto in possibilities:
		for key in proto.valid_neighbours.keys(): #X, Y, Z
			for neighbour in proto.valid_neighbours[key]:
				if not self.valid_neighbours[key].has(neighbour):
					self.valid_neighbours[key].append(neighbour)
	if possibilities.size() == 1:
		rotation = possibilities[0].rotation

func get_possibility(name : String):
	for proto in possibilities:
		if name == proto.name:
			return proto
	return null

func collapse(proto : Prototype):
	possibilities.clear()
	possibilities.append(proto)
	evaluate_entropy()
	update_sockets()

func evaluate_entropy():
	entropy = len(possibilities)
	if entropy == 1:
		chosen_block = possibilities[0]
		collapsed = true
	if entropy == 0:
		collapsed = true
