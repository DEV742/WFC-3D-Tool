extends Control
class_name Biomes
@onready var biome_name = $BiomeEdit
@onready var biome_list = $BiomeList
@onready var asset_list = $AssetsList


var biomes = {}
var assets = {}
var assets_controller

const save_path = "res://biomes.gen"

func save_json():
	var json = JSON.stringify(biomes)
	print(json)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(json)
	
	return json

func update_assets():
	var biome_array = []
	for asset in assets.keys():
		biome_array = []
		for biome in biomes.keys():
			if biomes[biome].has(asset):
				biome_array.append(biome)
		assets[asset].biomes = biome_array

func update_asset_list():
	asset_list.clear()
	if not assets.is_empty():
		for key in assets.keys():
			asset_list.add_item(key, assets[key].thumbnail)

func _ready():
	assets_controller = get_node("../Assets")
	assets = assets_controller.assets
	Biomes.load_biomes()
	update_biome_list()
	update_asset_list()
	update_assets()

static func load_biomes():
	var result
	if FileAccess.file_exists(save_path):
		print("file found")
		var file = FileAccess.open(save_path, FileAccess.READ)
		result = JSON.parse_string(file.get_var())
	else:
		print("file not found")
	return result

func update_biome_list():
	biome_list.clear()
	
	for key in biomes.keys():
		biome_list.add_item(key)

func _on_add_button_pressed():
	if not biomes.has(biome_name.text): 
		biomes[biome_name.text] = []
		biome_list.add_item(biome_name.text)
	save_json()


func _on_delete_button_pressed():
	var selected = biome_list.get_selected_items()
	
	for item in selected:
		if biomes.has(biome_list.get_item_text(item)):
			biomes.erase(biome_list.get_item_text(item))
		
		biome_list.remove_item(item)
	


func _on_assign_button_pressed():
	var selected_biome = biome_list.get_selected_items()
	var selected_assets_ids = asset_list.get_selected_items()
	
	if not selected_biome.is_empty():
		biomes[biome_list.get_item_text(selected_biome[0])].clear()
		for id in selected_assets_ids:
			if not biomes[biome_list.get_item_text(selected_biome[0])].has(asset_list.get_item_text(id)):
				biomes[biome_list.get_item_text(selected_biome[0])].append(asset_list.get_item_text(id))
				
	update_assets()
	save_json()


func _on_biome_list_item_selected(index):
	var item = biome_list.get_item_text(index)
	
	asset_list.deselect_all()
	
	for id in range(asset_list.item_count):
		if biomes[item].has(asset_list.get_item_text(id)):
			asset_list.select(id, false)

func get_biomes():
	biomes = Biomes.load_biomes()
	var result = {}
	for biome in biomes.keys():
		if biomes[biome].size() != 0:
			result[biome] = biomes[biome]
	return result
