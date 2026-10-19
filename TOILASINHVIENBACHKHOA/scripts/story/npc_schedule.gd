class_name NpcSchedule
extends RefCounted
## Tính NPC đang ở đâu (E2). Logic thuần.


## {} nếu NPC không xuất hiện; ngược lại {place, anchor, behavior, entry_index}.
static func resolve(npc: NpcData, state: GameState) -> Dictionary:
	var day: int = state.clock.day
	var slot: int = state.clock.slot
	var weekday: int = state.clock.get_weekday()
	for i in npc.schedule.size():
		var entry: Dictionary = npc.schedule[i]
		if day < int(entry.get("day_from", 1)):
			continue
		var day_to: int = int(entry.get("day_to", 0))
		if day_to > 0 and day > day_to:
			continue
		var weekdays: Array = entry.get("weekdays", [])
		if not weekdays.is_empty() and not weekdays.has(weekday):
			continue
		var slots: Array = entry.get("slots", [])
		if not slots.is_empty() and not slots.has(slot):
			continue
		var condition: String = str(entry.get("condition", ""))
		if not condition.is_empty() and not DialogueCondition.evaluate(condition, state):
			continue
		var place: String = str(entry.get("place", ""))
		if place.is_empty():
			return {}  # mục khớp nói rõ "vắng mặt"
		return {
			"place": place,
			"anchor": str(entry.get("anchor", "")),
			"behavior": str(entry.get("behavior", "stand")),
			"entry_index": i,
		}
	return {}


## Giá trị trạng thái NPC (0/không có → 1).
static func state_value(npc: NpcData, state: GameState) -> int:
	if npc.state_flag.is_empty():
		return 1
	return maxi(1, state.flags.get_flag(npc.state_flag, 1))
