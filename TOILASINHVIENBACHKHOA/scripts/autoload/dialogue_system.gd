extends Node
## DialogueSystem (bước 3) — chạy hội thoại .dlg cho ván hiện tại; UI (DialogueBox) nghe signal.
## Autoload: không khai báo class_name. Đăng ký ngay sau Game.

signal dialogue_started(node_id: String)
signal dialogue_finished(node_id: String)
signal dialogue_event(event_name: String, args: PackedStringArray)
signal line_shown(line: Dictionary)  ## {speaker, display_name, name_color, portrait, expression, text, line_key, is_read}
signal choices_shown(choices: Array)  ## [{text, enabled, reason, index}]

const CHARACTERS_DIR: String = "res://data/characters/"
const FLAG_REGISTRY_PATH: String = "res://data/story_flags.tres"
const HISTORY_LIMIT: int = 200

var characters: Dictionary = {}  # id -> CharacterData
var flag_registry: StoryFlagRegistry
var read_log: ReadLog = ReadLog.new()
## Lịch sử phiên chơi: [{name, text}] — 200 câu gần nhất.
var history: Array[Dictionary] = []
## Thời điểm (ms) hội thoại bắt đầu/kết thúc — để UI bỏ qua lần nhấn E mở/đóng hội thoại.
var last_started_msec: int = 0
var last_finished_msec: int = 0

var _library: DialogueLibrary = null
var _runner: DialogueRunner = null
var _commands: Dictionary = {}


func _ready() -> void:
	_load_characters()
	flag_registry = load(FLAG_REGISTRY_PATH) as StoryFlagRegistry
	if flag_registry == null:
		flag_registry = StoryFlagRegistry.new()
	read_log.load_from()
	Game.state_replaced.connect(_on_state_replaced)


# --- API ------------------------------------------------------------------

func start(node_id: String) -> bool:
	if is_active() or not Game.has_active_game():
		return false
	var library: DialogueLibrary = get_library()
	if not library.has_dialogue(node_id):
		push_warning("DialogueSystem: không có node '%s'" % node_id)
		return false
	_runner = DialogueRunner.new(library, Game.state)
	_runner.commands = _commands
	for id: String in characters.keys():
		_runner.npc_names[id] = (characters[id] as CharacterData).display_name
	_runner.line_shown.connect(_on_line)
	_runner.choices_shown.connect(func(choices: Array) -> void: choices_shown.emit(choices))
	_runner.event_emitted.connect(
		func(event_name: String, args: PackedStringArray) -> void: dialogue_event.emit(event_name, args)
	)
	_runner.feedback.connect(func(text: String) -> void: Toast.show_message(text, 2.5))
	_runner.finished.connect(_on_finished)
	last_started_msec = Time.get_ticks_msec()
	dialogue_started.emit(node_id)
	if Game.state.player_name.is_empty():
		Game.state.player_name = PlayerDefaults.name_or_default("")
	return _runner.start(node_id)


func is_active() -> bool:
	return _runner != null and _runner.is_running()


func has_dialogue(node_id: String) -> bool:
	return get_library().has_dialogue(node_id)


func advance() -> void:
	if is_active():
		_runner.advance()


func choose(index: int, text: String = "") -> void:
	if not is_active():
		return
	if not text.is_empty():
		_push_history("", "→ " + text)
	_runner.choose(index)


## handler(args: PackedStringArray, state: GameState) -> void
func register_command(command_name: String, handler: Callable) -> void:
	_commands[command_name] = handler
	_library = null  # parse lại để chấp nhận lệnh mới


func reload_content() -> void:
	_library = null
	var errors: PackedStringArray = get_errors()
	if errors.is_empty():
		Toast.show_message("Đã nạp lại hội thoại (%d node)" % get_library().content.nodes.size())
	else:
		Toast.show_message("Nạp lại hội thoại: %d lỗi — xem Output" % errors.size())
		for error: String in errors:
			push_warning(error)


func get_library() -> DialogueLibrary:
	if _library == null:
		_library = DialogueLibrary.load_dir(DialogueLibrary.DEFAULT_DIR, PackedStringArray(_commands.keys()))
	return _library


func get_errors() -> PackedStringArray:
	return get_library().get_errors()


func command_names() -> PackedStringArray:
	return PackedStringArray(_commands.keys())


func get_character(id: String) -> CharacterData:
	return characters.get(id, null) as CharacterData


func display_name_of(speaker: String) -> String:
	if speaker == "player":
		return PlayerDefaults.name_or_default(Game.state.player_name if Game.state != null else "")
	if speaker == "narrator":
		return ""
	var data: CharacterData = get_character(speaker)
	return data.display_name if data != null else speaker


# --- Nội bộ ---------------------------------------------------------------

func _on_line(entry: Dictionary) -> void:
	var speaker: String = str(entry["speaker"])
	var data: CharacterData = get_character(speaker)
	var line: Dictionary = entry.duplicate()
	line["display_name"] = display_name_of(speaker)
	line["name_color"] = data.name_color if data != null else Color.WHITE
	line["portrait"] = data.get_portrait(str(entry["expression"])) if data != null else null
	line["is_read"] = read_log.is_read(str(entry["line_key"]))
	read_log.mark_read(str(entry["line_key"]))
	_push_history(str(line["display_name"]), str(line["text"]))
	line_shown.emit(line)


func _on_finished(node_id: String) -> void:
	last_finished_msec = Time.get_ticks_msec()
	read_log.save_to()
	for error: String in _runner.errors:
		push_warning("DialogueSystem: %s" % error)
	dialogue_finished.emit(node_id)


func _on_state_replaced() -> void:
	if _runner != null and _runner.is_running():
		_runner.stop()
	history.clear()


func _push_history(speaker_name: String, text: String) -> void:
	history.append({"name": speaker_name, "text": text})
	if history.size() > HISTORY_LIMIT:
		history.remove_at(0)


func _load_characters() -> void:
	for file_name: String in DirAccess.get_files_at(CHARACTERS_DIR):
		var clean: String = file_name.trim_suffix(".remap")
		if not clean.ends_with(".tres"):
			continue
		var data: CharacterData = load(CHARACTERS_DIR + clean) as CharacterData
		if data != null:
			characters[data.id] = data
