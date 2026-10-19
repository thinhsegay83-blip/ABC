extends "res://tests/test_case.gd"


func test_bands() -> void:
	assert_eq(StoryVars.relation_band(19), "Người lạ")
	assert_eq(StoryVars.relation_band(20), "Quen")
	assert_eq(StoryVars.relation_band(39), "Quen")
	assert_eq(StoryVars.relation_band(40), "Bạn")
	assert_eq(StoryVars.relation_band(59), "Bạn")
	assert_eq(StoryVars.relation_band(60), "Thân")
	assert_eq(StoryVars.relation_band(79), "Thân")
	assert_eq(StoryVars.relation_band(80), "Rất thân")
