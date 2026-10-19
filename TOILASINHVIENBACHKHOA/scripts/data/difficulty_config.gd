class_name DifficultyConfig
extends Resource
## Cấu hình chế độ chơi (J13, J18). Số liệu nằm trong data/difficulty_*.tres (theo BALANCE.md).

## Mã chế độ, lưu trong save: "easy" / "hard" / "extreme".
@export var id: String = ""
## Tên hiển thị: "Dễ" / "Khó" / "Cực khó".
@export var display_name: String = ""
## Tiền ban đầu (VND).
@export var starting_money: int = 0
## Hệ số tốc độ tụt Đói/Thể lực/Sanity mỗi khung giờ.
@export var decay_multiplier: float = 1.0
## Hệ số lương làm thêm.
@export var wage_multiplier: float = 1.0
## Mô tả ngắn hiện trong hộp thoại chọn chế độ.
@export_multiline var description: String = ""
