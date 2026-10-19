extends Control
## Bảng chọn ô lưu (J2). Chỉ phát slot_chosen — việc lưu/tải do màn hình cha làm.
## LOAD: hiện ô tự lưu + ô 1–3, ô trống bị disable.
## SAVE: chỉ ô 1–3; ô đã có dữ liệu phải bấm 2 lần mới ghi đè.

signal slot_chosen(slot: int)
signal closed

enum Mode { SAVE, LOAD }

const AUTO_SLOT_NAME: String = "Tự lưu"
const OVERWRITE_HINT: String = "Bấm lần nữa để ghi đè"
const SLOT_BUTTON_MIN_SIZE: Vector2 = Vector2(0, 48)

var _mode: int = Mode.LOAD
var _slot_buttons: Dictionary = {}  # slot (int) -> Button
var _slot_infos: Dictionary = {}  # slot (int) -> Dictionary từ SaveSystem.get_slot_info()
var _pending_overwrite_slot: int = -1
var _emit_pending: bool = false

@onready var _title_label: Label = %TitleLabel
@onready var _slot_list: VBoxContainer = %SlotList
@onready var _close_button: Button = %CloseButton


func _ready() -> void:
	_close_button.pressed.connect(close)


## Mở bảng ở chế độ Mode.SAVE hoặc Mode.LOAD (gọi lại để làm mới danh sách).
func open(mode: int) -> void:
	_mode = mode
	_pending_overwrite_slot = -1
	_emit_pending = false
	_title_label.text = "Lưu game" if _mode == Mode.SAVE else "Tải game"
	_rebuild_list()
	show()
	_focus_first_enabled()


## Đóng bảng (nút Đóng / Esc từ màn hình cha).
func close() -> void:
	if not visible:
		return
	_pending_overwrite_slot = -1
	hide()
	closed.emit()


func get_mode() -> int:
	return _mode


# --- Dựng danh sách ---------------------------------------------------------

func _rebuild_list() -> void:
	for child: Node in _slot_list.get_children():
		_slot_list.remove_child(child)
		child.queue_free()
	_slot_buttons.clear()
	_slot_infos.clear()

	if _mode == Mode.LOAD:
		_add_slot_button(SaveSystem.AUTO_SLOT)
	for slot: int in range(1, SaveSystem.MANUAL_SLOT_COUNT + 1):
		_add_slot_button(slot)
	_update_button_texts()


func _add_slot_button(slot: int) -> void:
	var info: Dictionary = SaveSystem.get_slot_info(slot)
	var exists: bool = bool(info.get("exists", false))
	var button: Button = Button.new()
	button.name = "Slot%d" % slot
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = SLOT_BUTTON_MIN_SIZE
	button.disabled = _mode == Mode.LOAD and not exists
	button.pressed.connect(_on_slot_pressed.bind(slot))
	_slot_list.add_child(button)
	_slot_buttons[slot] = button
	_slot_infos[slot] = info


## Cập nhật chữ trên các nút (không tạo lại nút — an toàn khi đang trong signal pressed).
func _update_button_texts() -> void:
	for slot: int in _slot_buttons.keys():
		var button: Button = _slot_buttons[slot]
		var info: Dictionary = _slot_infos.get(slot, {})
		button.text = _format_slot_text(slot, info)


## "Ô 1 — Ngày 3 (Tuần 1, Chiều) · Khó · 13.850.000 đ · 18/10/2026 21:30" hoặc "Ô 2 — Trống".
func _format_slot_text(slot: int, info: Dictionary) -> String:
	var slot_title: String = _slot_title(slot)
	if not bool(info.get("exists", false)):
		return "%s — Trống" % slot_title
	if slot == _pending_overwrite_slot:
		return "%s — %s" % [slot_title, OVERWRITE_HINT]

	var parts: PackedStringArray = PackedStringArray()
	parts.append(
		"%s — Ngày %d (Tuần %d, %s)"
		% [
			slot_title,
			int(info.get("day", 1)),
			int(info.get("week", 1)),
			str(info.get("slot_name", "")),
		]
	)
	var difficulty_name: String = str(info.get("difficulty_name", ""))
	if not difficulty_name.is_empty():
		parts.append(difficulty_name)
	parts.append(MoneyFormat.format_vnd(int(info.get("money", 0))))
	var saved_at_text: String = str(info.get("saved_at_text", ""))
	if not saved_at_text.is_empty():
		parts.append(saved_at_text)
	return " · ".join(parts)


func _slot_title(slot: int) -> String:
	if slot == SaveSystem.AUTO_SLOT:
		return AUTO_SLOT_NAME
	return "Ô %d" % slot


func _focus_first_enabled() -> void:
	for child: Node in _slot_list.get_children():
		var button: Button = child as Button
		if button != null and not button.disabled:
			button.grab_focus()
			return
	_close_button.grab_focus()


# --- Xử lý bấm --------------------------------------------------------------

func _on_slot_pressed(slot: int) -> void:
	if _emit_pending:
		return
	var info: Dictionary = _slot_infos.get(slot, {})
	var exists: bool = bool(info.get("exists", false))
	if _mode == Mode.LOAD and not exists:
		return
	# Ghi đè ô đã có dữ liệu: lần bấm đầu chỉ hỏi xác nhận.
	if _mode == Mode.SAVE and exists and _pending_overwrite_slot != slot:
		_pending_overwrite_slot = slot
		_update_button_texts()
		return
	_pending_overwrite_slot = -1
	_update_button_texts()
	_emit_pending = true
	# Phát trễ một nhịp: màn hình cha có thể gọi open() để làm mới (xóa chính nút đang phát signal).
	_emit_slot_chosen.call_deferred(slot)


func _emit_slot_chosen(slot: int) -> void:
	_emit_pending = false
	slot_chosen.emit(slot)
