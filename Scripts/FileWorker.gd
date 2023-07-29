extends Node
class_name FileWorker

static func load_gltf(path: String) -> Node:
	var gltf_state = GLTFState.new()
	var gltf_doc = GLTFDocument.new()
	var file = FileAccess.open(path, FileAccess.READ)
	var fileBytes = PackedByteArray()
	fileBytes = file.get_buffer(file.get_length())
	
	gltf_doc.append_from_buffer(fileBytes, "", gltf_state)
	
	print(gltf_state.get_materials().size())
	
	var generated_node = gltf_doc.generate_scene(gltf_state)
	return generated_node

static func save_scene(scene_name: String, scene: Node) -> String:
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene)
	var path = "res://Scenes/Assets/" + scene_name + ".tscn"
	var err = ResourceSaver.save(packed_scene, path)
	if err != OK:
		print("Error while saving scene")
		return ""
	return path

static func load_scenes() -> Dictionary:
	var list = get_assets_list()
	
	var loaded_assets = {}
	
	for asset_name in list.keys():
		var scene = load_scene(asset_name)
		var asset = AssetBlock.new()
		asset.asset_name = scene.get_meta("name")
		asset.weight = int(scene.get_meta("weight"))
		asset.sockets = scene.get_meta("sockets")
		asset.scene = scene
		var bytes = scene.get_meta("thumbnail")
		if bytes != null:
			var img = Image.create_from_data(50,50, false, Image.FORMAT_RGBA8, bytes)
			var tex = ImageTexture.create_from_image(img)
			asset.thumbnail = tex
		
		loaded_assets[asset_name] = asset
	
	return loaded_assets


static func get_assets_list() -> Dictionary:
	var dir = DirAccess.open("res://Scenes/Assets/")
	
	var assets = {}
	var files = dir.get_files()
	
	var file_name
	for file in files:
		file_name = file.get_basename().trim_prefix(file.get_base_dir())
		assets[file_name] = file
	
	return assets

static func load_scene(scene_name : String) -> Node:
	var path = "res://Scenes/Assets/" + scene_name + ".tscn"
	var node = load(path).instantiate()
	return node
