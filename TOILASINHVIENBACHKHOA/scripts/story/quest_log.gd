class_name QuestLog
extends RefCounted
## Sổ nhiệm vụ (H2). Logic thuần trên StoryState.quests.

const NOT_STARTED: int = 0
const ACTIVE: int = 1
const DONE: int = 2
const FAILED: int = 3


## Bắt đầu nhiệm vụ. true nếu vừa bắt đầu.
static func start(story: StoryState, quest: QuestData, day: int) -> bool:
	if story.quest_state(quest.id) != NOT_STARTED:
		return false
	story.quests[quest.id] = {"state": ACTIVE, "step": 0, "started_day": day}
	return true


static func complete(story: StoryState, quest_id: String) -> bool:
	if story.quest_state(quest_id) == DONE:
		return false
	var entry: Dictionary = story.quests.get(quest_id, {"step": 0, "started_day": 0})
	entry["state"] = DONE
	story.quests[quest_id] = entry
	return true


static func fail(story: StoryState, quest_id: String) -> bool:
	if story.quest_state(quest_id) != ACTIVE:
		return false
	(story.quests[quest_id] as Dictionary)["state"] = FAILED
	return true


## Tự bắt đầu / tự qua bước / tự hoàn thành theo điều kiện.
## Trả [{kind: "started"/"done", quest: QuestData}] để hiện thông báo.
static func evaluate(story: StoryState, quests: Array[QuestData], state: GameState) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for quest: QuestData in quests:
		var current: int = story.quest_state(quest.id)
		if current == NOT_STARTED and not quest.start_condition.is_empty() \
				and DialogueCondition.evaluate(quest.start_condition, state):
			start(story, quest, state.clock.day)
			events.append({"kind": "started", "quest": quest})
			current = ACTIVE
		if current != ACTIVE:
			continue
		var entry: Dictionary = story.quests[quest.id]
		var step: int = int(entry["step"])
		while step < quest.steps.size():
			var condition: String = str(quest.steps[step].get("done_condition", ""))
			if condition.is_empty() or not DialogueCondition.evaluate(condition, state):
				break
			step += 1
		entry["step"] = step
		if not quest.steps.is_empty() and step >= quest.steps.size():
			entry["state"] = DONE
			events.append({"kind": "done", "quest": quest})
	return events


## Hạn hiện hành của nhiệm vụ (0 = không có).
static func deadline(quest: QuestData, state: GameState) -> int:
	if not quest.deadline_extend_flag.is_empty() and state.flags.get_flag(quest.deadline_extend_flag) == 1:
		return quest.extended_deadline_day
	return quest.deadline_day


## Số ngày còn lại (-1 nếu không có hạn).
static func days_left(quest: QuestData, state: GameState) -> int:
	var due: int = deadline(quest, state)
	return -1 if due <= 0 else due - state.clock.day


static func current_step_text(story: StoryState, quest: QuestData) -> String:
	var step: int = int((story.quests.get(quest.id, {}) as Dictionary).get("step", 0))
	if step < quest.steps.size():
		return str(quest.steps[step].get("text", ""))
	return ""
