extends "res://tests/test_case.gd"

const GameStateScript: GDScript = preload("res://scripts/core/game_state.gd")


func test_missing_story_defaults() -> void:
	var copy: GameState = GameStateScript.new()
	copy.from_dict({"stats": {}, "clock": {}, "flags": {}})
	assert_eq(copy.story.messages.size(), 0)
	assert_eq(copy.story.known_npcs.size(), 0)


func test_ints_after_json() -> void:
	var state: GameState = GameStateScript.new()
	state.story.events_fired["x"] = 4
	state.story.meet("minh")
	state.story.pending_calls.append("me")
	var copy: GameState = GameStateScript.new()
	copy.from_dict(json_round_trip(state.to_dict()))
	assert_eq(typeof(copy.story.events_fired["x"]), TYPE_INT)
	assert_eq(copy.story.known_npcs, ["minh"] as Array[String])
	assert_eq(copy.story.pending_calls, ["me"] as Array[String])
