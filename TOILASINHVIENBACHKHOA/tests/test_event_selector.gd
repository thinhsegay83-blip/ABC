extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")
const Sel: GDScript = preload("res://scripts/story/event_selector.gd")
const GameStateScript: GDScript = preload("res://scripts/core/game_state.gd")

const TEXT: String = """
== a
@trigger day_start
@when day >= 2
@when flag.x == 1
narrator: a

== b
@trigger day_start
@priority 5
narrator: b

== c
@trigger day_start
@once
narrator: c

== d
@trigger interact minh
@daily
narrator: d

== e
@trigger interact minh
@priority 3
narrator: e

== f
@trigger interact k
narrator: f
"""

var fx: Object
var nodes: Array[Dictionary]


func before_each() -> void:
	fx = Fixture.new("hard")
	nodes = DialogueLibrary.from_text(TEXT).triggered_nodes()


func _select(trigger: String, arg: String = "") -> Array[String]:
	return Sel.select(nodes, trigger, arg, fx.state, fx.state.story)


func test_trigger_and_when() -> void:
	assert_eq(_select("day_start"), ["b", "c"] as Array[String], "a chưa đủ điều kiện; b ưu tiên cao")
	fx.state.flags.set_flag("x", 1)
	fx.state.clock.set_time(2, 0)
	assert_eq(_select("day_start"), ["b", "a", "c"] as Array[String], "cùng ưu tiên → theo thứ tự file")


func test_interact_arg_and_priority() -> void:
	assert_eq(_select("interact", "minh"), ["e", "d"] as Array[String])
	assert_eq(_select("interact", "k"), ["f"] as Array[String])


func test_once_survives_save() -> void:
	fx.state.story.events_fired["c"] = 1
	var copy: GameState = GameStateScript.new()
	copy.from_dict(json_round_trip(fx.state.to_dict()))
	assert_false(Sel.select(nodes, "day_start", "", copy, copy.story).has("c"))


func test_daily() -> void:
	fx.state.story.events_fired["d"] = 1
	assert_false(_select("interact", "minh").has("d"))
	fx.state.clock.set_time(2, 0)
	assert_true(_select("interact", "minh").has("d"))


func test_validate() -> void:
	var bad: Array[Dictionary] = DialogueLibrary.from_text("== z\n@trigger bay_lung\n@trigger interact khong_co\nnarrator: x\n").triggered_nodes()
	var errors: PackedStringArray = Sel.validate(bad[0], {"npc": ["minh"]})
	assert_eq(errors.size(), 2, str(errors))
