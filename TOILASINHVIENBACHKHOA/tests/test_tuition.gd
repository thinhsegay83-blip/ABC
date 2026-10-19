extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")
const TuitionScript: GDScript = preload("res://scripts/life/tuition.gd")

var fx: Object
var config: EconomyConfig


func before_each() -> void:
	fx = Fixture.new("hard")
	config = fx.sim.catalog.economy


func _goto_day(day: int) -> void:
	fx.state.stats.set_stat(PlayerStats.Stat.SANITY, 100)
	fx.state.stats.set_stat(PlayerStats.Stat.STAMINA, 100)
	while fx.state.clock.day < day:
		fx.state.stats.set_stat(PlayerStats.Stat.HUNGER, 100)
		fx.state.stats.set_stat(PlayerStats.Stat.STAMINA, 100)
		fx.pass_slots(1)


func test_pay_before_deadline() -> void:
	fx.state.stats.set_money(17000000)
	var result: Dictionary = fx.sim.pay_tuition()
	assert_true(result["ok"])
	assert_eq(fx.state.stats.get_money(), 1000000)
	assert_eq(fx.state.flags.get_flag("da_dong_hoc_phi"), 1)
	assert_false(fx.sim.pay_tuition()["ok"], "không đóng 2 lần")


func test_not_enough() -> void:
	assert_false(fx.sim.pay_tuition()["ok"])  # Khó: 14 triệu − 300k KTX


func test_day14_still_on_time_day15_late() -> void:
	_goto_day(14)
	assert_eq(fx.state.flags.get_flag("hoc_phi_tre_han"), 0, "ngày 14 vẫn trong hạn")
	var sanity: int = fx.stat(PlayerStats.Stat.SANITY)
	_goto_day(15)
	assert_eq(fx.state.flags.get_flag("hoc_phi_tre_han"), 1)
	assert_eq(TuitionScript.amount_due(fx.state, config), 16500000)


func test_late_sanity_penalty_once() -> void:
	_goto_day(14)
	fx.state.stats.set_stat(PlayerStats.Stat.SANITY, 80)
	fx.pass_slots(4)  # sang ngày 15
	assert_eq(fx.state.clock.day, 15)
	assert_eq(fx.stat(PlayerStats.Stat.SANITY), 70)
	fx.sim.handle_new_day(15)
	assert_eq(fx.stat(PlayerStats.Stat.SANITY), 70, "không xử lý 2 lần cùng ngày")


func test_pay_during_extension() -> void:
	_goto_day(16)
	fx.state.stats.set_money(16500000)
	assert_true(fx.sim.pay_tuition()["ok"])
	assert_eq(fx.state.stats.get_money(), 0)


func test_overdue_only_warns() -> void:
	_goto_day(29)
	assert_eq(fx.state.flags.get_flag("hoc_phi_qua_han"), 1)
	assert_eq(fx.state.flags.get_flag("da_dong_hoc_phi"), 0)


func test_reminder_days() -> void:
	_goto_day(8)
	var found: bool = false
	for text: String in fx.messages:
		if text.begins_with("Còn 6 ngày tới hạn học phí"):
			found = true
	assert_true(found, "nhắc đầu ngày 8: còn 6 ngày")
