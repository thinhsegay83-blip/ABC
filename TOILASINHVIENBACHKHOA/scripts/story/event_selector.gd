class_name EventSelector
extends RefCounted
## Chọn sự kiện (storylet) theo metadata của node hội thoại (bước 5). Logic thuần.
## @trigger <loại> [đối số], @when <đk> (nhiều dòng = and), @priority <số>, @once, @daily.

const TRIGGERS: Array[String] = [
	"day_start", "slot_start", "enter_area", "interact", "sleep", "phone_call",
]


## candidates: node (Dictionary) theo thứ tự file/dòng. Trả danh sách node_id đã sắp ưu tiên.
static func select(
	candidates: Array[Dictionary], trigger: String, arg: String, state: GameState, story: StoryState
) -> Array[String]:
	var matched: Array[Dictionary] = []
	for i in candidates.size():
		var node: Dictionary = candidates[i]
		if not matches(node, trigger, arg, state, story):
			continue
		matched.append({"id": node["id"], "priority": priority_of(node), "order": i})
	matched.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["priority"]) != int(b["priority"]):
			return int(a["priority"]) > int(b["priority"])
		return int(a["order"]) < int(b["order"])
	)
	var result: Array[String] = []
	for entry: Dictionary in matched:
		result.append(str(entry["id"]))
	return result


static func matches(node: Dictionary, trigger: String, arg: String, state: GameState, story: StoryState) -> bool:
	var meta: Dictionary = node["meta"]
	var trigger_ok: bool = false
	for value: Variant in meta.get("trigger", []):
		var parts: PackedStringArray = str(value).split(" ", false)
		if parts.is_empty() or parts[0] != trigger:
			continue
		if parts.size() < 2 or parts[1] == arg:
			trigger_ok = true
			break
	if not trigger_ok:
		return false
	return conditions_hold(node, state, story)


## @once / @daily / @when (không xét trigger) — dùng để kiểm tra lại lúc thật sự chạy.
static func conditions_hold(node: Dictionary, state: GameState, story: StoryState) -> bool:
	var meta: Dictionary = node["meta"]
	var node_id: String = str(node["id"])
	if meta.has("once") and story.events_fired.has(node_id):
		return false
	if meta.has("daily") and int(story.events_fired.get(node_id, -1)) == state.clock.day:
		return false
	for condition: Variant in meta.get("when", []):
		if not DialogueCondition.evaluate(str(condition), state):
			return false
	return true


static func priority_of(node: Dictionary) -> int:
	var values: Array = (node["meta"] as Dictionary).get("priority", [])
	return str(values[0]).to_int() if not values.is_empty() else 0


## Lỗi metadata của một node ("" = hợp lệ). known_ids: {"area": [...], "npc": [...], "contact": [...]}
static func validate(node: Dictionary, known_ids: Dictionary) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var meta: Dictionary = node["meta"]
	var where: String = "%s:%d (%s)" % [node["file"], int(node["line"]), node["id"]]
	for value: Variant in meta.get("trigger", []):
		var parts: PackedStringArray = str(value).split(" ", false)
		if parts.is_empty() or not TRIGGERS.has(parts[0]):
			errors.append("%s: trigger lạ '%s'" % [where, value])
			continue
		var needs_arg: Dictionary = {"enter_area": "area", "interact": "npc", "phone_call": "contact"}
		if needs_arg.has(parts[0]):
			if parts.size() < 2:
				errors.append("%s: '%s' thiếu đối số" % [where, parts[0]])
			elif known_ids.has(needs_arg[parts[0]]) and not (known_ids[needs_arg[parts[0]]] as Array).has(parts[1]):
				errors.append("%s: id lạ '%s' trong '%s'" % [where, parts[1], value])
	for condition: Variant in meta.get("when", []):
		var problem: String = DialogueCondition.validate(str(condition))
		if not problem.is_empty():
			errors.append("%s: @when %s" % [where, problem])
	return errors
