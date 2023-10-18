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

@onready var progress_bar = $ProgressBar
@onready var button = $GenerateButton
var biome_debug_gizmo = preload("res://Util/biome_debug.tscn")

var settings : Settings

var objects = []
@onready var used_items_list = $UsedAssets 

func _ready():
	var root_node = get_tree().get_root().get_child(0)
	grid_controller = root_node.find_child("Grid")
	biome_controller = get_node("../Biomes")
	biomes = biome_controller.get_biomes()
	settings = get_node("../Settings")
	self._update_grid.connect(grid_controller.update_grid)
	assets_controller = get_node("../Assets")
	
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
	if wfc == null:
		wfc = WFC.new()
	wfc.grid_root = grid_controller
	wfc.assets = assets
	wfc.grid_x = grid_x
	wfc.grid_y = grid_y
	wfc.grid_z = grid_z
	wfc.progress_bar = progress_bar
	wfc.generate_button = button
	wfc.biomes_enabled = biomes_enabled
	if biomes_enabled:
		wfc.biomes = biomes
	
	button.set_disabled(true)
	wfc.initialize(pool)
	wfc.solve()


func _on_clean_up_button_toggled(button_pressed):
	clean_up = button_pressed
