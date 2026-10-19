extends CanvasLayer
## Hướng dẫn chơi (J11): mỗi gợi ý hiện MỘT lần (cờ tut_<id>), bảng nhỏ góc dưới phải, tự ẩn ~6 giây.
## Tắt trong Cài đặt ("Hiện hướng dẫn") thì không hiện nhưng cờ vẫn ghi.

const LAYER_INDEX: int = 15
const SHOW_SECONDS: float = 6.0
const DATA_PATH: String = "res://data/tutorial_hints.tres"

var _texts: Dictionary = {}  # id -> text
var _queue: Array[String] = []
var _panel: PanelContainer
var _label: Label
var _timer: float = 0.0


func _ready() -> void:
	layer = LAYER_INDEX
	var data: TutorialHintSet = load(DATA_PATH) as TutorialHintSet
	if data != null:
		for hint: Dictionary in data.hints:
			_texts[str(hint["id"])] = str(hint["text"])
	_build()
	DialogueSystem.dialogue_started.connect(func(_id: String) -> void: trigger("hoi_thoai"))
	DialogueSystem.dialogue_finished.connect(func(_id: String) -> void: trigger("hanh_dong"))
	EventDirector.messages_changed.connect(func() -> void: trigger("dien_thoai"))
	StudentLife.day_summary_ready.connect(func(_s: Dictionary) -> void: trigger("tong_ket"))
	AnomalyDirector.stair_loop_started.connect(func() -> void: trigger("goi_y"))
	Game.time_changed.connect(_on_time_changed)
	Game.stats_changed.connect(_on_stats_changed)


func _process(delta: float) -> void:
	if _panel.visible:
		_timer -= delta
		if _timer <= 0.0:
			_panel.visible = false
	if not _panel.visible and not _queue.is_empty() and not DialogueSystem.is_active():
		_show(_queue.pop_front())


## Gợi ý id (nếu chưa từng hiện). Trả true nếu vừa xếp hàng.
func trigger(id: String) -> bool:
	if not Game.has_active_game() or not _texts.has(id):
		return false
	var flag: String = "tut_" + id
	if Game.state.flags.get_flag(flag) != 0:
		return false
	Game.state.flags.set_flag(flag, 1)
	if Settings.show_tutorial and not _queue.has(id):
		_queue.append(id)
		return true
	return false


func _on_time_changed(day: int, slot: int) -> void:
	if not StudentLife.has_game():
		return
	if not StudentLife.sim.class_now().is_empty():
		trigger("di_hoc")
	if slot == GameClock.Slot.EVENING:
		trigger("ngu")
	if day >= 2:
		trigger("hoc_phi")
	if slot == GameClock.Slot.AFTERNOON:
		trigger("tkb")
	if not Game.state.life.inventory.to_dict().is_empty():
		trigger("tui_do")
	if Game.state.flags.get_flag("lam_them_quan") == 1:
		trigger("lam_them")
	if Game.state.flags.get_flag("radar_lan_dau") == 1:
		trigger("radar")


func _on_stats_changed() -> void:
	if Game.has_active_game() and Game.state.stats.get_stat(PlayerStats.Stat.HUNGER) < 40:
		trigger("an_uong")


func _show(id: String) -> void:
	_label.text = str(_texts.get(id, ""))
	_panel.visible = true
	_timer = SHOW_SECONDS


func _build() -> void:
	_panel = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.18, 0.92)
	style.border_color = Color(0.98, 0.83, 0.42, 0.6)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	_panel.add_theme_stylebox_override("panel", style)
	_panel.anchor_left = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = -440
	_panel.offset_right = -16
	_panel.offset_top = -170
	_panel.offset_bottom = -64
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.visible = false
	add_child(_panel)
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", 15)
	_panel.add_child(_label)
