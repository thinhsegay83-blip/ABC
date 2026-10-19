class_name RecurringCharges
extends RefCounted
## Phí định kỳ (B4): tiền KTX mỗi tháng (28 ngày). Bước 5 thêm quỹ phòng bằng register().
## Mỗi khoản: {id, label, amount, period_days, first_day, condition_flag}
## condition_flag rỗng = luôn thu; có tên cờ = chỉ thu khi cờ đó == 1.
## on_charge (tùy chọn): Callable(state) gọi sau khi thu (vd. quỹ phòng tăng).

var entries: Array[Dictionary] = []


static func with_defaults(config: EconomyConfig) -> RecurringCharges:
	var charges: RecurringCharges = RecurringCharges.new()
	charges.register({
		"id": "ktx",
		"label": "Tiền KTX tháng",
		"amount": config.ktx_fee,
		"period_days": config.month_length_days,
		"first_day": 1,
		"condition_flag": "",
	})
	return charges


func register(entry: Dictionary) -> void:
	for existing: Dictionary in entries:
		if existing["id"] == entry["id"]:
			push_warning("RecurringCharges: trùng id %s" % entry["id"])
			return
	entries.append(entry)


func is_due(entry: Dictionary, day: int) -> bool:
	var first: int = int(entry.get("first_day", 1))
	var period: int = maxi(1, int(entry.get("period_days", 28)))
	return day >= first and (day - first) % period == 0


## Ngày thu kế tiếp từ `day` (kể cả hôm nay).
func next_due_day(entry: Dictionary, day: int) -> int:
	var first: int = int(entry.get("first_day", 1))
	var period: int = maxi(1, int(entry.get("period_days", 28)))
	if day <= first:
		return first
	return first + ceili(float(day - first) / period) * period


## Thu các khoản đến hạn hôm nay. Trả thông báo cần hiện.
func process_day(state: GameState, day: int) -> Array[String]:
	var messages: Array[String] = []
	for entry: Dictionary in entries:
		var id: String = str(entry["id"])
		if not is_due(entry, day):
			continue
		if int(state.life.charges_last_day.get(id, 0)) == day:
			continue  # đã thu hôm nay
		var flag: String = str(entry.get("condition_flag", ""))
		if not flag.is_empty() and state.flags.get_flag(flag) != 1:
			continue
		var amount: int = int(entry["amount"])
		Economy.charge(state, amount, str(entry["label"]))
		state.life.charges_last_day[id] = day
		if entry.has("on_charge"):
			(entry["on_charge"] as Callable).call(state)
		if state.stats.get_money() < 0:
			messages.append("%s: −%s — số dư đang âm!" % [entry["label"], MoneyFormat.format_vnd(amount)])
		else:
			messages.append("%s: −%s" % [entry["label"], MoneyFormat.format_vnd(amount)])
	return messages
