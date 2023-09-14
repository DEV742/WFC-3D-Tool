
class_name Prototype

var asset_name = ""
var rotation = 0
var sockets = {"+X": [], "-X": [], "+Y": [], "-Y": [], "+Z": [], "-Z": []}
var weight = 0.0
var acc_weight = 0.0

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
	var output_order = {"R":"+X", "B":"-Z", "L":"-X", "F":"+Z", "U":"+Y", "D":"-Y"}
	var temp
	var swap

	for i in range(rotation_index):
		temp = rotated["F"]
		for key in order:
			swap = rotated[key]
			rotated[key] = temp
			temp = swap
	
	for key in output_order.keys():
		output[output_order[key]] = JSON.parse_string(rotated[key])
		if output[output_order[key]].size() > 0 and output[output_order[key]].values().has(""):
			output[output_order[key]].clear()
	
	return output

static func generate_from_asset(asset : AssetBlock):
	var prototypes = []
	prototypes.resize(4)
	
	for i in range(prototypes.size()):
		prototypes[i] = Prototype.new()
		prototypes[i].asset_name  = asset.asset_name
		prototypes[i].rotation = i
		prototypes[i].sockets = generate_sockets(asset.sockets, i).duplicate()
		prototypes[i].weight = float(asset.weight)
	return prototypes

