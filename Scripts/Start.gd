extends Control

@onready var wfc_info_window = $WFCInfo
@onready var wfc_design_window = $"3DModelInfo"
@onready var wfc_guide_window = $Guide

func _on_accept_dialog_close_requested():
	wfc_info_window.visible = false


func _on_wfc_info_pressed():
	wfc_info_window.visible = true


func _on_model_design_pressed():
	wfc_design_window.visible = true


func _on_d_model_info_close_requested():
	wfc_design_window.visible = false


func _on_guide_close_requested():
	wfc_guide_window.visible = false


func _on_guide_button_pressed():
	wfc_guide_window.visible = true
