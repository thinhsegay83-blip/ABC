extends "res://tests/test_case.gd"

const Cond: GDScript = preload("res://scripts/dialogue/dialogue_condition.gd")
const GameStateScript: GDScript = preload("res://scripts/core/game_state.gd")

var state: GameState


func before_each() -> void:
	state = GameStateScript.new()
	state.flags.set_flag("x", 3)
	state.stats.set_money(500)
	state.stats.set_relationship("minh", 40)
	state.stats.set_stat(PlayerStats.Stat.SANITY, 77)
	state.clock.set_time(9, GameClock.Slot.EVENING)  # Thứ Ba tuần 2


func test_operators() -> void:
	assert_true(Cond.evaluate("flag.x == 3", state))
	assert_true(Cond.evaluate("flag.x != 2", state))
	assert_true(Cond.evaluate("flag.x >= 3", state))
	assert_true(Cond.evaluate("flag.x <= 3", state))
	assert_false(Cond.evaluate("flag.x > 3", state))
	assert_false(Cond.evaluate("flag.x < 3", state))
	assert_true(Cond.evaluate("flag.chua_co == 0", state), "cờ chưa có = 0")


func test_and_binds_tighter_than_or() -> void:
	assert_true(Cond.evaluate("day == 1 and week == 1 or money == 500", state))
	assert_true(Cond.evaluate("money == 500 or day == 1 and week == 9", state))
	assert_false(Cond.evaluate("money == 1 or day == 9 and week == 9", state))


func test_variables_and_constants() -> void:
	assert_true(Cond.evaluate("slot == TOI", state))
	assert_true(Cond.evaluate("weekday == 1", state))
	assert_true(Cond.evaluate("week == 2", state))
	assert_true(Cond.evaluate("rel.minh >= 40", state))
	assert_true(Cond.evaluate("money > 499", state))
	assert_true(Cond.evaluate("stat.sanity == 77", state))


func test_unknown_variable_false_with_error() -> void:
	var errors: PackedStringArray = PackedStringArray()
	assert_false(Cond.evaluate("bien_la == 1", state, errors))
	assert_eq(errors.size(), 1)
	assert_true(Cond.validate("bien_la == 1") != "")
	assert_true(Cond.validate("flag.x = 1") != "", "sai toán tử")
	assert_eq(Cond.validate("flag.x == 1 and slot == DEM"), "")
