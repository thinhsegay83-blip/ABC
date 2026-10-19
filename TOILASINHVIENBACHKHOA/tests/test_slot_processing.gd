extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")


func test_skipping_class_marks_absent() -> void:
	var fx: Object = Fixture.new("hard")
	var at: Vector2i = fx.first_class_from(2)
	fx.walk_to(at.x, at.y)
	var subject: String = fx.sim.class_now()
	fx.pass_slots(1)
	assert_eq(int(fx.state.life.academics[subject]["absent"]), 1)


func test_jump_does_not_mark_absent() -> void:
	var fx: Object = Fixture.new("hard")
	fx.state.clock.set_time(20, GameClock.Slot.MORNING)
	var total_absent: int = 0
	for subject: Variant in fx.state.life.academics.keys():
		total_absent += int(fx.state.life.academics[subject]["absent"])
	assert_eq(total_absent, 0)
