extends Window

@onready var socket_list = $MarginContainer/Panel/ItemList
@onready var socket_text = $MarginContainer/Panel/Label

var socket_key = ""
var socket_string = ""
var target : LineEdit


func init_list(list : Dictionary, target_edit : LineEdit):
	var current_socket_string = target_edit.text
	var array
	if current_socket_string != "":
		array = JSON.parse_string(current_socket_string)
	target = target_edit
	socket_list.clear()
	for key in list.keys():
		socket_list.add_item(key, list[key].thumbnail)
	socket_list.add_item("Empty")
	socket_list.deselect_all()
	socket_text.text = "String:"
	
	#select the items present in the socket
	if array != null:
		for array_item in array:
			for i in socket_list.get_item_count():
				if socket_list.get_item_text(i) == array_item:
					socket_list.select(i, false)
		socket_text.text = JSON.stringify(array)
	else:
		socket_text.text = "String:"


func _on_item_list_multi_selected(_index, _selected):
	var idx = socket_list.get_selected_items()
	var array = []
	for id in idx:
		if socket_list.get_item_text(id) != "Empty":
			array.append(socket_list.get_item_text(id))
		elif array.size() == 0:
			array.append("")
	var str_json = JSON.stringify(array)
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
