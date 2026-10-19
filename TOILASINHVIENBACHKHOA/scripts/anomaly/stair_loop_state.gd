class_name StairLoopState
extends RefCounted
## G3: trạng thái vòng lặp cầu thang (QĐ-6.1 = A "Chiếu nghỉ lạ"). Logic thuần.
## Luật: chiếu nghỉ có chỗ lệch → đi xuống; y như cũ → đi lên. Đúng liền required_streak lần → thoát.

var active: bool = false
var streak: int = 0
var required_streak: int = 4
var mistakes_total: int = 0
var mistakes_in_row: int = 0
var landing_index: int = 0
var current_anomaly: String = ""
## Đã gọi tiền bối ở chiếu nghỉ này chưa (mỗi chiếu nghỉ 1 lần).
var assist_used_here: bool = false

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _pool: Array[String] = []
var _bag: Array[String] = []
var _normals_in_row: int = 0
var _last_anomaly: String = ""


func start(seed_value: int, anomaly_ids: Array[String], streak_needed: int = 4) -> void:
	_rng.seed = seed_value
	_pool = anomaly_ids.duplicate()
	_bag.clear()
	active = true
	streak = 0
	required_streak = streak_needed
	mistakes_total = 0
	mistakes_in_row = 0
	landing_index = 0
	current_anomaly = ""  # chiếu nghỉ đầu tiên luôn bình thường
	_normals_in_row = 1
	_last_anomaly = ""
	assist_used_here = false


## Quyết định chiếu nghỉ kế tiếp; trả id chỗ lệch hoặc "".
func next_landing() -> String:
	landing_index += 1
	assist_used_here = false
	var anomalous: bool = _rng.randf() < 0.5
	if _normals_in_row >= 2:
		anomalous = true  # không quá 2 chiếu nghỉ bình thường liên tiếp
	if not anomalous or _pool.is_empty():
		current_anomaly = ""
		_normals_in_row += 1
		return current_anomaly
	_normals_in_row = 0
	current_anomaly = _draw()
	_last_anomaly = current_anomaly
	return current_anomaly


## "up"/"down" → "correct" / "wrong" / "escaped".
func choose(direction: String) -> String:
	var correct: bool = (current_anomaly.is_empty() and direction == "up") \
			or (not current_anomaly.is_empty() and direction == "down")
	if not correct:
		streak = 0
		mistakes_total += 1
		mistakes_in_row += 1
		return "wrong"
	streak += 1
	mistakes_in_row = 0
	if streak >= required_streak:
		active = false
		return "escaped"
	return "correct"


## Mức gợi ý 1–3: theo Trí tuệ + 1 mức mỗi N lần sai liên tiếp, trần 3.
func hint_level(knowledge: int, config: PuzzleHintConfig) -> int:
	var level: int = 1
	if knowledge >= config.level3_min:
		level = 3
	elif knowledge >= config.level2_min:
		level = 2
	@warning_ignore("integer_division")
	level += mistakes_in_row / maxi(1, config.mistakes_per_level)
	return mini(level, 3)


func should_offer_assist(config: PuzzleHintConfig = null) -> bool:
	var needed: int = config.assist_after_mistakes if config != null else 8
	return mistakes_total >= needed


## Không lặp chỗ lệch tới khi dùng hết danh sách; không 2 lần liền cùng một chỗ lệch.
func _draw() -> String:
	if _bag.is_empty():
		_bag = _pool.duplicate()
		for i in range(_bag.size() - 1, 0, -1):
			var j: int = _rng.randi_range(0, i)
			var tmp: String = _bag[i]
			_bag[i] = _bag[j]
			_bag[j] = tmp
		if _bag.size() > 1 and _bag[_bag.size() - 1] == _last_anomaly:
			# Phần tử rút ra đầu tiên (cuối mảng) trùng lần trước → đổi chỗ.
			var swap: String = _bag[0]
			_bag[0] = _bag[_bag.size() - 1]
			_bag[_bag.size() - 1] = swap
	return _bag.pop_back()


func to_dict() -> Dictionary:
	return {
		"active": active, "streak": streak, "required_streak": required_streak,
		"mistakes_total": mistakes_total, "mistakes_in_row": mistakes_in_row,
		"landing_index": landing_index, "current_anomaly": current_anomaly,
	}


func from_dict(data: Dictionary) -> void:
	active = bool(data.get("active", false))
	streak = int(data.get("streak", 0))
	required_streak = int(data.get("required_streak", 4))
	mistakes_total = int(data.get("mistakes_total", 0))
	mistakes_in_row = int(data.get("mistakes_in_row", 0))
	landing_index = int(data.get("landing_index", 0))
	current_anomaly = str(data.get("current_anomaly", ""))
