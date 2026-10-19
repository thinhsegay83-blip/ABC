extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")

var fx: Object
var nodes: Array[Dictionary]


func before_each() -> void:
	fx = Fixture.new("hard")
	var dialogue: Node = (Engine.get_main_loop() as SceneTree).root.get_node("DialogueSystem")
	nodes = DialogueLibrary.load_dir(DialogueLibrary.DEFAULT_DIR, dialogue.command_names()).triggered_nodes()
	fx.state.flags.set_flag("minh_trang_thai", 2)


func _sleep_events() -> Array[String]:
	return EventSelector.select(nodes, "sleep", "", fx.state, fx.state.story)


func test_day_18_matches() -> void:
	fx.state.clock.set_time(18, GameClock.Slot.NIGHT)
	assert_eq(fx.state.clock.get_weekday(), 3, "ngày 18 là Thứ Năm")
	assert_true(_sleep_events().has("t3_dem_minh_ra_ngoai"))


func test_not_day_17_or_week_4() -> void:
	fx.state.clock.set_time(17, GameClock.Slot.NIGHT)
	assert_false(_sleep_events().has("t3_dem_minh_ra_ngoai"))
	fx.state.clock.set_time(22, GameClock.Slot.NIGHT)
	assert_false(_sleep_events().has("t3_dem_minh_ra_ngoai"))


func test_later_in_week_and_once() -> void:
	fx.state.clock.set_time(20, GameClock.Slot.EVENING)
	assert_true(_sleep_events().has("t3_dem_minh_ra_ngoai"), "đêm 18 không ngủ → khớp ngày 19–21")
	fx.state.story.events_fired["t3_dem_minh_ra_ngoai"] = 20
	fx.state.clock.set_time(21, GameClock.Slot.NIGHT)
	assert_false(_sleep_events().has("t3_dem_minh_ra_ngoai"), "@once")


func test_minh_state_required() -> void:
	fx.state.flags.set_flag("minh_trang_thai", 1)
	fx.state.clock.set_time(18, GameClock.Slot.NIGHT)
	assert_false(_sleep_events().has("t3_dem_minh_ra_ngoai"))


func test_interrupted_sleep_resumes() -> void:
	fx.state.clock.set_time(18, GameClock.Slot.EVENING)
	fx.sim.sleep_interrupters.append(func(_c: Dictionary) -> bool: return true)
	var result: Dictionary = fx.sim.perform_action("ngu")
	assert_true(result.get("interrupted", false))
	assert_eq(fx.state.clock.slot, GameClock.Slot.NIGHT, "dừng ở khung Đêm")
	assert_true(fx.sim.is_sleep_interrupted())
	fx.state.stats.set_stat(PlayerStats.Stat.STAMINA, 20)
	fx.state.stats.set_stat(PlayerStats.Stat.HUNGER, 100)
	fx.sim.complete_sleep(0.7)
	assert_eq(fx.state.clock.day, 19)
	assert_eq(fx.state.clock.slot, GameClock.Slot.MORNING)
	# 20 − 5 (khung Đêm→Sáng) + roundi((60 + 15 ngủ từ Tối) × 0,7) = 15 + 53 = 68
	assert_eq(fx.stat(PlayerStats.Stat.STAMINA), 68)
	assert_false(fx.sim.is_sleep_interrupted())
