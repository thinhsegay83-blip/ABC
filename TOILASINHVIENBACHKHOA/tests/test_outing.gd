extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")

var fx: Object


func before_each() -> void:
	fx = Fixture.new("hard")
	fx.walk_to(1, GameClock.Slot.EVENING)
	fx.state.stats.set_stat(PlayerStats.Stat.SANITY, 50)


func test_outing() -> void:
	var money: int = fx.state.stats.get_money()
	var result: Dictionary = fx.sim.perform_action("di_choi", {"npc": "minh"})
	assert_true(result["ok"], str(result))
	assert_eq(fx.state.stats.get_money(), money - 50000)
	assert_eq(fx.stat(PlayerStats.Stat.SANITY), 65)
	assert_eq(fx.state.stats.get_relationship("minh"), 5)


func test_once_per_day_per_npc_and_evening_only() -> void:
	fx.sim.perform_action("di_choi", {"npc": "minh"})
	fx.walk_to(2, GameClock.Slot.MORNING)
	assert_false(fx.sim.perform_action("di_choi", {"npc": "minh"})["ok"], "chỉ buổi Tối")
	fx.walk_to(2, GameClock.Slot.EVENING)
	assert_true(fx.sim.perform_action("di_choi", {"npc": "minh"})["ok"], "ngày mới đi lại được")
	fx.state.clock.set_time(2, GameClock.Slot.EVENING)
	assert_false(fx.sim.perform_action("di_choi", {"npc": "minh"})["ok"], "lần 2 cùng ngày bị chặn")


func test_needs_money() -> void:
	fx.state.stats.set_money(10000)
	assert_false(fx.sim.perform_action("di_choi", {"npc": "minh"})["ok"])
