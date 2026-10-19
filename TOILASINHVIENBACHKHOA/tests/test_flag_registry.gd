extends "res://tests/test_case.gd"


func test_story_flags_present() -> void:
	var registry: StoryFlagRegistry = load("res://data/story_flags.tres") as StoryFlagRegistry
	assert_not_null(registry)
	if registry == null:
		return
	for flag_name: String in ["ktx_khu", "da_gop_quy", "da_dong_hoc_phi", "nhan_viec_to_roi",
			"canh_bao_minh", "minh_trang_thai", "thoat_cau_thang"]:
		assert_true(registry.has_flag_name(flag_name), flag_name)
