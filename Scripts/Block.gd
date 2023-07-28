extends Node3D

@export var block_name : String
@export var mesh : MeshInstance3D
@export var weight : int

#Format: [U, D, F, B, L, R]
@export var sockets = {"U":"", "D":"", "F":"", "B":"", "L":"", "R":""}



#TODO
# > setMesh
# > setWeight
# > setName
# > setSockets
# > addSocket
