
class_name Prototype

var asset_name = ""
var rotation = 0
var sockets = {"+X": "", "-X": "", "+Y": "", "-Y": "", "+Z": "", "-Z": ""}
const output_order = {"R":"+X", "B":"-Z", "L":"-X", "F":"+Z", "U":"+Y", "D":"-Y"}
var weight = 0.0
var biomes = []
var acc_weight = 0.0

var constrain_to = ""
var constrain_from = ""

#             B                                      R
#          ________                               ________
#         |        |        90 deg rot clk       |        |
#    R    |   U/D  |   L   =============>    F   |        |    B
#         |________|                             |________|
#             F                                       L
#
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
	return prototypes
	
static func generate_empty():
	
	var proto = Prototype.new()
	proto.asset_name = "Empty block"
	proto.rotation = 0
	proto.weight = 0.01
	proto.sockets = {"+X": "", "-X": "", "+Y": "", "-Y": "", "+Z": "", "-Z": ""}
	for socket_key in proto.sockets:
		proto.sockets[socket_key] = "-1"
	return proto
		
