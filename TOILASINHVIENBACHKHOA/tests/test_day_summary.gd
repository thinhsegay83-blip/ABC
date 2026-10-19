extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")


func test_summary_of_day_one() -> void:
	var fx: Object = Fixture.new("hard")
	fx.state.flags.set_flag("lam_them_quan", 1)
	fx.sim.perform_action("lam_quan_com")  # Sáng → +120.000
	fx.sim.buy_item("quay_quan", "com_tam")  # −30.000
	fx.walk_to(1, GameClock.Slot.NIGHT)
	fx.pass_slots(1)  # sang ngày 2
	assert_eq(fx.summaries.size(), 1)
	var s: Dictionary = fx.summaries[0]
	assert_eq(int(s["day"]), 1)
	assert_eq(s["weekday_name"], "Thứ Hai")
	assert_eq(int(s["income_total"]), 120000)
	assert_eq(int(s["expense_total"]), 300000 + 30000, "KTX + cơm")
	assert_eq(int(s["money_after"]) - int(s["money_before"]), 120000 - 330000)
	assert_eq((s["stats"] as Array).size(), 4)
	assert_true((s["upcoming"] as Array).size() >= 2)
	assert_eq(fx.state.life.ledger_today.size(), 0, "sổ ngày mới đã xóa")
