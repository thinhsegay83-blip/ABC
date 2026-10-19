class_name Economy
extends RefCounted
## Mọi thay đổi tiền đi qua đây để ghi sổ thu chi của ngày (B10).


## Thu nhập (lương, tip…).
static func earn(state: GameState, amount: int, label: String) -> void:
	if amount <= 0:
		return
	state.stats.change_money(amount)
	_log(state, "income", label, amount)


## Chi tiêu tự nguyện: không đủ tiền → false, không trừ.
static func spend(state: GameState, amount: int, label: String) -> bool:
	if amount < 0 or state.stats.get_money() < amount:
		return false
	if amount == 0:
		return true
	state.stats.change_money(-amount)
	_log(state, "expense", label, amount)
	return true


## Khoản bắt buộc (phí KTX…): trừ kể cả khi thành âm tiền (A5 cho phép âm).
static func charge(state: GameState, amount: int, label: String) -> void:
	if amount <= 0:
		return
	state.stats.change_money(-amount)
	_log(state, "expense", label, amount)


## Làm tròn lương tới bội số `step` gần nhất.
static func round_to(amount: float, step: int) -> int:
	if step <= 1:
		return roundi(amount)
	return roundi(amount / step) * step


static func _log(state: GameState, kind: String, label: String, amount: int) -> void:
	state.life.ledger_today.append({"kind": kind, "label": label, "amount": amount})
