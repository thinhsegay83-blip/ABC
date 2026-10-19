extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")

var fx: Object


func before_each() -> void:
	fx = Fixture.new("hard")
	fx.state.stats.set_stat(PlayerStats.Stat.STAMINA, 50)


func test_cafein_up_then_down() -> void:
	assert_true(fx.sim.buy_item("goc_ca_phe", "ca_phe_coc")["ok"])
	assert_eq(fx.stat(PlayerStats.Stat.STAMINA), 70)
	fx.pass_slots(1)  # 70 − 5
	assert_eq(fx.stat(PlayerStats.Stat.STAMINA), 65)
	assert_true(fx.sim.has_effect("cafein"))
	fx.pass_slots(1)  # 65 − 5 − 10 (hết cafein)
	assert_eq(fx.stat(PlayerStats.Stat.STAMINA), 50)
	assert_false(fx.sim.has_effect("cafein"))


func test_rebuy_resets_duration() -> void:
	fx.sim.buy_item("goc_ca_phe", "ca_phe_coc")
	fx.pass_slots(1)
	fx.sim.buy_item("goc_ca_phe", "ca_phe_coc")
	fx.pass_slots(1)
	assert_true(fx.sim.has_effect("cafein"), "uống lại thì đặt lại 2 khung")
	assert_eq(fx.state.life.status_effects.size(), 1, "không cộng dồn")
