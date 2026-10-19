extends "res://tests/test_case.gd"
## Kịch bản đổi khu → signal area_change_requested cho bản đồ; về menu khi đang chờ vào cầu thang không lỗi.

var requests: Array[String] = []
var _capture: Callable


func before_each() -> void:
	requests.clear()
	var log_requests: Array[String] = requests
	_capture = func(area_id: String, spawn_id: String) -> void: log_requests.append(area_id + "/" + spawn_id)
	AnomalyDirector.area_change_requested.connect(_capture)
	Game.new_game("hard")


func after_each() -> void:
	AnomalyDirector.area_change_requested.disconnect(_capture)
	AnomalyDirector.abort_loop()
	Game.end_game()


func _read_all() -> void:
	for _i in 200:
		if not DialogueSystem.is_active():
			return
		DialogueSystem.advance()


func test_climax_moves_to_hallway() -> void:
	assert_true(DialogueSystem.start("t4_cao_trao_noi_dung"))
	_read_all()
	assert_eq(requests, ["ktx_hallway/corridor_from_room"] as Array[String])
	assert_eq(EventDirector.current_place, "ktx_hallway")
	assert_true(AnomalyDirector.pending_start, "chờ hội thoại xong mới vào cầu thang")
	AnomalyDirector.start_pending()
	assert_true(AnomalyDirector.loop.active)


func test_escape_and_sleep_resume_request_area() -> void:
	AnomalyDirector.begin_stair_loop()
	_read_all()
	for _i in 20:
		if not AnomalyDirector.loop.active:
			break
		AnomalyDirector.stair_choose("up" if AnomalyDirector.loop.current_anomaly.is_empty() else "down")
		_read_all()
	assert_false(AnomalyDirector.loop.active, "thoát được")
	assert_true(requests.has("ktx_hallway/"), "thoát cầu thang → về hành lang")
	_read_all()
	EventDirector.pump()
	_read_all()
	requests.clear()
	DialogueSystem.get("_commands")["sleep_resume"].call(PackedStringArray(["1.0"]), Game.state)
	assert_eq(requests, ["ktx_room/"] as Array[String], "ngủ tiếp → về phòng")


func test_pending_after_quit_is_dropped() -> void:
	AnomalyDirector.pending_start = true
	Game.end_game()
	AnomalyDirector.start_pending()
	assert_false(AnomalyDirector.pending_start)
	assert_false(AnomalyDirector.loop.active, "không vào cầu thang khi đã thoát ván")
