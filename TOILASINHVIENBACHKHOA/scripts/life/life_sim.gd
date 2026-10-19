class_name LifeSim
extends RefCounted
## Bộ điều phối đời sinh viên (bước 4): hành động, cửa hàng, hiệu ứng, hậu quả chỉ số,
## điểm danh, phí định kỳ, học phí, tổng kết ngày.
## Không phụ thuộc autoload: autoload StudentLife chỉ nối signal của Game vào các hàm handle_*.
## Trong test, nối thẳng signal của GameClock (xem attach_clock()).

signal message_posted(text: String)
signal day_summary_ready(summary: Dictionary)
signal action_performed(action_id: String, result: Dictionary)
## Ngất / kiệt sức: UI bước 2 có thể đưa nhân vật về giường.
signal collapsed(kind: String)

const SLOTS_PER_DAY: int = GameClock.SLOT_COUNT

var catalog: LifeCatalog
var state: GameState = null
var charges: RecurringCharges
## Tiến 1 khung giờ: Game.advance_time (trong game) hoặc state.advance_time(decay) (trong test).
var advance_slot: Callable
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Hàm ngắt giấc ngủ (bước 6 — sự kiện đêm): Callable(context: Dictionary) -> bool.
## Trả true = có sự kiện; giấc ngủ dừng ở khung Đêm, sự kiện xong thì gọi complete_sleep().
var sleep_interrupters: Array[Callable] = []

## Mốc khung giờ (day * 4 + slot) mà việc tua giờ (kiệt sức ngủ li bì) không được vượt qua
## — vd. cao trào Đêm ngày 28 (bước 7).
var time_barriers: Array[int] = []

var _collapsing: bool = false
var _sleep_from_slot: int = -1


func _init(life_catalog: LifeCatalog, advancer: Callable) -> void:
	catalog = life_catalog
	advance_slot = advancer
	charges = RecurringCharges.with_defaults(catalog.economy)
	rng.randomize()


# --- Vòng đời -------------------------------------------------------------

## Gắn với một ván. Ván mới (hoặc save cũ thiếu "life") → khởi tạo TKB, thu phí ngày đầu.
func bind(new_state: GameState) -> void:
	state = new_state
	charges = RecurringCharges.with_defaults(catalog.economy)
	_sleep_from_slot = -1
	if state == null:
		return
	RoomFund.register(state, catalog.economy, charges)
	if not state.life.initialized:
		start_new_life()


func start_new_life(seed_value: int = -1) -> void:
	var life: LifeState = state.life
	life.schedule_seed = seed_value if seed_value >= 0 else int(rng.randi() & 0x7fffffff)
	life.schedule = ScheduleGenerator.generate(life.schedule_seed, catalog.subjects)
	for subject: SubjectData in catalog.subjects:
		AcademicRecord.get_record(life, subject.id)
	life.last_slot_key = current_key()
	life.last_processed_day = state.clock.day
	life.initialized = true
	_begin_day(state.clock.day)


## Chỉ dùng trong test: nối signal đồng hồ trực tiếp.
func attach_clock(clock: GameClock) -> void:
	clock.time_changed.connect(handle_time_changed)
	clock.new_day.connect(handle_new_day)


## Gọi mỗi khi đồng hồ đổi. Chỉ xử lý "khung vừa hết" khi đi tuần tự từng khung;
## nhảy giờ (tải game, debug set_time) chỉ đồng bộ lại — không đánh vắng hàng loạt.
func handle_time_changed(day: int, slot: int) -> void:
	if state == null or not state.life.initialized:
		return
	var key: int = day * SLOTS_PER_DAY + slot
	var life: LifeState = state.life
	if key == life.last_slot_key + 1:
		_process_slot_end(life.last_slot_key)
	life.last_slot_key = key


## Gọi khi sang ngày mới, TRƯỚC khi Game tự lưu.
func handle_new_day(day: int) -> void:
	if state == null or not state.life.initialized:
		return
	var life: LifeState = state.life
	if day <= life.last_processed_day:
		return
	day_summary_ready.emit(DaySummaryBuilder.build(state, catalog, charges, day - 1))
	life.last_processed_day = day
	_begin_day(day)


# --- Hành động (C1, D1) ---------------------------------------------------

## Danh sách hành động ở một nơi: [{action, enabled, reason, preview}].
func get_place_actions(place_id: String) -> Array[Dictionary]:
	if place_id.is_empty():
		return []
	var result: Array[Dictionary] = []
	for action: ActionData in catalog.actions_at(place_id):
		var requires_ok: bool = eval_requires(action.requires)
		if action.hide_when_locked and not requires_ok:
			continue
		var reason: String = check_action(action)
		result.append({
			"action": action,
			"enabled": reason.is_empty(),
			"reason": reason,
			"preview": preview_action(action),
		})
	return result


## "" = làm được; ngược lại là lý do bằng tiếng Việt.
func check_action(action: ActionData, params: Dictionary = {}) -> String:
	if state == null:
		return "Chưa có ván chơi"
	if not eval_requires(action.requires):
		return action.requires_reason if not action.requires_reason.is_empty() else "Chưa đủ điều kiện"
	var slot: int = state.clock.slot
	if action.category == "class":
		if class_now().is_empty():
			return "Không có tiết lúc này"
		if state.life.attended_slot_keys.has(current_key()):
			return "Bạn đã điểm danh tiết này rồi"
		return ""
	if not action.allowed_slots.is_empty() and not action.allowed_slots.has(slot):
		return action.wrong_slot_reason if not action.wrong_slot_reason.is_empty() \
				else "Không làm được vào lúc này"
	if action.counts_as_shift and state.life.shifts_today >= catalog.economy.max_shifts_per_day:
		return "Hôm nay bạn đã làm đủ %d ca" % catalog.economy.max_shifts_per_day
	if action.price > 0 and state.stats.get_money() < action.price:
		return "Thiếu %s" % MoneyFormat.format_vnd(action.price - state.stats.get_money())
	if action.category == "outing":
		var npc: String = str(params.get("npc", ""))
		if state.life.outings_today.has(npc):
			return "Hôm nay đã đi chơi cùng người này rồi"
	return ""


## Xem trước minh bạch: {text, may_faint, wage_min, wage_max}.
func preview_action(action: ActionData) -> Dictionary:
	var parts: PackedStringArray = PackedStringArray()
	var wage_min: int = 0
	var wage_max: int = 0
	if action.category == "sleep":
		parts.append("Ngủ tới sáng")
	elif action.slot_cost > 0:
		parts.append("%d khung giờ" % action.slot_cost)
	else:
		parts.append("Không tốn thời gian")
	if action.price > 0:
		parts.append("−" + MoneyFormat.format_vnd(action.price))
	if action.base_wage > 0:
		wage_min = _wage(action.base_wage)
		wage_max = _wage(action.base_wage + action.tip_max)
		if wage_max > wage_min:
			parts.append("+%s–%s" % [MoneyFormat.format_vnd(wage_min).trim_suffix(" đ"), MoneyFormat.format_vnd(wage_max)])
		else:
			parts.append("+" + MoneyFormat.format_vnd(wage_min))
	var stamina_delta: int = action.stamina
	if action.category == "sleep" and state != null and state.clock.slot == GameClock.Slot.EVENING:
		stamina_delta += catalog.economy.early_sleep_bonus_stamina
	_append_delta(parts, "Thể lực", stamina_delta)
	_append_delta(parts, "Đói", action.hunger)
	_append_delta(parts, "Sanity", action.sanity)
	_append_delta(parts, "Trí tuệ", action.knowledge)
	var may_faint: bool = false
	if state != null and action.category != "sleep" and action.slot_cost > 0:
		may_faint = state.stats.get_stat(PlayerStats.Stat.STAMINA) + action.stamina <= 0
	return {"text": " · ".join(parts), "may_faint": may_faint, "wage_min": wage_min, "wage_max": wage_max}


## Thực hiện hành động. params: {"subject": id} cho tự học.
## Trả {ok, reason, message, money}.
func perform_action(action_id: String, params: Dictionary = {}) -> Dictionary:
	var action: ActionData = catalog.get_action(action_id)
	if action == null:
		return {"ok": false, "reason": "Không có hành động '%s'" % action_id, "message": "", "money": 0}
	var reason: String = check_action(action, params)
	if not reason.is_empty():
		return {"ok": false, "reason": reason, "message": "", "money": 0}
	if action.category == "sleep":
		return _sleep(action)

	var life: LifeState = state.life
	var stats: PlayerStats = state.stats
	var hungry: bool = is_hungry()
	var money: int = 0
	var message: String = action.display_name
	match action.category:
		"class":
			var subject: String = class_now()
			AcademicRecord.record_attend(life, subject, _scaled_study(2, hungry))
			life.attended_slot_keys.append(current_key())
			life.attended_today.append(catalog.subject_name(subject))
			message = "Vào học %s" % catalog.subject_name(subject)
		"study":
			var subject: String = str(params.get("subject", default_study_subject()))
			var base: int = 5 if has_textbook(subject) else 3
			AcademicRecord.record_study(life, subject, _scaled_study(base, hungry))
			message = "Tự học %s" % catalog.subject_name(subject)
		"work":
			money = _wage(action.base_wage + rng.randi_range(0, action.tip_max))
			Economy.earn(state, money, action.display_name)
			life.shifts_today += 1
			message = "%s: +%s" % [action.display_name, MoneyFormat.format_vnd(money)]
		"outing":
			var npc: String = str(params.get("npc", ""))
			Economy.spend(state, action.price, action.display_name)
			life.outings_today.append(npc)
			if not npc.is_empty() and action.relationship_delta != 0:
				stats.change_relationship(npc, action.relationship_delta)
			message = action.narration[rng.randi_range(0, action.narration.size() - 1)] \
					if not action.narration.is_empty() else action.display_name
		"special":
			if not action.sets_flag.is_empty():
				state.flags.set_flag(action.sets_flag, 1)
			if action.sets_flag == "lam_them_quan":
				message = "Chủ quán đồng ý nhận bạn làm thêm: phụ quán cơm buổi Sáng/Chiều, bưng cà phê buổi Tối."
	stats.change_stat(PlayerStats.Stat.STAMINA, action.stamina)
	stats.change_stat(PlayerStats.Stat.HUNGER, action.hunger)
	stats.change_stat(PlayerStats.Stat.SANITY, action.sanity)
	var knowledge_gain: int = action.knowledge
	if action.category in ["class", "study"]:
		knowledge_gain = _scaled_study(action.knowledge, hungry)
	stats.change_stat(PlayerStats.Stat.KNOWLEDGE, knowledge_gain)
	if knowledge_gain > 0:
		message += " · Trí tuệ +%d" % knowledge_gain
	if hungry and action.category in ["class", "study"]:
		message += " (đói lả nên học kém)"
	if not action.adds_flag.is_empty() and action.adds_flag_amount != 0:
		if action.adds_flag == StoryVars.K_FLAG:
			StoryVars.add_k_involvement(state, action.adds_flag_amount)
		else:
			state.flags.set_flag(action.adds_flag, state.flags.get_flag(action.adds_flag) + action.adds_flag_amount)

	for _i in action.slot_cost:
		advance_slot.call()
	var result: Dictionary = {"ok": true, "reason": "", "message": message, "money": money}
	action_performed.emit(action_id, result)
	check_collapse()
	return result


func _sleep(action: ActionData) -> Dictionary:
	var from_slot: int = state.clock.slot
	for handler: Callable in sleep_interrupters:
		if handler.call({"from_slot": from_slot, "day": state.clock.day}):
			# Có sự kiện đêm: ngủ tới khung Đêm rồi dừng; sự kiện xong gọi complete_sleep().
			_sleep_from_slot = from_slot
			while state.clock.slot != GameClock.Slot.NIGHT:
				advance_slot.call()
			var interrupted: Dictionary = {"ok": true, "reason": "", "message": "", "money": 0, "interrupted": true}
			action_performed.emit(action.id, interrupted)
			return interrupted
	return _finish_sleep(action, from_slot, 1.0)


func is_sleep_interrupted() -> bool:
	return _sleep_from_slot >= 0


## Ngủ tiếp sau khi sự kiện đêm kết thúc (lệnh hội thoại "~ sleep [hệ số hồi]").
func complete_sleep(recovery_multiplier: float = 1.0) -> Dictionary:
	var action: ActionData = catalog.get_action("ngu")
	var from_slot: int = _sleep_from_slot if _sleep_from_slot >= 0 else state.clock.slot
	_sleep_from_slot = -1
	return _finish_sleep(action, from_slot, recovery_multiplier)


func _finish_sleep(action: ActionData, from_slot: int, recovery_multiplier: float) -> Dictionary:
	var target_day: int = state.clock.day + 1
	var guard: int = 0
	while not (state.clock.day == target_day and state.clock.slot == GameClock.Slot.MORNING):
		advance_slot.call()
		guard += 1
		if guard > SLOTS_PER_DAY * 2:
			push_error("LifeSim: ngủ không tới được buổi sáng")
			break
	var recovery: int = action.stamina
	if from_slot == GameClock.Slot.EVENING:
		recovery += catalog.economy.early_sleep_bonus_stamina
	var message: String = "Bạn ngủ một giấc tới sáng"
	if is_hungry():
		@warning_ignore("integer_division")
		recovery = recovery / 2
		message += " (bụng đói nên ngủ không ngon)"
	recovery = roundi(recovery * recovery_multiplier)
	state.stats.change_stat(PlayerStats.Stat.STAMINA, recovery)
	state.stats.change_stat(PlayerStats.Stat.SANITY, action.sanity)
	var result: Dictionary = {"ok": true, "reason": "", "message": message, "money": 0}
	action_performed.emit(action.id, result)
	check_collapse()
	return result


# --- Cửa hàng (D6, D7) ----------------------------------------------------

## [{item, enabled, reason}] của một quầy.
func get_shop_items(shop_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var shop: ShopData = catalog.get_shop(shop_id)
	if shop == null:
		return result
	var closed: String = _shop_closed_reason(shop)
	for item_id: String in shop.item_ids:
		var item: ItemData = catalog.get_item(item_id)
		if item == null:
			continue
		var reason: String = closed
		if reason.is_empty() and state.stats.get_money() < item.price:
			reason = "Thiếu %s" % MoneyFormat.format_vnd(item.price - state.stats.get_money())
		result.append({"item": item, "enabled": reason.is_empty(), "reason": reason})
	return result


## Mua 1 món. Trả {ok, reason, message}.
func buy_item(shop_id: String, item_id: String, carry: bool = false) -> Dictionary:
	var shop: ShopData = catalog.get_shop(shop_id)
	var item: ItemData = catalog.get_item(item_id)
	if shop == null or item == null or not shop.item_ids.has(item_id):
		return {"ok": false, "reason": "Quầy không bán món này", "message": ""}
	var closed: String = _shop_closed_reason(shop)
	if not closed.is_empty():
		return {"ok": false, "reason": closed, "message": ""}
	if not Economy.spend(state, item.price, item.display_name):
		return {
			"ok": false,
			"reason": "Thiếu %s" % MoneyFormat.format_vnd(item.price - state.stats.get_money()),
			"message": "",
		}
	var parts: PackedStringArray = PackedStringArray()
	parts.append("Đã mua %s (−%s)" % [item.display_name, MoneyFormat.format_vnd(item.price)])
	if item.consume_on_buy and not (carry and item.can_carry):
		_apply_item(item, parts)
	else:
		state.life.inventory.add(item.id)
		parts.append("đã cho vào túi")
	if state.stats.get_stat(PlayerStats.Stat.HUNGER) >= catalog.economy.hungry_threshold:
		state.life.warnings_shown.erase("hungry")
	return {"ok": true, "reason": "", "message": " · ".join(parts)}


## Dùng 1 món trong túi (I1). Trả {ok, reason, message}.
func use_item(item_id: String) -> Dictionary:
	var item: ItemData = catalog.get_item(item_id)
	if item == null or state.life.inventory.count(item_id) <= 0:
		return {"ok": false, "reason": "Không có món này trong túi", "message": ""}
	if not can_use_item(item):
		return {"ok": false, "reason": "Không dùng được", "message": ""}
	state.life.inventory.remove(item_id)
	var parts: PackedStringArray = PackedStringArray()
	parts.append("Đã dùng %s" % item.display_name)
	_apply_item(item, parts)
	return {"ok": true, "reason": "", "message": " · ".join(parts)}


static func can_use_item(item: ItemData) -> bool:
	return item.category in ["food", "drink"]


func _apply_item(item: ItemData, parts: PackedStringArray) -> void:
	state.stats.change_stat(PlayerStats.Stat.HUNGER, item.hunger)
	state.stats.change_stat(PlayerStats.Stat.STAMINA, item.stamina)
	state.stats.change_stat(PlayerStats.Stat.SANITY, item.sanity)
	_append_delta(parts, "Đói", item.hunger)
	_append_delta(parts, "Thể lực", item.stamina)
	_append_delta(parts, "Sanity", item.sanity)
	if not item.effect_id.is_empty():
		add_effect(item.effect_id)
	if state.stats.get_stat(PlayerStats.Stat.HUNGER) >= catalog.economy.hungry_threshold:
		state.life.warnings_shown.erase("hungry")


func _shop_closed_reason(shop: ShopData) -> String:
	if state == null:
		return "Chưa có ván chơi"
	if not shop.open_slots.is_empty() and not shop.open_slots.has(state.clock.slot):
		return "%s đã đóng cửa" % shop.display_name
	return ""


# --- Hiệu ứng tạm thời (QĐ-4.3) -------------------------------------------

## Thêm hiệu ứng; đang có thì đặt lại thời gian (không cộng dồn).
func add_effect(effect_id: String) -> void:
	var effect: StatusEffectData = catalog.get_effect(effect_id)
	if effect == null:
		return
	for entry: Dictionary in state.life.status_effects:
		if entry["id"] == effect_id:
			entry["slots_left"] = effect.duration_slots
			return
	state.life.status_effects.append({"id": effect_id, "slots_left": effect.duration_slots})


func has_effect(effect_id: String) -> bool:
	for entry: Dictionary in state.life.status_effects:
		if entry["id"] == effect_id:
			return true
	return false


# --- Học phí (B3) ---------------------------------------------------------

func pay_tuition() -> Dictionary:
	var config: EconomyConfig = catalog.economy
	var reason: String = Tuition.can_pay(state, config)
	if not reason.is_empty():
		return {"ok": false, "reason": reason, "message": ""}
	var amount: int = Tuition.amount_due(state, config)
	Tuition.pay(state, config)
	return {"ok": true, "reason": "", "message": "Đã đóng học phí HK1: −%s" % MoneyFormat.format_vnd(amount)}


# --- Hậu quả chỉ số (A1–A3) -----------------------------------------------

## Kiểm tra ngất (Thể lực 0) và kiệt sức tinh thần (Sanity 0). true nếu có xảy ra.
func check_collapse() -> bool:
	if state == null or _collapsing:
		return false
	var config: EconomyConfig = catalog.economy
	var stats: PlayerStats = state.stats
	if stats.get_stat(PlayerStats.Stat.SANITY) <= 0:
		_collapsing = true
		_post("Bạn kiệt sức về tinh thần và ngủ li bì suốt một ngày. Hãy chăm sóc bản thân nhiều hơn.")
		var target_day: int = state.clock.day + 2
		var guard: int = 0
		while not (state.clock.day == target_day and state.clock.slot == GameClock.Slot.MORNING):
			if time_barriers.has(current_key()):
				break  # không tua qua mốc cốt truyện bắt buộc
			advance_slot.call()
			guard += 1
			if guard > SLOTS_PER_DAY * 3:
				break
		stats.set_stat(PlayerStats.Stat.SANITY, config.rest_sanity)
		stats.set_stat(PlayerStats.Stat.STAMINA, config.rest_stamina)
		state.life.faint_slot_key = current_key()
		_collapsing = false
		collapsed.emit("rest")
		return true
	if stats.get_stat(PlayerStats.Stat.STAMINA) <= 0 and state.life.faint_slot_key != current_key():
		_collapsing = true
		_post("Bạn kiệt sức và ngất đi… Tỉnh dậy trên giường ở KTX.")
		advance_slot.call()
		stats.set_stat(PlayerStats.Stat.STAMINA, config.faint_stamina)
		stats.change_stat(PlayerStats.Stat.SANITY, config.faint_sanity)
		state.life.faint_slot_key = current_key()
		_collapsing = false
		collapsed.emit("faint")
		return true
	return false


func is_hungry() -> bool:
	return state.stats.get_stat(PlayerStats.Stat.HUNGER) < catalog.economy.hungry_threshold


# --- Tra cứu cho UI -------------------------------------------------------

func current_key() -> int:
	return state.clock.day * SLOTS_PER_DAY + state.clock.slot


## Môn đang có tiết ở khung hiện tại ("" nếu không).
func class_now() -> String:
	return class_at(state.clock.day, state.clock.slot)


func class_at(day: int, slot: int) -> String:
	if state == null or day < catalog.economy.classes_start_day:
		return ""
	var weekday: int = posmod(day - 1, GameClock.DAYS_PER_WEEK)
	return ScheduleGenerator.subject_at(state.life.schedule, weekday, slot)


## "Vật lý 1 — Chiều nay" / "Giải tích 1 — Sáng Thứ Ba"; "" nếu 2 tuần tới không có tiết.
func next_class_text() -> String:
	if state == null:
		return ""
	var start: int = current_key()
	for key in range(start, start + SLOTS_PER_DAY * 14):
		@warning_ignore("integer_division")
		var day: int = key / SLOTS_PER_DAY
		var slot: int = key % SLOTS_PER_DAY
		var subject: String = class_at(day, slot)
		if subject.is_empty():
			continue
		if key == start and state.life.attended_slot_keys.has(key):
			continue
		var when: String
		if day == state.clock.day:
			when = "%s nay" % GameClock.slot_display_name(slot) if key != start else "ngay bây giờ"
		elif day == state.clock.day + 1:
			when = "%s mai" % GameClock.slot_display_name(slot)
		else:
			when = "%s %s" % [
				GameClock.slot_display_name(slot),
				GameClock.weekday_display_name(posmod(day - 1, GameClock.DAYS_PER_WEEK)),
			]
		return "%s — %s" % [catalog.subject_name(subject), when]
	return ""


## "Học phí: còn 9 ngày" — "" khi đã đóng.
func tuition_text() -> String:
	if state == null or Tuition.is_paid(state):
		return ""
	var left: int = Tuition.days_left(state, catalog.economy)
	var due: String = MoneyFormat.format_vnd(Tuition.amount_due(state, catalog.economy))
	if left < 0:
		return "Học phí: QUÁ HẠN — %s" % due
	if left == 0:
		return "Học phí: hạn cuối HÔM NAY — %s" % due
	return "Học phí: còn %d ngày — %s" % [left, due]


func has_textbook(subject: String) -> bool:
	return state.life.inventory.count("giao_trinh_" + subject) > 0


## Môn nên tự học mặc định: môn có điểm nắm bài thấp nhất.
func default_study_subject() -> String:
	var best: String = ""
	var best_study: int = 1 << 30
	for subject: SubjectData in catalog.subjects:
		var rec: Dictionary = AcademicRecord.get_record(state.life, subject.id)
		if int(rec["study"]) < best_study:
			best_study = int(rec["study"])
			best = subject.id
	return best


## Điều kiện cú pháp hội thoại (DialogueCondition), vd. "flag.lam_them_quan == 1 and week >= 3".
func eval_requires(expr: String) -> bool:
	if expr.strip_edges().is_empty():
		return true
	var errors: PackedStringArray = PackedStringArray()
	var ok: bool = DialogueCondition.evaluate(expr, state, errors)
	for error: String in errors:
		push_warning("LifeSim: %s" % error)
	return ok


# --- Nội bộ ---------------------------------------------------------------

## Đầu ngày: chụp chỉ số, reset sổ ngày, thu phí, kiểm hạn học phí.
func _begin_day(day: int) -> void:
	var life: LifeState = state.life
	life.ledger_today.clear()
	life.shifts_today = 0
	life.attended_today.clear()
	life.missed_today.clear()
	life.outings_today.clear()
	life.day_start_stats = {
		"stamina": state.stats.get_stat(PlayerStats.Stat.STAMINA),
		"hunger": state.stats.get_stat(PlayerStats.Stat.HUNGER),
		"sanity": state.stats.get_stat(PlayerStats.Stat.SANITY),
		"knowledge": state.stats.get_stat(PlayerStats.Stat.KNOWLEDGE),
		"money": state.stats.get_money(),
	}
	for text: String in charges.process_day(state, day):
		_post(text)
	for text: String in Tuition.process_day_start(state, catalog.economy, day):
		_post(text)


## Xử lý khung giờ vừa hết: vắng tiết, hiệu ứng hết hạn, hậu quả đói.
func _process_slot_end(key: int) -> void:
	var life: LifeState = state.life
	var config: EconomyConfig = catalog.economy
	@warning_ignore("integer_division")
	var day: int = key / SLOTS_PER_DAY
	var slot: int = key % SLOTS_PER_DAY

	var subject: String = class_at(day, slot)
	if not subject.is_empty() and not life.attended_slot_keys.has(key):
		AcademicRecord.record_absent(life, subject)
		life.missed_today.append(catalog.subject_name(subject))
		_post("Bạn đã vắng tiết %s — điểm chuyên cần bị trừ" % catalog.subject_name(subject))
	# Chỉ giữ các khóa điểm danh từ khung đang xét trở đi.
	var kept: Array[int] = []
	for attended_key: int in life.attended_slot_keys:
		if attended_key > key:
			kept.append(attended_key)
	life.attended_slot_keys = kept

	var still: Array[Dictionary] = []
	for entry: Dictionary in life.status_effects:
		entry["slots_left"] = int(entry["slots_left"]) - 1
		if int(entry["slots_left"]) > 0:
			still.append(entry)
			continue
		var effect: StatusEffectData = catalog.get_effect(str(entry["id"]))
		if effect != null:
			state.stats.change_stat(PlayerStats.Stat.STAMINA, effect.on_end_stamina)
			if not effect.end_message.is_empty():
				_post(effect.end_message)
	life.status_effects = still

	var hunger: int = state.stats.get_stat(PlayerStats.Stat.HUNGER)
	if hunger <= 0:
		state.stats.change_stat(PlayerStats.Stat.STAMINA, -config.starving_stamina_per_slot)
	elif hunger < config.hungry_threshold:
		state.stats.change_stat(PlayerStats.Stat.STAMINA, -config.hungry_stamina_per_slot)
	if hunger < config.hungry_threshold:
		if not life.warnings_shown.get("hungry", false):
			life.warnings_shown["hungry"] = true
			_post("Bạn đói lả — học kém hẳn đi, Thể lực tụt nhanh. Hãy ăn gì đó!")
	else:
		life.warnings_shown.erase("hungry")


func _wage(amount: int) -> int:
	return Economy.round_to(amount * state.wage_multiplier, catalog.economy.wage_round_to)


## Đói lả → hiệu quả học ×0,5 (làm tròn xuống, tối thiểu 1).
static func _scaled_study(amount: int, hungry: bool) -> int:
	if amount <= 0 or not hungry:
		return amount
	@warning_ignore("integer_division")
	return maxi(1, amount / 2)


static func _append_delta(parts: PackedStringArray, label: String, delta: int) -> void:
	if delta > 0:
		parts.append("%s +%d" % [label, delta])
	elif delta < 0:
		parts.append("%s −%d" % [label, -delta])


func _post(text: String) -> void:
	message_posted.emit(text)
