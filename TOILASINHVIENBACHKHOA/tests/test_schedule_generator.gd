extends "res://tests/test_case.gd"

const Gen: GDScript = preload("res://scripts/life/schedule_generator.gd")
const LifeCatalogScript: GDScript = preload("res://scripts/life/life_catalog.gd")

var subjects: Array[SubjectData] = []


func before_each() -> void:
	subjects = LifeCatalogScript.load_default().subjects


func test_same_seed_same_schedule() -> void:
	assert_eq(Gen.generate(42, subjects), Gen.generate(42, subjects))


func test_different_seeds_vary() -> void:
	var distinct: Dictionary = {}
	for seed_value in 20:
		distinct[str(Gen.generate(seed_value, subjects))] = true
	assert_true(distinct.size() > 5, "20 seed phải cho nhiều TKB khác nhau")


func test_constraints_hold_for_many_seeds() -> void:
	for seed_value in 60:
		var schedule: Array[Dictionary] = Gen.generate(seed_value, subjects)
		assert_eq(schedule.size(), 6, "đủ 6 buổi/tuần (seed %d)" % seed_value)
		var per_day: Dictionary = {}
		var cells: Dictionary = {}
		var counts: Dictionary = {}
		for entry: Dictionary in schedule:
			var weekday: int = entry["weekday"]
			var slot: int = entry["slot"]
			var subject: String = entry["subject"]
			assert_true(weekday >= 0 and weekday <= 4, "chỉ Thứ Hai–Thứ Sáu")
			assert_true(slot == 0 or slot == 1, "chỉ Sáng/Chiều")
			assert_false(cells.has(Vector2i(weekday, slot)), "không trùng ô")
			cells[Vector2i(weekday, slot)] = true
			per_day[weekday] = int(per_day.get(weekday, 0)) + 1
			counts[subject] = int(counts.get(subject, 0)) + 1
			for other: Dictionary in schedule:
				if other != entry and other["subject"] == subject:
					assert_true(absi(int(other["weekday"]) - weekday) >= 2, "cùng môn cách ≥ 1 ngày")
		for day: Variant in per_day.keys():
			assert_true(int(per_day[day]) <= 2, "≤ 2 buổi/ngày")
		assert_true(10 - schedule.size() >= 2, "còn ≥ 2 nửa ngày trống")
		for subject: SubjectData in subjects:
			assert_eq(int(counts.get(subject.id, 0)), subject.sessions_per_week, subject.id)


func test_no_class_before_start_day() -> void:
	var fx: Object = preload("res://tests/life_fixture.gd").new()
	assert_eq(fx.sim.class_at(1, 0), "")
	assert_eq(fx.sim.class_at(1, 1), "")
