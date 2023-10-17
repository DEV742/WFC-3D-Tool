extends Control

@onready var settings_popup = $AssetImporter
@onready var file_dialog = $FileDialog
@onready var item_list = $ItemList
@onready var grid = $AssetImporter/MarginContainer/Panel/PreviewContainer/SubViewport/ModelContainer/Grid
var thumb_camera
var main_camera

var assets = {}

var selected_asset: AssetBlock

var generated_node

var imported_asset : AssetBlock

@onready var delete_dialog  = $DeleteDialog
@onready var field_dialog = $FieldDialog
@onready var name_taken_dialog = $NameTakenDialog
@onready var not_saved_dialog = $NotSavedDialog
@onready var socket_creator_dialog = $SocketCreator

#Settings fields
@onready var asset_name = $NameEdit
@onready var asset_weight = $WeightEdit
@onready var biome_edit = $BiomeEdit
@onready var biome_editor = $BiomeEditor
@onready var asset_sockets = {
	"U" : $SocketEdit_U,
	"D" : $SocketEdit_D,
	"F" : $SocketEdit_F,
	"B" : $SocketEdit_B,
	"L" : $SocketEdit_L,
	"R" : $SocketEdit_R
}

var changes_made = false
var clicked_idx : int
var previous_clicked_idx : int
var previous_edit_string = ""

var biomes
@export var biomes_controller : Biomes

@onready var constr_to_edit = $ConstrainToLabel/ConstraintToSelect
@onready var constr_from_edit = $ConstrainFromLabel/ConstraintFromSelect

#Importer fields
@onready var model_name = $AssetImporter/MarginContainer/Panel/HSplitContainer/LeftPanel/AssetNameEdit
@onready var model_weight = $AssetImporter/MarginContainer/Panel/HSplitContainer/LeftPanel/WeightEdit

@onready var constr_to = $AssetImporter/MarginContainer/Panel/HSplitContainer/LeftPanel/ConstrToLabel/ConstraintToSelect
@onready var constr_from = $AssetImporter/MarginContainer/Panel/HSplitContainer/LeftPanel/ConstrFromLabel/ConstraintFromSelect

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

func _init():
	previous_clicked_idx = -1
	print(FileWorker.get_assets_list())
	assets = FileWorker.load_scenes()
	biomes = Biomes.load_biomes()
	
	var biome_array = []
	for asset in assets.keys():
		biome_array = []
		for biome in biomes.keys():
			if biomes[biome].has(asset):
				biome_array.append(biome)
		assets[asset].biomes = biome_array
		
func get_assets():
	return assets
	
func _ready():
	var root_node = get_tree().get_root().get_child(0)
	thumb_camera = root_node.find_child("ThumbnailCamera")
	main_camera = root_node.find_child("Camera")
	self.enter_demo.connect(root_node._enter_demo_mode)
	self.exit_demo.connect(root_node._exit_demo_mode)
	self.set_demo_model.connect(root_node._set_demo_model)
	if not assets.is_empty():
		for scene_name in assets.keys():
			item_list.add_item(scene_name, assets[scene_name].thumbnail)

func _on_file_dialog_file_selected(path):
	generated_node = FileWorker.load_gltf(path)
	grid.visible = false
	settings_popup.visible = true
	enter_demo.emit()
	set_demo_model.emit(generated_node)
	imported_asset = AssetBlock.new()
	


func _on_add_button_pressed():
	file_dialog.visible = true
	#file dialog fields can be cleared here

func _on_import_save_button_pressed():
	
	var fields_validated = true
	if model_name.text == "" or model_weight.text == "":
		fields_validated = false
	var socket_values = {}
	for socket_key in model_sockets.keys():
		if model_sockets[socket_key].text == "":
			fields_validated = false
		else:
			socket_values[socket_key] = model_sockets[socket_key].text
	
	if FileWorker.scene_exists(model_name.text):
		name_taken_dialog.visible = true
		return
	
	if fields_validated:
		var img = thumb_camera.get_viewport().get_texture().get_image()
		img.resize(50, 50)
		var tex = ImageTexture.create_from_image(img)
		exit_demo.emit()
		settings_popup.visible = false
		imported_asset = AssetBlock.new()
		imported_asset.asset_name = model_name.text
		imported_asset.weight = model_weight.text
		imported_asset.thumbnail = tex
		imported_asset.sockets = socket_values
		imported_asset.scene = generated_node
		var selected_item = constr_from.get_selected_id()
		if selected_item == -1:
			imported_asset.constrain_from = "None"
		else:
			imported_asset.constrain_from = constr_from.get_item_text(selected_item)
		selected_item = constr_to.get_selected_id()
		if selected_item == -1:
			imported_asset.constrain_to = "None"
		else:
			imported_asset.constrain_to = constr_to.get_item_text(selected_item)
		
		generated_node.set_meta("name", imported_asset.asset_name)
		generated_node.set_meta("thumbnail", imported_asset.thumbnail.get_image().get_data())
		generated_node.set_meta("weight", imported_asset.weight)
		generated_node.set_meta("sockets", imported_asset.sockets)
		generated_node.set_meta("biomes", imported_asset.biomes)
		generated_node.set_meta("constrain_to", imported_asset.constrain_to)
		generated_node.set_meta("constrain_from", imported_asset.constrain_from)
		var path = FileWorker.save_scene(imported_asset.asset_name, generated_node)
		imported_asset.path = path
		assets[imported_asset.asset_name] = imported_asset
		item_list.add_item(imported_asset.asset_name, tex)
	else:
		field_dialog.visible = true
		return


func _on_item_list_item_selected(index):
	if not changes_made:
		load_asset_data(index)

func load_asset_data(index):
	print(item_list.get_item_text(index))
	var selected = assets[item_list.get_item_text(index)]
	selected_asset = selected
	asset_name.set_text(selected.asset_name)
	asset_weight.set_text(str(selected.weight))
	
	if selected.constrain_from.is_empty() or selected.constrain_from == "None":
		constr_from_edit.select(0)
	else:
		print(selected.constrain_from)
		for i in range(constr_from_edit.item_count):
			if constr_from_edit.get_item_text(i) == selected.constrain_from:
				constr_from_edit.select(i)
	
	if selected.constrain_to.is_empty() or selected.constrain_to == "None":
		constr_to_edit.select(0)
	else:
		print(selected.constrain_to)
		for i in range(constr_to_edit.item_count):
			if constr_to_edit.get_item_text(i) == selected.constrain_to:
				constr_to_edit.select(i)
	
	for socket_key in asset_sockets.keys():
		asset_sockets[socket_key].set_text(selected.sockets[socket_key])

func _on_save_button_pressed():
	if selected_asset == null:
		print("no asset selected!")
		return
	if FileWorker.scene_exists(asset_name.text) and selected_asset.asset_name != asset_name.text:
		name_taken_dialog.visible = true
		return
	save_asset()

func save_asset():
	var old_name = selected_asset.asset_name
	selected_asset.asset_name = asset_name.text
	selected_asset.weight = asset_weight.text
	var selected_constraint = constr_to_edit.get_selected_id()
	if selected_constraint == -1:
		selected_asset.constrain_to = "None"
	else:
		selected_asset.constrain_to = constr_to_edit.get_item_text(selected_constraint)
	
	selected_constraint = constr_from_edit.get_selected_id()
	if selected_constraint == -1:
		selected_asset.constrain_from = "None"
	else:
		selected_asset.constrain_from = constr_from_edit.get_item_text(selected_constraint)
	
	selected_asset.scene.set_meta("name", selected_asset.asset_name)
	selected_asset.scene.set_meta("thumbnail", selected_asset.thumbnail.get_image().get_data())
	selected_asset.scene.set_meta("weight", selected_asset.weight)
	selected_asset.scene.set_meta("sockets", selected_asset.sockets)
	selected_asset.scene.set_meta("biomes", selected_asset.biomes)
	selected_asset.scene.set_meta("constrain_to", selected_asset.constrain_to)
	selected_asset.scene.set_meta("constrain_from", selected_asset.constrain_from)
	if old_name != selected_asset.asset_name:
		FileWorker.rename_scene(old_name, selected_asset.asset_name)
	FileWorker.save_scene(selected_asset.asset_name, selected_asset.scene)
	#reload scenes?
	reload_item_list()
	for i in range(0, item_list.item_count):
		if item_list.get_item_text(i) == selected_asset.asset_name:
			item_list.select(i)
	changes_made = false
	previous_clicked_idx = -1
	
func reload_item_list():
	item_list.clear()
	assets = FileWorker.load_scenes()
	
	biomes = Biomes.load_biomes()
	
	var biome_array = []
	for asset in assets.keys():
		biome_array = []
		for biome in biomes.keys():
			if biomes[biome].has(asset):
				biome_array.append(biome)
		assets[asset].biomes = biome_array
	
	for scene_name in assets.keys():
		item_list.add_item(scene_name, assets[scene_name].thumbnail)


func _on_delete_button_pressed():
	delete_dialog.visible = true


func _on_asset_importer_close_requested():
	exit_demo.emit()
	settings_popup.visible = false


func _on_name_edit_text_changed(_new_text):
	changes_made = true


func _on_weight_edit_text_changed(_new_text):
	changes_made = true


func _on_socket_edit_u_text_changed(_new_text):
	changes_made = true


func _on_socket_edit_d_text_changed(_new_text):
	changes_made = true


func _on_socket_edit_f_text_changed(_new_text):
	changes_made = true


func _on_socket_edit_b_text_changed(_new_text):
	changes_made = true


func _on_socket_edit_l_text_changed(_new_text):
	changes_made = true


func _on_socket_edit_r_text_changed(_new_text):
	changes_made = true


func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	if changes_made:
		not_saved_dialog.visible = true
		if previous_clicked_idx == -1:
			previous_clicked_idx = clicked_idx
	clicked_idx = index

func _on_not_saved_dialog_canceled():
	load_asset_data(clicked_idx)
	changes_made = false
	previous_clicked_idx = -1


func _on_not_saved_dialog_confirmed():
	if FileWorker.scene_exists(asset_name.text) and selected_asset.asset_name != asset_name.text:
		name_taken_dialog.visible = true
		item_list.select(previous_clicked_idx)
		return
	save_asset()


func _on_delete_dialog_confirmed():
	if selected_asset == null:
		print("no asset selected")
		return
	var scene_name = selected_asset.asset_name
	FileWorker.delete_scene(scene_name)
	#delete this item from all item sockets?
	item_list.clear()
	assets = FileWorker.load_scenes()
	for key in assets.keys():
		item_list.add_item(key, assets[key].thumbnail)

func init_socket_creator(socket : String, sockets_list : Dictionary, asset : AssetBlock):
	previous_edit_string = sockets_list[socket].text
	socket_creator_dialog.socket_key = socket
	socket_creator_dialog.init_list(assets, sockets_list[socket], asset)
	socket_creator_dialog.visible = true

func init_biome_selector():

	biome_editor.visible = true
	pass

func _on_socket_edit_u_focus_entered():
	if selected_asset == null:
		print("no asset selected")
		return
	init_socket_creator("U", asset_sockets, selected_asset)

func _on_socket_edit_d_focus_entered():
	if selected_asset == null:
		print("no asset selected")
		return
	init_socket_creator("D", asset_sockets, selected_asset)


func _on_socket_edit_f_focus_entered():
	if selected_asset == null:
		print("no asset selected")
		return
	init_socket_creator("F", asset_sockets, selected_asset)


func _on_socket_edit_b_focus_entered():
	if selected_asset == null:
		print("no asset selected")
		return
	init_socket_creator("B", asset_sockets, selected_asset)



func _on_socket_edit_l_focus_entered():
	if selected_asset == null:
		print("no asset selected")
		return
	init_socket_creator("L", asset_sockets, selected_asset)



func _on_socket_edit_r_focus_entered():
	if selected_asset == null:
		print("no asset selected")
		return
	init_socket_creator("R", asset_sockets, selected_asset)





func _asset_importer_socket_U_focus():
	init_socket_creator("U", model_sockets, imported_asset)


func _asset_importer_socket_D_focus():
	init_socket_creator("D", model_sockets, imported_asset)



func _asset_importer_socket_F_focus():
	init_socket_creator("F", model_sockets, imported_asset)



func _asset_importer_socket_B_focus():
	init_socket_creator("B", model_sockets, imported_asset)



func _asset_importer_socket_R_focus():
	init_socket_creator("R", model_sockets, imported_asset)



func _asset_importer_socket_L_focus():
	init_socket_creator("L", model_sockets, imported_asset)



func _on_biome_edit_text_changed(_new_text):
	changes_made = true


func _on_biome_edit_focus_entered():
	init_biome_selector()
	



func _on_constraint_from_select_item_selected(_index):
	changes_made = true


func _on_constraint_to_select_item_selected(_index):
	changes_made = true
