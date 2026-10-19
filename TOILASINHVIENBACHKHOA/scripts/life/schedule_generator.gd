class_name ScheduleGenerator
extends RefCounted
## Thời khóa biểu ngẫu nhiên theo seed (B2). Cùng seed → cùng TKB.
## Ràng buộc: Thứ Hai–Thứ Sáu, chỉ Sáng/Chiều; mỗi môn ≤ 1 buổi/ngày; mỗi ngày ≤ 2 buổi;
## 2 buổi cùng môn cách nhau ≥ 1 ngày; mỗi tuần còn ≥ 2 nửa ngày trống.

const SCHOOL_DAYS: int = 5  # weekday 0..4 = Thứ Hai..Thứ Sáu
const CLASS_SLOTS: Array[int] = [GameClock.Slot.MORNING, GameClock.Slot.AFTERNOON]
const MAX_PER_DAY: int = 2
const MIN_FREE_HALF_DAYS: int = 2
const MAX_ATTEMPTS: int = 50


## Trả mảng {weekday, slot, subject}, sắp theo thứ rồi khung giờ. Rỗng nếu không xếp được.
static func generate(seed_value: int, subjects: Array[SubjectData]) -> Array[Dictionary]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var sessions: Array[String] = []
	for subject: SubjectData in subjects:
		for _i in subject.sessions_per_week:
			sessions.append(subject.id)
	if sessions.size() > SCHOOL_DAYS * CLASS_SLOTS.size() - MIN_FREE_HALF_DAYS:
		push_warning("ScheduleGenerator: quá nhiều buổi học/tuần")
		return []
	for _attempt in MAX_ATTEMPTS:
		var result: Array[Dictionary] = []
		if _place(sessions, 0, result, rng):
			result.sort_custom(_compare)
			return result
	push_warning("ScheduleGenerator: không xếp được TKB")
	return []


## Môn học ở (weekday, slot), "" nếu trống.
static func subject_at(schedule: Array[Dictionary], weekday: int, slot: int) -> String:
	for entry: Dictionary in schedule:
		if int(entry["weekday"]) == weekday and int(entry["slot"]) == slot:
			return str(entry["subject"])
	return ""


static func _place(
	sessions: Array[String], index: int, result: Array[Dictionary], rng: RandomNumberGenerator
) -> bool:
	if index >= sessions.size():
		return true
	var subject: String = sessions[index]
	for cell: Vector2i in _shuffled_cells(rng):
		if not _is_valid(result, cell.x, cell.y, subject):
			continue
		result.append({"weekday": cell.x, "slot": cell.y, "subject": subject})
		if _place(sessions, index + 1, result, rng):
			return true
		result.pop_back()
	return false


static func _is_valid(result: Array[Dictionary], weekday: int, slot: int, subject: String) -> bool:
	var count_today: int = 0
	for entry: Dictionary in result:
		var other_day: int = int(entry["weekday"])
		if other_day == weekday:
			if int(entry["slot"]) == slot:
				return false
			count_today += 1
		if str(entry["subject"]) == subject and absi(other_day - weekday) < 2:
			return false  # cùng ngày hoặc ngày liền kề
	return count_today < MAX_PER_DAY


static func _shuffled_cells(rng: RandomNumberGenerator) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for weekday in SCHOOL_DAYS:
		for slot: int in CLASS_SLOTS:
			cells.append(Vector2i(weekday, slot))
	# Fisher–Yates bằng rng có seed (không dùng shuffle() toàn cục để giữ tính tất định).
	for i in range(cells.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: Vector2i = cells[i]
		cells[i] = cells[j]
		cells[j] = tmp
	return cells


static func _compare(a: Dictionary, b: Dictionary) -> bool:
	if int(a["weekday"]) != int(b["weekday"]):
		return int(a["weekday"]) < int(b["weekday"])
	return int(a["slot"]) < int(b["slot"])
