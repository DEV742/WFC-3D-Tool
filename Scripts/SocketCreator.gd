extends Window

@onready var socket_list = $MarginContainer/Panel/ItemList
@onready var socket_text = $MarginContainer/Panel/Label
@onready var weight_edit = $MarginContainer/Panel/WeightEdit

var socket_key = ""
var socket_string = ""
var target : LineEdit
var dict = {}


func init_list(list : Dictionary, target_edit : LineEdit):
	dict.clear()
	
	var current_socket_string = target_edit.text
	if current_socket_string != "" and current_socket_string != "[\"\"]":
		dict = JSON.parse_string(current_socket_string)
	target = target_edit
	socket_list.clear()
	for key in list.keys():
		socket_list.add_item(key, list[key].thumbnail)
		var id = 0
		if dict.size() > 0 and dict.has(key):
			id = socket_list.add_item(dict[key])
			socket_list.set_item_selectable(id, false)
		else:
			id = socket_list.add_item("1.0")
			socket_list.set_item_selectable(id, false)
			
	socket_list.add_item("Empty")
	socket_list.deselect_all()
	socket_text.text = "String:"
	
	#select the items present in the socket
	if dict != null:
		for array_item in dict.keys():
			for i in socket_list.get_item_count():
				if socket_list.get_item_text(i) == array_item:
					socket_list.select(i, false)
		socket_string = JSON.stringify(dict)
		socket_text.text = socket_string
	else:
		socket_text.text = "String:"


func _on_item_list_multi_selected(_index, _selected):
	var idx = socket_list.get_selected_items()
	var sockets_dict = {}
	for id in idx:
		if socket_list.get_item_text(id) != "Empty":
			sockets_dict[socket_list.get_item_text(id)] = socket_list.get_item_text(id+1)
		elif sockets_dict.size() == 0:
			sockets_dict[""] = ""
	var str_json = JSON.stringify(sockets_dict)
	socket_string = str_json
	print(str_json)
	socket_text.text = str_json
	


func _on_save_button_pressed():
	target.set_text(socket_string)
	self.visible = false
	target.text_changed.emit(socket_string)
	target.release_focus()


func _on_close_requested():
	self.visible = false
	if target != null:
		target.release_focus()


func _on_socket_weight_apply_pressed():
	var selected = socket_list.get_selected_items()
	for i in range(selected.size()):
		socket_list.set_item_text(selected[i]+1, weight_edit.text)
		dict[socket_list.get_item_text(selected[i])] = weight_edit.text
	socket_string = JSON.stringify(dict)
	socket_text.text = socket_string
