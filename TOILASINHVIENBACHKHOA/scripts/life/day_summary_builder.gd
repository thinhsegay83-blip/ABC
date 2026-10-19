class_name DaySummaryBuilder
extends RefCounted
## Lập dữ liệu màn tổng kết cuối ngày (B10). Logic thuần → test được.

const STAT_ROWS: Array = [
	[PlayerStats.Stat.STAMINA, "stamina"],
	[PlayerStats.Stat.HUNGER, "hunger"],
	[PlayerStats.Stat.SANITY, "sanity"],
	[PlayerStats.Stat.KNOWLEDGE, "knowledge"],
]


## Gọi lúc vừa sang ngày mới, TRƯỚC khi xóa sổ của ngày `day`.
## Trả:
## {day, weekday_name, incomes: [{label, amount}], expenses: [...], income_total, expense_total,
##  money_before, money_after, stats: [{name, before, after, delta}], attended: [], missed: [],
##  upcoming: [String]}
static func build(
	state: GameState, catalog: LifeCatalog, charges: RecurringCharges, day: int
) -> Dictionary:
	var life: LifeState = state.life
	var incomes: Array[Dictionary] = []
	var expenses: Array[Dictionary] = []
	var income_total: int = 0
	var expense_total: int = 0
	for entry: Dictionary in life.ledger_today:
		var row: Dictionary = {"label": entry["label"], "amount": int(entry["amount"])}
		if entry["kind"] == "income":
			incomes.append(row)
			income_total += int(entry["amount"])
		else:
			expenses.append(row)
			expense_total += int(entry["amount"])

	var stats_rows: Array[Dictionary] = []
	for row: Array in STAT_ROWS:
		var stat: int = row[0]
		var after: int = state.stats.get_stat(stat)
		var before: int = int(life.day_start_stats.get(row[1], after))
		stats_rows.append({
			"name": PlayerStats.stat_display_name(stat),
			"before": before,
			"after": after,
			"delta": after - before,
		})

	var money_after: int = state.stats.get_money()
	return {
		"day": day,
		"weekday_name": GameClock.weekday_display_name(posmod(day - 1, GameClock.DAYS_PER_WEEK)),
		"incomes": incomes,
		"expenses": expenses,
		"income_total": income_total,
		"expense_total": expense_total,
		"money_before": int(life.day_start_stats.get("money", money_after)),
		"money_after": money_after,
		"stats": stats_rows,
		"attended": life.attended_today.duplicate(),
		"missed": life.missed_today.duplicate(),
		"upcoming": upcoming(state, catalog, charges, day + 1),
	}


## Các mốc sắp tới, nhìn từ ngày `from_day`.
static func upcoming(
	state: GameState, catalog: LifeCatalog, charges: RecurringCharges, from_day: int
) -> Array[String]:
	var lines: Array[String] = []
	var config: EconomyConfig = catalog.economy
	if not Tuition.is_paid(state):
		var left: int = Tuition.deadline(state, config) - from_day
		if left >= 0:
			lines.append("Học phí: còn %d ngày — cần %s" % [
				left, MoneyFormat.format_vnd(Tuition.amount_due(state, config))
			])
		else:
			lines.append("Học phí: ĐÃ QUÁ HẠN — cần %s" % MoneyFormat.format_vnd(
				Tuition.amount_due(state, config)
			))
	for entry: Dictionary in charges.entries:
		var due_day: int = charges.next_due_day(entry, from_day)
		lines.append("%s: ngày %d (%s)" % [
			entry["label"], due_day, MoneyFormat.format_vnd(int(entry["amount"]))
		])
	var classes: Array[String] = []
	if from_day >= config.classes_start_day:
		var weekday: int = posmod(from_day - 1, GameClock.DAYS_PER_WEEK)
		for slot: int in ScheduleGenerator.CLASS_SLOTS:
			var subject: String = ScheduleGenerator.subject_at(state.life.schedule, weekday, slot)
			if not subject.is_empty():
				classes.append("%s (%s)" % [catalog.subject_name(subject), GameClock.slot_display_name(slot)])
	if classes.is_empty():
		lines.append("Ngày mai: không có tiết")
	else:
		lines.append("Ngày mai: " + ", ".join(classes))
	return lines
