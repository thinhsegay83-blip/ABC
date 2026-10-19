extends "res://tests/test_case.gd"
## Hướng dẫn chơi (J11, bước 7): dữ liệu gợi ý + mỗi gợi ý chỉ hiện một lần (cờ tut_<id>).

const HintsScript: GDScript = preload("res://scripts/ui/tutorial_hints.gd")
const EXPECTED_IDS: Array[String] = [
	"hanh_dong", "hoi_thoai", "dien_thoai", "tkb", "di_hoc", "lam_them", "an_uong",
	"ngu", "tong_ket", "hoc_phi", "tui_do", "radar", "goi_y",
]

var hints: CanvasLayer
var _old_setting: bool = true


func before_each() -> void:
	_old_setting = Settings.show_tutorial
	hints = HintsScript.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(hints)


func after_each() -> void:
	hints.free()
	Settings.show_tutorial = _old_setting
	Game.end_game()


func test_data_complete() -> void:
	var data: TutorialHintSet = load(HintsScript.DATA_PATH) as TutorialHintSet
	assert_not_null(data)
	if data == null:
		return
	var ids: Array[String] = []
	for hint: Dictionary in data.hints:
		var id: String = str(hint.get("id", ""))
		assert_false(ids.has(id), "trùng id " + id)
		ids.append(id)
		assert_true(str(hint.get("text", "")).length() >= 20, id + ": thiếu nội dung")
	ids.sort()
	var expected: Array[String] = EXPECTED_IDS.duplicate()
	expected.sort()
	assert_eq(ids, expected)


func test_shows_once() -> void:
	Settings.show_tutorial = true
	Game.new_game("hard")
	assert_true(hints.trigger("tkb"), "lần đầu xếp hàng")
	assert_eq(Game.state.flags.get_flag("tut_tkb"), 1)
	assert_false(hints.trigger("tkb"), "lần sau không hiện lại")
	assert_false(hints.trigger("khong_co"), "id lạ")


func test_disabled_still_marks_flag() -> void:
	Settings.show_tutorial = false
	Game.new_game("hard")
	assert_false(hints.trigger("ngu"))
	assert_eq(Game.state.flags.get_flag("tut_ngu"), 1, "tắt hướng dẫn vẫn ghi cờ")


func test_no_game_no_hint() -> void:
	Game.end_game()
	assert_false(hints.trigger("tkb"))


func test_flag_survives_save() -> void:
	Game.new_game("hard")
	hints.trigger("an_uong")
	var data: Dictionary = json_round_trip(Game.state.to_dict())
	var restored: GameState = GameState.new()
	restored.from_dict(data)
	assert_eq(restored.flags.get_flag("tut_an_uong"), 1)
