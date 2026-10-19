extends Node
## Game — trung tâm của ván chơi: giữ GameState, chuyển tiếp signal, tự lưu đầu mỗi ngày.
## Autoload: không khai báo class_name.

signal state_replaced  ## Có ván mới hoặc vừa tải game.
signal stats_changed  ## Chuyển tiếp từ state.stats.
signal time_changed(day: int, slot: int)  ## Chuyển tiếp từ state.clock.
signal new_day(day: int)

const DIFFICULTY_PATHS: Array[String] = [
	"res://data/difficulty_easy.tres",
	"res://data/difficulty_hard.tres",
	"res://data/difficulty_extreme.tres",
]
const TIME_DECAY_PATH: String = "res://data/time_decay.tres"
const FONT_REGULAR_PATH: String = "res://fonts/BeVietnamPro-Regular.ttf"
const FONT_BOLD_PATH: String = "res://fonts/BeVietnamPro-Bold.ttf"

var state: GameState = null
var time_decay: TimeDecayConfig

var _difficulties: Array[DifficultyConfig] = []
var _difficulties_loaded: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_time_decay()
	_ensure_input_actions()
	_apply_font()


## Danh sách chế độ chơi theo thứ tự DIFFICULTY_PATHS (bản sao mảng).
func get_difficulties() -> Array[DifficultyConfig]:
	if not _difficulties_loaded:
		_load_difficulties()
	var result: Array[DifficultyConfig] = []
	result.append_array(_difficulties)
	return result


## null nếu không có chế độ với id này.
func get_difficulty(id: String) -> DifficultyConfig:
	for config: DifficultyConfig in get_difficulties():
		if config.id == id:
			return config
	return null


func new_game(difficulty_id: String) -> void:
	var difficulty: DifficultyConfig = get_difficulty(difficulty_id)
	if difficulty == null:
		# GameState tự dùng cấu hình mặc định khi nhận null.
		push_warning("Game: không tìm thấy chế độ '%s'" % difficulty_id)
	var new_state: GameState = GameState.new()
	new_state.setup_new_game(difficulty)
	_bind_state(new_state)
	state_replaced.emit()


func load_game(new_state: GameState) -> void:
	if new_state == null:
		push_warning("Game: load_game nhận GameState null, bỏ qua")
		return
	_bind_state(new_state)
	state_replaced.emit()


## Kết thúc ván (về menu chính). Không phát state_replaced để UI cũ không đọc state null.
func end_game() -> void:
	_bind_state(null)


func has_active_game() -> bool:
	return state != null


## Qua một khung giờ: tụt chỉ số theo chế độ rồi tăng đồng hồ.
func advance_time() -> void:
	if state == null:
		return
	state.advance_time(time_decay)


# --- Nội bộ ---------------------------------------------------------------

## Ngắt signal của state cũ, nối signal của state mới để chuyển tiếp.
func _bind_state(new_state: GameState) -> void:
	if state != null:
		if state.stats.stats_changed.is_connected(_on_stats_changed):
			state.stats.stats_changed.disconnect(_on_stats_changed)
		if state.clock.time_changed.is_connected(_on_time_changed):
			state.clock.time_changed.disconnect(_on_time_changed)
		if state.clock.new_day.is_connected(_on_new_day):
			state.clock.new_day.disconnect(_on_new_day)
	state = new_state
	if state != null:
		state.stats.stats_changed.connect(_on_stats_changed)
		state.clock.time_changed.connect(_on_time_changed)
		state.clock.new_day.connect(_on_new_day)


func _on_stats_changed() -> void:
	stats_changed.emit()


func _on_time_changed(day: int, slot: int) -> void:
	time_changed.emit(day, slot)


## Sang ngày mới → tự lưu (J2) và báo toast (J8).
func _on_new_day(day: int) -> void:
	new_day.emit(day)
	if state == null:
		return  # một listener của new_day có thể đã kết thúc ván
	if SaveSystem.autosave(state):
		Toast.show_message("Đã tự lưu — Ngày %d" % day)
	else:
		Toast.show_message("Tự lưu thất bại!")


func _load_difficulties() -> void:
	_difficulties.clear()
	for path: String in DIFFICULTY_PATHS:
		if not ResourceLoader.exists(path):
			push_warning("Game: thiếu file chế độ chơi %s" % path)
			continue
		var config: DifficultyConfig = load(path) as DifficultyConfig
		if config == null:
			push_warning("Game: %s không phải DifficultyConfig" % path)
			continue
		_difficulties.append(config)
	_difficulties_loaded = true


func _load_time_decay() -> void:
	if ResourceLoader.exists(TIME_DECAY_PATH):
		time_decay = load(TIME_DECAY_PATH) as TimeDecayConfig
	if time_decay == null:
		push_warning("Game: không nạp được %s, dùng giá trị mặc định" % TIME_DECAY_PATH)
		time_decay = TimeDecayConfig.new()


## J6: phòng khi project.godot thiếu action (vd. bị Editor ghi đè) → thêm bằng code.
func _ensure_input_actions() -> void:
	_ensure_key_action(&"pause", KEY_ESCAPE)
	_ensure_key_action(&"debug", KEY_F1)
	_ensure_key_action(&"interact", KEY_E)
	_ensure_key_action(&"dialogue_next", KEY_SPACE)
	_ensure_key_action(&"dialogue_skip", KEY_CTRL)
	_ensure_key_action(&"dialogue_auto", KEY_T)
	_ensure_key_action(&"dialogue_history", KEY_L)
	_ensure_key_action(&"phone", KEY_TAB)
	_ensure_key_action(&"inventory", KEY_I)
	_ensure_key_action(&"hint", KEY_G)


func _ensure_key_action(action: StringName, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	if not InputMap.action_get_events(action).is_empty():
		return
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action, event)


## J7: dùng Be Vietnam Pro làm font mặc định nếu có file; không có thì giữ font của engine.
func _apply_font() -> void:
	var regular: Font = _load_font(FONT_REGULAR_PATH)
	if regular == null:
		print_verbose("Game: chưa có %s, dùng font mặc định (fonts/README.md)" % FONT_REGULAR_PATH)
		return
	ThemeDB.fallback_font = regular
	# Theme mặc định của engine có default_font riêng, được ưu tiên hơn fallback_font
	# → đổi luôn cả nó thì mọi Control mới chắc chắn dùng Be Vietnam Pro.
	var default_theme: Theme = ThemeDB.get_default_theme()
	if default_theme != null:
		default_theme.default_font = regular
		var bold: Font = _load_font(FONT_BOLD_PATH)
		if bold != null:
			default_theme.set_font(&"bold_font", &"RichTextLabel", bold)


static func _load_font(path: String) -> Font:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Font
