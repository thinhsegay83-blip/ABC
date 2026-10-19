extends Node2D
## Scene chơi chính. Bước 1 chỉ có chữ tạm + HUD + menu tạm dừng; bản đồ làm ở bước 2.

## Dùng khi chạy thẳng scene này (F6) mà chưa có ván chơi.
const FALLBACK_DIFFICULTY_ID: String = "hard"

@onready var _hint_label: Label = %HintLabel


func _ready() -> void:
	get_tree().paused = false
	if not Game.has_active_game():
		Game.new_game(FALLBACK_DIFFICULTY_ID)
	_hint_label.text = _build_hint()


static func _build_hint() -> String:
	var hints: PackedStringArray = PackedStringArray()
	hints.append("Esc: tạm dừng")
	if OS.is_debug_build():
		hints.append("F1: menu debug")
	hints.append("Nút “Nghỉ” trên HUD: qua khung giờ")
	return "   ·   ".join(hints)
