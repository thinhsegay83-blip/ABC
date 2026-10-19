extends "res://tests/test_case.gd"
## Màn "Còn tiếp…" (bước 7): dữ liệu tổng kết thuần (không cần dựng UI).

const Ending: GDScript = preload("res://scripts/ui/ending_screen.gd")
const GameStateScript: GDScript = preload("res://scripts/core/game_state.gd")

var state: GameState


func before_each() -> void:
	state = GameStateScript.new()
	state.setup_new_game(load("res://data/difficulty_hard.tres") as DifficultyConfig)
	state.clock.set_time(28, GameClock.Slot.NIGHT)


func _texts() -> Array[String]:
	var result: Array[String] = []
	for line: Dictionary in Ending.build_summary(state):
		result.append(str(line["text"]))
	return result


func test_tuition_lines() -> void:
	assert_true(Ending.tuition_line(state).contains("CHƯA ĐÓNG"))
	state.flags.set_flag(Tuition.FLAG_PAID, 1)
	assert_eq(Ending.tuition_line(state), "Học phí: đã đóng đúng hạn.")
	state.flags.set_flag(Tuition.FLAG_LATE, 1)
	assert_eq(Ending.tuition_line(state), "Học phí: đã đóng trong thời gian gia hạn.")


func test_summary_basics() -> void:
	state.flags.set_flag("ktx_khu", 2)
	state.stats.set_money(1234000)
	var texts: Array[String] = _texts()
	assert_eq(texts[0], "Còn tiếp…")
	assert_true(texts.has("Đã sống 28 ngày ở KTX Khu B."))
	assert_true(texts.has("Tiền hiện có: 1.234.000 đ"))
	assert_true(texts.any(func(t: String) -> bool: return t.begins_with("GPA tạm tính: ")))
	assert_true(texts.any(func(t: String) -> bool: return t.begins_with("Quan hệ với Minh: ")))
	assert_true(texts.any(func(t: String) -> bool: return t.begins_with("Anh K.: ")))
	assert_true(texts.has("Cảm ơn bạn đã chơi thử!"))
	assert_true(texts.any(func(t: String) -> bool: return t.contains("SIL Open Font License")), "ghi công font")


func test_default_ktx_is_a() -> void:
	assert_true(_texts().has("Đã sống 28 ngày ở KTX Khu A."))


func test_choices_recap() -> void:
	assert_eq(Ending.choices_recap(state), [
		"Góp quỹ phòng: không", "Việc phát tờ rơi cho K.: không nhận",
		"Cảnh báo Minh: không", "Giải vòng lặp bằng Vật lý: chưa",
	] as Array[String])
	state.flags.set_flag("da_gop_quy", 1)
	state.flags.set_flag("nhan_viec_to_roi", 2)
	state.flags.set_flag("canh_bao_minh", 1)
	state.flags.set_flag("hieu_vong_lap", 1)
	assert_eq(Ending.choices_recap(state), [
		"Góp quỹ phòng: có", "Việc phát tờ rơi cho K.: đã nghỉ",
		"Cảnh báo Minh: có", "Giải vòng lặp bằng Vật lý: có",
	] as Array[String])
	state.flags.set_flag("nhan_viec_to_roi", 1)
	assert_eq(Ending.choices_recap(state)[1], "Việc phát tờ rơi cho K.: vẫn đang làm")
