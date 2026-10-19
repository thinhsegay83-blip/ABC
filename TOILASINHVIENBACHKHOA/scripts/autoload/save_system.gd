extends Node
## SaveSystem (J2) — lưu/tải JSON trong user://saves/: 1 ô tự lưu (0) + 3 ô thủ công (1–3).
## Dùng được khi chỉ new() mà không thêm vào scene tree (để test).
## Autoload: không khai báo class_name.

const SAVE_DIR: String = "user://saves/"
const AUTO_SLOT: int = 0
const MANUAL_SLOT_COUNT: int = 3  # ô 1, 2, 3
const AUTOSAVE_FILE: String = "autosave.json"
const SLOT_FILE_FORMAT: String = "slot_%d.json"
const TEMP_SUFFIX: String = ".tmp"
## Quy ước tên file chế độ chơi (khớp Game.DIFFICULTY_PATHS) — dùng để lấy tên hiển thị.
const DIFFICULTY_PATH_FORMAT: String = "res://data/difficulty_%s.tres"

## Test có thể đổi sang thư mục khác, vd. "user://test_saves/".
var save_dir: String = SAVE_DIR

var _difficulty_names: Dictionary = {}  # id (String) -> display_name (String)


## Đường dẫn đầy đủ của ô: 0 → <save_dir>/autosave.json, n → <save_dir>/slot_n.json.
func get_slot_path(slot: int) -> String:
	if slot == AUTO_SLOT:
		return save_dir.path_join(AUTOSAVE_FILE)
	return save_dir.path_join(SLOT_FILE_FORMAT % slot)


## Ghi file tạm rồi đổi tên để không làm hỏng save cũ nếu ghi dở. Tạo thư mục nếu chưa có.
func save_to_slot(slot: int, state: GameState) -> bool:
	if state == null:
		push_warning("SaveSystem: không có GameState để lưu")
		return false
	if not _is_valid_slot(slot):
		push_warning("SaveSystem: ô lưu không hợp lệ: %d" % slot)
		return false
	if not _ensure_save_dir():
		return false
	var text: String = SaveCodec.to_json(state, Time.get_unix_time_from_system())
	if text.is_empty():
		return false
	return _write_atomic(get_slot_path(slot), text)


## Trả null nếu ô không có save hoặc save hỏng.
func load_from_slot(slot: int) -> GameState:
	if not has_save(slot):
		return null
	var data: Dictionary = _read_slot_data(slot)
	if data.is_empty():
		return null
	return SaveCodec.decode(data)


func autosave(state: GameState) -> bool:
	return save_to_slot(AUTO_SLOT, state)


func has_save(slot: int) -> bool:
	return _is_valid_slot(slot) and FileAccess.file_exists(get_slot_path(slot))


## Thông tin hiển thị cho danh sách ô lưu. "exists" = false nếu ô trống hoặc save hỏng.
func get_slot_info(slot: int) -> Dictionary:
	var info: Dictionary = {
		"exists": false,
		"slot": slot,
		"day": 0,
		"week": 0,
		"slot_name": "",
		"difficulty_name": "",
		"money": 0,
		"saved_at": 0.0,
		"saved_at_text": "",
	}
	if not has_save(slot):
		return info
	var data: Dictionary = _read_slot_data(slot)
	if data.is_empty():
		return info
	var state: GameState = SaveCodec.decode(data)
	if state == null:
		return info

	var saved_at: float = _to_float(data.get("saved_at", 0.0))
	info["exists"] = true
	info["day"] = state.clock.day
	info["week"] = state.clock.get_week()
	info["slot_name"] = GameClock.slot_display_name(state.clock.slot)
	info["difficulty_name"] = _difficulty_display_name(state.difficulty_id)
	info["money"] = state.stats.get_money()
	info["saved_at"] = saved_at
	info["saved_at_text"] = _format_timestamp(saved_at)
	return info


## Ô có saved_at mới nhất (kể cả ô tự lưu); -1 nếu không có save hợp lệ nào.
func get_latest_slot() -> int:
	var best_slot: int = -1
	var best_time: float = 0.0
	for slot: int in range(AUTO_SLOT, MANUAL_SLOT_COUNT + 1):
		var info: Dictionary = get_slot_info(slot)
		if not bool(info["exists"]):
			continue
		var saved_at: float = float(info["saved_at"])
		if best_slot == -1 or saved_at > best_time:
			best_slot = slot
			best_time = saved_at
	return best_slot


# --- Nội bộ ---------------------------------------------------------------

## Ghi ra file tạm rồi đổi tên → save cũ không bị hỏng nếu ghi dở giữa chừng.
func _write_atomic(path: String, text: String) -> bool:
	var temp_path: String = path + TEMP_SUFFIX
	var file: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_warning(
			"SaveSystem: không mở được %s (%s)" % [temp_path, error_string(FileAccess.get_open_error())]
		)
		return false
	file.store_string(text)
	var write_err: Error = file.get_error()
	file.close()
	if write_err != OK:
		push_warning("SaveSystem: ghi %s lỗi (%s)" % [temp_path, error_string(write_err)])
		DirAccess.remove_absolute(temp_path)
		return false

	var err: Error = DirAccess.rename_absolute(temp_path, path)
	if err != OK and FileAccess.file_exists(path):
		# Một số nền tảng không cho đổi tên đè file có sẵn → xóa file cũ rồi thử lại.
		DirAccess.remove_absolute(path)
		err = DirAccess.rename_absolute(temp_path, path)
	if err != OK:
		push_warning("SaveSystem: không đổi tên %s → %s (%s)" % [temp_path, path, error_string(err)])
		DirAccess.remove_absolute(temp_path)
		return false
	return true


func _is_valid_slot(slot: int) -> bool:
	return slot >= AUTO_SLOT and slot <= MANUAL_SLOT_COUNT


func _ensure_save_dir() -> bool:
	if DirAccess.dir_exists_absolute(save_dir):
		return true
	var err: Error = DirAccess.make_dir_recursive_absolute(save_dir)
	if err != OK and err != ERR_ALREADY_EXISTS:
		push_warning("SaveSystem: không tạo được thư mục %s (%s)" % [save_dir, error_string(err)])
		return false
	return true


## Đọc và parse JSON của ô; trả {} nếu không đọc được hoặc không phải Dictionary.
func _read_slot_data(slot: int) -> Dictionary:
	var path: String = get_slot_path(slot)
	if not FileAccess.file_exists(path):
		return {}
	var text: String = FileAccess.get_file_as_string(path)
	if text.is_empty():
		return {}
	var json: JSON = JSON.new()
	if json.parse(text) != OK:
		push_warning("SaveSystem: save hỏng ở %s (dòng %d: %s)" % [
			path, json.get_error_line(), json.get_error_message()
		])
		return {}
	var parsed: Variant = json.data
	if parsed is Dictionary:
		return parsed as Dictionary
	return {}


## Lấy tên hiển thị của chế độ từ file .tres (J13); không có file thì trả lại id.
func _difficulty_display_name(difficulty_id: String) -> String:
	if _difficulty_names.has(difficulty_id):
		return str(_difficulty_names[difficulty_id])
	var display_name: String = difficulty_id
	var path: String = DIFFICULTY_PATH_FORMAT % difficulty_id
	if not difficulty_id.is_empty() and ResourceLoader.exists(path):
		var config: DifficultyConfig = load(path) as DifficultyConfig
		if config != null and not config.display_name.is_empty():
			display_name = config.display_name
	_difficulty_names[difficulty_id] = display_name
	return display_name


## "18/10/2026 21:30" theo giờ máy.
static func _format_timestamp(unix_time: float) -> String:
	if unix_time <= 0.0:
		return ""
	var tz: Dictionary = Time.get_time_zone_from_system()
	var bias_minutes: int = int(tz.get("bias", 0))
	var local_unix: int = int(unix_time) + bias_minutes * 60
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(local_unix)
	return "%02d/%02d/%04d %02d:%02d" % [
		int(dt.get("day", 1)),
		int(dt.get("month", 1)),
		int(dt.get("year", 1970)),
		int(dt.get("hour", 0)),
		int(dt.get("minute", 0)),
	]


static func _to_float(value: Variant) -> float:
	if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
		return float(value)
	return 0.0
