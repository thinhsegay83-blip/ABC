extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")

var fx: Object


func before_each() -> void:
	fx = Fixture.new("hard")


func test_blocked_before_week3_or_without_job() -> void:
	fx.state.flags.set_flag("nhan_viec_to_roi", 1)
	assert_false(fx.sim.perform_action("phat_to_roi")["ok"], "tuần 1")
	fx.state.clock.set_time(15, 0)
	fx.state.flags.set_flag("nhan_viec_to_roi", 0)
	assert_false(fx.sim.perform_action("phat_to_roi")["ok"], "chưa nhận việc")
	assert_eq(fx.sim.get_place_actions("lecture_hall").filter(
		func(e: Dictionary) -> bool: return (e["action"] as ActionData).id == "phat_to_roi").size(), 0,
		"ẩn khỏi menu khi chưa nhận việc")


func test_wage_and_involvement() -> void:
	fx.state.clock.set_time(15, 0)
	fx.state.flags.set_flag("nhan_viec_to_roi", 1)
	var money: int = fx.state.stats.get_money()
	assert_true(fx.sim.perform_action("phat_to_roi")["ok"])
	assert_eq(fx.state.stats.get_money() - money, 350000)
	assert_eq(fx.state.flags.get_flag("dinh_lieu_k"), 10)
	assert_true(fx.sim.perform_action("phat_to_roi")["ok"])
	assert_false(fx.sim.perform_action("phat_to_roi")["ok"], "tính vào giới hạn 2 ca/ngày")


func test_extreme_wage_and_clamp() -> void:
	var hard_fx: Object = Fixture.new("extreme")
	hard_fx.state.clock.set_time(15, 0)
	hard_fx.state.flags.set_flag("nhan_viec_to_roi", 1)
	hard_fx.state.flags.set_flag("dinh_lieu_k", 95)
	var money: int = hard_fx.state.stats.get_money()
	hard_fx.sim.perform_action("phat_to_roi")
	assert_eq(hard_fx.state.stats.get_money() - money, 315000)
	assert_eq(hard_fx.state.flags.get_flag("dinh_lieu_k"), 100, "kẹp ≤ 100")


func test_band() -> void:
	assert_eq(StoryVars.k_involvement_band(29), "thấp")
	assert_eq(StoryVars.k_involvement_band(30), "vừa")
	assert_eq(StoryVars.k_involvement_band(60), "cao")
