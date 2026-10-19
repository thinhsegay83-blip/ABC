extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")

var fx: Object


func before_each() -> void:
	fx = Fixture.new("hard")
	fx.state.flags.set_flag("lam_them_quan", 1)


func test_faint_when_stamina_zero() -> void:
	fx.state.stats.set_stat(PlayerStats.Stat.STAMINA, 5)
	var sanity: int = fx.stat(PlayerStats.Stat.SANITY)
	var start_key: int = fx.state.clock.day * 4 + fx.state.clock.slot
	fx.sim.perform_action("lam_quan_com")
	assert_eq(fx.stat(PlayerStats.Stat.STAMINA), 30)
	assert_eq(fx.stat(PlayerStats.Stat.SANITY), sanity - 5)
	assert_eq(fx.state.clock.day * 4 + fx.state.clock.slot, start_key + 2, "ca làm + 1 khung ngất")


func test_hungry_extra_stamina_loss() -> void:
	fx.state.stats.set_stat(PlayerStats.Stat.HUNGER, 15)
	fx.state.stats.set_stat(PlayerStats.Stat.STAMINA, 80)
	fx.pass_slots(1)  # tụt 5 theo chế độ + 3 vì đói lả
	assert_eq(fx.stat(PlayerStats.Stat.STAMINA), 72)
	fx.state.stats.set_stat(PlayerStats.Stat.HUNGER, 0)
	fx.pass_slots(1)  # 5 + 6 vì đói = 0
	assert_eq(fx.stat(PlayerStats.Stat.STAMINA), 61)


func test_sanity_zero_rest() -> void:
	fx.state.stats.set_stat(PlayerStats.Stat.SANITY, 0)
	var day: int = fx.state.clock.day
	assert_true(fx.sim.check_collapse())
	assert_eq(fx.state.clock.day, day + 2)
	assert_eq(fx.state.clock.slot, GameClock.Slot.MORNING)
	assert_eq(fx.stat(PlayerStats.Stat.SANITY), 30)
	assert_eq(fx.stat(PlayerStats.Stat.STAMINA), 60)


func test_no_double_faint_same_slot() -> void:
	fx.state.stats.set_stat(PlayerStats.Stat.STAMINA, 0)
	assert_true(fx.sim.check_collapse())
	fx.state.stats.set_stat(PlayerStats.Stat.STAMINA, 0)
	assert_false(fx.sim.check_collapse(), "không ngất 2 lần trong 1 khung")
