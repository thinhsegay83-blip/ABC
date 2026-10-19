extends "res://tests/test_case.gd"

const GameStateScript: GDScript = preload("res://scripts/core/game_state.gd")
const SaveCodecScript: GDScript = preload("res://scripts/core/save_codec.gd")
const SaveSystemScript: GDScript = preload("res://scripts/autoload/save_system.gd")
const TEST_DIR: String = "user://test_saves/"

var save_system: Node


func before_each() -> void:
	_clean_dir()
	save_system = SaveSystemScript.new()
	save_system.save_dir = TEST_DIR


func after_each() -> void:
	if save_system != null:
		save_system.free()
		save_system = null
	_clean_dir()


func _clean_dir() -> void:
	if not DirAccess.dir_exists_absolute(TEST_DIR):
		return
	for file_name: String in DirAccess.get_files_at(TEST_DIR):
		DirAccess.remove_absolute(TEST_DIR + file_name)
	DirAccess.remove_absolute(TEST_DIR)


func _make_state(day: int, money: int) -> GameState:
	var state: GameState = GameStateScript.new()
	state.setup_new_game(load("res://data/difficulty_hard.tres") as DifficultyConfig)
	state.clock.set_time(day, GameClock.Slot.AFTERNOON)
	state.stats.set_money(money)
	state.flags.set_flag("ktx_khu", 1)
	return state


func test_codec_round_trip_keeps_ints() -> void:
	var text: String = SaveCodecScript.to_json(_make_state(5, 13850000), 1000.0)
	var loaded: GameState = SaveCodecScript.from_json(text)
	assert_not_null(loaded)
	if loaded == null:
		return
	assert_eq(loaded.stats.get_money(), 13850000)
	assert_eq(loaded.clock.day, 5)
	assert_eq(loaded.flags.get_flag("ktx_khu"), 1)


func test_codec_rejects_bad_data() -> void:
	assert_null(SaveCodecScript.from_json("không phải json"), "JSON lỗi")
	assert_null(SaveCodecScript.decode({"version": 1}), "thiếu state")
	assert_null(SaveCodecScript.decode({"state": {}}), "thiếu version")
	var future: Dictionary = SaveCodecScript.encode(_make_state(1, 0), 0.0)
	future["version"] = SaveCodecScript.SAVE_VERSION + 1
	assert_null(SaveCodecScript.decode(future), "version mới hơn")


func test_save_and_load_slot() -> void:
	assert_true(save_system.save_to_slot(2, _make_state(9, 777000)))
	assert_true(save_system.has_save(2))
	var loaded: GameState = save_system.load_from_slot(2)
	assert_not_null(loaded)
	if loaded != null:
		assert_eq(loaded.clock.day, 9)
		assert_eq(loaded.stats.get_money(), 777000)
		assert_eq(loaded.difficulty_id, "hard")


func test_empty_slot_info() -> void:
	var info: Dictionary = save_system.get_slot_info(3)
	assert_false(bool(info.get("exists", true)))
	assert_null(save_system.load_from_slot(3))
	assert_eq(save_system.get_latest_slot(), -1)


func test_corrupt_file_returns_null() -> void:
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	var file: FileAccess = FileAccess.open(save_system.get_slot_path(1), FileAccess.WRITE)
	file.store_string("{hỏng")
	file.close()
	assert_null(save_system.load_from_slot(1))


func test_latest_slot_and_autosave() -> void:
	assert_true(save_system.save_to_slot(1, _make_state(3, 0)))
	assert_true(save_system.autosave(_make_state(4, 0)))
	var latest: int = save_system.get_latest_slot()
	assert_true(latest == 0 or latest == 1, "ô mới nhất phải là 0 hoặc 1")
	var info: Dictionary = save_system.get_slot_info(0)
	assert_true(bool(info.get("exists", false)))
	assert_eq(int(info.get("day", 0)), 4)
