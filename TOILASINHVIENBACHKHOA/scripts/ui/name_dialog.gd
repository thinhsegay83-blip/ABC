extends Control
## Hộp đặt tên nhân vật (J10). Dựng bằng code; main_menu.gd tạo và mở sau khi chọn chế độ.

signal name_confirmed(player_name: String)
signal cancelled

var _edit: LineEdit
var _error: Label
var _start_button: Button
var _defaults: PlayerDefaults


func _ready() -> void:
	_defaults = PlayerDefaults.load_default()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.09, 0.12, 0.97)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.custom_minimum_size = Vector2(420, 0)
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	var title: Label = Label.new()
	title.text = "Tên của bạn là gì?"
	title.add_theme_font_size_override("font_size", 24)
	box.add_child(title)
	var row: HBoxContainer = HBoxContainer.new()
	box.add_child(row)
	_edit = LineEdit.new()
	_edit.max_length = PlayerName.MAX_LENGTH
	_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_edit.add_theme_font_size_override("font_size", 20)
	_edit.text_changed.connect(_on_text_changed)
	_edit.text_submitted.connect(func(_text: String) -> void: _confirm())
	row.add_child(_edit)
	var random_button: Button = Button.new()
	random_button.text = "Ngẫu nhiên"
	random_button.pressed.connect(_random_name)
	row.add_child(random_button)
	_error = Label.new()
	_error.add_theme_color_override("font_color", Color(1.0, 0.45, 0.38))
	_error.add_theme_font_size_override("font_size", 14)
	box.add_child(_error)
	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(buttons)
	var back: Button = Button.new()
	back.text = "Quay lại"
	back.pressed.connect(close)
	buttons.add_child(back)
	_start_button = Button.new()
	_start_button.text = "Bắt đầu"
	_start_button.pressed.connect(_confirm)
	buttons.add_child(_start_button)
	hide()


func open(default_name: String = "") -> void:
	_edit.text = default_name if not default_name.is_empty() else _defaults.default_name
	_on_text_changed(_edit.text)
	show()
	_edit.grab_focus()
	_edit.select_all()


func close() -> void:
	if not visible:
		return
	hide()
	cancelled.emit()


func _confirm() -> void:
	if not PlayerName.validate(_edit.text).is_empty():
		return
	hide()
	name_confirmed.emit(PlayerName.sanitize(_edit.text))


func _on_text_changed(text: String) -> void:
	var problem: String = PlayerName.validate(text)
	_error.text = problem
	_start_button.disabled = not problem.is_empty()


func _random_name() -> void:
	if _defaults.random_names.is_empty():
		return
	_edit.text = _defaults.random_names[randi() % _defaults.random_names.size()]
	_on_text_changed(_edit.text)
