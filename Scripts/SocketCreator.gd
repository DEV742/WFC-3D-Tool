extends Window

@onready var socket_list = $MarginContainer/Panel/ItemList

@onready var grid = $MarginContainer/Panel/ScrollContainer/GridContainer

@onready var socket_id_edit = $MarginContainer/Panel/Socket

var socket_key = ""
var socket_string = ""

var edited_asset : AssetBlock

var target : LineEdit

var assets = {}

var added_assets = []

var elements = {}

var socket_id = ""

var used_sockets = []


func clear_grid_elements():
	for key in elements.keys():
		if len(elements[key]) != 0:
			for item in elements[key]:
				if item.get_parent() == grid:
					grid.remove_child(item)
	

func load_valid_neighbours(socket : String):
	var img
	var label
	added_assets.clear()
	clear_grid_elements()
	for item_key in assets.keys():
		for s in assets[item_key].sockets.keys():
			var data = assets[item_key].sockets[s]
			if str(data) == socket and not added_assets.has(item_key):
				img = TextureRect.new()
				label = Label.new()
				img.texture = assets[item_key].thumbnail
				label.text = item_key
				grid.add_child(img)
				grid.add_child(label)
				elements[item_key] = []
				elements[item_key].append(img)
				elements[item_key].append(label)
				added_assets.append(item_key)

func init_list(list : Dictionary, target_edit : LineEdit, asset : AssetBlock):
	socket_list.deselect_all()
	edited_asset = asset
	target = target_edit
	assets = list
	added_assets.clear()
	
	clear_grid_elements()
	
	var string = asset.sockets[socket_key]

	socket_id_edit.text = str(string)
	load_valid_neighbours(string)

	for item_key in list.keys():
		for socket_dir in list[item_key].sockets.keys():
			var data = list[item_key].sockets[socket_dir]
			if not used_sockets.has(str(data)):
				socket_list.add_item(str(data))
				used_sockets.append(str(data))
	
	for i in range(socket_list.item_count):
		if socket_list.get_item_text(i) == str(string):
			socket_list.select(i)


func _on_save_button_pressed():
	var text = socket_id_edit.text
	while str(text).ends_with(" "):
		text = str(text).substr(0, len(text)-1)
	socket_id = text

	edited_asset.sockets[socket_key] = socket_id
	print(socket_id)
	target.set_text(socket_id)
	self.visible = false
	target.text_changed.emit(socket_string)
	target.release_focus()


func _on_close_requested():
	self.visible = false
	if target != null:
		target.release_focus()


func _on_item_list_item_selected(index):
	var text = socket_list.get_item_text(index)
	socket_id_edit.text = text
	load_valid_neighbours(text)


func _on_socket_text_changed(new_text):
	while str(new_text).ends_with(" "):
		new_text = str(new_text).substr(0, len(new_text)-1)
	for i in range(socket_list.item_count):
		if socket_list.get_item_text(i) == new_text:
			socket_list.select(i)
	load_valid_neighbours(new_text)
