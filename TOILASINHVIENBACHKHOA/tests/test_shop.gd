extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")

var fx: Object


func before_each() -> void:
	fx = Fixture.new("hard")


func test_not_enough_money() -> void:
	fx.state.stats.set_money(10000)
	var result: Dictionary = fx.sim.buy_item("quay_quan", "com_tam")
	assert_false(result["ok"])
	assert_eq(fx.state.stats.get_money(), 10000)
	assert_eq(result["reason"], "Thiếu 20.000 đ")


func test_food_applies_now() -> void:
	fx.state.stats.set_stat(PlayerStats.Stat.HUNGER, 40)
	var money: int = fx.state.stats.get_money()
	assert_true(fx.sim.buy_item("quay_quan", "com_tam")["ok"])
	assert_eq(fx.stat(PlayerStats.Stat.HUNGER), 65)
	assert_eq(fx.state.stats.get_money(), money - 30000)
	assert_true(fx.ledger_has("Cơm tấm"))


func test_textbook_goes_to_inventory() -> void:
	assert_true(fx.sim.buy_item("quay_photo", "giao_trinh_vat_ly_1")["ok"])
	assert_eq(fx.state.life.inventory.count("giao_trinh_vat_ly_1"), 1)


func test_closed_shop() -> void:
	fx.walk_to(1, GameClock.Slot.NIGHT)
	assert_false(fx.sim.buy_item("quay_quan", "banh_mi")["ok"])
	assert_true(fx.sim.buy_item("may_ban_nuoc", "mi_goi")["ok"], "máy bán nước mở cả đêm")
