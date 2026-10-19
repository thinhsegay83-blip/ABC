class_name GameClock
extends RefCounted
## Đồng hồ game (B1): ngày, 4 khung giờ, tuần. Ngày 1 = Thứ Hai tuần 1.

signal time_changed(day: int, slot: int)
signal new_day(day: int)

enum Slot { MORNING, AFTERNOON, EVENING, NIGHT }

const SLOT_COUNT: int = 4
const DAYS_PER_WEEK: int = 7

var day: int = 1
var slot: int = Slot.MORNING


## Sang khung giờ kế tiếp; qua Đêm thì về Sáng ngày hôm sau.
## Thứ tự: cập nhật biến → time_changed → (nếu sang ngày) new_day.
func advance() -> void:
	var crossed_day: bool = false
	slot += 1
	if slot >= SLOT_COUNT:
		slot = Slot.MORNING
		day += 1
		crossed_day = true
	time_changed.emit(day, slot)
	if crossed_day:
		new_day.emit(day)


## Đặt thời gian trực tiếp (tải game / debug). Chỉ emit time_changed.
func set_time(new_day_value: int, new_slot: int) -> void:
	day = maxi(1, new_day_value)
	slot = clampi(new_slot, 0, SLOT_COUNT - 1)
	time_changed.emit(day, slot)


func get_week() -> int:
	@warning_ignore("integer_division")
	return (day - 1) / DAYS_PER_WEEK + 1


## 0 = Thứ Hai … 6 = Chủ Nhật.
func get_weekday() -> int:
	return posmod(day - 1, DAYS_PER_WEEK)


func to_dict() -> Dictionary:
	return {"day": day, "slot": slot}


## JSON trả số dạng float → ép int. Khóa thiếu thì giữ giá trị hiện tại.
func from_dict(data: Dictionary) -> void:
	var loaded_day: int = _to_int(data.get("day", day), day)
	var loaded_slot: int = _to_int(data.get("slot", slot), slot)
	set_time(loaded_day, loaded_slot)


static func slot_display_name(slot_value: int) -> String:
	match slot_value:
		Slot.MORNING:
			return "Sáng"
		Slot.AFTERNOON:
			return "Chiều"
		Slot.EVENING:
			return "Tối"
		Slot.NIGHT:
			return "Đêm"
	return "?"


static func weekday_display_name(weekday: int) -> String:
	match weekday:
		0:
			return "Thứ Hai"
		1:
			return "Thứ Ba"
		2:
			return "Thứ Tư"
		3:
			return "Thứ Năm"
		4:
			return "Thứ Sáu"
		5:
			return "Thứ Bảy"
		6:
			return "Chủ Nhật"
	return "?"


## Ép Variant (int/float/bool/chuỗi số) về int; kiểu khác trả fallback.
static func _to_int(value: Variant, fallback: int) -> int:
	match typeof(value):
		TYPE_INT, TYPE_FLOAT, TYPE_BOOL:
			return int(value)
		TYPE_STRING, TYPE_STRING_NAME:
			var text: String = str(value)
			if text.is_valid_int():
				return text.to_int()
			if text.is_valid_float():
				return int(text.to_float())
	return fallback
