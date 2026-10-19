extends "res://tests/test_case.gd"
## Mọi .dlg trong content/dialogue/ phải sạch lỗi. Cần autoload (lệnh do các bước đăng ký).

const ALLOWED_SPEAKERS: Array[String] = ["player", "narrator"]


func test_content_clean() -> void:
	var dialogue: Node = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("DialogueSystem")
	assert_not_null(dialogue, "cần autoload DialogueSystem")
	if dialogue == null:
		return
	var library: DialogueLibrary = DialogueLibrary.load_dir(
		DialogueLibrary.DEFAULT_DIR, dialogue.command_names()
	)
	assert_eq(library.get_errors().size(), 0, "\n".join(library.get_errors()))
	var registry: StoryFlagRegistry = dialogue.flag_registry
	var flag_regex: RegEx = RegEx.create_from_string("flag\\.([a-z0-9_]+)")
	for node_id: String in library.content.order:
		var node: Dictionary = library.content.nodes[node_id]
		for entry: Dictionary in node["entries"]:
			match str(entry["type"]):
				"line":
					var speaker: String = entry["speaker"]
					assert_true(ALLOWED_SPEAKERS.has(speaker) or dialogue.get_character(speaker) != null,
							"%s: người nói lạ '%s'" % [node_id, speaker])
					_check_flags(flag_regex, str(entry["cond"]), registry, node_id)
				"choices":
					for option: Dictionary in entry["options"]:
						assert_true(library.has_dialogue(str(option["target"])),
								"%s: lựa chọn trỏ tới node không có '%s'" % [node_id, option["target"]])
						_check_flags(flag_regex, str(option["cond"]) + " " + str(option["need"]), registry, node_id)
				"cmd":
					var args: PackedStringArray = entry["args"]
					if entry["name"] == "goto":
						assert_true(library.has_dialogue(args[0]), "%s: goto node không có '%s'" % [node_id, args[0]])
					if entry["name"] in ["set", "add"]:
						assert_true(registry.has_flag_name(args[0]), "%s: cờ chưa có trong danh mục '%s'" % [node_id, args[0]])
					_check_flags(flag_regex, str(entry["cond"]), registry, node_id)


func _check_flags(regex: RegEx, text: String, registry: StoryFlagRegistry, node_id: String) -> void:
	for m: RegExMatch in regex.search_all(text):
		assert_true(registry.has_flag_name(m.get_string(1)),
				"%s: cờ chưa có trong danh mục '%s'" % [node_id, m.get_string(1)])
