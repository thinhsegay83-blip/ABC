extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")
const Sched: GDScript = preload("res://scripts/story/npc_schedule.gd")

var fx: Object


func before_each() -> void:
	fx = Fixture.new("hard")


func _npc(entries: Array[Dictionary]) -> NpcData:
	var npc: NpcData = NpcData.new()
	npc.id = "x"
	npc.schedule = entries
	return npc


func test_first_match_wins_and_filters() -> void:
	var npc: NpcData = _npc([
		{"slots": [0], "place": "library", "weekdays": [1]},
		{"slots": [0], "place": "food_shop"},
		{"place": "ktx_room", "day_from": 5, "day_to": 6},
	])
	assert_eq(Sched.resolve(npc, fx.state)["place"], "food_shop", "ngày 1 = Thứ Hai, không khớp mục 1")
	fx.state.clock.set_time(2, GameClock.Slot.MORNING)
	assert_eq(Sched.resolve(npc, fx.state)["place"], "library")
	fx.state.clock.set_time(5, GameClock.Slot.EVENING)
	assert_eq(Sched.resolve(npc, fx.state)["place"], "ktx_room")
	fx.state.clock.set_time(7, GameClock.Slot.EVENING)
	assert_eq(Sched.resolve(npc, fx.state), {}, "ngoài day_to → không có")


func test_condition_and_class_now() -> void:
	var npc: NpcData = _npc([
		{"place": "lecture_hall", "condition": "class_now == 1"},
		{"place": "ktx_room", "condition": "flag.x == 1"},
	])
	assert_eq(Sched.resolve(npc, fx.state), {})
	fx.state.flags.set_flag("x", 1)
	assert_eq(Sched.resolve(npc, fx.state)["place"], "ktx_room")
	var at: Vector2i = fx.first_class_from(2)
	fx.state.clock.set_time(at.x, at.y)
	assert_eq(Sched.resolve(npc, fx.state)["place"], "lecture_hall")
