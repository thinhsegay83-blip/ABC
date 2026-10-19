extends Node
## StudentLife (bước 4) — nối LifeSim vào Game: thời gian, ngày mới, thông báo.
## Logic nằm ở scripts/life/ (test được không cần autoload). Autoload: không khai báo class_name.
## Đăng ký SAU Game: handler new_day chạy trước khi Game tự lưu (Game phát new_day rồi mới lưu).

signal day_summary_ready(summary: Dictionary)
signal action_performed(action_id: String, result: Dictionary)
signal collapsed(kind: String)

var catalog: LifeCatalog
var sim: LifeSim


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	catalog = LifeCatalog.load_default()
	sim = LifeSim.new(catalog, Callable(Game, "advance_time"))
	sim.message_posted.connect(_on_message)
	sim.day_summary_ready.connect(func(summary: Dictionary) -> void: day_summary_ready.emit(summary))
	sim.action_performed.connect(
		func(action_id: String, result: Dictionary) -> void: action_performed.emit(action_id, result)
	)
	sim.collapsed.connect(func(kind: String) -> void: collapsed.emit(kind))
	Game.state_replaced.connect(_sync_state)
	Game.time_changed.connect(_on_time_changed)
	Game.new_day.connect(_on_new_day)
	_register_dialogue_hooks()
	_sync_state()


func _exit_tree() -> void:
	for variable: String in ["item.", "class_now", "shifts_today"]:
		DialogueCondition.unregister_variable(variable)


func has_game() -> bool:
	_sync_state()
	return sim.state != null


func get_place_actions(place_id: String) -> Array[Dictionary]:
	_sync_state()
	return sim.get_place_actions(place_id)


func perform_action(action_id: String, params: Dictionary = {}) -> Dictionary:
	_sync_state()
	var result: Dictionary = sim.perform_action(action_id, params)
	_show_result(result)
	return result


func get_shop_items(shop_id: String) -> Array[Dictionary]:
	_sync_state()
	return sim.get_shop_items(shop_id)


func buy_item(shop_id: String, item_id: String) -> Dictionary:
	_sync_state()
	var result: Dictionary = sim.buy_item(shop_id, item_id)
	_show_result(result)
	return result


func pay_tuition() -> Dictionary:
	_sync_state()
	var result: Dictionary = sim.pay_tuition()
	_show_result(result)
	return result


# --- Nội bộ ---------------------------------------------------------------

## Lệnh + biến điều kiện của bước 4 cho hội thoại/sự kiện.
func _register_dialogue_hooks() -> void:
	DialogueSystem.register_command("action", func(args: PackedStringArray, _state: GameState) -> void:
		if args.is_empty():
			return
		var params: Dictionary = {}
		if args.size() >= 2:
			params = {"subject": args[1], "npc": args[1]}
		perform_action(args[0], params)
	)
	DialogueSystem.register_command("give", func(args: PackedStringArray, state: GameState) -> void:
		if args.is_empty():
			return
		var amount: int = args[1].to_int() if args.size() >= 2 else 1
		state.life.inventory.add(args[0], amount)
		var item: ItemData = catalog.get_item(args[0])
		Toast.show_message("Nhận được: %s" % (item.display_name if item != null else args[0]))
	)
	DialogueSystem.register_command("take", func(args: PackedStringArray, state: GameState) -> void:
		if not args.is_empty():
			state.life.inventory.remove(args[0], args[1].to_int() if args.size() >= 2 else 1)
	)
	DialogueSystem.register_command("pay_tuition", func(_args: PackedStringArray, _state: GameState) -> void:
		pay_tuition()
	)
	DialogueSystem.register_command("pass_slots", func(args: PackedStringArray, _state: GameState) -> void:
		var count: int = args[0].to_int() if not args.is_empty() else 1
		for _i in count:
			Game.advance_time()
	)
	DialogueCondition.register_variable("item.", func(variable: String, state: GameState) -> int:
		return state.life.inventory.count(variable.substr(5))
	)
	DialogueCondition.register_variable("class_now", func(_variable: String, state: GameState) -> int:
		if sim.state != state:
			return 0
		return 0 if sim.class_now().is_empty() else 1
	)
	DialogueCondition.register_variable("shifts_today", func(_variable: String, state: GameState) -> int:
		return state.life.shifts_today
	)


## Theo kịp Game.state (ván mới, tải game, về menu chính).
func _sync_state() -> void:
	if sim.state != Game.state:
		sim.bind(Game.state)


func _on_time_changed(day: int, slot: int) -> void:
	_sync_state()
	sim.handle_time_changed(day, slot)
	# Hậu quả (ngất…) cần qua thêm khung giờ → không gọi lồng trong handler time_changed.
	sim.check_collapse.call_deferred()


func _on_new_day(day: int) -> void:
	_sync_state()
	sim.handle_new_day(day)


func _on_message(text: String) -> void:
	Toast.show_message(text, 3.5)


func _show_result(result: Dictionary) -> void:
	var text: String = str(result.get("message", "")) if result.get("ok", false) \
			else str(result.get("reason", ""))
	if not text.is_empty():
		Toast.show_message(text, 3.0)
