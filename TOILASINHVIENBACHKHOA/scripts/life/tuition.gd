class_name Tuition
extends RefCounted
## Học phí HK1 (B3). Luật đã chốt:
## - Hạn chính: hết ngày `tuition_due_day` → đầu ngày hôm sau mới xử lý trễ hạn.
## - Trễ → gia hạn tới hết `tuition_extended_due_day`, phạt cộng vào khoản phải đóng (QĐ-4.2),
##   Sanity giảm.
## - Quá cả hạn gia hạn → MVP chỉ cảnh báo (bản đầy đủ: Bad Ending "nghỉ học", C1).
## Trạng thái nằm trong cờ: da_dong_hoc_phi, hoc_phi_tre_han, hoc_phi_qua_han.

const FLAG_PAID: String = "da_dong_hoc_phi"
const FLAG_LATE: String = "hoc_phi_tre_han"
const FLAG_OVERDUE: String = "hoc_phi_qua_han"
const LEDGER_LABEL: String = "Học phí HK1"


static func is_paid(state: GameState) -> bool:
	return state.flags.get_flag(FLAG_PAID) == 1


static func is_late(state: GameState) -> bool:
	return state.flags.get_flag(FLAG_LATE) == 1


static func amount_due(state: GameState, config: EconomyConfig) -> int:
	if is_paid(state):
		return 0
	var amount: int = config.tuition_amount
	if is_late(state):
		amount += config.tuition_late_penalty
	return amount


## Ngày cuối được đóng (hạn chính hoặc hạn gia hạn).
static func deadline(state: GameState, config: EconomyConfig) -> int:
	return config.tuition_extended_due_day if is_late(state) else config.tuition_due_day


## Số ngày còn lại tính từ hôm nay (0 = hôm nay là ngày cuối).
static func days_left(state: GameState, config: EconomyConfig) -> int:
	return deadline(state, config) - state.clock.day


## "" nếu đóng được; ngược lại là lý do.
static func can_pay(state: GameState, config: EconomyConfig) -> String:
	if is_paid(state):
		return "Bạn đã đóng học phí rồi"
	var due: int = amount_due(state, config)
	var money: int = state.stats.get_money()
	if money < due:
		return "Còn thiếu %s" % MoneyFormat.format_vnd(due - money)
	return ""


## Đóng một lần đủ. false nếu không đóng được.
static func pay(state: GameState, config: EconomyConfig) -> bool:
	if not can_pay(state, config).is_empty():
		return false
	if not Economy.spend(state, amount_due(state, config), LEDGER_LABEL):
		return false
	state.flags.set_flag(FLAG_PAID, 1)
	return true


## Xử lý đầu ngày: trễ hạn, quá hạn, nhắc hạn. Trả thông báo cần hiện.
static func process_day_start(state: GameState, config: EconomyConfig, day: int) -> Array[String]:
	var messages: Array[String] = []
	if is_paid(state):
		return messages
	if not is_late(state) and day > config.tuition_due_day:
		state.flags.set_flag(FLAG_LATE, 1)
		state.stats.change_stat(PlayerStats.Stat.SANITY, config.tuition_late_sanity)
		messages.append(
			"Đã quá hạn học phí. Bạn được gia hạn tới hết Chủ Nhật tuần %d, kèm phạt %s."
			% [_week_of(config.tuition_extended_due_day), MoneyFormat.format_vnd(config.tuition_late_penalty)]
		)
	if is_late(state) and day > config.tuition_extended_due_day:
		if state.flags.get_flag(FLAG_OVERDUE) != 1:
			state.flags.set_flag(FLAG_OVERDUE, 1)
			messages.append("Bạn đã quá cả hạn gia hạn học phí! Hãy đóng ngay ở máy đóng học phí.")
		return messages
	var reminders: Array[int] = (
		config.tuition_extended_reminder_days if is_late(state) else config.tuition_reminder_days
	)
	if reminders.has(day):
		var left: int = deadline(state, config) - day
		var when: String = "Hôm nay là hạn cuối đóng học phí" if left == 0 \
				else "Còn %d ngày tới hạn học phí" % left
		messages.append("%s — cần %s, bạn đang có %s." % [
			when,
			MoneyFormat.format_vnd(amount_due(state, config)),
			MoneyFormat.format_vnd(state.stats.get_money()),
		])
	return messages


static func _week_of(day: int) -> int:
	@warning_ignore("integer_division")
	return (day - 1) / GameClock.DAYS_PER_WEEK + 1
