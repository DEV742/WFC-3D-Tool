extends Node3D

class_name AssetBlock

var asset_name : String
var weight : float
var thumbnail : ImageTexture
var path : String
var scene : Node
var biomes : Array
var constrain_to : String
var constrain_from : String
var edge_block : bool

#Format: [U, D, F, B, L, R]
var sockets = {"U":"", "D":"", "F":"", "B":"", "L":"", "R":""}

