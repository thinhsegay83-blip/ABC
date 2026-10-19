extends "res://tests/test_case.gd"

const GameStateScript: GDScript = preload("res://scripts/core/game_state.gd")
const TimeDecayScript: GDScript = preload("res://scripts/data/time_decay_config.gd")

var state: GameState


func before_each() -> void:
	state = GameStateScript.new()


func _difficulty(id: String) -> DifficultyConfig:
	return load("res://data/difficulty_%s.tres" % id) as DifficultyConfig


func test_difficulty_files_match_balance() -> void:
	# Số liệu theo BALANCE.md.
	var easy: DifficultyConfig = _difficulty("easy")
	var hard: DifficultyConfig = _difficulty("hard")
	var extreme: DifficultyConfig = _difficulty("extreme")
	assert_not_null(easy)
	assert_not_null(hard)
	assert_not_null(extreme)
	if easy == null or hard == null or extreme == null:
		return
	assert_eq(easy.starting_money, 15000000)
	assert_almost_eq(easy.decay_multiplier, 0.75)
	assert_eq(hard.starting_money, 14000000)
	assert_almost_eq(hard.decay_multiplier, 1.0)
	assert_eq(extreme.starting_money, 12000000)
	assert_almost_eq(extreme.decay_multiplier, 1.25)
	assert_almost_eq(extreme.wage_multiplier, 0.9)


func test_setup_new_game() -> void:
	state.flags.set_flag("cu", 1)
	state.clock.set_time(9, GameClock.Slot.NIGHT)
	state.setup_new_game(_difficulty("extreme"))
	assert_eq(state.difficulty_id, "extreme")
	assert_eq(state.stats.get_money(), 12000000)
	assert_eq(state.stats.get_stat(PlayerStats.Stat.STAMINA), GameState.START_STAMINA)
	assert_eq(state.stats.get_stat(PlayerStats.Stat.HUNGER), GameState.START_HUNGER)
	assert_eq(state.clock.day, 1)
	assert_eq(state.clock.slot, GameClock.Slot.MORNING)
	assert_false(state.flags.has_flag("cu"))


func test_decay_uses_multiplier() -> void:
	var decay: TimeDecayConfig = TimeDecayScript.new()
	decay.hunger_per_slot = 8
	decay.stamina_per_slot = 4
	decay.sanity_per_slot = 0
	state.setup_new_game(_difficulty("easy"))  # ×0,75
	state.apply_decay(decay)
	assert_eq(state.stats.get_stat(PlayerStats.Stat.HUNGER), GameState.START_HUNGER - 6)
	assert_eq(state.stats.get_stat(PlayerStats.Stat.STAMINA), GameState.START_STAMINA - 3)
	assert_eq(state.stats.get_stat(PlayerStats.Stat.SANITY), GameState.START_SANITY)


func test_advance_time_moves_clock() -> void:
	var decay: TimeDecayConfig = TimeDecayScript.new()
	state.setup_new_game(_difficulty("hard"))
	state.advance_time(decay)
	assert_eq(state.clock.slot, GameClock.Slot.AFTERNOON)
	assert_true(state.stats.get_stat(PlayerStats.Stat.HUNGER) < GameState.START_HUNGER)


func test_dict_round_trip_through_json() -> void:
	state.setup_new_game(_difficulty("easy"))
	state.stats.set_money(-5000)
	state.flags.set_flag("da_gop_quy", 1)
	state.clock.set_time(10, GameClock.Slot.EVENING)
	var copy: GameState = GameStateScript.new()
	copy.from_dict(json_round_trip(state.to_dict()))
	assert_eq(copy.difficulty_id, "easy")
	assert_almost_eq(copy.decay_multiplier, 0.75)
	assert_eq(copy.stats.get_money(), -5000)
	assert_eq(copy.flags.get_flag("da_gop_quy"), 1)
	assert_eq(copy.clock.day, 10)
