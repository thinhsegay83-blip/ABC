class_name RoomFund
extends RefCounted
## Quỹ phòng (D4): góp 200.000/tháng; Minh + 2 bạn cùng phòng cũng góp (QĐ-5.2 = A).
## Số dư quỹ lưu trong cờ quy_phong (VND) — để C1 làm "Minh mất tích cùng quỹ chung".

const JOIN_FLAG: String = "da_gop_quy"
const BALANCE_FLAG: String = "quy_phong"
const JOINED_DAY_FLAG: String = "sys_quy_phong_ngay_gop"
const CHARGE_ID: String = "quy_phong"
const MEMBERS: int = 4  # bạn + Minh + 2 bạn cùng phòng


## Gọi khi cờ da_gop_quy thành 1. Idempotent: đã góp rồi thì không thu thêm.
static func join(state: GameState, config: EconomyConfig, charges: RecurringCharges) -> bool:
	if state.flags.get_flag(JOINED_DAY_FLAG) > 0:
		return false
	var day: int = state.clock.day
	state.flags.set_flag(JOINED_DAY_FLAG, day)
	if state.flags.get_flag(JOIN_FLAG) != 1:
		state.flags.set_flag(JOIN_FLAG, 1)
	Economy.charge(state, config.room_fund_fee, "Góp quỹ phòng")
	add_round(state, config)
	register(state, config, charges)
	return true


## Đăng ký khoản thu định kỳ (gọi cả khi tải game có cờ đã góp).
static func register(state: GameState, config: EconomyConfig, charges: RecurringCharges) -> void:
	var joined_day: int = state.flags.get_flag(JOINED_DAY_FLAG)
	if joined_day <= 0:
		return
	for entry: Dictionary in charges.entries:
		if entry["id"] == CHARGE_ID:
			return
	charges.register({
		"id": CHARGE_ID,
		"label": "Quỹ phòng tháng",
		"amount": config.room_fund_fee,
		"period_days": config.month_length_days,
		"first_day": joined_day + config.month_length_days,
		"condition_flag": JOIN_FLAG,
		"on_charge": func(charged_state: GameState) -> void: add_round(charged_state, config),
	})


## Cả phòng góp một kỳ → quỹ tăng MEMBERS × phí.
static func add_round(state: GameState, config: EconomyConfig) -> void:
	state.flags.set_flag(BALANCE_FLAG, state.flags.get_flag(BALANCE_FLAG) + MEMBERS * config.room_fund_fee)
