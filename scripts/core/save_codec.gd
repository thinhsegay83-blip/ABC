class_name SaveCodec
extends RefCounted
## Mã hóa / giải mã save (J2). Chỉ hàm static, không đụng tới file — việc đọc/ghi do SaveSystem làm.
## Dạng save: {"version": int, "saved_at": float (unix), "state": GameState.to_dict()}

const SAVE_VERSION: int = 1


static func encode(state: GameState, saved_at_unix: float) -> Dictionary:
	if state == null:
		push_error("SaveCodec.encode: state là null")
		return {}
	return {
		"version": SAVE_VERSION,
		"saved_at": saved_at_unix,
		"state": state.to_dict(),
	}


## Trả null nếu thiếu "state"/"version", sai kiểu, hoặc save của bản mới hơn.
static func decode(data: Dictionary) -> GameState:
	if not data.has("state") or not data.has("version"):
		return null
	var version_value: Variant = data["version"]
	if typeof(version_value) != TYPE_INT and typeof(version_value) != TYPE_FLOAT:
		return null
	var version: int = int(version_value)  # JSON trả float
	if version > SAVE_VERSION:
		push_warning("SaveCodec: save phiên bản %d mới hơn bản game (%d)" % [version, SAVE_VERSION])
		return null
	var state_value: Variant = data["state"]
	if not (state_value is Dictionary):
		return null
	var state_data: Dictionary = state_value
	if version < SAVE_VERSION:
		state_data = _migrate(state_data, version)
	var state: GameState = GameState.new()
	state.from_dict(state_data)
	return state


static func to_json(state: GameState, saved_at_unix: float) -> String:
	return JSON.stringify(encode(state, saved_at_unix), "\t")


## Trả null nếu chuỗi không phải JSON hợp lệ hoặc không phải save hợp lệ.
static func from_json(text: String) -> GameState:
	var json: JSON = JSON.new()
	if json.parse(text) != OK:
		push_warning(
			"SaveCodec: JSON lỗi ở dòng %d: %s" % [json.get_error_line(), json.get_error_message()]
		)
		return null
	var parsed: Variant = json.data
	if not (parsed is Dictionary):
		return null
	return decode(parsed)


## Nâng cấp dữ liệu save cũ lên SAVE_VERSION, từng bước một phiên bản.
## Khi tăng SAVE_VERSION: thêm nhánh `match` cho phiên bản cũ tương ứng.
static func _migrate(state_data: Dictionary, from_version: int) -> Dictionary:
	var migrated: Dictionary = state_data.duplicate(true)
	var version: int = maxi(from_version, 0)
	while version < SAVE_VERSION:
		match version:
			_:
				# Hiện chưa có thay đổi định dạng nào giữa các phiên bản → giữ nguyên.
				pass
		version += 1
	return migrated
