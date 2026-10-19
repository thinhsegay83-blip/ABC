class_name LifeState
extends RefCounted
## Trạng thái đời sinh viên (bước 4), lưu trong save dưới khóa "life".
## Mọi số đọc từ JSON đều ép int() vì JSON trả float.

## false = ván chưa được khởi tạo phần đời sinh viên (ván mới hoặc save cũ thiếu "life").
var initialized: bool = false
var schedule_seed: int = 0
## Mảng {weekday: int, slot: int, subject: String} — TKB lặp lại mỗi tuần.
var schedule: Array[Dictionary] = []
## subject_id -> {attended: int, absent: int, study: int}
var academics: Dictionary = {}
var inventory: Inventory = Inventory.new()
## Mảng {id: String, slots_left: int}
var status_effects: Array[Dictionary] = []
var shifts_today: int = 0
## Mảng {kind: "income"/"expense", label: String, amount: int} của ngày đang chơi.
var ledger_today: Array[Dictionary] = []
## Chỉ số lúc bắt đầu ngày: {stamina, hunger, sanity, knowledge, money}.
var day_start_stats: Dictionary = {}
var attended_today: Array[String] = []
var missed_today: Array[String] = []
## Khóa khung giờ (day * 4 + slot) đã vào học — để không đánh vắng.
var attended_slot_keys: Array[int] = []
var last_processed_day: int = 0
var last_slot_key: int = 0
## Khung giờ đã ngất gần nhất (không ngất 2 lần trong 1 khung).
var faint_slot_key: int = -1
## charge_id -> ngày thu gần nhất.
var charges_last_day: Dictionary = {}
## Cảnh báo ngưỡng đã báo (để chỉ báo lần đầu chạm ngưỡng).
var warnings_shown: Dictionary = {}


func to_dict() -> Dictionary:
	return {
		"initialized": initialized,
		"schedule_seed": schedule_seed,
		"schedule": schedule.duplicate(true),
		"academics": academics.duplicate(true),
		"inventory": inventory.to_dict(),
		"status_effects": status_effects.duplicate(true),
		"shifts_today": shifts_today,
		"ledger_today": ledger_today.duplicate(true),
		"day_start_stats": day_start_stats.duplicate(),
		"attended_today": attended_today.duplicate(),
		"missed_today": missed_today.duplicate(),
		"attended_slot_keys": attended_slot_keys.duplicate(),
		"last_processed_day": last_processed_day,
		"last_slot_key": last_slot_key,
		"faint_slot_key": faint_slot_key,
		"charges_last_day": charges_last_day.duplicate(),
		"warnings_shown": warnings_shown.duplicate(),
	}


func from_dict(data: Dictionary) -> void:
	initialized = bool(data.get("initialized", false))
	schedule_seed = int(data.get("schedule_seed", 0))
	schedule.clear()
	for entry: Variant in _array(data, "schedule"):
		if entry is Dictionary:
			schedule.append({
				"weekday": int(entry.get("weekday", 0)),
				"slot": int(entry.get("slot", 0)),
				"subject": str(entry.get("subject", "")),
			})
	academics.clear()
	var acad: Dictionary = _dict(data, "academics")
	for subject: Variant in acad.keys():
		var rec: Variant = acad[subject]
		if rec is Dictionary:
			academics[str(subject)] = {
				"attended": int(rec.get("attended", 0)),
				"absent": int(rec.get("absent", 0)),
				"study": int(rec.get("study", 0)),
			}
	inventory.from_dict(_dict(data, "inventory"))
	status_effects.clear()
	for entry: Variant in _array(data, "status_effects"):
		if entry is Dictionary:
			status_effects.append({
				"id": str(entry.get("id", "")),
				"slots_left": int(entry.get("slots_left", 0)),
			})
	shifts_today = int(data.get("shifts_today", 0))
	ledger_today.clear()
	for entry: Variant in _array(data, "ledger_today"):
		if entry is Dictionary:
			ledger_today.append({
				"kind": str(entry.get("kind", "expense")),
				"label": str(entry.get("label", "")),
				"amount": int(entry.get("amount", 0)),
			})
	day_start_stats.clear()
	var start: Dictionary = _dict(data, "day_start_stats")
	for key: Variant in start.keys():
		day_start_stats[str(key)] = int(start[key])
	attended_today = _string_array(data, "attended_today")
	missed_today = _string_array(data, "missed_today")
	attended_slot_keys.clear()
	for value: Variant in _array(data, "attended_slot_keys"):
		attended_slot_keys.append(int(value))
	last_processed_day = int(data.get("last_processed_day", 0))
	last_slot_key = int(data.get("last_slot_key", 0))
	faint_slot_key = int(data.get("faint_slot_key", -1))
	charges_last_day.clear()
	var charges: Dictionary = _dict(data, "charges_last_day")
	for key: Variant in charges.keys():
		charges_last_day[str(key)] = int(charges[key])
	warnings_shown.clear()
	var warnings: Dictionary = _dict(data, "warnings_shown")
	for key: Variant in warnings.keys():
		warnings_shown[str(key)] = bool(warnings[key])


static func _dict(data: Dictionary, key: String) -> Dictionary:
	var value: Variant = data.get(key, {})
	return value if value is Dictionary else {}


static func _array(data: Dictionary, key: String) -> Array:
	var value: Variant = data.get(key, [])
	return value if value is Array else []


static func _string_array(data: Dictionary, key: String) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in _array(data, key):
		result.append(str(value))
	return result
