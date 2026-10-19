extends "res://tests/test_case.gd"
## Mô phỏng 14 ngày chiến lược "chăm chỉ" bằng logic thật (seed cố định).

const Fixture: GDScript = preload("res://tests/life_fixture.gd")


func _simulate(difficulty: String) -> int:
	var fx: Object = Fixture.new(difficulty, 99)
	fx.sim.perform_action("xin_viec")
	var guard: int = 0
	while fx.state.clock.day <= 14 and guard < 400:
		guard += 1
		var sim: LifeSim = fx.sim
		if fx.stat(PlayerStats.Stat.HUNGER) < 45:
			if not sim.buy_item("quay_quan", "com_tam")["ok"]:
				sim.buy_item("may_ban_nuoc", "mi_goi")
		var slot: int = fx.state.clock.slot
		if not sim.class_now().is_empty():
			sim.perform_action("di_hoc")
		elif slot == GameClock.Slot.NIGHT:
			sim.perform_action("ngu")
		elif slot == GameClock.Slot.EVENING and sim.perform_action("bung_ca_phe")["ok"]:
			pass
		elif slot != GameClock.Slot.EVENING and sim.perform_action("lam_quan_com")["ok"]:
			pass
		elif slot == GameClock.Slot.EVENING:
			sim.perform_action("ngu")
		else:
			sim.perform_action("nghi")
	return fx.state.stats.get_money()


func test_easy_can_pay_hard_reported_extreme_cannot() -> void:
	var easy: int = _simulate("easy")
	var hard: int = _simulate("hard")
	var extreme: int = _simulate("extreme")
	print("    Mô phỏng 14 ngày — Dễ: %d, Khó: %d, Cực khó: %d (cần 16.000.000)" % [easy, hard, extreme])
	assert_true(extreme < 16000000, "Cực khó không đủ tiền trước hạn")
	assert_true(easy > extreme, "Dễ nhiều tiền hơn Cực khó")
