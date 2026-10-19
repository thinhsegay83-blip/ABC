extends "res://tests/test_case.gd"
## Metadata sự kiện trong content/dialogue/ + dữ liệu NPC/nhiệm vụ hợp lệ. Cần autoload.


func test_events_and_data_valid() -> void:
	var root: Window = (Engine.get_main_loop() as SceneTree).root
	var dialogue: Node = root.get_node_or_null("DialogueSystem")
	var director: Node = root.get_node_or_null("EventDirector")
	assert_not_null(director, "cần autoload EventDirector")
	if dialogue == null or director == null:
		return
	var library: DialogueLibrary = DialogueLibrary.load_dir(DialogueLibrary.DEFAULT_DIR, dialogue.command_names())
	var contacts: Array = director.CONTACT_NAMES.keys() + Array(director.NPC_IDS)
	var known: Dictionary = {"area": Array(director.AREA_IDS), "npc": Array(director.NPC_IDS), "contact": contacts}
	for node: Dictionary in library.triggered_nodes():
		var errors: PackedStringArray = EventSelector.validate(node, known)
		assert_eq(errors.size(), 0, "\n".join(errors))
	for npc_id: String in director.NPC_IDS:
		var npc: NpcData = director.npcs.get(npc_id, null)
		assert_not_null(npc, "thiếu data/npcs/%s.tres" % npc_id)
		if npc == null:
			continue
		assert_true(library.has_dialogue(npc.default_dialogue), "%s: thiếu hội thoại mặc định '%s'" % [npc_id, npc.default_dialogue])
		assert_not_null(dialogue.get_character(npc.character_id), "%s: thiếu CharacterData" % npc_id)
		for entry: Dictionary in npc.schedule:
			var place: String = str(entry.get("place", ""))
			assert_true(place.is_empty() or director.AREA_IDS.has(place), "%s: nơi lạ '%s'" % [npc_id, place])
			var condition: String = str(entry.get("condition", ""))
			assert_true(condition.is_empty() or DialogueCondition.validate(condition) == "", "%s: %s" % [npc_id, condition])
	assert_eq(director.quests.size(), director.QUEST_IDS.size(), "đủ file nhiệm vụ")
	for quest: QuestData in director.quests:
		if not quest.start_condition.is_empty():
			assert_eq(DialogueCondition.validate(quest.start_condition), "", quest.id)
		for step: Dictionary in quest.steps:
			assert_eq(DialogueCondition.validate(str(step["done_condition"])), "", quest.id)
