extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")


func test_join_charges_once_and_registers() -> void:
	var fx: Object = Fixture.new("hard")
	var money: int = fx.state.stats.get_money()
	assert_true(RoomFund.join(fx.state, fx.sim.catalog.economy, fx.sim.charges))
	assert_eq(fx.state.stats.get_money(), money - 200000)
	assert_eq(fx.state.flags.get_flag("quy_phong"), 800000, "4 người × 200.000")
	assert_false(RoomFund.join(fx.state, fx.sim.catalog.economy, fx.sim.charges), "idempotent")
	assert_eq(fx.state.stats.get_money(), money - 200000)
	var entry: Dictionary = {}
	for e: Dictionary in fx.sim.charges.entries:
		if e["id"] == "quy_phong":
			entry = e
	assert_eq(int(entry["first_day"]), 29)
	fx.state.life.charges_last_day.clear()
	fx.sim.charges.process_day(fx.state, 29)
	assert_eq(fx.state.flags.get_flag("quy_phong"), 1600000)
	fx.state.flags.set_flag("da_gop_quy", 0)
	var before: int = fx.state.stats.get_money()
	fx.sim.charges.process_day(fx.state, 57)
	assert_eq(fx.state.stats.get_money(), before - 300000, "tắt cờ → chỉ còn tiền KTX")


func test_register_after_load() -> void:
	var fx: Object = Fixture.new("hard")
	RoomFund.join(fx.state, fx.sim.catalog.economy, fx.sim.charges)
	fx.sim.bind(fx.state)  # như tải game: charges dựng lại
	var ids: Array = fx.sim.charges.entries.map(func(e: Dictionary) -> String: return str(e["id"]))
	assert_true(ids.has("quy_phong"))
