extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")


func test_ktx_day1_and_day29() -> void:
	var fx: Object = Fixture.new("hard")
	assert_eq(fx.state.stats.get_money(), 14000000 - 300000, "thu KTX ngày 1")
	assert_true(fx.ledger_has("Tiền KTX tháng"))
	var charges: RecurringCharges = fx.sim.charges
	var entry: Dictionary = charges.entries[0]
	assert_true(charges.is_due(entry, 29))
	assert_false(charges.is_due(entry, 28))
	assert_eq(charges.next_due_day(entry, 2), 29)


func test_allows_negative_and_condition() -> void:
	var fx: Object = Fixture.new("hard")
	fx.state.stats.set_money(100000)
	var charges: RecurringCharges = fx.sim.charges
	charges.register({
		"id": "quy_phong", "label": "Quỹ phòng", "amount": 200000,
		"period_days": 28, "first_day": 1, "condition_flag": "da_gop_quy",
	})
	fx.state.life.charges_last_day.clear()
	charges.process_day(fx.state, 29)
	assert_eq(fx.state.stats.get_money(), -200000, "KTX trừ cả khi âm; quỹ chưa góp thì không thu")
	fx.state.flags.set_flag("da_gop_quy", 1)
	charges.process_day(fx.state, 57)
	assert_eq(fx.state.stats.get_money(), -700000)
