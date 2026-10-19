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
	_sync_state()


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
