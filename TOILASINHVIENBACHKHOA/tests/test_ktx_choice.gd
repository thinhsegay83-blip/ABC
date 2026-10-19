extends "res://tests/test_case.gd"
## Chọn KTX Khu A/B ở màn mở đầu (F3, bước 7). QĐ-7.1 = A: hai khu chỉ khác lời mô tả,
## cùng giá KTX — chọn khu không thu thêm tiền (khoản KTX ngày 1 chỉ thu một lần).

var _options: Array = []


func after_each() -> void:
	Game.end_game()


func _play_intro(pick: String) -> GameState:
	var capture: Callable = func(shown: Array) -> void: _options.assign(shown)
	DialogueSystem.choices_shown.connect(capture)
	Game.new_game("hard")
	assert_true(EventDirector.pump(), "mở đầu tự chạy ở ván mới")
	for _i in 200:
		if not DialogueSystem.is_active():
			break
		if _options.is_empty():
			DialogueSystem.advance()
			continue
		var shown: Array = _options.duplicate()
		_options.clear()
		for option: Dictionary in shown:
			if str(option["text"]).contains(pick):
				DialogueSystem.choose(int(option["index"]))
				break
	DialogueSystem.choices_shown.disconnect(capture)
	return Game.state


func _ktx_charges(state: GameState) -> int:
	var count: int = 0
	for entry: Dictionary in state.life.ledger_today:
		if str(entry["label"]) == "Tiền KTX tháng":
			count += 1
	return count


func test_pick_a() -> void:
	var state: GameState = _play_intro("KTX Khu A")
	assert_false(DialogueSystem.is_active())
	assert_eq(state.flags.get_flag("ktx_khu"), 1)
	assert_eq(state.flags.get_flag("minh_trang_thai"), 1, "vào phòng gặp Minh")
	assert_eq(_ktx_charges(state), 1)


func test_pick_b_same_price() -> void:
	var a: GameState = _play_intro("KTX Khu A")
	var money_a: int = a.stats.get_money()
	Game.end_game()
	var b: GameState = _play_intro("KTX Khu B")
	assert_eq(b.flags.get_flag("ktx_khu"), 2)
	assert_eq(b.stats.get_money(), money_a, "QĐ-7.1 = A: hai khu cùng giá")
	assert_eq(_ktx_charges(b), 1, "không thu KTX 2 lần ngày 1")


func test_choice_survives_save() -> void:
	var state: GameState = _play_intro("KTX Khu B")
	var restored: GameState = GameState.new()
	restored.from_dict(json_round_trip(state.to_dict()))
	assert_eq(restored.flags.get_flag("ktx_khu"), 2)
