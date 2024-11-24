extends Camera3D
class_name Camera

@onready var hud: Control = get_node("HUD")

@onready var fovSlider: HSlider = get_node("HUD/FOV/Fov Slider")

@onready var lookH: HSlider = get_node("HUD/LOOK/Look H")
@onready var lookV: VSlider = get_node("HUD/LOOK/Look V")

@export var planes: Node3D
@export var headBackground: CSGSphere3D

@onready var otherCamera: Camera3D = get_node("HUD/AXIS/SubViewportContainer/SubViewport/Other Handle/Other Camera")

@onready var fileDialog: Control = get_node("File Dialog")
@onready var fileName: LineEdit = get_node("File Dialog/Container/MarginContainer/VBoxContainer/HBoxContainer/File Name")
@onready var invalidNameLabel: Label = get_node("File Dialog/Invalid Name Label")

func _ready():
	self.fov = 95
	self.size = 75 / 10 + 2
	otherCamera.fov = 75
	otherCamera.size = 75 / 10 + 2
	get_viewport().transparent_bg = true

func _process(delta):
	if Input.is_action_just_pressed("Enter") and fileDialog.visible:
		_on_ok_button_pressed()

func _on_fov_slider_value_changed(value):
	var f: float = 100-value
	self.fov = f+20
	self.size = (f / 10) + 2


func _on_projection_option_item_selected(index):
	projection = index
	otherCamera.projection = index


func _on_look_h_value_changed(value):
	get_parent().rotation_degrees = Vector3(get_parent().rotation_degrees.x, 360.0-(value-180.0), 0)
	otherCamera.get_parent().rotation_degrees = Vector3(get_parent().rotation_degrees.x, value-180.0, 0)

func _on_look_v_value_changed(value):
	get_parent().rotation_degrees = Vector3(value-180.0, get_parent().rotation_degrees.y, 0)
	otherCamera.get_parent().rotation_degrees = Vector3(value-180.0, get_parent().rotation_degrees.y, 0)


func _on_step_h_value_changed(value):
	lookH.step = value

func _on_step_v_value_changed(value):
	lookV.step = value


func _on_reset_look_pressed():
	get_parent().rotation_degrees = Vector3.ZERO
	otherCamera.get_parent().rotation_degrees = Vector3.ZERO
	lookH.value = 180
	lookV.value = 180
	fovSlider.value = 75
	self.fov = 95
	self.size = 75 / 10 + 2


func _on_reset_look_h_pressed():
	get_parent().rotation_degrees = Vector3(get_parent().rotation_degrees.x, 0, 0)
	lookH.value = 180

func _on_reset_look_v_pressed():
	get_parent().rotation_degrees = Vector3(0, get_parent().rotation_degrees.y, 0)
	lookV.value = 180

func _on_planes_box_toggled(toggled_on):
	planes.visible = toggled_on


func _on_aot_box_toggled(toggled_on):
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, toggled_on)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, toggled_on)

var export_image: Image
func _on_export_button_pressed():
	hud.visible = false
	headBackground.visible = false
	await get_tree().create_timer(get_process_delta_time()*2.0).timeout
	export_image = self.get_viewport().get_texture().get_image()
	fileDialog.visible = true

func close_file_dialog():
	fileDialog.visible = false
	hud.visible = true
	headBackground.visible = true

func _on_ok_button_pressed():
	invalidNameLabel.visible = false
	var file_name: String = fileName.text
	var can_save: bool = not(file_name.contains("\\") or file_name.contains("/") or file_name.contains(":") or file_name.contains("*") or file_name.contains("?") or file_name.contains('"') or file_name.contains("<") or file_name.contains(">") or file_name.contains("|")) and not(file_name.ends_with("."))
	
	if can_save:
		export_image.save_png(file_name+".png")
		close_file_dialog()
	else:
		invalidNameLabel.visible = true


func _on_cancel_button_pressed():
	invalidNameLabel.visible = false
	close_file_dialog()


func _on_erase_file_name_pressed():
	fileName.text = ""
