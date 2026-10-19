extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")
const Sched: GDScript = preload("res://scripts/story/npc_schedule.gd")

var fx: Object
var minh: NpcData


func before_each() -> void:
	fx = Fixture.new("hard")
	minh = load("res://data/npcs/minh.tres") as NpcData
	fx.state.clock.set_time(1, GameClock.Slot.EVENING)


func test_default_state_one() -> void:
	assert_eq(Sched.state_value(minh, fx.state), 1)
	assert_eq(Sched.resolve(minh, fx.state)["place"], "ktx_room")


func test_state_three_faces_wall_at_night() -> void:
	fx.state.flags.set_flag("minh_trang_thai", 3)
	var info: Dictionary = Sched.resolve(minh, fx.state)
	assert_eq(info["place"], "ktx_hallway")
	assert_eq(info["behavior"], "face_wall")
	assert_true(minh.murmurs.size() >= 3)


func test_state_four_absent() -> void:
	fx.state.flags.set_flag("minh_trang_thai", 4)
	assert_eq(Sched.resolve(minh, fx.state), {})
