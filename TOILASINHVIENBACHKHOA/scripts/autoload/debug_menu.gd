extends CanvasLayer
## DebugMenu (J12) — F1 bật/tắt, chỉ có ở bản debug: chỉnh chỉ số, tiền, thời gian, cờ cốt truyện.
## UI dựng hoàn toàn bằng code. Autoload: không khai báo class_name.

const LAYER_INDEX: int = 120
const PANEL_WIDTH: float = 380.0
const SCREEN_MARGIN: float = 8.0
const STAT_STEP: int = 10
const MONEY_STEP: int = 100000
const REFRESH_INTERVAL: float = 0.5
const FLAG_VALUE_MIN: float = -1000.0
const FLAG_VALUE_MAX: float = 1000.0

var _panel: PanelContainer
var _summary_label: Label
var _flag_name_edit: LineEdit
var _flag_value_spin: SpinBox
var _refresh_timer: float = 0.0


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	layer = LAYER_INDEX
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_panel.visible = false
	Game.stats_changed.connect(_refresh_if_visible)
	Game.time_changed.connect(_refresh_if_visible.unbind(2))
	Game.state_replaced.connect(_refresh_if_visible)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug"):
		toggle()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _panel == null or not _panel.visible:
		return
	# Ván đã kết thúc (về menu chính) → tự đóng.
	if not Game.has_active_game():
		close()
		return
	# Tự cập nhật định kỳ để thấy cả thay đổi cờ từ nơi khác.
	_refresh_timer -= delta
	if _refresh_timer <= 0.0:
		_refresh()


func toggle() -> void:
	if _panel.visible:
		close()
	else:
		open()


## Chỉ mở được khi đang có ván chơi.
func open() -> void:
	if not Game.has_active_game():
		Toast.show_message("Menu debug: chưa có ván chơi nào.")
		return
	_panel.visible = true
	_refresh()


func close() -> void:
	_panel.visible = false


# --- Dựng UI --------------------------------------------------------------

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.name = "DebugPanel"
	_panel.anchor_left = 0.0
	_panel.anchor_top = 0.0
	_panel.anchor_right = 0.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = SCREEN_MARGIN
	_panel.offset_top = SCREEN_MARGIN
	_panel.offset_right = SCREEN_MARGIN + PANEL_WIDTH
	_panel.offset_bottom = -SCREEN_MARGIN
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.08, 0.92)
	style.border_color = Color(1.0, 0.75, 0.2, 0.6)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(10.0)
	_panel.add_theme_stylebox_override(&"panel", style)
	add_child(_panel)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_panel.add_child(scroll)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override(&"separation", 6)
	scroll.add_child(box)

	var title: Label = Label.new()
	title.text = "MENU DEBUG (F1)"
	title.add_theme_color_override(&"font_color", Color(1.0, 0.8, 0.3))
	box.add_child(title)

	# A1–A4: mỗi chỉ số một hàng −10 / +10.
	for stat_value: Variant in PlayerStats.Stat.values():
		var stat: int = int(stat_value)
		box.add_child(_make_step_row(
			PlayerStats.stat_display_name(stat),
			"−%d" % STAT_STEP,
			_change_stat.bind(stat, -STAT_STEP),
			"+%d" % STAT_STEP,
			_change_stat.bind(stat, STAT_STEP)
		))

	# A5: tiền.
	var money_text: String = MoneyFormat.format_vnd(MONEY_STEP).trim_suffix(" đ")  # "100.000"
	box.add_child(_make_step_row(
		"Tiền",
		"−" + money_text,
		_change_money.bind(-MONEY_STEP),
		"+" + money_text,
		_change_money.bind(MONEY_STEP)
	))

	box.add_child(HSeparator.new())

	var advance_button: Button = Button.new()
	advance_button.text = "Qua khung giờ"
	advance_button.pressed.connect(_advance_slot)
	box.add_child(advance_button)

	var jump_button: Button = Button.new()
	jump_button.text = "Nhảy 1 ngày (không tụt chỉ số)"
	jump_button.pressed.connect(_jump_one_day)
	box.add_child(jump_button)

	box.add_child(HSeparator.new())

	# Cờ cốt truyện: tên + giá trị + nút đặt.
	var flag_row: HBoxContainer = HBoxContainer.new()
	_flag_name_edit = LineEdit.new()
	_flag_name_edit.placeholder_text = "Tên cờ (vd. da_gop_quy)"
	_flag_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_flag_name_edit.text_submitted.connect(_on_flag_name_submitted)
	flag_row.add_child(_flag_name_edit)
	_flag_value_spin = SpinBox.new()
	_flag_value_spin.min_value = FLAG_VALUE_MIN
	_flag_value_spin.max_value = FLAG_VALUE_MAX
	_flag_value_spin.step = 1.0
	_flag_value_spin.rounded = true
	_flag_value_spin.allow_greater = true
	_flag_value_spin.allow_lesser = true
	_flag_value_spin.value = 1.0
	flag_row.add_child(_flag_value_spin)
	var flag_button: Button = Button.new()
	flag_button.text = "Đặt cờ"
	flag_button.pressed.connect(_set_flag)
	flag_row.add_child(flag_button)
	box.add_child(flag_row)

	box.add_child(HSeparator.new())

	_summary_label = Label.new()
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(_summary_label)


## Một hàng: nhãn + nút giảm + nút tăng.
func _make_step_row(
	label_text: String,
	minus_text: String,
	minus_action: Callable,
	plus_text: String,
	plus_action: Callable
) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	var label: Label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(90.0, 0.0)
	row.add_child(label)
	var minus_button: Button = Button.new()
	minus_button.text = minus_text
	minus_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	minus_button.pressed.connect(minus_action)
	row.add_child(minus_button)
	var plus_button: Button = Button.new()
	plus_button.text = plus_text
	plus_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	plus_button.pressed.connect(plus_action)
	row.add_child(plus_button)
	return row


# --- Hành động ------------------------------------------------------------

func _change_stat(stat: int, delta: int) -> void:
	if not Game.has_active_game():
		return
	Game.state.stats.change_stat(stat, delta)
	_refresh()


func _change_money(delta: int) -> void:
	if not Game.has_active_game():
		return
	Game.state.stats.change_money(delta)
	_refresh()


func _advance_slot() -> void:
	if not Game.has_active_game():
		return
	Game.advance_time()
	_refresh()


## Sang sáng hôm sau mà không tụt chỉ số (chỉ phát time_changed, không tự lưu).
func _jump_one_day() -> void:
	if not Game.has_active_game():
		return
	var clock: GameClock = Game.state.clock
	clock.set_time(clock.day + 1, GameClock.Slot.MORNING)
	_refresh()


func _set_flag() -> void:
	if not Game.has_active_game():
		return
	var key: String = _flag_name_edit.text.strip_edges()
	if key.is_empty():
		Toast.show_message("Nhập tên cờ trước đã.")
		return
	var value: int = int(_flag_value_spin.value)
	Game.state.flags.set_flag(key, value)
	Toast.show_message("Đã đặt cờ %s = %d" % [key, value])
	_refresh()


func _on_flag_name_submitted(_text: String) -> void:
	_set_flag()


# --- Tóm tắt trạng thái ---------------------------------------------------

func _refresh_if_visible() -> void:
	if _panel != null and _panel.visible:
		_refresh()


func _refresh() -> void:
	_refresh_timer = REFRESH_INTERVAL
	if _summary_label == null:
		return
	if not Game.has_active_game():
		_summary_label.text = "Chưa có ván chơi."
		return
	_summary_label.text = _build_summary(Game.state)


func _build_summary(game_state: GameState) -> String:
	var lines: PackedStringArray = PackedStringArray()

	var difficulty_name: String = game_state.difficulty_id
	var difficulty: DifficultyConfig = Game.get_difficulty(game_state.difficulty_id)
	if difficulty != null:
		difficulty_name = difficulty.display_name
	lines.append("Chế độ: %s · tụt ×%.2f · lương ×%.2f" % [
		difficulty_name, game_state.decay_multiplier, game_state.wage_multiplier
	])

	var clock: GameClock = game_state.clock
	lines.append("Ngày %d · Tuần %d · %s · %s" % [
		clock.day,
		clock.get_week(),
		GameClock.weekday_display_name(clock.get_weekday()),
		GameClock.slot_display_name(clock.slot),
	])

	var stats: PlayerStats = game_state.stats
	lines.append("Tiền: %s" % MoneyFormat.format_vnd(stats.get_money()))
	var stat_parts: PackedStringArray = PackedStringArray()
	for stat_value: Variant in PlayerStats.Stat.values():
		var stat: int = int(stat_value)
		stat_parts.append("%s %d" % [PlayerStats.stat_display_name(stat), stats.get_stat(stat)])
	lines.append(" · ".join(stat_parts))

	lines.append("Quan hệ: %s" % _format_dict(stats.get_relationships()))
	lines.append("Cờ: %s" % _format_dict(game_state.flags.to_dict()))
	return "\n".join(lines)


## "a = 1, b = 2" (sắp xếp theo khóa); rỗng thì "(trống)".
static func _format_dict(data: Dictionary) -> String:
	if data.is_empty():
		return "(trống)"
	var keys: Array = data.keys()
	keys.sort()
	var parts: PackedStringArray = PackedStringArray()
	for key: Variant in keys:
		parts.append("%s = %s" % [str(key), str(data[key])])
	return ", ".join(parts)
