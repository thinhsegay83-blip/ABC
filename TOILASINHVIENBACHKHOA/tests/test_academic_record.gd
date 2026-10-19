extends "res://tests/test_case.gd"

const Rec: GDScript = preload("res://scripts/life/academic_record.gd")
const LifeStateScript: GDScript = preload("res://scripts/core/life_state.gd")

var life: LifeState


func before_each() -> void:
	life = LifeStateScript.new()


func test_counts() -> void:
	Rec.record_attend(life, "vat_ly_1", 2)
	Rec.record_absent(life, "vat_ly_1")
	Rec.record_study(life, "vat_ly_1", 3)
	var rec: Dictionary = Rec.get_record(life, "vat_ly_1")
	assert_eq(int(rec["attended"]), 1)
	assert_eq(int(rec["absent"]), 1)
	assert_eq(int(rec["study"]), 5)


func test_score_example_from_spec() -> void:
	# Đi học đủ, không tự học → 3 + 7 × (2/3) = 7,67 → 7,7
	for _i in 4:
		Rec.record_attend(life, "giai_tich_1", 2)
	assert_almost_eq(Rec.score10(Rec.get_record(life, "giai_tich_1")), 7.7, 0.001)


func test_score_no_session() -> void:
	assert_almost_eq(Rec.score10(Rec.get_record(life, "hoa_dai_cuong")), -1.0)


func test_scale4_boundaries() -> void:
	assert_almost_eq(Rec.to_scale4(8.5), 4.0)
	assert_almost_eq(Rec.to_scale4(8.4), 3.5)
	assert_almost_eq(Rec.to_scale4(7.0), 3.0)
	assert_almost_eq(Rec.to_scale4(5.5), 2.0)
	assert_almost_eq(Rec.to_scale4(5.4), 1.5)
	assert_almost_eq(Rec.to_scale4(3.9), 0.0)
	assert_eq(Rec.letter(8.5), "A")
	assert_eq(Rec.letter(3.9), "F")


func test_gpa_weighted_and_skips_empty() -> void:
	var a: SubjectData = SubjectData.new()
	a.id = "a"
	a.credits = 4
	var b: SubjectData = SubjectData.new()
	b.id = "b"
	b.credits = 2
	var c: SubjectData = SubjectData.new()
	c.id = "c"
	c.credits = 3
	# a: chuyên cần đủ, nắm bài đủ → 10 → 4,0 ; b: vắng hết → 0 → 0,0 ; c: chưa có buổi
	Rec.record_attend(life, "a", 3)
	Rec.record_absent(life, "b")
	Rec.get_record(life, "c")
	var subjects: Array[SubjectData] = [a, b, c]
	assert_almost_eq(Rec.gpa(life, subjects), snappedf((4.0 * 4 + 0.0 * 2) / 6.0, 0.01))
