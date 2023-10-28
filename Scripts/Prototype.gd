
class_name Prototype

var asset_name = ""
var name = ""
var rotation = 0
var sockets = {"+X": "", "-X": "", "+Y": "", "-Y": "", "+Z": "", "-Z": ""}
const output_order = {"R":"+X", "B":"-Z", "L":"-X", "F":"+Z", "U":"+Y", "D":"-Y"}
var weight = 0.0
var biomes = []
var acc_weight = 0.0
var edge_block = false

var valid_neighbours = {}#direction_key->list of prototype_names

var constrain_to = ""
var constrain_from = ""

#             B                                      R
#          ________                               ________
#         |        |        90 deg rot clk       |        |
#    R    |   U/D  |   L   =============>    F   |        |    B
#         |________|                             |________|
#
#             F                                       L
static func generate_sockets(asset_sockets : Dictionary, rotation_index : int):
	var rotated = asset_sockets.duplicate()
	var output = {}
	var order = ["R", "B", "L", "F"]
	var temp
	var swap

	for i in range(rotation_index):
		temp = rotated["F"]
		for key in order:
			swap = rotated[key]
			rotated[key] = temp
			temp = swap
	for key in output_order.keys():
		output[output_order[key]] = rotated[key]
	
	return output


static func generate_sockets_empty(asset_sockets : Dictionary, rotation_index : int):
	var rotated = asset_sockets.duplicate()
	var order = ["+X", "-Z", "-X", "+Z"]
	var temp
	var swap

	for i in range(rotation_index):
		temp = rotated["+Z"]
		for key in order:
			swap = rotated[key]
			rotated[key] = temp
			temp = swap
	
	
	return rotated

static func generate_protos(assets : Dictionary) -> Array:
	#create a dictionary of rotated prototypes
	#iterate through every prototype, look at its sockets and populate the valid_neighbours with
	#prototypes with the same rotation id
	
	var protos = {} #name -> rotation(1-4)->proto
	var list = []
	for asset_key in assets:
		if not protos.has(asset_key):
			var arr = []
			arr = generate_from_asset(assets[asset_key])
			for i in range(4):
				var proto_name = asset_key + "_" + str(i)
				arr[i].name = proto_name
			protos[asset_key] = arr
	#protos["Empty block"] = generate_empty()
	
	for proto in protos.keys():
		for i in range(4):
			for direction_key in protos[proto][i].sockets.keys():
				#name, direction_key, socket
				var socket = protos[proto][i].sockets[direction_key]
				if socket != "-1":
					protos[proto][i].valid_neighbours[direction_key] = get_neighbours(protos, socket, protos[proto][i].rotation, direction_key)
				else:
					protos[proto][i].valid_neighbours[direction_key] = []
					protos[proto][i].valid_neighbours[direction_key].append("Empty block")
			list.append(protos[proto][i])
	
	var empty = generate_empty(protos)
	list.append(empty)
	
	#print(str(len(list)))
	return list

static func get_neighbours(protos : Dictionary, socket : String, rotation_id : int, direction_key : String) -> Array:
	var list = []
	var opposite = {"L" : "R", "R" : "L"}
	if (str(socket[len(socket)-1]).to_upper() == "S"):
		for item_key in protos.keys():
			for i in range(4):
				var data = protos[item_key][i].sockets[WFC.OPPOSITE_DIRECTIONS[direction_key]]
				if str(data) == socket and not list.has(item_key):
					list.append(protos[item_key][i].name)
	
	elif (str(socket[len(socket)-1]).to_upper() == "L" or str(socket[len(socket)-1]).to_upper() == "R"):
		var p_socket = socket.substr(0, len(socket)-1) #socket w-out the letter
		var p_letter = socket.substr(len(socket)-1, len(socket)).to_upper() # the letter
		var opposite_socket = p_socket + opposite[p_letter].to_lower()
		for item_key in protos.keys():
			for i in range(4):
				var data = protos[item_key][i].sockets[WFC.OPPOSITE_DIRECTIONS[direction_key]]
				if str(data) == opposite_socket and not list.has(item_key):
					list.append(protos[item_key][i].name)
	elif socket == "-1":
		for item_key in protos.keys():
			for i in range(4):
				var data = protos[item_key][i].sockets[WFC.OPPOSITE_DIRECTIONS[direction_key]]
				if str(data) == socket and not list.has(item_key):
					list.append(protos[item_key][i].name)
	else:
		for item_key in protos.keys():
				var data = protos[item_key][rotation_id].sockets[WFC.OPPOSITE_DIRECTIONS[direction_key]]
				if str(data) == socket and not list.has(item_key) and socket != "-1":
					list.append(protos[item_key][rotation_id].name)
	
	return list

static func generate_from_asset(asset : AssetBlock):
	var prototypes = []
	prototypes.resize(4)
	
	for i in range(prototypes.size()):
		prototypes[i] = Prototype.new()
		prototypes[i].asset_name = asset.asset_name
		prototypes[i].rotation = i
		prototypes[i].sockets = generate_sockets(asset.sockets, i).duplicate()
		prototypes[i].weight = float(asset.weight)
		prototypes[i].biomes = asset.biomes
		prototypes[i].constrain_to = asset.constrain_to
		prototypes[i].constrain_from = asset.constrain_from
		prototypes[i].edge_block = asset.edge_block
	return prototypes

static func generate_empty(protos : Dictionary):
	var proto = Prototype.new()
	proto.asset_name = "Empty block"
	proto.name = proto.asset_name
	proto.rotation = 0
	proto.edge_block = true
	proto.weight = 0.1
	proto.sockets = {"+X": "-1", "-X": "-1", "+Y": "-1", "-Y": "-1", "+Z": "-1", "-Z": "-1"}
	for key in proto.sockets.keys():
		proto.valid_neighbours[key] = get_neighbours(protos, proto.sockets[key], 0, key)
		proto.valid_neighbours[key].append("Empty block")
	return proto
