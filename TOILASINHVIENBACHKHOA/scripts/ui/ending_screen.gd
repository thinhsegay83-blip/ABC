extends CanvasLayer
## Màn "Còn tiếp…" (bước 7): bắt sự kiện hội thoại "to_be_continued", hiện tổng kết MVP,
## ghi bản lưu kết thúc (ô tự lưu, cờ mvp_hoan_thanh = 1), nút về menu chính (QĐ-7.4 = A).

const GROUP: StringName = &"ending"
const LAYER_INDEX: int = 95
const ACCENT: Color = Color(0.98, 0.83, 0.42, 1.0)
const MUTED: Color = Color(0.7, 0.72, 0.78, 1.0)

var _root: Control
var _body: VBoxContainer
var _pending: bool = false


func _ready() -> void:
	layer = LAYER_INDEX
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group(GROUP)
	_build()
	DialogueSystem.dialogue_event.connect(_on_dialogue_event)
	DialogueSystem.dialogue_finished.connect(func(_id: String) -> void:
		if _pending:
			_pending = false
			show_summary(true)
	)


func _on_dialogue_event(event_name: String, _args: PackedStringArray) -> void:
	if event_name == "to_be_continued":
		_pending = true


## save_ending: ghi bản lưu kết thúc (lần đầu). Tải lại bản lưu đó thì chỉ hiện tổng kết.
func show_summary(save_ending: bool = false) -> void:
	if not Game.has_active_game():
		return
	var state: GameState = Game.state
	if save_ending:
		state.flags.set_flag("mvp_hoan_thanh", 1)
		SaveSystem.save_to_slot(SaveSystem.AUTO_SLOT, state)
	get_tree().call_group(&"life_ui", &"close_all")
	get_tree().call_group(&"phone", &"close")
	for line: Dictionary in build_summary(state):
		_body.add_child(_label(str(line["text"]), int(line.get("size", 16)), line.get("color", Color.WHITE)))
	var back: Button = Button.new()
	back.text = "Về menu chính"
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(_to_main_menu)
	_body.add_child(back)
	_root.visible = true
	_root.modulate.a = 0.0
	create_tween().tween_property(_root, "modulate:a", 1.0, 1.2)


## Dữ liệu tổng kết (thuần, test được): [{text, size?, color?}].
static func build_summary(state: GameState) -> Array[Dictionary]:
	var lines: Array[Dictionary] = []
	lines.append({"text": "Còn tiếp…", "size": 40, "color": ACCENT})
	lines.append({"text": "Đã sống %d ngày ở KTX Khu %s." % [
		state.clock.day, "B" if state.flags.get_flag("ktx_khu") == 2 else "A"
	]})
	lines.append({"text": "Tiền hiện có: " + MoneyFormat.format_vnd(state.stats.get_money())})
	var stat_parts: PackedStringArray = PackedStringArray()
	for stat: int in [PlayerStats.Stat.STAMINA, PlayerStats.Stat.HUNGER, PlayerStats.Stat.SANITY, PlayerStats.Stat.KNOWLEDGE]:
		stat_parts.append("%s %d" % [PlayerStats.stat_display_name(stat), state.stats.get_stat(stat)])
	lines.append({"text": " · ".join(stat_parts), "color": MUTED})
	var subjects: Array[SubjectData] = LifeCatalog.load_default().subjects
	var gpa: float = AcademicRecord.gpa(state.life, subjects)
	lines.append({"text": "GPA tạm tính: " + ("chưa có" if gpa < 0.0 else "%.2f / 4" % gpa)})
	lines.append({"text": tuition_line(state), "color": ACCENT})
	lines.append({"text": "Quan hệ với Minh: " + StoryVars.relation_band(state.stats.get_relationship("minh")), "color": MUTED})
	lines.append({"text": "Anh K.: " + StoryVars.k_contact_note(state.flags.get_flag(StoryVars.K_FLAG)), "color": MUTED})
	for choice: String in choices_recap(state):
		lines.append({"text": "• " + choice})
	lines.append({"text": "Cảm ơn bạn đã chơi thử!", "size": 20, "color": ACCENT})
	lines.append({"text": "Font Be Vietnam Pro — SIL Open Font License 1.1.", "size": 12, "color": MUTED})
	return lines


static func tuition_line(state: GameState) -> String:
	if Tuition.is_paid(state):
		if Tuition.is_late(state):
			return "Học phí: đã đóng trong thời gian gia hạn."
		return "Học phí: đã đóng đúng hạn."
	return "Học phí: CHƯA ĐÓNG. Ở bản đầy đủ, quá hạn gia hạn (hết tuần 4) sẽ dẫn tới kết thúc \"Nghỉ học\"."


static func choices_recap(state: GameState) -> Array[String]:
	var result: Array[String] = []
	var flags: FlagStore = state.flags
	result.append("Góp quỹ phòng: " + ("có" if flags.get_flag("da_gop_quy") == 1 else "không"))
	match flags.get_flag("nhan_viec_to_roi"):
		1:
			result.append("Việc phát tờ rơi cho K.: vẫn đang làm")
		2:
			result.append("Việc phát tờ rơi cho K.: đã nghỉ")
		_:
			result.append("Việc phát tờ rơi cho K.: không nhận")
	result.append("Cảnh báo Minh: " + ("có" if flags.get_flag("canh_bao_minh") == 1 else "không"))
	result.append("Giải vòng lặp bằng Vật lý: " + ("có" if flags.get_flag("hieu_vong_lap") == 1 else "chưa"))
	return result


func _to_main_menu() -> void:
	_root.visible = false
	Game.end_game()
	SceneLoader.change_scene(SceneLoader.MAIN_MENU_SCENE)


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.visible = false
	add_child(_root)
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.04, 0.97)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(bg)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)
	_body = VBoxContainer.new()
	_body.custom_minimum_size = Vector2(720, 0)
	_body.add_theme_constant_override("separation", 8)
	center.add_child(_body)


static func _label(text: String, size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label
