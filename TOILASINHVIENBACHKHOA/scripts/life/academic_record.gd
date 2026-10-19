class_name AcademicRecord
extends RefCounted
## Điểm danh + điểm quá trình từng môn (C2, C3). Dữ liệu nằm trong LifeState.academics.
## Điểm 10 [ĐX] = 3 × tỉ lệ chuyên cần + 7 × mức nắm bài, làm tròn 0,1.
## Mức nắm bài = min(1, study / (3 × số buổi đã diễn ra)).

const ATTEND_WEIGHT: float = 3.0
const MASTERY_WEIGHT: float = 7.0
const STUDY_PER_SESSION: float = 3.0

## Mốc quy đổi thang 10 → thang 4 (phổ biến ở đào tạo tín chỉ VN). [min_10, điểm_4, chữ]
const GRADE_TABLE: Array = [
	[8.5, 4.0, "A"], [8.0, 3.5, "B+"], [7.0, 3.0, "B"], [6.5, 2.5, "C+"],
	[5.5, 2.0, "C"], [5.0, 1.5, "D+"], [4.0, 1.0, "D"], [0.0, 0.0, "F"],
]


static func get_record(life: LifeState, subject: String) -> Dictionary:
	if not life.academics.has(subject):
		life.academics[subject] = {"attended": 0, "absent": 0, "study": 0}
	return life.academics[subject]


static func record_attend(life: LifeState, subject: String, study_points: int) -> void:
	var rec: Dictionary = get_record(life, subject)
	rec["attended"] = int(rec["attended"]) + 1
	rec["study"] = int(rec["study"]) + study_points


static func record_absent(life: LifeState, subject: String) -> void:
	var rec: Dictionary = get_record(life, subject)
	rec["absent"] = int(rec["absent"]) + 1


static func record_study(life: LifeState, subject: String, study_points: int) -> void:
	var rec: Dictionary = get_record(life, subject)
	rec["study"] = int(rec["study"]) + study_points


static func sessions_held(rec: Dictionary) -> int:
	return int(rec.get("attended", 0)) + int(rec.get("absent", 0))


## -1 nếu môn chưa có buổi nào.
static func score10(rec: Dictionary) -> float:
	var sessions: int = sessions_held(rec)
	if sessions == 0:
		return -1.0
	var attendance: float = float(int(rec.get("attended", 0))) / sessions
	var mastery: float = minf(1.0, float(int(rec.get("study", 0))) / (STUDY_PER_SESSION * sessions))
	return snappedf(ATTEND_WEIGHT * attendance + MASTERY_WEIGHT * mastery, 0.1)


static func to_scale4(score: float) -> float:
	return float(_grade_row(score)[1])


static func letter(score: float) -> String:
	return str(_grade_row(score)[2])


## GPA tạm tính có trọng số tín chỉ; -1 nếu chưa môn nào có buổi.
static func gpa(life: LifeState, subjects: Array[SubjectData]) -> float:
	var total_points: float = 0.0
	var total_credits: int = 0
	for subject: SubjectData in subjects:
		var rec: Dictionary = life.academics.get(subject.id, {})
		var score: float = score10(rec)
		if score < 0.0:
			continue
		total_points += to_scale4(score) * subject.credits
		total_credits += subject.credits
	if total_credits == 0:
		return -1.0
	return snappedf(total_points / total_credits, 0.01)


static func _grade_row(score: float) -> Array:
	# Cộng epsilon nhỏ để 8.5 lưu dạng 8.4999… vẫn được tính là 8.5.
	for row: Array in GRADE_TABLE:
		if score + 0.0001 >= float(row[0]):
			return row
	return GRADE_TABLE[GRADE_TABLE.size() - 1]
