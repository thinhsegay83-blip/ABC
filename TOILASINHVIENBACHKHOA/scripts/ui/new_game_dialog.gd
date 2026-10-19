extends Control
## Hộp thoại chọn chế độ chơi (J18). Mỗi chế độ trong Game.get_difficulties() là một nút:
## tên + mô tả + tiền ban đầu.

signal difficulty_chosen(difficulty_id: String)
signal cancelled

## Chế độ được focus sẵn khi mở hộp thoại (trải nghiệm chuẩn).
const DEFAULT_FOCUS_ID: String = "hard"
const BUTTON_MIN_SIZE: Vector2 = Vector2(600, 0)
const META_DIFFICULTY_ID: StringName = &"difficulty_id"

@onready var _difficulty_list: VBoxContainer = %DifficultyList
@onready var _cancel_button: Button = %CancelButton


func _ready() -> void:
	_cancel_button.pressed.connect(close)


func open() -> void:
	_rebuild_list()
	show()
	_focus_default()


## Đóng mà không chọn chế độ (nút Hủy / Esc).
func close() -> void:
	if not visible:
		return
	hide()
	cancelled.emit()


func _rebuild_list() -> void:
	for child: Node in _difficulty_list.get_children():
		_difficulty_list.remove_child(child)
		child.queue_free()

	var difficulties: Array = Game.get_difficulties()
	if difficulties.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "Không tìm thấy dữ liệu chế độ chơi (data/difficulty_*.tres)."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_difficulty_list.add_child(empty_label)
		return

	for difficulty: DifficultyConfig in difficulties:
		if difficulty != null:
			_difficulty_list.add_child(_make_button(difficulty))


func _make_button(difficulty: DifficultyConfig) -> Button:
	var button: Button = Button.new()
	button.text = _describe(difficulty)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.custom_minimum_size = BUTTON_MIN_SIZE
	button.set_meta(META_DIFFICULTY_ID, difficulty.id)
	button.pressed.connect(_on_difficulty_pressed.bind(difficulty.id))
	return button


## Chữ trên nút: tên chế độ, mô tả, tiền ban đầu — mỗi phần một dòng.
static func _describe(difficulty: DifficultyConfig) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append(difficulty.display_name)
	var description: String = difficulty.description.strip_edges()
	if not description.is_empty():
		lines.append(description)
	lines.append("Tiền ban đầu: " + MoneyFormat.format_vnd(difficulty.starting_money))
	return "\n".join(lines)


func _focus_default() -> void:
	var first_button: Button = null
	for child: Node in _difficulty_list.get_children():
		var button: Button = child as Button
		if button == null:
			continue
		if first_button == null:
			first_button = button
		if str(button.get_meta(META_DIFFICULTY_ID, "")) == DEFAULT_FOCUS_ID:
			button.grab_focus()
			return
	if first_button != null:
		first_button.grab_focus()
	else:
		_cancel_button.grab_focus()


func _on_difficulty_pressed(difficulty_id: String) -> void:
	hide()
	difficulty_chosen.emit(difficulty_id)
