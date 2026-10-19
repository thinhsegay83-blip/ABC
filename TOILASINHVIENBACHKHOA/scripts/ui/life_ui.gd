extends CanvasLayer
## Giao diện đời sinh viên (bước 4), dựng hoàn toàn bằng code:
## - Menu hành động theo nơi chốn (C1, D1) + quầy bán hàng (D6) + đóng học phí (B3)
## - Thời khóa biểu & bảng điểm tạm tính (B2, C2, C3)
## - Màn tổng kết cuối ngày (B10)
## Đặt SAU PauseMenu trong game.tscn để nhận Esc trước (đóng bảng thay vì tạm dừng).
## Tạm thời mở bằng nút "Hành động" trên HUD; khi có bản đồ (bước 2), gọi open_place(place_id)
## từ Interactable tương ứng (giường → ktx_room, quầy → food_shop…).

const GROUP: StringName = &"life_ui"
const MENU_LAYER: int = 40
const PANEL_WIDTH: float = 560.0
const BG_COLOR: Color = Color(0.07, 0.08, 0.11, 0.95)
const DIM_COLOR: Color = Color(0.0, 0.0, 0.0, 0.45)
const TITLE_COLOR: Color = Color(0.98, 0.83, 0.42, 1.0)
const MUTED_COLOR: Color = Color(0.62, 0.65, 0.72, 1.0)
const WARN_COLOR: Color = Color(1.0, 0.45, 0.38, 1.0)
const GOOD_COLOR: Color = Color(0.45, 0.85, 0.55, 1.0)

var _current_place: String = "ktx_room"
var _dim: ColorRect
var _menu_panel: PanelContainer
var _menu_body: VBoxContainer
var _info_panel: PanelContainer
var _info_body: VBoxContainer
var _summary_panel: PanelContainer
var _summary_body: VBoxContainer
var _pending_summaries: Array[Dictionary] = []


func _ready() -> void:
	layer = MENU_LAYER
	add_to_group(GROUP)
	_build()
	StudentLife.day_summary_ready.connect(_on_day_summary)
	Game.stats_changed.connect(_refresh_if_open)
	Game.time_changed.connect(_refresh_if_open.unbind(2))


func _unhandled_input(event: InputEvent) -> void:
	# Esc đóng bảng đang mở trước khi tới menu tạm dừng.
	if event.is_action_pressed(&"pause") and is_any_open() and not _summary_panel.visible:
		close_all()
		get_viewport().set_input_as_handled()


# --- API công khai --------------------------------------------------------

func open_place(place_id: String) -> void:
	if place_id != EventDirector.current_place:
		EventDirector.enter_area(place_id)
	_current_place = place_id
	_info_panel.visible = false
	_menu_panel.visible = true
	_dim.visible = true
	_refresh_menu()


func toggle_actions() -> void:
	if _menu_panel.visible:
		close_all()
	else:
		open_place(_current_place)


func close_all() -> void:
	_menu_panel.visible = false
	_info_panel.visible = false
	_dim.visible = _summary_panel.visible


func is_any_open() -> bool:
	return _menu_panel.visible or _info_panel.visible or _summary_panel.visible


# --- Dựng khung -----------------------------------------------------------

func _build() -> void:
	_dim = ColorRect.new()
	_dim.color = DIM_COLOR
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_dim.visible = false
	add_child(_dim)

	_menu_panel = _make_panel()
	_menu_body = _menu_panel.get_child(0).get_child(0) as VBoxContainer
	_info_panel = _make_panel()
	_info_body = _info_panel.get_child(0).get_child(0) as VBoxContainer
	_summary_panel = _make_panel()
	_summary_body = _summary_panel.get_child(0).get_child(0) as VBoxContainer


## PanelContainer giữa màn hình, chứa ScrollContainer → VBoxContainer.
func _make_panel() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.set_corner_radius_all(10)
	style.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", style)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.visible = false
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(PANEL_WIDTH - 32, 520)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	var body: VBoxContainer = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 6)
	scroll.add_child(body)
	add_child(panel)
	return panel


# --- Menu hành động -------------------------------------------------------

func _refresh_if_open() -> void:
	if _menu_panel.visible:
		_refresh_menu()


func _refresh_menu() -> void:
	_clear(_menu_body)
	if not StudentLife.has_game():
		return
	var sim: LifeSim = StudentLife.sim
	_menu_body.add_child(_label(LifeCatalog.place_name(_current_place), 22, TITLE_COLOR))

	# Thanh chọn nơi (tạm thời, tới khi có bản đồ ở bước 2).
	var place_bar: HFlowContainer = HFlowContainer.new()
	for place_id: String in LifeCatalog.PLACE_ORDER:
		var place_button: Button = _button(LifeCatalog.place_name(place_id), 13)
		place_button.disabled = place_id == _current_place
		place_button.pressed.connect(open_place.bind(place_id))
		place_bar.add_child(place_button)
	_menu_body.add_child(_label("Đi tới (tạm thời, chưa có bản đồ):", 12, MUTED_COLOR))
	_menu_body.add_child(place_bar)
	_menu_body.add_child(HSeparator.new())

	var people: Array[Dictionary] = EventDirector.npcs_at(_current_place)
	if not people.is_empty():
		_menu_body.add_child(_label("Ở đây có", 17, TITLE_COLOR))
		for person: Dictionary in people:
			_add_npc_row(person)
		_menu_body.add_child(HSeparator.new())

	for entry: Dictionary in sim.get_place_actions(_current_place):
		var action: ActionData = entry["action"]
		if action.category == "study":
			_add_study_rows(entry)
		else:
			_add_action_row(entry, action.display_name, {})

	for shop: ShopData in StudentLife.catalog.shops_at(_current_place):
		_menu_body.add_child(HSeparator.new())
		_menu_body.add_child(_label(shop.display_name, 17, TITLE_COLOR))
		for item_entry: Dictionary in sim.get_shop_items(shop.id):
			_add_item_row(shop.id, item_entry)

	if _current_place == "lecture_hall":
		_menu_body.add_child(HSeparator.new())
		_add_tuition_row()
	if _current_place == "ktx_room":
		_menu_body.add_child(HSeparator.new())
		var info_button: Button = _button("Bàn học: Thời khóa biểu & bảng điểm", 15)
		info_button.pressed.connect(_open_info)
		_menu_body.add_child(info_button)

	_menu_body.add_child(HSeparator.new())
	var close_button: Button = _button("Đóng (Esc)", 15)
	close_button.pressed.connect(close_all)
	_menu_body.add_child(close_button)


func _add_npc_row(person: Dictionary) -> void:
	var npc: NpcData = person["npc"]
	var info: Dictionary = person["info"]
	var display: String = DialogueSystem.display_name_of(npc.character_id)
	var button: Button = _button("Nói chuyện với %s" % display, 16)
	button.pressed.connect(_talk.bind(npc.id))
	_menu_body.add_child(button)
	if info["behavior"] == "face_wall" and not npc.murmurs.is_empty():
		var murmur: String = npc.murmurs[randi() % npc.murmurs.size()]
		_menu_body.add_child(_label("   (đứng quay mặt vào tường, lẩm bẩm: %s)" % murmur, 13, MUTED_COLOR))


func _talk(npc_id: String) -> void:
	close_all()
	if not EventDirector.interact(npc_id):
		Toast.show_message("%s không muốn nói chuyện lúc này." % DialogueSystem.display_name_of(npc_id))


func _add_action_row(entry: Dictionary, title: String, params: Dictionary) -> void:
	var action: ActionData = entry["action"]
	var preview: Dictionary = entry["preview"]
	var button: Button = _button(title, 16)
	button.disabled = not entry["enabled"]
	button.pressed.connect(_do_action.bind(action.id, params))
	_menu_body.add_child(button)
	var detail: String = str(preview["text"])
	if not entry["enabled"]:
		detail = "%s — %s" % [entry["reason"], detail]
	_menu_body.add_child(_label("   " + detail, 13, MUTED_COLOR))
	if preview.get("may_faint", false) and entry["enabled"]:
		_menu_body.add_child(_label("   Có thể ngất!", 13, WARN_COLOR))


## Tự học: một dòng cho mỗi môn (có giáo trình thì ghi chú).
func _add_study_rows(entry: Dictionary) -> void:
	var action: ActionData = entry["action"]
	var sim: LifeSim = StudentLife.sim
	if not entry["enabled"]:
		_add_action_row(entry, action.display_name, {})
		return
	for subject: SubjectData in StudentLife.catalog.subjects:
		var title: String = "%s: %s" % [action.display_name, subject.display_name]
		if sim.has_textbook(subject.id):
			title += " (có giáo trình)"
		_add_action_row(entry, title, {"subject": subject.id})


func _add_item_row(shop_id: String, entry: Dictionary) -> void:
	var item: ItemData = entry["item"]
	var row: HBoxContainer = HBoxContainer.new()
	var text: String = "%s — %s" % [item.display_name, MoneyFormat.format_vnd(item.price)]
	var effects: PackedStringArray = PackedStringArray()
	if item.hunger != 0:
		effects.append("Đói %+d" % item.hunger)
	if item.stamina != 0:
		effects.append("Thể lực %+d" % item.stamina)
	if item.sanity != 0:
		effects.append("Sanity %+d" % item.sanity)
	if not item.effect_id.is_empty():
		effects.append("tạm thời")
	if not item.study_subject.is_empty():
		effects.append("tự học môn này +5 thay vì +3")
	if not effects.is_empty():
		text += "  (" + ", ".join(effects) + ")"
	var label: Label = _label(text, 14, Color.WHITE)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(label)
	var buy: Button = _button("Mua" if entry["enabled"] else str(entry["reason"]), 13)
	buy.disabled = not entry["enabled"]
	buy.pressed.connect(_buy.bind(shop_id, item.id, false))
	row.add_child(buy)
	if item.can_carry and item.consume_on_buy:
		var carry: Button = _button("Mang về", 13)
		carry.disabled = not entry["enabled"]
		carry.pressed.connect(_buy.bind(shop_id, item.id, true))
		row.add_child(carry)
	_menu_body.add_child(row)


func _add_tuition_row() -> void:
	var state: GameState = Game.state
	var config: EconomyConfig = StudentLife.catalog.economy
	_menu_body.add_child(_label("Máy đóng học phí", 17, TITLE_COLOR))
	if Tuition.is_paid(state):
		_menu_body.add_child(_label("Bạn đã đóng học phí HK1.", 14, GOOD_COLOR))
		return
	var due: int = Tuition.amount_due(state, config)
	var money: int = state.stats.get_money()
	_menu_body.add_child(_label("Số phải đóng: %s" % MoneyFormat.format_vnd(due), 14, Color.WHITE))
	_menu_body.add_child(_label("Số dư: %s → sau khi đóng: %s" % [
		MoneyFormat.format_vnd(money), MoneyFormat.format_vnd(money - due)
	], 14, MUTED_COLOR))
	var reason: String = Tuition.can_pay(state, config)
	var pay: Button = _button("Đóng học phí" if reason.is_empty() else reason, 15)
	pay.disabled = not reason.is_empty()
	pay.pressed.connect(_pay_tuition)
	_menu_body.add_child(pay)


func _do_action(action_id: String, params: Dictionary) -> void:
	var result: Dictionary = await _with_fade(
		func() -> Dictionary: return StudentLife.perform_action(action_id, params)
	)
	if result.get("ok", false):
		_refresh_if_open()


func _buy(shop_id: String, item_id: String, carry: bool) -> void:
	StudentLife.buy_item(shop_id, item_id, carry)
	_refresh_menu()


func _pay_tuition() -> void:
	StudentLife.pay_tuition()
	_refresh_menu()


## Màn mờ ngắn khi hành động tốn thời gian.
func _with_fade(work: Callable) -> Dictionary:
	var veil: ColorRect = ColorRect.new()
	veil.color = Color(0, 0, 0, 0)
	veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(veil)
	var tween: Tween = create_tween()
	tween.tween_property(veil, "color:a", 0.85, 0.15)
	await tween.finished
	var result: Dictionary = work.call()
	var tween_out: Tween = create_tween()
	tween_out.tween_property(veil, "color:a", 0.0, 0.15)
	await tween_out.finished
	veil.queue_free()
	return result


# --- Thời khóa biểu & bảng điểm -------------------------------------------

func _open_info() -> void:
	_menu_panel.visible = false
	_info_panel.visible = true
	_dim.visible = true
	_clear(_info_body)
	var sim: LifeSim = StudentLife.sim
	var life: LifeState = Game.state.life
	_info_body.add_child(_label("Thời khóa biểu (lặp lại mỗi tuần)", 20, TITLE_COLOR))
	var grid: GridContainer = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_child(_label("", 14, MUTED_COLOR))
	grid.add_child(_label("Sáng", 14, MUTED_COLOR))
	grid.add_child(_label("Chiều", 14, MUTED_COLOR))
	var today_weekday: int = Game.state.clock.get_weekday()
	for weekday in GameClock.DAYS_PER_WEEK:
		var day_color: Color = TITLE_COLOR if weekday == today_weekday else Color.WHITE
		grid.add_child(_label(GameClock.weekday_display_name(weekday), 14, day_color))
		for slot: int in ScheduleGenerator.CLASS_SLOTS:
			var subject: String = ScheduleGenerator.subject_at(life.schedule, weekday, slot)
			var text: String = "—" if subject.is_empty() else StudentLife.catalog.subject_name(subject)
			grid.add_child(_label(text, 14, day_color))
	_info_body.add_child(grid)
	var next_text: String = sim.next_class_text()
	if not next_text.is_empty():
		_info_body.add_child(_label("Tiết tiếp: " + next_text, 14, MUTED_COLOR))

	_info_body.add_child(HSeparator.new())
	_info_body.add_child(_label("Bảng điểm tạm tính (chưa có thi)", 20, TITLE_COLOR))
	var table: GridContainer = GridContainer.new()
	table.columns = 5
	table.add_theme_constant_override("h_separation", 14)
	for header: String in ["Môn (tín chỉ)", "Có mặt", "Vắng", "Điểm 10", "Điểm 4"]:
		table.add_child(_label(header, 13, MUTED_COLOR))
	for subject: SubjectData in StudentLife.catalog.subjects:
		var rec: Dictionary = AcademicRecord.get_record(life, subject.id)
		var score: float = AcademicRecord.score10(rec)
		table.add_child(_label("%s (%d)" % [subject.display_name, subject.credits], 14, Color.WHITE))
		table.add_child(_label(str(int(rec["attended"])), 14, Color.WHITE))
		var absent: int = int(rec["absent"])
		table.add_child(_label(str(absent), 14, WARN_COLOR if absent > 0 else Color.WHITE))
		table.add_child(_label("—" if score < 0.0 else "%.1f" % score, 14, Color.WHITE))
		table.add_child(_label(
			"—" if score < 0.0 else "%.1f (%s)" % [AcademicRecord.to_scale4(score), AcademicRecord.letter(score)],
			14, Color.WHITE
		))
	_info_body.add_child(table)
	var gpa: float = AcademicRecord.gpa(life, StudentLife.catalog.subjects)
	_info_body.add_child(_label(
		"GPA tạm tính: " + ("chưa có" if gpa < 0.0 else "%.2f / 4" % gpa), 16, TITLE_COLOR
	))
	var back: Button = _button("Quay lại", 15)
	back.pressed.connect(open_place.bind("ktx_room"))
	_info_body.add_child(back)


# --- Tổng kết cuối ngày ---------------------------------------------------

func _on_day_summary(summary: Dictionary) -> void:
	_pending_summaries.append(summary)
	if not _summary_panel.visible:
		_show_next_summary()


func _show_next_summary() -> void:
	if _pending_summaries.is_empty():
		_summary_panel.visible = false
		EventDirector.unblock("summary")
		_dim.visible = _menu_panel.visible or _info_panel.visible
		return
	# Ngủ li bì nhiều ngày: chỉ cần xem tổng kết mới nhất.
	var summary: Dictionary = _pending_summaries.pop_back()
	_pending_summaries.clear()
	_menu_panel.visible = false
	_info_panel.visible = false
	_summary_panel.visible = true
	_dim.visible = true
	EventDirector.block("summary")
	_clear(_summary_body)
	_summary_body.add_child(_label(
		"Tổng kết Ngày %d — %s" % [int(summary["day"]), summary["weekday_name"]], 22, TITLE_COLOR
	))
	_add_money_section("Thu", summary["incomes"], int(summary["income_total"]), GOOD_COLOR)
	_add_money_section("Chi", summary["expenses"], int(summary["expense_total"]), WARN_COLOR)
	_summary_body.add_child(_label("Số dư: %s → %s" % [
		MoneyFormat.format_vnd(int(summary["money_before"])),
		MoneyFormat.format_vnd(int(summary["money_after"])),
	], 16, Color.WHITE))
	_summary_body.add_child(HSeparator.new())
	_summary_body.add_child(_label("Chỉ số", 17, TITLE_COLOR))
	for row: Dictionary in summary["stats"]:
		var delta: int = int(row["delta"])
		var color: Color = GOOD_COLOR if delta > 0 else (WARN_COLOR if delta < 0 else MUTED_COLOR)
		_summary_body.add_child(_label("%s: %d → %d (%+d)" % [
			row["name"], int(row["before"]), int(row["after"]), delta
		], 14, color))
	_summary_body.add_child(HSeparator.new())
	_summary_body.add_child(_label("Học tập", 17, TITLE_COLOR))
	var attended: Array = summary["attended"]
	var missed: Array = summary["missed"]
	_summary_body.add_child(_label(
		"Đã học: " + (", ".join(PackedStringArray(attended)) if not attended.is_empty() else "không có"),
		14, Color.WHITE
	))
	if not missed.is_empty():
		_summary_body.add_child(_label("Đã vắng: " + ", ".join(PackedStringArray(missed)), 14, WARN_COLOR))
	_summary_body.add_child(HSeparator.new())
	_summary_body.add_child(_label("Sắp tới", 17, TITLE_COLOR))
	for line: Variant in summary["upcoming"]:
		_summary_body.add_child(_label("• " + str(line), 14, Color.WHITE))
	var continue_button: Button = _button("Tiếp tục", 16)
	continue_button.pressed.connect(_show_next_summary)
	_summary_body.add_child(continue_button)


func _add_money_section(title: String, rows: Array, total: int, color: Color) -> void:
	_summary_body.add_child(_label("%s: %s" % [title, MoneyFormat.format_vnd(total)], 16, color))
	for row: Variant in rows:
		var entry: Dictionary = row
		_summary_body.add_child(_label("   %s: %s" % [
			entry["label"], MoneyFormat.format_vnd(int(entry["amount"]))
		], 13, MUTED_COLOR))


# --- Tiện ích -------------------------------------------------------------

static func _label(text: String, size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


static func _button(text: String, size: int) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", size)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	return button


static func _clear(node: Node) -> void:
	for child: Node in node.get_children():
		node.remove_child(child)
		child.queue_free()
