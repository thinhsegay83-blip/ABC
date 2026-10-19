extends CanvasLayer
## Điện thoại (I2) + túi đồ (I1). Tab bật/tắt, I mở thẳng Túi đồ, Esc đóng.
## Thời gian không trôi khi mở (không có hành động nào chạy). Dựng bằng code.
## Ô sóng trên thanh trạng thái (_signal_label) để bước 6 làm nhiễu khi có dị tượng.

const GROUP: StringName = &"phone"
const LAYER_INDEX: int = 48
const PHONE_SIZE: Vector2 = Vector2(380, 640)
const BG_COLOR: Color = Color(0.05, 0.06, 0.08, 0.98)
const SCREEN_COLOR: Color = Color(0.11, 0.13, 0.17, 1.0)
const ACCENT: Color = Color(0.98, 0.83, 0.42, 1.0)
const MUTED: Color = Color(0.62, 0.65, 0.72, 1.0)
const WARN: Color = Color(1.0, 0.45, 0.38, 1.0)
const GOOD: Color = Color(0.45, 0.85, 0.55, 1.0)
const APPS: Array = [
	["messages", "Tin nhắn"], ["wallet", "Ví"], ["schedule", "Lịch học"], ["quests", "Nhiệm vụ"],
	["contacts", "Danh bạ"], ["inventory", "Túi đồ"], ["radar", "Radar"],
]

var _frame: PanelContainer
var _status_label: Label
var _signal_label: Label
var _title_label: Label
var _back_button: Button
var _body: VBoxContainer
var _hud_button: Button
var _app: String = ""
var _thread: String = ""


func _ready() -> void:
	layer = LAYER_INDEX
	add_to_group(GROUP)
	_build()
	_frame.visible = false
	EventDirector.messages_changed.connect(_refresh_badge)
	EventDirector.calls_changed.connect(_refresh_badge)
	Game.state_replaced.connect(_refresh_badge)
	Game.stats_changed.connect(_refresh_if_open)
	_refresh_badge()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"phone"):
		toggle()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"inventory") and not DialogueSystem.is_active():
		open("inventory")
		get_viewport().set_input_as_handled()
	elif is_open() and event.is_action_pressed(&"pause"):
		if _app.is_empty():
			close()
		else:
			_go_back()
		get_viewport().set_input_as_handled()


# --- API ------------------------------------------------------------------

func toggle() -> void:
	if is_open():
		close()
	else:
		open()


func open(app: String = "") -> void:
	if not Game.has_active_game() or DialogueSystem.is_active():
		return
	get_tree().call_group(&"life_ui", &"close_all")
	_frame.visible = true
	_show_app(app)


func close() -> void:
	_frame.visible = false
	_app = ""
	_thread = ""
	_refresh_badge()


func is_open() -> bool:
	return _frame.visible


# --- Điều hướng -----------------------------------------------------------

func _show_app(app: String) -> void:
	_app = app
	_thread = ""
	_render()


func _go_back() -> void:
	if not _thread.is_empty():
		_thread = ""
		_render()
	else:
		_show_app("")


func _refresh_if_open() -> void:
	if is_open():
		_render()


func _render() -> void:
	_clear(_body)
	if not Game.has_active_game():
		return
	var clock: GameClock = Game.state.clock
	_status_label.text = "%s · Ngày %d" % [GameClock.slot_display_name(clock.slot), clock.day]
	_back_button.visible = not _app.is_empty()
	match _app:
		"":
			_title_label.text = "Điện thoại"
			_render_home()
		"messages":
			_title_label.text = "Tin nhắn"
			_render_messages()
		"wallet":
			_title_label.text = "Ví"
			_render_wallet()
		"schedule":
			_title_label.text = "Lịch học"
			_render_schedule()
		"quests":
			_title_label.text = "Nhiệm vụ"
			_render_quests()
		"contacts":
			_title_label.text = "Danh bạ"
			_render_contacts()
		"inventory":
			_title_label.text = "Túi đồ"
			_render_inventory()
		"radar":
			_title_label.text = "Radar"
			_body.add_child(_label("Không phát hiện tín hiệu lạ.", 16, MUTED))


func _render_home() -> void:
	var story: StoryState = Game.state.story
	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for app: Array in APPS:
		var text: String = str(app[1])
		if app[0] == "messages" and story.unread_count() > 0:
			text += " (%d)" % story.unread_count()
		if app[0] == "contacts" and not story.pending_calls.is_empty():
			text += " • cuộc gọi"
		var button: Button = _button(text, 16)
		button.custom_minimum_size = Vector2(160, 64)
		button.pressed.connect(_show_app.bind(str(app[0])))
		grid.add_child(button)
	_body.add_child(grid)


# --- Ứng dụng -------------------------------------------------------------

func _render_messages() -> void:
	var story: StoryState = Game.state.story
	if _thread.is_empty():
		var senders: Array[String] = []
		for message: Dictionary in story.messages:
			if not senders.has(str(message["sender"])):
				senders.append(str(message["sender"]))
		if senders.is_empty():
			_body.add_child(_label("Chưa có tin nhắn.", 15, MUTED))
		senders.reverse()
		for sender: String in senders:
			var unread: int = story.unread_count(sender)
			var text: String = EventDirector.contact_name(sender)
			if unread > 0:
				text += "  (%d mới)" % unread
			var button: Button = _button(text, 16)
			button.pressed.connect(func() -> void:
				_thread = sender
				_render()
			)
			_body.add_child(button)
		return
	story.mark_read(_thread)
	_refresh_badge()
	_body.add_child(_label(EventDirector.contact_name(_thread), 18, ACCENT))
	for message: Dictionary in story.messages:
		if message["sender"] != _thread:
			continue
		_body.add_child(_label("Ngày %d · %s" % [int(message["day"]), GameClock.slot_display_name(int(message["slot"]))], 12, MUTED))
		_body.add_child(_label(str(message["text"]), 15, Color.WHITE))


func _render_wallet() -> void:
	var state: GameState = Game.state
	var sim: LifeSim = StudentLife.sim
	var config: EconomyConfig = StudentLife.catalog.economy
	var money: int = state.stats.get_money()
	_body.add_child(_label("Số dư: " + MoneyFormat.format_vnd(money), 20, WARN if money < 0 else ACCENT))
	var income: int = 0
	var expense: int = 0
	for entry: Dictionary in state.life.ledger_today:
		if entry["kind"] == "income":
			income += int(entry["amount"])
		else:
			expense += int(entry["amount"])
	_body.add_child(_label("Hôm nay: thu %s · chi %s" % [
		MoneyFormat.format_vnd(income), MoneyFormat.format_vnd(expense)
	], 14, MUTED))
	for entry: Dictionary in state.life.ledger_today:
		var sign: String = "+" if entry["kind"] == "income" else "−"
		_body.add_child(_label("   %s: %s%s" % [entry["label"], sign, MoneyFormat.format_vnd(int(entry["amount"]))], 13, MUTED))
	_body.add_child(HSeparator.new())
	_body.add_child(_label("Khoản sắp tới", 16, ACCENT))
	for entry: Dictionary in sim.charges.entries:
		var flag: String = str(entry.get("condition_flag", ""))
		if not flag.is_empty() and state.flags.get_flag(flag) != 1:
			continue
		_body.add_child(_label("• %s: ngày %d — %s" % [
			entry["label"], sim.charges.next_due_day(entry, state.clock.day + 1),
			MoneyFormat.format_vnd(int(entry["amount"]))
		], 14, Color.WHITE))
	if state.flags.get_flag(RoomFund.JOIN_FLAG) == 1:
		_body.add_child(_label("Quỹ phòng: " + MoneyFormat.format_vnd(state.flags.get_flag(RoomFund.BALANCE_FLAG)), 14, GOOD))
	_body.add_child(HSeparator.new())
	_body.add_child(_label("Học phí HK1", 16, ACCENT))
	if Tuition.is_paid(state):
		_body.add_child(_label("Đã đóng.", 14, GOOD))
		return
	_body.add_child(_label(sim.tuition_text(), 14, Color.WHITE))
	var reason: String = Tuition.can_pay(state, config)
	var pay: Button = _button("Đóng học phí" if reason.is_empty() else reason, 15)
	pay.disabled = not reason.is_empty()
	pay.pressed.connect(func() -> void:
		StudentLife.pay_tuition()
		_render()
	)
	_body.add_child(pay)


func _render_schedule() -> void:
	var life: LifeState = Game.state.life
	var catalog: LifeCatalog = StudentLife.catalog
	for weekday in 5:
		var parts: PackedStringArray = PackedStringArray()
		for slot: int in ScheduleGenerator.CLASS_SLOTS:
			var subject: String = ScheduleGenerator.subject_at(life.schedule, weekday, slot)
			if not subject.is_empty():
				parts.append("%s: %s" % [GameClock.slot_display_name(slot), catalog.subject_name(subject)])
		var color: Color = ACCENT if weekday == Game.state.clock.get_weekday() else Color.WHITE
		_body.add_child(_label("%s — %s" % [
			GameClock.weekday_display_name(weekday), ", ".join(parts) if not parts.is_empty() else "trống"
		], 14, color))
	_body.add_child(_label("Thứ Bảy, Chủ Nhật — trống", 14, MUTED))
	var next_text: String = StudentLife.sim.next_class_text()
	if not next_text.is_empty():
		_body.add_child(_label("Tiết tiếp: " + next_text, 14, MUTED))
	_body.add_child(HSeparator.new())
	_body.add_child(_label("Điểm tạm tính", 16, ACCENT))
	for subject: SubjectData in catalog.subjects:
		var rec: Dictionary = AcademicRecord.get_record(life, subject.id)
		var score: float = AcademicRecord.score10(rec)
		var score_text: String = "—" if score < 0.0 else "%.1f (%s)" % [score, AcademicRecord.letter(score)]
		_body.add_child(_label("%s: %s · vắng %d" % [subject.display_name, score_text, int(rec["absent"])], 14,
				WARN if int(rec["absent"]) > 0 else Color.WHITE))
	var gpa: float = AcademicRecord.gpa(life, catalog.subjects)
	_body.add_child(_label("GPA tạm tính: " + ("chưa có" if gpa < 0.0 else "%.2f / 4" % gpa), 15, ACCENT))


func _render_quests() -> void:
	var state: GameState = Game.state
	var story: StoryState = state.story
	var any_active: bool = false
	for quest: QuestData in EventDirector.quests:
		if story.quest_state(quest.id) != QuestLog.ACTIVE:
			continue
		any_active = true
		var title: String = quest.title + (" (tùy chọn)" if quest.optional else "")
		_body.add_child(_label(title, 16, ACCENT))
		var step_text: String = QuestLog.current_step_text(story, quest)
		if not step_text.is_empty():
			_body.add_child(_label("→ " + step_text, 14, Color.WHITE))
		var left: int = QuestLog.days_left(quest, state)
		if left >= 0:
			_body.add_child(_label("Còn %d ngày" % left, 13, WARN if left <= 2 else MUTED))
		elif QuestLog.deadline(quest, state) > 0:
			_body.add_child(_label("Đã quá hạn", 13, WARN))
	if not any_active:
		_body.add_child(_label("Không có nhiệm vụ đang làm.", 15, MUTED))
	var done: PackedStringArray = PackedStringArray()
	for quest: QuestData in EventDirector.quests:
		if story.quest_state(quest.id) == QuestLog.DONE:
			done.append(quest.title)
	if not done.is_empty():
		_body.add_child(HSeparator.new())
		_body.add_child(_label("Đã xong: " + ", ".join(done), 13, GOOD))


func _render_contacts() -> void:
	var state: GameState = Game.state
	var story: StoryState = state.story
	var ids: Array[String] = []
	for contact_id: String in story.pending_calls:
		ids.append(contact_id)
	for message: Dictionary in story.messages:
		if not ids.has(str(message["sender"])):
			ids.append(str(message["sender"]))
	for npc_id: String in story.known_npcs:
		if not ids.has(npc_id):
			ids.append(npc_id)
	if ids.is_empty():
		_body.add_child(_label("Danh bạ trống. Hãy làm quen với mọi người.", 15, MUTED))
	for contact_id: String in ids:
		var row: HBoxContainer = HBoxContainer.new()
		var info: VBoxContainer = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_child(_label(EventDirector.contact_name(contact_id), 16, Color.WHITE))
		if story.known_npcs.has(contact_id):
			var value: int = state.stats.get_relationship(contact_id)
			info.add_child(_label("%s · %d" % [StoryVars.relation_band(value), value], 13, MUTED))
		if contact_id == "k":
			info.add_child(_label(StoryVars.k_contact_note(state.flags.get_flag(StoryVars.K_FLAG)), 13, MUTED))
		row.add_child(info)
		var ringing: bool = story.pending_calls.has(contact_id)
		if ringing or EventDirector.has_call_event(contact_id):
			var call: Button = _button("Nghe" if ringing else "Gọi", 14)
			call.pressed.connect(func() -> void:
				close()
				EventDirector.phone_call(contact_id)
			)
			row.add_child(call)
		_body.add_child(row)


func _render_inventory() -> void:
	var state: GameState = Game.state
	var catalog: LifeCatalog = StudentLife.catalog
	var items: Dictionary = state.life.inventory.to_dict()
	if items.is_empty():
		_body.add_child(_label("Túi đồ trống.", 15, MUTED))
		return
	for item_id: Variant in items.keys():
		var item: ItemData = catalog.get_item(str(item_id))
		var name: String = item.display_name if item != null else str(item_id)
		var row: HBoxContainer = HBoxContainer.new()
		var label: Label = _label("%s ×%d" % [name, int(items[item_id])], 15, Color.WHITE)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		if item != null and LifeSim.can_use_item(item):
			var use: Button = _button("Dùng", 14)
			use.pressed.connect(func() -> void:
				StudentLife.use_item(item.id)
				_render()
			)
			row.add_child(use)
		_body.add_child(row)
		if item != null and not item.description.is_empty():
			_body.add_child(_label(item.description, 13, MUTED))


# --- Dựng giao diện -------------------------------------------------------

func _build() -> void:
	_frame = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.set_corner_radius_all(28)
	style.set_content_margin_all(14)
	style.border_color = Color(0.3, 0.32, 0.38)
	style.set_border_width_all(3)
	_frame.add_theme_stylebox_override("panel", style)
	_frame.anchor_left = 1.0
	_frame.anchor_right = 1.0
	_frame.anchor_top = 0.5
	_frame.anchor_bottom = 0.5
	_frame.offset_left = -PHONE_SIZE.x - 40
	_frame.offset_right = -40
	_frame.offset_top = -PHONE_SIZE.y / 2
	_frame.offset_bottom = PHONE_SIZE.y / 2
	add_child(_frame)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	_frame.add_child(column)
	var status: HBoxContainer = HBoxContainer.new()
	column.add_child(status)
	_status_label = _label("", 13, MUTED)
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.add_child(_status_label)
	_signal_label = _label("▂▄▆ 4G  ▮▮▮", 13, MUTED)
	status.add_child(_signal_label)
	var header: HBoxContainer = HBoxContainer.new()
	column.add_child(header)
	_back_button = _button("‹ Quay lại", 14)
	_back_button.pressed.connect(_go_back)
	header.add_child(_back_button)
	_title_label = _label("Điện thoại", 20, ACCENT)
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_child(_title_label)
	var screen: PanelContainer = PanelContainer.new()
	var screen_style: StyleBoxFlat = StyleBoxFlat.new()
	screen_style.bg_color = SCREEN_COLOR
	screen_style.set_corner_radius_all(10)
	screen_style.set_content_margin_all(10)
	screen.add_theme_stylebox_override("panel", screen_style)
	screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(screen)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	screen.add_child(scroll)
	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 6)
	scroll.add_child(_body)
	var close_button: Button = _button("Đóng (Tab / Esc)", 14)
	close_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	close_button.pressed.connect(close)
	column.add_child(close_button)

	_hud_button = _button("Điện thoại (Tab)", 14)
	_hud_button.anchor_left = 1.0
	_hud_button.anchor_right = 1.0
	_hud_button.anchor_top = 1.0
	_hud_button.anchor_bottom = 1.0
	_hud_button.offset_left = -200
	_hud_button.offset_right = -16
	_hud_button.offset_top = -52
	_hud_button.offset_bottom = -16
	_hud_button.pressed.connect(toggle)
	add_child(_hud_button)


func _refresh_badge() -> void:
	if _hud_button == null:
		return
	_hud_button.visible = Game.has_active_game()
	if not Game.has_active_game():
		return
	var story: StoryState = Game.state.story
	var text: String = "Điện thoại (Tab)"
	if not story.pending_calls.is_empty():
		text += " • Cuộc gọi!"
	elif story.unread_count() > 0:
		text += " • %d tin mới" % story.unread_count()
	_hud_button.text = text
	_hud_button.add_theme_color_override("font_color", ACCENT if text.contains("•") else Color.WHITE)


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
	return button


static func _clear(node: Node) -> void:
	for child: Node in node.get_children():
		node.remove_child(child)
		child.queue_free()
