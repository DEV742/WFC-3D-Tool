extends Control

@onready var file_address = $FileLabel
@onready var settings_popup = $AssetImporter
@onready var file_dialog = $FileDialog
@onready var item_list = $ItemList
@onready var grid = $AssetImporter/MarginContainer/Panel/PreviewContainer/SubViewport/ModelContainer/Grid
var thumb_camera
var main_camera

#Importer fields
@onready var model_name = $AssetImporter/MarginContainer/Panel/HSplitContainer/LeftPanel/AssetNameEdit

signal enter_demo
signal exit_demo
signal set_demo_model(model : Node3D)

var gltf_state = GLTFState.new()
var gltf_doc = GLTFDocument.new()
var file

func _ready():
	var root_node = get_tree().get_root().get_child(0)
	thumb_camera = root_node.find_child("ThumbnailCamera")
	main_camera = root_node.find_child("Camera")
	self.enter_demo.connect(root_node._enter_demo_mode)
	self.exit_demo.connect(root_node._exit_demo_mode)
	self.set_demo_model.connect(root_node._set_demo_model)
	
func _on_file_dialog_file_selected(path):
	gltf_state = GLTFState.new()
	gltf_doc = GLTFDocument.new()
	file_address.text = "Selected file: " + path
	file = FileAccess.open(path, FileAccess.READ)
	var fileBytes = PackedByteArray()
	fileBytes = file.get_buffer(file.get_length())
	
	gltf_doc.append_from_buffer(fileBytes, "", gltf_state)
	
	print(gltf_state.get_materials().size())
	
	var generated_node = gltf_doc.generate_scene(gltf_state)
	grid.visible = false
	settings_popup.popup()
	enter_demo.emit()
	set_demo_model.emit(generated_node)
	file.close()
	

func save_model():
	print("hello")

func _on_add_button_pressed():
	file_dialog.visible = true


func _on_import_save_button_pressed():
	var img = thumb_camera.get_viewport().get_texture().get_image()
	img.resize(50, 50)
	var tex = ImageTexture.create_from_image(img)
	item_list.add_item(model_name.text, tex)
	exit_demo.emit()
	settings_popup.hide()
