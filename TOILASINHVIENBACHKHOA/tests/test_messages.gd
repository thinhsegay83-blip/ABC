extends "res://tests/test_case.gd"

const StoryStateScript: GDScript = preload("res://scripts/core/story_state.gd")


func test_messages_round_trip() -> void:
	var story: StoryState = StoryStateScript.new()
	story.add_message("me", "Ăn cơm chưa?", 2, 0)
	story.add_message("nhom_lop", "Mai có tiết.", 2, 1)
	assert_eq(story.unread_count(), 2)
	story.mark_read("me")
	assert_eq(story.unread_count(), 1)
	assert_eq(story.unread_count("me"), 0)
	var copy: StoryState = StoryStateScript.new()
	copy.from_dict(json_round_trip(story.to_dict()))
	assert_eq(copy.unread_count(), 1)
	assert_eq(int(copy.messages[1]["day"]), 2)
	assert_eq(copy.add_message("me", "x", 3, 0)["id"], 3, "id tiếp tục sau khi tải")
