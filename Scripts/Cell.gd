
class_name Cell
var possibilities = []
var chosen_block = null
var clean_up_possibilities = []
var collapsed = false
var pos : Vector3
var entropy = INF
var sockets = {"+X":{}, "-X":{}, "+Y":{}, "-Y":{}, "+Z":{}, "-Z":{}}
var rotation = 0
	

#needs debugging
func update_sockets():
	self.sockets = {"+X":{}, "-X":{}, "+Y":{}, "-Y":{}, "+Z":{}, "-Z":{}}
	for proto in possibilities:
		for key in proto.sockets.keys(): #X, Y, Z
			for item in proto.sockets[key].keys(): #asset_names
					if not sockets[key].has(item):
						sockets[key][item] = float(proto.sockets[key][item])
					else:
						if sockets[key][item] < float(proto.sockets[key][item]):
							sockets[key][item] = float(proto.sockets[key][item])
	if possibilities.size() == 1:
		rotation = possibilities[0].rotation

func get_possibility(name : String):
	for pos in possibilities:
		if name == pos.asset_name:
			return pos
	return null
