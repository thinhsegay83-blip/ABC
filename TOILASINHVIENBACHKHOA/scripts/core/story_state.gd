class_name StoryState
extends RefCounted
## Trạng thái cốt truyện (bước 5), lưu trong save dưới khóa "story".

## event_id -> ngày kích gần nhất
var events_fired: Dictionary = {}
## quest_id -> {state: int (0 chưa nhận, 1 đang làm, 2 xong, 3 thất bại), step: int, started_day: int}
var quests: Dictionary = {}
## [{id, sender, text, day, slot, read}]
var messages: Array[Dictionary] = []
## NPC đã gặp (hiện trong danh bạ).
var known_npcs: Array[String] = []
## Cuộc gọi đến đang chờ nghe: contact_id.
var pending_calls: Array[String] = []
var _next_message_id: int = 1


func add_message(sender: String, text: String, day: int, slot: int) -> Dictionary:
	var message: Dictionary = {
		"id": _next_message_id, "sender": sender, "text": text,
		"day": day, "slot": slot, "read": false,
	}
	_next_message_id += 1
	messages.append(message)
	return message


func unread_count(sender: String = "") -> int:
	var count: int = 0
	for message: Dictionary in messages:
		if not message["read"] and (sender.is_empty() or message["sender"] == sender):
			count += 1
	return count


func mark_read(sender: String) -> void:
	for message: Dictionary in messages:
		if message["sender"] == sender:
			message["read"] = true


func meet(npc_id: String) -> bool:
	if known_npcs.has(npc_id):
		return false
	known_npcs.append(npc_id)
	return true


func quest_state(quest_id: String) -> int:
	return int((quests.get(quest_id, {}) as Dictionary).get("state", 0))


func to_dict() -> Dictionary:
	return {
		"events_fired": events_fired.duplicate(),
		"quests": quests.duplicate(true),
		"messages": messages.duplicate(true),
		"known_npcs": known_npcs.duplicate(),
		"pending_calls": pending_calls.duplicate(),
		"next_message_id": _next_message_id,
	}


func from_dict(data: Dictionary) -> void:
	events_fired.clear()
	var fired: Variant = data.get("events_fired", {})
	if fired is Dictionary:
		for key: Variant in fired.keys():
			events_fired[str(key)] = int(fired[key])
	quests.clear()
	var quest_data: Variant = data.get("quests", {})
	if quest_data is Dictionary:
		for key: Variant in quest_data.keys():
			var entry: Variant = quest_data[key]
			if entry is Dictionary:
				quests[str(key)] = {
					"state": int(entry.get("state", 0)),
					"step": int(entry.get("step", 0)),
					"started_day": int(entry.get("started_day", 0)),
				}
	messages.clear()
	var message_data: Variant = data.get("messages", [])
	if message_data is Array:
		for entry: Variant in message_data:
			if entry is Dictionary:
				messages.append({
					"id": int(entry.get("id", 0)),
					"sender": str(entry.get("sender", "")),
					"text": str(entry.get("text", "")),
					"day": int(entry.get("day", 1)),
					"slot": int(entry.get("slot", 0)),
					"read": bool(entry.get("read", false)),
				})
	known_npcs.clear()
	var known: Variant = data.get("known_npcs", [])
	if known is Array:
		for value: Variant in known:
			known_npcs.append(str(value))
	pending_calls.clear()
	var calls: Variant = data.get("pending_calls", [])
	if calls is Array:
		for value: Variant in calls:
			pending_calls.append(str(value))
	_next_message_id = int(data.get("next_message_id", messages.size() + 1))
