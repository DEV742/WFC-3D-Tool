extends Node
class_name FileWorker
const asset_path = "user://Imports/"

static func load_gltf(path: String) -> Node:
	var gltf_state = GLTFState.new()
	var gltf_doc = GLTFDocument.new()
	var file = FileAccess.open(path, FileAccess.READ)
	var fileBytes = PackedByteArray()
	fileBytes = file.get_buffer(file.get_length())
	
	var error = gltf_doc.append_from_buffer(fileBytes, "", gltf_state)
	if error != OK:
		print("Possible empty or corrupted model")
	print(gltf_state.get_materials().size())
	
	var generated_node = gltf_doc.generate_scene(gltf_state)
	return generated_node

static func load_glb_web(bytes : PackedByteArray) -> Node:
	var gltf_state = GLTFState.new()
	var gltf_doc = GLTFDocument.new()
	
	var error = gltf_doc.append_from_buffer(bytes, "", gltf_state)
	if error != OK:
		print("Possible empty or corrupted model")
	print(gltf_state.get_materials().size())
	
	var generated_node = gltf_doc.generate_scene(gltf_state)
	return generated_node
	

static func get_buffer_from_scene(scene : Node) -> PackedByteArray:
	var gltf_state = GLTFState.new()
	var gltf_document = GLTFDocument.new()
	
	gltf_document.append_from_scene(scene, gltf_state)
	
	var array = gltf_document.generate_buffer(gltf_state)
	return array

static func save_scene(scene_name: String, scene: Node) -> String:
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene)
	
	if not DirAccess.dir_exists_absolute(asset_path):
		DirAccess.make_dir_absolute(asset_path)
	
	var path = asset_path + scene_name + ".tscn"
	var err = ResourceSaver.save(packed_scene, path)
	if err != OK:
		print("Error while saving scene")
		return ""
	return path

static func delete_scene(scene_name: String) -> bool:
	var path = asset_path + scene_name + ".tscn"
	var err = DirAccess.remove_absolute(path)
	if err == OK:
		return true
	else:
		return false

static func rename_scene(scene_to_rename: String, new_scene_name: String) -> bool:
	var path = asset_path + scene_to_rename + ".tscn"
	var path_new = asset_path + new_scene_name + ".tscn"
	var err = DirAccess.rename_absolute(path, path_new)
	
	if err == OK:
		return true
	else:
		return false


static func export_scene(scene_root : Node, path : String) -> bool:
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	var err = gltf_doc.append_from_scene(scene_root, gltf_state)
	if  err == OK:
		var write_err = gltf_doc.write_to_filesystem(gltf_state, path)
		if write_err == OK:
			print("File saved to: " + path)
			return true
	return false

static func load_scenes() -> Dictionary:
	var list = get_assets_list()
	if list.is_empty():
		return {}
	var loaded_assets = {}
	
	for asset_name in list.keys():
		var scene = load_scene(asset_name)
		var asset = AssetBlock.new()
		asset.asset_name = scene.get_meta("name")
		asset.weight = float(scene.get_meta("weight"))
		asset.sockets = scene.get_meta("sockets")
		if (scene.has_meta("constrain_to")):
			asset.constrain_to = scene.get_meta("constrain_to")
		if (scene.has_meta("constrain_from")):
			asset.constrain_from = scene.get_meta("constrain_from")
		asset.scene = scene
		var bytes = scene.get_meta("thumbnail")
		if scene.has_meta("edge_block"):
			asset.edge_block = scene.get_meta("edge_block")
		if bytes != null:
			var img = Image.create_from_data(50,50, false, Image.FORMAT_RGBA8, bytes)
			var tex = ImageTexture.create_from_image(img)
			asset.thumbnail = tex
		
		loaded_assets[asset_name] = asset
	
	return loaded_assets


static func get_assets_list() -> Dictionary:
	var dir = DirAccess.open(asset_path)
	if dir == null:
		return {}
	var assets = {}
	var files = dir.get_files()
	var file_name
	for file in files:
		file_name = file.get_basename().trim_prefix(file.get_base_dir())
		assets[file_name] = file
	
	return assets

static func import_test_set() -> void:
	var dir = DirAccess.open("res://Util/StartSet/")
	if dir == null:
		return
	if not DirAccess.dir_exists_absolute(asset_path):
		DirAccess.make_dir_absolute(asset_path)
	var assets = []
	var files = dir.get_files()
	var file_name
	for file in files:
		file_name = file
		print(file)
		assets.append(file_name)
	
	for file in assets:
		var source_path
		var target_path
		if OS.has_feature("web"):
			source_path = "res://Util/StartSet/" + file
			target_path = asset_path + file
		else:
			source_path = "res://Util/StartSet/" + file
			target_path = asset_path + file
		copy_from_res(source_path.trim_suffix(".remap"), target_path.trim_suffix("remap"))
		
static func copy_from_res(from: String, to: String) -> void:
	var file_from = ResourceLoader.load(from)
	var saved = ResourceSaver.save(file_from, to)
	print("Copying " + from + " to " + to + " : " + str(saved))
	if saved != OK:
		print("Error while saving scene")
		return

static func load_scene(scene_name : String) -> Node:
	var path = asset_path + scene_name + ".tscn"
	var node = load(path).instantiate()
	return node

static func scene_exists(scene_name : String) -> bool:
	var path = asset_path + scene_name + ".tscn"
	if FileAccess.file_exists(path):
		return true
	else:
		return false
