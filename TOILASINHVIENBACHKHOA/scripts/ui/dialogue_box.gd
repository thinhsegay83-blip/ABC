extends CanvasLayer
## Hộp thoại (E1 + J9): chân dung, tên, chữ chạy, lựa chọn, Tự động / Tua / Lịch sử.
## Dựng bằng code. Nghe DialogueSystem; đặt sau PauseMenu trong game.tscn để nhận phím trước
## (Esc chỉ bị giữ lại khi đang mở Lịch sử).

const LAYER_INDEX: int = 30
const BOX_HEIGHT: float = 200.0
const PORTRAIT_SIZE: float = 192.0
const MARGIN: float = 24.0
const BG_COLOR: Color = Color(0.06, 0.07, 0.1, 0.94)
const NARRATOR_COLOR: Color = Color(0.82, 0.84, 0.9, 1.0)
const DISABLED_COLOR: Color = Color(0.55, 0.57, 0.62, 1.0)
const SKIP_INTERVAL: float = 0.06
const AUTO_PER_CHAR: float = 0.03
## Bỏ qua phím "tiếp" trong khoảng này sau khi hội thoại vừa mở (lần nhấn E dùng để mở).
const OPEN_GRACE_MSEC: int = 200

var _root: Control
var _box: PanelContainer
var _portrait: TextureRect
var _name_label: Label
var _text: RichTextLabel
var _arrow: Label
var _auto_button: Button
var _skip_button: Button
var _choice_panel: VBoxContainer
var _history_panel: PanelContainer
var _history_text: RichTextLabel

var _line: Dictionary = {}
var _typing: bool = false
var _char_progress: float = 0.0
var _auto: bool = false
var _skip_toggle: bool = false
## Tua tạm dừng ở câu chưa đọc tới khi thả Ctrl.
var _skip_paused: bool = false
var _wait_timer: float = 0.0
var _choices: Array = []
var _choice_buttons: Array[Button] = []


func _ready() -> void:
	layer = LAYER_INDEX
	_build()
	_hide_all()
	DialogueSystem.dialogue_started.connect(_on_started)
	DialogueSystem.dialogue_finished.connect(_on_finished)
	DialogueSystem.line_shown.connect(_on_line)
	DialogueSystem.choices_shown.connect(_on_choices)


func _process(delta: float) -> void:
	if not _root.visible or _history_panel.visible:
		return
	if _typing:
		var speed: int = Settings.text_speed
		if speed <= 0 or _is_skipping():
			_finish_typing()
		else:
			_char_progress += speed * delta
			_text.visible_characters = int(_char_progress)
			if _text.visible_characters >= _text.get_total_character_count():
				_finish_typing()
		return
	if not _choices.is_empty() or _line.is_empty():
		return
	if _is_skipping():
		_wait_timer -= delta
		if _wait_timer <= 0.0:
			_next()
	elif _auto:
		_wait_timer -= delta
		if _wait_timer <= 0.0:
			_next()


func _unhandled_input(event: InputEvent) -> void:
	if not _root.visible:
		return
	if _history_panel.visible:
		if event.is_action_pressed(&"pause") or event.is_action_pressed(&"dialogue_history"):
			_history_panel.visible = false
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"dialogue_history") or _is_wheel_up(event):
		_open_history()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"dialogue_auto"):
		_set_auto(not _auto)
		get_viewport().set_input_as_handled()
		return
	if not _choices.is_empty():
		_handle_choice_input(event)
		return
	var click: bool = event is InputEventMouseButton and event.pressed \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	if event.is_action_pressed(&"dialogue_next") or click:
		if Time.get_ticks_msec() - DialogueSystem.last_started_msec < OPEN_GRACE_MSEC:
			return
		get_viewport().set_input_as_handled()
		if _typing:
			_finish_typing()
		else:
			_next()


# --- Sự kiện từ DialogueSystem --------------------------------------------

func _on_started(_node_id: String) -> void:
	_root.visible = true
	_box.visible = true
	_line = {}
	_choices = []


func _on_finished(_node_id: String) -> void:
	_hide_all()


func _on_line(line: Dictionary) -> void:
	_clear_choices()
	_line = line
	var speaker: String = str(line["speaker"])
	var is_narrator: bool = speaker == "narrator"
	_name_label.visible = not is_narrator
	_name_label.text = str(line["display_name"])
	_name_label.add_theme_color_override("font_color", line["name_color"])
	var portrait: Texture2D = line.get("portrait", null) as Texture2D
	_portrait.texture = portrait
	_portrait.visible = portrait != null and not is_narrator
	var body: String = str(line["text"])
	_text.text = "[i]%s[/i]" % body if is_narrator else body
	_text.add_theme_color_override("default_color", NARRATOR_COLOR if is_narrator else Color.WHITE)
	_text.visible_characters = 0
	_char_progress = 0.0
	_typing = true
	# Tua chỉ chạy qua câu đã đọc (trừ khi cài đặt cho tua cả câu chưa đọc).
	if _is_skipping() and not bool(line.get("is_read", false)) and not Settings.skip_unread:
		_skip_paused = true
		_skip_toggle = false
		_skip_button.button_pressed = false
	_arrow.visible = false


func _on_choices(choices: Array) -> void:
	_finish_typing()
	_arrow.visible = false
	_choices = choices
	_clear_choices()
	var number: int = 1
	for choice: Variant in choices:
		var data: Dictionary = choice
		var label: String = "%d. %s" % [number, data["text"]]
		if not data["enabled"]:
			label += "  (%s)" % data["reason"]
		var button: Button = Button.new()
		button.text = label
		button.disabled = not data["enabled"]
		button.add_theme_font_size_override("font_size", 18)
		button.custom_minimum_size = Vector2(520, 40)
		button.pressed.connect(_choose.bind(int(data["index"]), str(data["text"])))
		_choice_panel.add_child(button)
		_choice_buttons.append(button)
		number += 1
	_choice_panel.visible = true
	_focus_first_choice.call_deferred()


# --- Hành vi --------------------------------------------------------------

func _next() -> void:
	_line = {}
	_arrow.visible = false
	DialogueSystem.advance()


func _finish_typing() -> void:
	if not _typing:
		return
	_typing = false
	_text.visible_characters = -1
	_arrow.visible = _choices.is_empty()
	var chars: int = _text.get_total_character_count()
	if _is_skipping():
		_wait_timer = SKIP_INTERVAL
	else:
		_wait_timer = Settings.auto_delay + AUTO_PER_CHAR * chars


func _is_skipping() -> bool:
	if _skip_paused:
		if Input.is_action_pressed(&"dialogue_skip"):
			return false
		_skip_paused = false
	return _skip_toggle or Input.is_action_pressed(&"dialogue_skip")


func _stop_skip() -> void:
	_skip_toggle = false
	_skip_button.button_pressed = false


func _set_auto(enabled: bool) -> void:
	_auto = enabled
	_auto_button.button_pressed = enabled


func _choose(index: int, text: String) -> void:
	_clear_choices()
	_choices = []
	DialogueSystem.choose(index, text)


func _handle_choice_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key: int = (event as InputEventKey).physical_keycode
	if key >= KEY_1 and key <= KEY_9:
		var choice_index: int = key - KEY_1
		if choice_index < _choices.size():
			var data: Dictionary = _choices[choice_index]
			if data["enabled"]:
				get_viewport().set_input_as_handled()
				_choose(int(data["index"]), str(data["text"]))


func _focus_first_choice() -> void:
	for button: Button in _choice_buttons:
		if is_instance_valid(button) and not button.disabled:
			button.grab_focus()
			return


func _clear_choices() -> void:
	for button: Button in _choice_buttons:
		if is_instance_valid(button):
			button.queue_free()
	_choice_buttons.clear()
	_choice_panel.visible = false


func _open_history() -> void:
	var lines: PackedStringArray = PackedStringArray()
	for entry: Dictionary in DialogueSystem.history:
		var speaker: String = str(entry["name"])
		if speaker.is_empty():
			lines.append("[i]%s[/i]" % entry["text"])
		else:
			lines.append("[b]%s:[/b] %s" % [speaker, entry["text"]])
	_history_text.text = "\n".join(lines)
	_history_panel.visible = true
	_history_text.scroll_to_line.call_deferred(maxi(0, _history_text.get_line_count() - 1))


func _hide_all() -> void:
	_root.visible = false
	_history_panel.visible = false
	_clear_choices()
	_choices = []
	_line = {}
	_typing = false
	_stop_skip()


static func _is_wheel_up(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.pressed \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_WHEEL_UP


# --- Dựng giao diện -------------------------------------------------------

func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_box = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.set_corner_radius_all(10)
	style.set_content_margin_all(14)
	_box.add_theme_stylebox_override("panel", style)
	_box.anchor_left = 0.0
	_box.anchor_right = 1.0
	_box.anchor_top = 1.0
	_box.anchor_bottom = 1.0
	_box.offset_left = MARGIN
	_box.offset_right = -MARGIN
	_box.offset_top = -BOX_HEIGHT - MARGIN
	_box.offset_bottom = -MARGIN
	_root.add_child(_box)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	_box.add_child(row)
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(PORTRAIT_SIZE, PORTRAIT_SIZE) * 0.85
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(_portrait)

	var column: VBoxContainer = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(column)
	var top: HBoxContainer = HBoxContainer.new()
	column.add_child(top)
	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 20)
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_name_label)
	_auto_button = _small_toggle("Tự động (T)")
	_auto_button.toggled.connect(func(on: bool) -> void: _auto = on)
	top.add_child(_auto_button)
	_skip_button = _small_toggle("Tua (Ctrl)")
	_skip_button.toggled.connect(func(on: bool) -> void: _skip_toggle = on)
	top.add_child(_skip_button)
	var history_button: Button = Button.new()
	history_button.text = "Lịch sử (L)"
	history_button.focus_mode = Control.FOCUS_NONE
	history_button.add_theme_font_size_override("font_size", 13)
	history_button.pressed.connect(_open_history)
	top.add_child(history_button)

	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.fit_content = false
	_text.scroll_active = false
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text.add_theme_font_size_override("normal_font_size", 20)
	_text.add_theme_font_size_override("italics_font_size", 20)
	_text.add_theme_font_size_override("bold_font_size", 20)
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_text)
	_arrow = Label.new()
	_arrow.text = "▼"
	_arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	column.add_child(_arrow)

	_choice_panel = VBoxContainer.new()
	_choice_panel.set_anchors_preset(Control.PRESET_CENTER)
	_choice_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_choice_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_choice_panel.offset_top = -120
	_choice_panel.add_theme_constant_override("separation", 8)
	_root.add_child(_choice_panel)

	_history_panel = PanelContainer.new()
	_history_panel.add_theme_stylebox_override("panel", style)
	_history_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_history_panel.offset_left = 120
	_history_panel.offset_right = -120
	_history_panel.offset_top = 60
	_history_panel.offset_bottom = -60
	_root.add_child(_history_panel)
	var history_column: VBoxContainer = VBoxContainer.new()
	_history_panel.add_child(history_column)
	var history_title: Label = Label.new()
	history_title.text = "Lịch sử hội thoại (L / Esc để đóng)"
	history_title.add_theme_font_size_override("font_size", 20)
	history_column.add_child(history_title)
	_history_text = RichTextLabel.new()
	_history_text.bbcode_enabled = true
	_history_text.scroll_following = true
	_history_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_history_text.add_theme_font_size_override("normal_font_size", 16)
	history_column.add_child(_history_text)


static func _small_toggle(text: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 13)
	return button
