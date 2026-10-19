extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")

var fx: Object


func before_each() -> void:
	fx = Fixture.new("hard")


func test_class_blocked_when_no_class() -> void:
	# Ngày 1 chưa có tiết.
	var result: Dictionary = fx.sim.perform_action("di_hoc")
	assert_false(result["ok"])
	assert_eq(result["reason"], "Không có tiết lúc này")


func test_attend_class() -> void:
	var at: Vector2i = fx.first_class_from(2)
	fx.walk_to(at.x, at.y)
	var subject: String = fx.sim.class_now()
	var knowledge: int = fx.stat(PlayerStats.Stat.KNOWLEDGE)
	var result: Dictionary = fx.sim.perform_action("di_hoc")
	assert_true(result["ok"], str(result))
	var rec: Dictionary = fx.state.life.academics[subject]
	assert_eq(int(rec["attended"]), 1)
	assert_eq(int(rec["absent"]), 0, "đã vào học thì không bị đánh vắng")
	assert_eq(fx.stat(PlayerStats.Stat.KNOWLEDGE), knowledge + 2)
	assert_eq(fx.state.clock.day * 4 + fx.state.clock.slot, at.x * 4 + at.y + 1, "tốn 1 khung")


func test_work_requires_job() -> void:
	var result: Dictionary = fx.sim.perform_action("lam_quan_com")
	assert_false(result["ok"])
	assert_eq(result["reason"], "Chưa xin được việc ở quán")


func test_ask_for_job_then_work_and_wage() -> void:
	assert_true(fx.sim.perform_action("xin_viec")["ok"])
	assert_eq(fx.state.flags.get_flag("lam_them_quan"), 1)
	assert_eq(fx.state.clock.slot, GameClock.Slot.MORNING, "xin việc không tốn thời gian")
	var money: int = fx.state.stats.get_money()
	var result: Dictionary = fx.sim.perform_action("lam_quan_com")
	assert_true(result["ok"])
	assert_eq(fx.state.stats.get_money() - money, 120000)
	assert_true(fx.ledger_has("Phụ quán cơm"))


func test_wrong_slot_reason() -> void:
	fx.state.flags.set_flag("lam_them_quan", 1)
	var result: Dictionary = fx.sim.perform_action("bung_ca_phe")  # đang Sáng
	assert_eq(result["reason"], "Quán cà phê chỉ cần người buổi Tối")


func test_max_two_shifts() -> void:
	fx.state.flags.set_flag("lam_them_quan", 1)
	assert_true(fx.sim.perform_action("lam_quan_com")["ok"])
	assert_true(fx.sim.perform_action("lam_quan_com")["ok"])
	var result: Dictionary = fx.sim.perform_action("bung_ca_phe")  # giờ là Tối
	assert_false(result["ok"])
	assert_eq(result["reason"], "Hôm nay bạn đã làm đủ 2 ca")


func test_extreme_wage_multiplier_and_tip_range() -> void:
	var hard_fx: Object = Fixture.new("extreme")
	hard_fx.state.flags.set_flag("lam_them_quan", 1)
	var money: int = hard_fx.state.stats.get_money()
	hard_fx.sim.perform_action("lam_quan_com")
	assert_eq(hard_fx.state.stats.get_money() - money, 108000)
	hard_fx.walk_to(1, GameClock.Slot.EVENING)
	money = hard_fx.state.stats.get_money()
	hard_fx.sim.perform_action("bung_ca_phe")
	var earned: int = hard_fx.state.stats.get_money() - money
	assert_true(earned >= 90000 and earned <= 117000, "tip trong 0–30.000 × 0,9: %d" % earned)
	assert_eq(earned % 1000, 0, "làm tròn 1.000")


func test_hungry_study_halved() -> void:
	fx.state.stats.set_stat(PlayerStats.Stat.HUNGER, 10)
	var subject: String = "vat_ly_1"
	var before: int = int(fx.state.life.academics[subject]["study"])
	fx.sim.perform_action("tu_hoc", {"subject": subject})
	assert_eq(int(fx.state.life.academics[subject]["study"]) - before, 1, "3 × 0,5 → 1")


func test_textbook_boosts_study() -> void:
	fx.state.life.inventory.add("giao_trinh_giai_tich_1")
	var before: int = int(fx.state.life.academics["giai_tich_1"]["study"])
	fx.sim.perform_action("tu_hoc", {"subject": "giai_tich_1"})
	assert_eq(int(fx.state.life.academics["giai_tich_1"]["study"]) - before, 5)


func test_sleep_until_morning() -> void:
	fx.walk_to(1, GameClock.Slot.EVENING)
	fx.state.stats.set_stat(PlayerStats.Stat.STAMINA, 20)
	fx.state.stats.set_stat(PlayerStats.Stat.HUNGER, 100)
	var result: Dictionary = fx.sim.perform_action("ngu")
	assert_true(result["ok"])
	assert_eq(fx.state.clock.day, 2)
	assert_eq(fx.state.clock.slot, GameClock.Slot.MORNING)
	# 20 − 5 × 2 khung + 60 + 15 (ngủ sớm) = 85
	assert_eq(fx.stat(PlayerStats.Stat.STAMINA), 85)
	assert_eq(fx.summaries.size(), 1, "có tổng kết ngày 1")
