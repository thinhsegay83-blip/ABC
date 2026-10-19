class_name PlayerStats
extends RefCounted
## Chỉ số nhân vật (A1–A6): Thể lực, Đói (độ no), Sanity, Trí tuệ, Tiền, Quan hệ.
## Logic thuần, không cần scene tree.

signal stats_changed

enum Stat { STAMINA, HUNGER, SANITY, KNOWLEDGE }

const MIN_VALUE: int = 0
const MAX_VALUE: int = 100

## Khóa trong to_dict(), theo đúng thứ tự enum Stat.
const STAT_KEYS: Array[String] = ["stamina", "hunger", "sanity", "knowledge"]

# HUNGER là "độ no": 100 = no căng, 0 = đói lả.
var _values: Array[int] = [MAX_VALUE, MAX_VALUE, MAX_VALUE, MIN_VALUE]
var _money: int = 0
var _relationships: Dictionary = {}  # npc_id (String) -> int 0–100


# --- A1–A4 ---------------------------------------------------------------

func get_stat(stat: int) -> int:
	if not _is_valid_stat(stat):
		push_error("PlayerStats: chỉ số không hợp lệ: %d" % stat)
		return 0
	return _values[stat]


func set_stat(stat: int, value: int) -> void:
	if not _is_valid_stat(stat):
		push_error("PlayerStats: chỉ số không hợp lệ: %d" % stat)
		return
	var clamped: int = clampi(value, MIN_VALUE, MAX_VALUE)
	if _values[stat] == clamped:
		return
	_values[stat] = clamped
	stats_changed.emit()


func change_stat(stat: int, delta: int) -> void:
	if delta == 0:
		return
	set_stat(stat, get_stat(stat) + delta)


# --- A5 Tiền (cho phép âm) ------------------------------------------------

func get_money() -> int:
	return _money


func set_money(value: int) -> void:
	if _money == value:
		return
	_money = value
	stats_changed.emit()


func change_money(delta: int) -> void:
	if delta == 0:
		return
	set_money(_money + delta)


# --- A6 Quan hệ theo NPC --------------------------------------------------

func get_relationship(npc_id: String) -> int:
	return int(_relationships.get(npc_id, 0))


func set_relationship(npc_id: String, value: int) -> void:
	var clamped: int = clampi(value, MIN_VALUE, MAX_VALUE)
	var old_value: int = get_relationship(npc_id)
	_relationships[npc_id] = clamped
	# NPC mới với giá trị 0 vẫn được ghi nhận, nhưng số không đổi → không emit.
	if old_value != clamped:
		stats_changed.emit()


func change_relationship(npc_id: String, delta: int) -> void:
	set_relationship(npc_id, get_relationship(npc_id) + delta)


func get_relationships() -> Dictionary:
	return _relationships.duplicate()


# --- Lưu / tải ------------------------------------------------------------

func to_dict() -> Dictionary:
	var result: Dictionary = {}
	for i in range(STAT_KEYS.size()):
		result[STAT_KEYS[i]] = _values[i]
	result["money"] = _money
	result["relationships"] = _relationships.duplicate()
	return result


## Nạp từ Dictionary (thường từ JSON → mọi số là float, phải ép int).
## Khóa thiếu thì giữ giá trị hiện tại; thiếu "relationships" thì coi như rỗng.
## Emit stats_changed đúng một lần.
func from_dict(data: Dictionary) -> void:
	for i in range(STAT_KEYS.size()):
		var value: int = _to_int(data.get(STAT_KEYS[i], _values[i]), _values[i])
		_values[i] = clampi(value, MIN_VALUE, MAX_VALUE)
	_money = _to_int(data.get("money", _money), _money)

	_relationships.clear()
	var rel_data: Variant = data.get("relationships", {})
	if rel_data is Dictionary:
		var rel_dict: Dictionary = rel_data
		for key: Variant in rel_dict.keys():
			var npc_id: String = str(key)
			var rel_value: int = _to_int(rel_dict[key], 0)
			_relationships[npc_id] = clampi(rel_value, MIN_VALUE, MAX_VALUE)
	stats_changed.emit()


static func stat_display_name(stat: int) -> String:
	match stat:
		Stat.STAMINA:
			return "Thể lực"
		Stat.HUNGER:
			return "Đói"
		Stat.SANITY:
			return "Sanity"
		Stat.KNOWLEDGE:
			return "Trí tuệ"
	return "?"


# --- Nội bộ ---------------------------------------------------------------

static func _is_valid_stat(stat: int) -> bool:
	return stat >= 0 and stat < STAT_KEYS.size()


## Ép Variant (int/float/bool/chuỗi số) về int; kiểu khác trả fallback.
static func _to_int(value: Variant, fallback: int) -> int:
	match typeof(value):
		TYPE_INT, TYPE_FLOAT, TYPE_BOOL:
			return int(value)
		TYPE_STRING, TYPE_STRING_NAME:
			var text: String = str(value)
			if text.is_valid_int():
				return text.to_int()
			if text.is_valid_float():
				return int(text.to_float())
	return fallback
