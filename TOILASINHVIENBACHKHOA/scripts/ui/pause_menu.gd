extends CanvasLayer
## Menu tạm dừng (J1) — phím "pause" (Esc). Chạy cả khi cây scene bị pause (process_mode ALWAYS).
## Lưu / tải game, cài đặt, về menu chính, thoát.

const SaveSlotsPanelScript = preload("res://scripts/ui/save_slots_panel.gd")
const SettingsPanelScript = preload("res://scripts/ui/settings_panel.gd")

var _slots_mode: int = SaveSlotsPanelScript.Mode.SAVE
var _last_focused: Button = null
var _leaving: bool = false  # đang về menu chính / thoát → bỏ qua mọi thao tác

@onready var _root: Control = %Root
@onready var _menu_panel: Control = %MenuPanel
@onready var _resume_button: Button = %ResumeButton
@onready var _save_button: Button = %SaveButton
@onready var _load_button: Button = %LoadButton
@onready var _settings_button: Button = %SettingsButton
@onready var _main_menu_button: Button = %MainMenuButton
@onready var _quit_button: Button = %QuitButton
@onready var _save_slots_panel: SaveSlotsPanelScript = %SaveSlotsPanel
@onready var _settings_panel: SettingsPanelScript = %SettingsPanel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root.hide()
	_save_slots_panel.hide()
	_settings_panel.hide()

	_resume_button.pressed.connect(resume)
	_save_button.pressed.connect(_on_save_pressed)
	_load_button.pressed.connect(_on_load_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_main_menu_button.pressed.connect(_on_main_menu_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)

	_save_slots_panel.slot_chosen.connect(_on_slot_chosen)
	_save_slots_panel.closed.connect(_on_sub_panel_closed)
	_settings_panel.closed.connect(_on_sub_panel_closed)


## Esc: đang mở bảng con thì đóng bảng con; không thì bật/tắt tạm dừng.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	get_viewport().set_input_as_handled()
	if _leaving or SceneLoader.is_transitioning:
		return
	if _save_slots_panel.visible:
		_save_slots_panel.close()
	elif _settings_panel.visible:
		_settings_panel.close()
	elif is_open():
		resume()
	else:
		open_menu()


func is_open() -> bool:
	return _root.visible


## Tạm dừng game và hiện menu.
func open_menu() -> void:
	if _leaving or not Game.has_active_game():
		return
	get_tree().paused = true
	_save_button.disabled = SaveGate.is_blocked()
	_save_button.tooltip_text = "Không thể lưu lúc này" if SaveGate.is_blocked() else ""
	_save_button.text = "Lưu game (không thể lưu lúc này)" if SaveGate.is_blocked() else "Lưu game"
	_menu_panel.show()
	_root.show()
	_resume_button.grab_focus()


## Đóng menu (và mọi bảng con) rồi chạy tiếp game.
func resume() -> void:
	if _leaving:
		return
	_hide_sub_panels()
	_root.hide()
	get_tree().paused = false


# --- Nút menu ---------------------------------------------------------------

func _on_save_pressed() -> void:
	if SaveGate.is_blocked():
		return
	_open_slots(SaveSlotsPanelScript.Mode.SAVE)


func _on_load_pressed() -> void:
	_open_slots(SaveSlotsPanelScript.Mode.LOAD)


func _on_settings_pressed() -> void:
	_before_open_sub_panel()
	_settings_panel.open()


func _on_main_menu_pressed() -> void:
	if _leaving:
		return
	_leaving = true
	_set_buttons_disabled(true)
	_hide_sub_panels()
	get_tree().paused = false
	Game.end_game()
	SceneLoader.change_scene(SceneLoader.MAIN_MENU_SCENE)


func _on_quit_pressed() -> void:
	_leaving = true
	get_tree().quit()


# --- Lưu / tải ----------------------------------------------------------------

func _open_slots(mode: int) -> void:
	_slots_mode = mode
	_before_open_sub_panel()
	_save_slots_panel.open(mode)


func _on_slot_chosen(slot: int) -> void:
	if _leaving:
		return
	if _slots_mode == SaveSlotsPanelScript.Mode.SAVE:
		_save_to_slot(slot)
	else:
		_load_from_slot(slot)


func _save_to_slot(slot: int) -> void:
	if not Game.has_active_game():
		Toast.show_message("Không có ván chơi nào để lưu.")
		return
	if SaveSystem.save_to_slot(slot, Game.state):
		Toast.show_message("Đã lưu vào ô %d" % slot)
		_save_slots_panel.close()
	else:
		Toast.show_message("Lưu thất bại — không ghi được file.")


func _load_from_slot(slot: int) -> void:
	var state: GameState = SaveSystem.load_from_slot(slot)
	if state == null:
		Toast.show_message("Không tải được bản lưu (file hỏng hoặc của phiên bản mới hơn).")
		_save_slots_panel.open(SaveSlotsPanelScript.Mode.LOAD)  # làm mới danh sách
		return
	Game.load_game(state)
	resume()
	if slot == SaveSystem.AUTO_SLOT:
		Toast.show_message("Đã tải bản tự lưu")
	else:
		Toast.show_message("Đã tải ô %d" % slot)


# --- Nội bộ -----------------------------------------------------------------

## Ẩn khung nút của menu để bảng con chiếm chỗ, nhớ nút đang focus để trả lại sau.
func _before_open_sub_panel() -> void:
	_last_focused = get_viewport().gui_get_focus_owner() as Button
	_menu_panel.hide()


func _on_sub_panel_closed() -> void:
	if _leaving or not is_open():
		return
	_menu_panel.show()
	if _last_focused != null and is_instance_valid(_last_focused):
		_last_focused.grab_focus()
	else:
		_resume_button.grab_focus()


## Ẩn các bảng con mà không trả focus về menu (cài đặt vẫn được lưu).
func _hide_sub_panels() -> void:
	if _settings_panel.visible:
		Settings.save_settings()
		_settings_panel.hide()
	_save_slots_panel.hide()
	_menu_panel.show()


func _set_buttons_disabled(disabled: bool) -> void:
	var buttons: Array[Button] = [
		_resume_button, _save_button, _load_button, _settings_button, _main_menu_button, _quit_button
	]
	for button: Button in buttons:
		button.disabled = disabled
