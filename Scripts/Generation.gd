extends Control

signal _update_grid(x : int, y : int, z : int)

var grid_x = 0
var grid_y = 0
var grid_z = 0

var assets : Dictionary
var grid_controller

var clean_up = false

var wfc

var objects = []
@onready var used_items_list = $UsedAssets 

func _ready():
	var root_node = get_tree().get_root().get_child(0)
	grid_controller = root_node.find_child("Grid")
	self._update_grid.connect(grid_controller.update_grid)
	assets = FileWorker.load_scenes()
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
	assets = FileWorker.load_scenes()
	for scene_name in assets.keys():
		used_items_list.add_item(scene_name, assets[scene_name].thumbnail)


func _on_generate_button_pressed():
	for obj in objects:
		obj.queue_free()
	objects.clear()
	var selected_items = used_items_list.get_selected_items()
	var pool = {}
	var grid = grid_controller.grid
	for item in selected_items:
		for asset_key in assets.keys():
			if used_items_list.get_item_text(item) == asset_key:
				pool[assets[asset_key].asset_name] = assets[asset_key]
	wfc = WFC.new()
	wfc.grid_x = grid_x
	wfc.grid_y = grid_y
	wfc.grid_z = grid_z
	wfc.initialize(pool)
	var result = wfc.solve(clean_up)
	for x in range(grid_x):
		for y in range(grid_y):
			for z in range(grid_z):
				var asset_name
				var obj
				if result[x][y][z].chosen_block != null:
					asset_name = result[x][y][z].chosen_block.asset_name
					obj = assets[asset_name].scene.duplicate()
					objects.append(obj)
					obj.position = result[x][y][z].pos
					obj.rotate_y(deg_to_rad(result[x][y][z].rotation * 90))
					grid_controller.add_child(obj)
	print("Done")
	


func _on_clean_up_button_toggled(button_pressed):
	clean_up = button_pressed
	for obj in objects:
		obj.queue_free()
	objects.clear()
	
	var result = wfc.clean_up()
	for x in range(grid_x):
		for y in range(grid_y):
			for z in range(grid_z):
				var asset_name
				var obj
				if result[x][y][z].chosen_block != null:
					asset_name = result[x][y][z].chosen_block.asset_name
					obj = assets[asset_name].scene.duplicate()
					objects.append(obj)
					obj.position = result[x][y][z].pos
					obj.rotate_y(deg_to_rad(result[x][y][z].rotation * 90))
					grid_controller.add_child(obj)
