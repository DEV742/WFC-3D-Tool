
class_name Cell
var possibilities = []
var collapsed = false
var pos : Vector3
var entropy = INF
var sockets = {"+X":[], "-X":[], "+Y":[], "-Y":[], "+Z":[], "-Z":[]}
var rotation = 0

#needs debugging
func update_sockets():
	self.sockets = {"+X":[], "-X":[], "+Y":[], "-Y":[], "+Z":[], "-Z":[]}
	for proto in possibilities:
		for key in proto.sockets.keys():
			for item in proto.sockets[key]:
					sockets[key].append(item)
	if possibilities.size() == 1:
		rotation = possibilities[0].rotation
