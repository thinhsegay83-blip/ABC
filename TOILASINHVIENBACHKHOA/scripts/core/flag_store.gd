class_name FlagStore
extends RefCounted
## Cờ cốt truyện (H1): khóa String → giá trị int. Bước 3 dùng để ghi nhớ lựa chọn.

signal flag_changed(key: String, value: int)

var _flags: Dictionary = {}  # String -> int


func get_flag(key: String, default_value: int = 0) -> int:
	if not _flags.has(key):
		return default_value
	return int(_flags[key])


## Chỉ emit flag_changed khi cờ mới hoặc giá trị thay đổi.
func set_flag(key: String, value: int) -> void:
	if _flags.has(key) and int(_flags[key]) == value:
		return
	_flags[key] = value
	flag_changed.emit(key, value)


func has_flag(key: String) -> bool:
	return _flags.has(key)


func clear() -> void:
	_flags.clear()


func to_dict() -> Dictionary:
	return _flags.duplicate()


## Nạp từ save. Không emit flag_changed để tránh kích hoạt lại sự kiện cốt truyện khi tải.
func from_dict(data: Dictionary) -> void:
	_flags.clear()
	for key: Variant in data.keys():
		var flag_key: String = str(key)
		var value: Variant = data[key]
		if _is_number_like(value):
			_flags[flag_key] = _to_int(value)  # JSON trả float → ép int
		else:
			push_warning("FlagStore: bỏ qua cờ '%s' vì giá trị không phải số" % flag_key)


## true nếu value là số, bool, hoặc chuỗi biểu diễn số.
static func _is_number_like(value: Variant) -> bool:
	match typeof(value):
		TYPE_INT, TYPE_FLOAT, TYPE_BOOL:
			return true
		TYPE_STRING, TYPE_STRING_NAME:
			var text: String = str(value)
			return text.is_valid_int() or text.is_valid_float()
	return false


## Gọi sau _is_number_like(value) == true.
static func _to_int(value: Variant) -> int:
	match typeof(value):
		TYPE_STRING, TYPE_STRING_NAME:
			var text: String = str(value)
			if text.is_valid_int():
				return text.to_int()
			return int(text.to_float())
	return int(value)
