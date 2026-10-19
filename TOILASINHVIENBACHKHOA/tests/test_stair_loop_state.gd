extends "res://tests/test_case.gd"

var ids: Array[String] = ["a", "b", "c", "d", "e", "f", "g", "h"]
var config: PuzzleHintConfig


func before_each() -> void:
	config = load("res://data/puzzle_hints.tres") as PuzzleHintConfig


func test_first_landing_normal_and_rules() -> void:
	var loop: StairLoopState = StairLoopState.new()
	loop.start(1, ids)
	assert_eq(loop.current_anomaly, "")
	assert_eq(loop.choose("down"), "wrong", "bình thường + xuống = sai")
	assert_eq(loop.streak, 0)
	loop.current_anomaly = ""
	assert_eq(loop.choose("up"), "correct", "bình thường + lên = đúng")
	loop.current_anomaly = "a"
	assert_eq(loop.choose("down"), "correct", "lệch + xuống = đúng")
	loop.current_anomaly = "a"
	assert_eq(loop.choose("up"), "wrong", "lệch + lên = sai")
	assert_eq(loop.streak, 0, "sai → streak 0")


func test_escape_after_four() -> void:
	var loop: StairLoopState = StairLoopState.new()
	loop.start(2, ids)
	var result: String = ""
	for _i in 4:
		result = loop.choose("down" if not loop.current_anomaly.is_empty() else "up")
		if result != "escaped":
			loop.next_landing()
	assert_eq(result, "escaped")
	assert_false(loop.active)


func test_sequence_constraints() -> void:
	for seed_value in 30:
		var loop: StairLoopState = StairLoopState.new()
		loop.start(seed_value, ids)
		var normals: int = 1
		var seen: Array[String] = []
		var last: String = ""
		for _i in 40:
			var anomaly: String = loop.next_landing()
			if anomaly.is_empty():
				normals += 1
				assert_true(normals <= 2, "không quá 2 chiếu nghỉ bình thường liên tiếp")
				continue
			normals = 0
			assert_true(anomaly != last, "không 2 lần liền cùng chỗ lệch")
			if seen.size() == ids.size():
				seen.clear()
			assert_false(seen.has(anomaly), "không lặp tới khi hết danh sách")
			seen.append(anomaly)
			last = anomaly


func test_hint_level_and_assist() -> void:
	var loop: StairLoopState = StairLoopState.new()
	loop.start(3, ids)
	assert_eq(loop.hint_level(10, config), 1)
	assert_eq(loop.hint_level(30, config), 2)
	assert_eq(loop.hint_level(60, config), 3)
	for _i in 3:
		loop.current_anomaly = ""
		loop.choose("down")
	assert_eq(loop.hint_level(10, config), 2, "+1 mức sau 3 lần sai liên tiếp")
	for _i in 3:
		loop.current_anomaly = ""
		loop.choose("down")
	assert_eq(loop.hint_level(60, config), 3, "trần 3")
	assert_false(loop.should_offer_assist(config))
	for _i in 2:
		loop.current_anomaly = ""
		loop.choose("down")
	assert_true(loop.should_offer_assist(config), "sau 8 lần sai")
