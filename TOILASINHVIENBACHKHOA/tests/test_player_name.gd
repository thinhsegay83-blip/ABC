extends "res://tests/test_case.gd"

const Name: GDScript = preload("res://scripts/dialogue/player_name.gd")
const GameStateScript: GDScript = preload("res://scripts/core/game_state.gd")


func test_sanitize() -> void:
	assert_eq(Name.sanitize("  Đức   Anh "), "Đức Anh")


func test_validate() -> void:
	assert_eq(Name.validate("Đức Anh"), "")
	assert_eq(Name.validate("Nguyễn-Văn A'"), "")
	assert_true(Name.validate("") != "", "rỗng")
	assert_true(Name.validate("12345678901234567") != "", "17 ký tự")
	assert_true(Name.validate("Phong[") != "")
	assert_true(Name.validate("{x}") != "")
	assert_true(Name.validate("a\nb") != "")


func test_save_round_trip_and_default() -> void:
	var state: GameState = GameStateScript.new()
	state.player_name = "Đức Anh"
	var copy: GameState = GameStateScript.new()
	copy.from_dict(json_round_trip(state.to_dict()))
	assert_eq(copy.player_name, "Đức Anh")
	var old: GameState = GameStateScript.new()
	old.from_dict({"stats": {}, "clock": {}, "flags": {}})
	assert_eq(PlayerDefaults.name_or_default(old.player_name), "Phong")
