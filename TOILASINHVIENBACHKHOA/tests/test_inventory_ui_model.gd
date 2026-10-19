extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")

var fx: Object


func before_each() -> void:
	fx = Fixture.new("hard")


func test_carry_then_use() -> void:
	fx.state.stats.set_stat(PlayerStats.Stat.HUNGER, 30)
	assert_true(fx.sim.buy_item("may_ban_nuoc", "mi_goi", true)["ok"])
	assert_eq(fx.stat(PlayerStats.Stat.HUNGER), 30, "mang về thì chưa ăn")
	assert_eq(fx.state.life.inventory.count("mi_goi"), 1)
	assert_true(fx.sim.use_item("mi_goi")["ok"])
	assert_eq(fx.stat(PlayerStats.Stat.HUNGER), 42)
	assert_eq(fx.state.life.inventory.count("mi_goi"), 0)


func test_non_carry_eaten_now() -> void:
	fx.state.stats.set_stat(PlayerStats.Stat.HUNGER, 30)
	fx.sim.buy_item("quay_quan", "com_tam", true)
	assert_eq(fx.stat(PlayerStats.Stat.HUNGER), 55, "cơm tấm không mang về được")


func test_story_item_not_usable() -> void:
	fx.state.life.inventory.add("xap_to_roi")
	assert_false(fx.sim.use_item("xap_to_roi")["ok"])
	assert_eq(fx.state.life.inventory.count("xap_to_roi"), 1)
