extends Control
## Menu chính (J1): Chơi mới (chọn chế độ — J18), Tiếp tục, Tải game, Cài đặt, Thoát.

const NewGameDialogScript = preload("res://scripts/ui/new_game_dialog.gd")
const SaveSlotsPanelScript = preload("res://scripts/ui/save_slots_panel.gd")
const SettingsPanelScript = preload("res://scripts/ui/settings_panel.gd")
const NameDialogScript = preload("res://scripts/ui/name_dialog.gd")

var _starting: bool = false  # đã vào game, đang chờ chuyển scene → khóa menu
var _last_focused: Button = null
var _chosen_difficulty: String = ""
var _name_dialog: NameDialogScript

@onready var _new_game_button: Button = %NewGameButton
@onready var _continue_button: Button = %ContinueButton
@onready var _load_button: Button = %LoadButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _new_game_dialog: NewGameDialogScript = %NewGameDialog
@onready var _save_slots_panel: SaveSlotsPanelScript = %SaveSlotsPanel
@onready var _settings_panel: SettingsPanelScript = %SettingsPanel


func _ready() -> void:
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_continue_button.pressed.connect(_on_continue_pressed)
	_load_button.pressed.connect(_on_load_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)

	_new_game_dialog.difficulty_chosen.connect(_on_difficulty_chosen)
	_new_game_dialog.cancelled.connect(_on_panel_closed)
	_save_slots_panel.slot_chosen.connect(_on_load_slot_chosen)
	_save_slots_panel.closed.connect(_on_panel_closed)
	_settings_panel.closed.connect(_on_panel_closed)

	_name_dialog = NameDialogScript.new()
	add_child(_name_dialog)
	_name_dialog.name_confirmed.connect(_on_name_confirmed)
	_name_dialog.cancelled.connect(_on_name_cancelled)

	_new_game_dialog.hide()
	_save_slots_panel.hide()
	_settings_panel.hide()

	_refresh_continue_button()
	_focus_default()


## Esc: đóng bảng con đang mở (nếu có).
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if _starting:
		return
	if _name_dialog.visible:
		_name_dialog.close()
	elif _new_game_dialog.visible:
		_new_game_dialog.close()
	elif _save_slots_panel.visible:
		_save_slots_panel.close()
	elif _settings_panel.visible:
		_settings_panel.close()
	else:
		return
	get_viewport().set_input_as_handled()


# --- Nút menu ---------------------------------------------------------------

func _on_new_game_pressed() -> void:
	_before_open_panel()
	_new_game_dialog.open()


func _on_continue_pressed() -> void:
	var slot: int = SaveSystem.get_latest_slot()
	if slot == -1:
		_refresh_continue_button()
		return
	if not _load_slot_and_start(slot):
		_refresh_continue_button()


func _on_load_pressed() -> void:
	_before_open_panel()
	_save_slots_panel.open(SaveSlotsPanelScript.Mode.LOAD)


func _on_settings_pressed() -> void:
	_before_open_panel()
	_settings_panel.open()


func _on_quit_pressed() -> void:
	get_tree().quit()


# --- Kết quả từ bảng con ------------------------------------------------------

## Chọn chế độ → hộp đặt tên (J10) → vào game.
func _on_difficulty_chosen(difficulty_id: String) -> void:
	if _starting:
		return
	_chosen_difficulty = difficulty_id
	_name_dialog.open()


func _on_name_confirmed(player_name: String) -> void:
	if _starting:
		return
	Game.new_game(_chosen_difficulty)
	Game.state.player_name = player_name
	_go_to_game()


## "Quay lại" từ hộp đặt tên → về hộp chọn chế độ.
func _on_name_cancelled() -> void:
	if not _starting:
		_new_game_dialog.open()


func _on_load_slot_chosen(slot: int) -> void:
	if _starting:
		return
	if not _load_slot_and_start(slot):
		# Ô hỏng → mở lại để cập nhật danh sách.
		_save_slots_panel.open(SaveSlotsPanelScript.Mode.LOAD)


## Gọi khi một bảng con đóng (Hủy / Đóng / Esc).
func _on_panel_closed() -> void:
	if _starting:
		return
	_set_menu_focusable(true)
	_refresh_continue_button()
	if _last_focused != null and is_instance_valid(_last_focused) and not _last_focused.disabled:
		_last_focused.grab_focus()
	else:
		_focus_default()


# --- Nội bộ -----------------------------------------------------------------

## Tải ô lưu và vào game. Trả false nếu ô trống/hỏng.
func _load_slot_and_start(slot: int) -> bool:
	var state: GameState = SaveSystem.load_from_slot(slot)
	if state == null:
		Toast.show_message("Không tải được bản lưu (file hỏng hoặc của phiên bản mới hơn).")
		return false
	Game.load_game(state)
	_go_to_game()
	return true


func _go_to_game() -> void:
	if _starting:
		return
	_starting = true
	_set_menu_disabled(true)
	SceneLoader.change_scene(SceneLoader.GAME_SCENE)


func _refresh_continue_button() -> void:
	var has_save: bool = SaveSystem.get_latest_slot() != -1
	_continue_button.disabled = not has_save
	_continue_button.tooltip_text = "" if has_save else "Chưa có bản lưu nào"


## Ghi nhớ nút đang focus và chặn focus lọt xuống menu phía sau bảng con.
func _before_open_panel() -> void:
	_last_focused = get_viewport().gui_get_focus_owner() as Button
	_set_menu_focusable(false)


func _menu_buttons() -> Array[Button]:
	return [_new_game_button, _continue_button, _load_button, _settings_button, _quit_button]


func _set_menu_focusable(enabled: bool) -> void:
	for button: Button in _menu_buttons():
		button.focus_mode = FOCUS_ALL if enabled else FOCUS_NONE


func _set_menu_disabled(disabled: bool) -> void:
	for button: Button in _menu_buttons():
		button.disabled = disabled


func _focus_default() -> void:
	if not _continue_button.disabled:
		_continue_button.grab_focus()
	else:
		_new_game_button.grab_focus()
