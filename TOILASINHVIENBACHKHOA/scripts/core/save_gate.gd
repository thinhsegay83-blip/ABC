class_name SaveGate
extends RefCounted
## Chặn lưu tay (vd. đang ở trong vòng lặp cầu thang). Không ảnh hưởng tự lưu đầu ngày.

static var _reasons: Dictionary = {}


static func block(reason: String) -> void:
	_reasons[reason] = true


static func unblock(reason: String) -> void:
	_reasons.erase(reason)


static func is_blocked() -> bool:
	return not _reasons.is_empty()


static func clear() -> void:
	_reasons.clear()
