class_name DialogueRunner
extends RefCounted
## Chạy một hội thoại trên một GameState (logic thuần — UI chỉ nghe signal).

signal line_shown(entry: Dictionary)  ## {speaker, expression, text, line_key}
signal choices_shown(choices: Array)  ## [{text, enabled, reason, index}]
signal event_emitted(event_name: String, args: PackedStringArray)
signal feedback(text: String)  ## thông báo minh bạch: "Sanity −5", "Tiền −200.000 đ"…
signal finished(node_id: String)

const MAX_SILENT_STEPS: int = 1000

var library: DialogueLibrary
var state: GameState
## Lệnh mở rộng: tên → Callable(args: PackedStringArray, state: GameState)
var commands: Dictionary = {}
## Tên hiển thị NPC (cho feedback quan hệ): npc_id → tên.
var npc_names: Dictionary = {}
var errors: PackedStringArray = PackedStringArray()

var _node: Dictionary = {}
var _start_id: String = ""
var _index: int = 0
var _running: bool = false
var _waiting_line: bool = false
var _current_choices: Array[Dictionary] = []


func _init(dialogue_library: DialogueLibrary, game_state: GameState) -> void:
	library = dialogue_library
	state = game_state


func is_running() -> bool:
	return _running


func start(node_id: String) -> bool:
	if _running or not library.has_dialogue(node_id):
		return false
	_start_id = node_id
	_running = true
	_jump(node_id)
	_continue()
	return true


## Sang dòng kế (UI gọi sau khi người chơi bấm tiếp).
func advance() -> void:
	if not _running or not _waiting_line:
		return
	_waiting_line = false
	_continue()


func choose(index: int) -> void:
	if not _running or _current_choices.is_empty():
		return
	for option: Dictionary in _current_choices:
		if int(option["index"]) == index and option["enabled"]:
			_current_choices.clear()
			_jump(str(option["target"]))
			_continue()
			return


## Dừng ngay (vd. về menu chính).
func stop() -> void:
	if _running:
		_finish()


func _jump(node_id: String) -> void:
	if not library.has_dialogue(node_id):
		errors.append("không có node '%s'" % node_id)
		_node = {}
	else:
		_node = library.get_dialogue(node_id)
	_index = 0


func _continue() -> void:
	var silent: int = 0
	while _running:
		if _node.is_empty():
			_finish()
			return
		var entries: Array = _node["entries"]
		if _index >= entries.size():
			_finish()  # hết node mà không goto/end → kết thúc
			return
		var entry: Dictionary = entries[_index]
		_index += 1
		silent += 1
		if silent > MAX_SILENT_STEPS:
			errors.append("vòng lặp vô hạn ở node '%s'" % _node["id"])
			push_error("DialogueRunner: vòng lặp vô hạn ở node '%s'" % _node["id"])
			_finish()
			return
		match str(entry["type"]):
			"line":
				if not _check(str(entry["cond"])):
					continue
				_waiting_line = true
				line_shown.emit({
					"speaker": entry["speaker"],
					"expression": entry["expression"],
					"text": substitute(str(entry["text"])),
					"line_key": "%s:%d" % [_node["id"], int(entry["index"])],
				})
				return
			"choices":
				var shown: Array[Dictionary] = []
				var options: Array = entry["options"]
				for i in options.size():
					var option: Dictionary = options[i]
					if not _check(str(option["cond"])):
						continue
					var need: String = str(option["need"])
					var enabled: bool = need.is_empty() or _check(need)
					shown.append({
						"text": substitute(str(option["text"])),
						"enabled": enabled,
						"reason": "" if enabled else str(option["need_reason"]),
						"index": i,
						"target": option["target"],
					})
				if shown.is_empty():
					continue
				_current_choices = shown
				var public: Array = []
				for option: Dictionary in shown:
					public.append({
						"text": option["text"], "enabled": option["enabled"],
						"reason": option["reason"], "index": option["index"],
					})
				choices_shown.emit(public)
				return
			"cmd":
				if not _check(str(entry["cond"])):
					continue
				if not _run_command(str(entry["name"]), entry["args"]):
					return  # ~ end
	return


## false = hội thoại đã kết thúc (~ end). ~ goto chỉ đổi node, vòng lặp _continue chạy tiếp
## (nhờ vậy goto vòng tròn vẫn bị bộ đếm MAX_SILENT_STEPS chặn, không tràn ngăn xếp).
func _run_command(command: String, args: PackedStringArray) -> bool:
	match command:
		"set":
			if args.size() >= 2:
				state.flags.set_flag(args[0], args[1].to_int())
		"add":
			if args.size() >= 2:
				state.flags.set_flag(args[0], state.flags.get_flag(args[0]) + args[1].to_int())
		"stat":
			if args.size() >= 2 and DialogueCondition.STAT_NAMES.has(args[0]):
				var stat: int = int(DialogueCondition.STAT_NAMES[args[0]])
				var delta: int = args[1].to_int()
				state.stats.change_stat(stat, delta)
				feedback.emit("%s %s" % [PlayerStats.stat_display_name(stat), _signed(delta)])
		"money":
			if args.size() >= 1:
				var amount: int = args[0].to_int()
				var label: String = args[1] if args.size() >= 2 else "Hội thoại"
				if amount < 0:
					Economy.charge(state, -amount, label)
				else:
					Economy.earn(state, amount, label)
				feedback.emit("Tiền %s%s" % ["+" if amount >= 0 else "−", MoneyFormat.format_vnd(absi(amount))])
		"rel":
			if args.size() >= 2:
				var delta: int = args[1].to_int()
				state.stats.change_relationship(args[0], delta)
				feedback.emit("Quan hệ với %s %s" % [str(npc_names.get(args[0], args[0])), _signed(delta)])
		"goto":
			if args.size() >= 1:
				_jump(args[0])
		"end":
			_finish()
			return false
		"toast":
			if args.size() >= 1:
				feedback.emit(substitute(args[0]))
		"emit":
			if args.size() >= 1:
				var rest: PackedStringArray = args.slice(1)
				event_emitted.emit(args[0], rest)
		_:
			if commands.has(command):
				(commands[command] as Callable).call(args, state)
			else:
				errors.append("lệnh chưa đăng ký '%s'" % command)
	return true


func _finish() -> void:
	_running = false
	_waiting_line = false
	_current_choices.clear()
	finished.emit(_start_id)


func _check(cond: String) -> bool:
	return cond.is_empty() or DialogueCondition.evaluate(cond, state, errors)


## Thay {player_name}, {money}, {day}, {week}. Biến lạ giữ nguyên + ghi lỗi.
func substitute(text: String) -> String:
	if text.find("{") < 0:
		return text
	var result: String = text
	result = result.replace("{player_name}", state.player_name)
	result = result.replace("{money}", MoneyFormat.format_vnd(state.stats.get_money()))
	result = result.replace("{day}", str(state.clock.day))
	result = result.replace("{week}", str(state.clock.get_week()))
	var leftover: RegExMatch = RegEx.create_from_string("\\{[a-z_]+\\}").search(result)
	if leftover != null:
		errors.append("biến lạ %s" % leftover.get_string())
	return result


static func _signed(delta: int) -> String:
	return "+%d" % delta if delta >= 0 else "−%d" % -delta
