extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")
const GameStateScript: GDScript = preload("res://scripts/core/game_state.gd")


func test_round_trip_json() -> void:
	var fx: Object = Fixture.new("hard")
	fx.state.life.inventory.add("giao_trinh_vat_ly_1", 2)
	fx.sim.add_effect("cafein")
	fx.state.life.shifts_today = 1
	var copy: GameState = GameStateScript.new()
	copy.from_dict(json_round_trip(fx.state.to_dict()))
	var life: LifeState = copy.life
	assert_true(life.initialized)
	assert_eq(life.schedule, fx.state.life.schedule)
	assert_eq(typeof(life.schedule[0]["weekday"]), TYPE_INT)
	assert_eq(life.inventory.count("giao_trinh_vat_ly_1"), 2)
	assert_eq(life.shifts_today, 1)
	assert_eq(int(life.status_effects[0]["slots_left"]), 2)
	assert_eq(int(life.charges_last_day["ktx"]), 1)


func test_old_save_without_life() -> void:
	var copy: GameState = GameStateScript.new()
	copy.from_dict({"stats": {}, "clock": {"day": 3, "slot": 1}, "flags": {}})
	assert_false(copy.life.initialized, "save cũ → LifeState mới, chưa khởi tạo")
