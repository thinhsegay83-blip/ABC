class_name DialogueCondition
extends RefCounted
## Điều kiện dùng chung cho hội thoại, hành động, sự kiện, nhiệm vụ.
## Cú pháp: các phép so sánh "<biến> <op> <giá trị>" nối bằng and / or (and ưu tiên hơn or, không ngoặc).
## op: == != >= <= > <. Giá trị: số nguyên hoặc hằng khung giờ SANG CHIEU TOI DEM.
## Biến có sẵn: flag.<cờ>, stat.stamina|hunger|sanity|knowledge, money, rel.<npc>, day, week,
## weekday (0 = Thứ Hai), slot (0–3). Bước sau đăng ký thêm biến qua register_variable().

const SLOT_CONSTANTS: Dictionary = {"SANG": 0, "CHIEU": 1, "TOI": 2, "DEM": 3}
const STAT_NAMES: Dictionary = {
	"stamina": PlayerStats.Stat.STAMINA,
	"hunger": PlayerStats.Stat.HUNGER,
	"sanity": PlayerStats.Stat.SANITY,
	"knowledge": PlayerStats.Stat.KNOWLEDGE,
}
const PLAIN_VARIABLES: Array[String] = ["money", "day", "week", "weekday", "slot"]

## Biến mở rộng: tên đầy đủ (vd. "class_now") hoặc tiền tố có dấu chấm (vd. "item.")
## → Callable(name: String, state: GameState) -> int.
static var _extra_variables: Dictionary = {}

static var _comparison_regex: RegEx = RegEx.create_from_string(
	"^\\s*([a-z_][a-z0-9_]*(?:\\.[a-z0-9_]+)?)\\s*(==|!=|>=|<=|>|<)\\s*(-?\\d+|SANG|CHIEU|TOI|DEM)\\s*$"
)


static func register_variable(name_or_prefix: String, resolver: Callable) -> void:
	_extra_variables[name_or_prefix] = resolver


## Gỡ biến mở rộng (autoload gọi khi rời cây, tránh giữ Callable của node đã hủy).
static func unregister_variable(name_or_prefix: String) -> void:
	_extra_variables.erase(name_or_prefix)


## "" nếu hợp lệ, ngược lại là mô tả lỗi.
static func validate(expr: String) -> String:
	var text: String = expr.strip_edges()
	if text.is_empty():
		return "điều kiện rỗng"
	for or_part: String in _split(text, " or "):
		for comparison: String in _split(or_part, " and "):
			var m: RegExMatch = _comparison_regex.search(comparison)
			if m == null:
				return "không hiểu điều kiện '%s'" % comparison.strip_edges()
			if not is_known_variable(m.get_string(1)):
				return "biến lạ '%s'" % m.get_string(1)
	return ""


static func evaluate(expr: String, state: GameState, errors: PackedStringArray = PackedStringArray()) -> bool:
	var text: String = expr.strip_edges()
	if text.is_empty():
		return true
	for or_part: String in _split(text, " or "):
		var all_true: bool = true
		for comparison: String in _split(or_part, " and "):
			if not _evaluate_comparison(comparison, state, errors):
				all_true = false
				break
		if all_true:
			return true
	return false


static func is_known_variable(variable: String) -> bool:
	if PLAIN_VARIABLES.has(variable) or _extra_variables.has(variable):
		return true
	var dot: int = variable.find(".")
	if dot < 0:
		return false
	var root: String = variable.substr(0, dot + 1)
	var rest: String = variable.substr(dot + 1)
	match root:
		"flag.", "rel.":
			return not rest.is_empty()
		"stat.":
			return STAT_NAMES.has(rest)
	return _extra_variables.has(root)


static func _evaluate_comparison(comparison: String, state: GameState, errors: PackedStringArray) -> bool:
	var m: RegExMatch = _comparison_regex.search(comparison)
	if m == null:
		errors.append("không hiểu điều kiện '%s'" % comparison.strip_edges())
		return false
	var variable: String = m.get_string(1)
	if not is_known_variable(variable):
		errors.append("biến lạ '%s'" % variable)
		return false
	var left: int = _value_of(variable, state)
	var raw: String = m.get_string(3)
	var right: int = int(SLOT_CONSTANTS[raw]) if SLOT_CONSTANTS.has(raw) else raw.to_int()
	match m.get_string(2):
		"==":
			return left == right
		"!=":
			return left != right
		">=":
			return left >= right
		"<=":
			return left <= right
		">":
			return left > right
		"<":
			return left < right
	return false


static func _value_of(variable: String, state: GameState) -> int:
	if state == null:
		return 0
	if _extra_variables.has(variable):
		return int((_extra_variables[variable] as Callable).call(variable, state))
	match variable:
		"money":
			return state.stats.get_money()
		"day":
			return state.clock.day
		"week":
			return state.clock.get_week()
		"weekday":
			return state.clock.get_weekday()
		"slot":
			return state.clock.slot
	var dot: int = variable.find(".")
	var root: String = variable.substr(0, dot + 1)
	var rest: String = variable.substr(dot + 1)
	match root:
		"flag.":
			return state.flags.get_flag(rest, 0)
		"rel.":
			return state.stats.get_relationship(rest)
		"stat.":
			return state.stats.get_stat(int(STAT_NAMES[rest]))
	if _extra_variables.has(root):
		return int((_extra_variables[root] as Callable).call(variable, state))
	return 0


static func _split(text: String, separator: String) -> PackedStringArray:
	return text.split(separator, false)
