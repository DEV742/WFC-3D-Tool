extends Node3D

class_name AssetBlock

var asset_name : String
var weight : int
var thumbnail : ImageTexture
var path : String
var scene : Node

#Format: [U, D, F, B, L, R]
var sockets = {"U":"", "D":"", "F":"", "B":"", "L":"", "R":""}


#TODO
# > setMesh
# > setWeight
# > setName
# > setSockets
# > addSocket
