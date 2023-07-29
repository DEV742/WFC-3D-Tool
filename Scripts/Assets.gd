extends Control

@onready var settings_popup = $AssetImporter
@onready var file_dialog = $FileDialog
@onready var item_list = $ItemList
@onready var grid = $AssetImporter/MarginContainer/Panel/PreviewContainer/SubViewport/ModelContainer/Grid
var thumb_camera
var main_camera

var assets = {}

var generated_node
#Settings fields
@onready var asset_name = $NameEdit
@onready var asset_weight = $WeightEdit
@onready var asset_sockets = {
	"U" : $SocketEdit_U,
	"D" : $SocketEdit_D,
	"F" : $SocketEdit_F,
	"B" : $SocketEdit_B,
	"L" : $SocketEdit_L,
	"R" : $SocketEdit_R
}

#Importer fields
@onready var model_name = $AssetImporter/MarginContainer/Panel/HSplitContainer/LeftPanel/AssetNameEdit
@onready var model_weight = $AssetImporter/MarginContainer/Panel/HSplitContainer/LeftPanel/WeightEdit

@onready var model_sockets = {
	"U" : $AssetImporter/MarginContainer/Panel/HSplitContainer/RightPanel/Socket_U,
	"D" : $AssetImporter/MarginContainer/Panel/HSplitContainer/RightPanel/Socket_D,
	"F" : $AssetImporter/MarginContainer/Panel/HSplitContainer/RightPanel/Socket_F,
	"B" : $AssetImporter/MarginContainer/Panel/HSplitContainer/RightPanel/Socket_B,
	"L" : $AssetImporter/MarginContainer/Panel/HSplitContainer/RightPanel/Socket_L,
	"R" : $AssetImporter/MarginContainer/Panel/HSplitContainer/RightPanel/Socket_R
}

signal enter_demo
signal exit_demo
signal set_demo_model(model : Node3D)

func _ready():
	var root_node = get_tree().get_root().get_child(0)
	thumb_camera = root_node.find_child("ThumbnailCamera")
	main_camera = root_node.find_child("Camera")
	self.enter_demo.connect(root_node._enter_demo_mode)
	self.exit_demo.connect(root_node._exit_demo_mode)
	self.set_demo_model.connect(root_node._set_demo_model)
	print(FileWorker.get_assets_list())
	assets = FileWorker.load_scenes()
	for scene_name in assets.keys():
		item_list.add_item(scene_name, assets[scene_name].thumbnail)
	
func _on_file_dialog_file_selected(path):
	generated_node = FileWorker.load_gltf(path)
	grid.visible = false
	settings_popup.popup()
	enter_demo.emit()
	set_demo_model.emit(generated_node)
	


func _on_add_button_pressed():
	file_dialog.visible = true


func _on_import_save_button_pressed():
	var img = thumb_camera.get_viewport().get_texture().get_image()
	img.resize(50, 50)
	var tex = ImageTexture.create_from_image(img)
	exit_demo.emit()
	settings_popup.hide()
	var socket_values : Dictionary
	for socket_key in model_sockets.keys():
		socket_values[socket_key] = model_sockets[socket_key].text
	var asset = AssetBlock.new()
	asset.asset_name = model_name.text
	asset.weight = model_weight.text
	asset.thumbnail = tex
	asset.sockets = socket_values
	asset.scene = generated_node
	
	generated_node.set_meta("name", asset.asset_name)
	generated_node.set_meta("thumbnail", asset.thumbnail.get_image().get_data())
	generated_node.set_meta("weight", asset.weight)
	generated_node.set_meta("sockets", asset.sockets)
	var path = FileWorker.save_scene(asset.asset_name, generated_node)
	asset.path = path
	assets[asset.asset_name] = asset
	item_list.add_item(asset.asset_name, tex)


func _on_item_list_item_selected(index):
	print(item_list.get_item_text(index))
	var selected = assets[item_list.get_item_text(index)]
	asset_name.set_text(selected.asset_name)
	asset_weight.set_text(str(selected.weight))
	for socket_key in asset_sockets.keys():
		asset_sockets[socket_key].set_text(selected.sockets[socket_key])
