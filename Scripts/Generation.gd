extends Control

signal _update_grid(x : int, y : int, z : int)

var grid_x = 0
var grid_y = 0
var grid_z = 0

var assets : Dictionary
var grid_controller

var clean_up = false

var wfc
var biomes
var biome_controller

var result

var assets_controller 

var display_entropy

@onready var progress_bar = $ProgressBar
@onready var export_button = $ExportButton
@onready var button = $GenerateButton
@onready var abort_button = $AbortButton

@onready var export_wizard = $ExportWizard
var biome_debug_gizmo = preload("res://Util/biome_debug.tscn")

var settings : Settings

var objects = []
@onready var used_items_list = $UsedAssets 
@onready var status_label = $StatusLabel

var tab_bar

func _ready():
	var root_node = get_tree().get_root().get_child(0)
	grid_controller = root_node.find_child("Grid")
	biome_controller = get_node("../Biomes")
	biomes = biome_controller.get_biomes()
	settings = get_node("../Settings")
	self._update_grid.connect(grid_controller.update_grid)
	assets_controller = get_node("../Assets")
	tab_bar = get_node("../../TabContainer")
	
	assets = assets_controller.assets.duplicate(true)
	if not assets.is_empty():
		for scene_name in assets.keys():
			used_items_list.add_item(scene_name, assets[scene_name].thumbnail)


func _on_grid_size_x_text_changed(new_text):
	grid_x = int(new_text)
	_update_grid.emit(grid_x, grid_y, grid_z)

func _on_grid_size_y_text_changed(new_text):
	grid_y = int(new_text)
	_update_grid.emit(grid_x, grid_y, grid_z)

func _on_grid_size_z_text_changed(new_text):
	grid_z = int(new_text)
	_update_grid.emit(grid_x, grid_y, grid_z)


func _on_deselect_all_button_pressed():
	used_items_list.deselect_all()


func _on_select_all_button_pressed():
	for idx in used_items_list.item_count:	
		used_items_list.select(idx, false)


func _on_tab_container_tab_changed(_tab):
	used_items_list.clear()
	biome_controller.update_asset_list()
	assets = assets_controller.assets
	for scene_name in assets.keys():
		used_items_list.add_item(scene_name, assets[scene_name].thumbnail)


func _on_generate_button_pressed():
	progress_bar.visible = true
	export_button.visible = false
	for obj in objects:
		obj.queue_free()
	objects.clear()
	var selected_items = used_items_list.get_selected_items()
	var pool = {}
	for item in selected_items:
		for asset_key in assets.keys():
			if used_items_list.get_item_text(item) == asset_key:
				pool[asset_key] = assets[asset_key]
				pool[asset_key].biomes = assets[asset_key].biomes
	var biomes_enabled = settings.biomes
	display_entropy = settings.display_entropy
	if wfc == null:
		wfc = WFC.new()
	wfc.grid_root = grid_controller
	wfc.assets = assets
	wfc.grid_x = grid_x
	wfc.grid_y = grid_y
	wfc.grid_z = grid_z
	wfc.progress_bar = progress_bar
	wfc.export_button = export_button
	wfc.generate_button = button
	wfc.abort_button = abort_button
	wfc.biomes_enabled = biomes_enabled
	wfc.animation_delay = settings.animation_delay
	wfc.tab_bar = tab_bar

	if biomes_enabled:
		wfc.biomes = biomes
	wfc.display_entropy = display_entropy
	wfc.status_label = status_label
	
	button.set_disabled(true)
	button.visible = false
	status_label.visible = true
	abort_button.visible = true
	abort_button.set_disabled(false)
	status_label.text = "Initializing WFC..."
	wfc.initialize(pool)
	wfc.solve()


func _on_clean_up_button_toggled(button_pressed):
	clean_up = button_pressed


func _on_export_button_pressed():
	if wfc != null and wfc.generation_finished:
		if OS.has_feature("web"):
			# save_data() reads the hex map and saves it as a pipe
			# delimited string
			var root_node = grid_controller
			var scene = prepare_scene(root_node)
			var bytes = FileWorker.get_buffer_from_scene(scene)
			#FileWorker.export_scene(scene, "user://export.glb")
			#var command = "save_file()"
			#var _ret = JavaScriptBridge.eval(command)
			JavaScriptBridge.download_buffer(bytes, "export.glb")
		else:
			export_wizard.visible = true
		


func _on_export_wizard_close_requested():
	export_wizard.visible = false

func prepare_scene(scene_root : Node3D) -> Node3D:
	var new_scene = Node3D.new()
	for root_child in scene_root.get_children():
		for child in root_child.get_children():
			var copy = child.duplicate()
			copy.position = child.get_global_position()
			copy.rotation = child.get_global_rotation()
			new_scene.add_child(copy, true)
	return new_scene

func _on_export_wizard_file_selected(path):
	print("Selected path: " + path)
	var root_node = grid_controller
	var scene = prepare_scene(root_node)
	FileWorker.export_scene(scene, path)


func _on_abort_button_pressed():
	wfc.is_aborted = true
