extends CanvasLayer
## Giao diện cầu thang vô tận (G3) — bản chữ, dùng tới khi có bản đồ cầu thang (bước 2).
## Mỗi chiếu nghỉ liệt kê các chi tiết; chiếu nghỉ đầu là "bản gốc". So sánh, đo tiếng ù bằng
## điện thoại (Tab → Radar), rồi chọn Đi lên / Đi xuống. Phím G: Suy nghĩ (gợi ý).

const LAYER_INDEX: int = 41
const BG_COLOR: Color = Color(0.07, 0.07, 0.12, 0.96)
const ACCENT: Color = Color(0.78, 0.7, 0.98, 1.0)
const MUTED: Color = Color(0.62, 0.65, 0.72, 1.0)

var _panel: PanelContainer
var _body: VBoxContainer


func _ready() -> void:
	layer = LAYER_INDEX
	_build()
	_panel.visible = false
	AnomalyDirector.stair_loop_started.connect(_refresh)
	AnomalyDirector.stair_landing_changed.connect(func(_index: int) -> void: _refresh())
	AnomalyDirector.stair_loop_ended.connect(func(_escaped: bool) -> void: _panel.visible = false)
	DialogueSystem.dialogue_finished.connect(func(_id: String) -> void: _refresh())
	DialogueSystem.dialogue_started.connect(func(_id: String) -> void: _panel.visible = false)


func _unhandled_input(event: InputEvent) -> void:
	if not AnomalyDirector.loop.active or DialogueSystem.is_active():
		return
	if event.is_action_pressed(&"hint"):
		AnomalyDirector.show_hint()
		get_viewport().set_input_as_handled()


func _refresh() -> void:
	var loop: StairLoopState = AnomalyDirector.loop
	_panel.visible = loop.active and not DialogueSystem.is_active()
	if not _panel.visible:
		return
	for child: Node in _body.get_children():
		_body.remove_child(child)
		child.queue_free()
	var title: String = "Chiếu nghỉ tầng 4" + (" — bản gốc" if loop.landing_index == 0 else " (lần %d)" % (loop.landing_index + 1))
	_body.add_child(_label(title, 22, ACCENT))
	for line: String in AnomalyDirector.landing_lines():
		_body.add_child(_label("• " + line, 16, Color.WHITE))
	_body.add_child(_label(AnomalyDirector.catalog.tech_plate, 15, MUTED))
	_body.add_child(_label("Tiếng ù rất trầm. Mở điện thoại (Tab) → Radar để đo.", 14, MUTED))
	var progress: String = "Đúng liên tiếp: %d / %d" % [loop.streak, loop.required_streak]
	_body.add_child(_label(progress, 14, MUTED))
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_body.add_child(row)
	var up: Button = _button("Đi lên ↑")
	up.pressed.connect(_choose.bind("up"))
	row.add_child(up)
	var down: Button = _button("Đi xuống ↓")
	down.pressed.connect(_choose.bind("down"))
	row.add_child(down)
	var think: Button = _button("Suy nghĩ (G)")
	think.pressed.connect(func() -> void: AnomalyDirector.show_hint())
	row.add_child(think)
	if AnomalyDirector.physics_question_available():
		var question: Button = _button("Ghi chú Vật lý")
		question.pressed.connect(func() -> void: AnomalyDirector.ask_physics_question())
		_body.add_child(question)
	if AnomalyDirector.can_call_senior():
		var senior: Button = _button("Gọi tiền bối (Sanity −5)")
		senior.pressed.connect(func() -> void: AnomalyDirector.call_senior())
		_body.add_child(senior)


func _choose(direction: String) -> void:
	AnomalyDirector.stair_choose(direction)
	_refresh()


func _build() -> void:
	_panel = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.set_corner_radius_all(10)
	style.set_content_margin_all(20)
	_panel.add_theme_stylebox_override("panel", style)
	_panel.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	_panel.offset_left = 40
	_panel.offset_right = 760
	_panel.offset_top = -260
	_panel.offset_bottom = 260
	add_child(_panel)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 8)
	_panel.add_child(_body)


static func _label(text: String, size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


static func _button(text: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 17)
	return button
