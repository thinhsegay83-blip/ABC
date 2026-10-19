class_name PuzzleHintConfig
extends Resource
## Ngưỡng Trí tuệ cho 3 mức gợi ý câu đố (FEATURES: câu đố kết hợp — Trí tuệ càng cao gợi ý càng rõ).

## Trí tuệ < level2_min → mức 1; < level3_min → mức 2; còn lại → mức 3.
@export var level2_min: int = 25
@export var level3_min: int = 50
## Sai liên tiếp mỗi N lần → gợi ý tự lên 1 mức.
@export var mistakes_per_level: int = 3
## Sai tổng N lần → mở "Gọi tiền bối".
@export var assist_after_mistakes: int = 8
@export var required_streak: int = 4
@export var wrong_sanity: int = -3
@export var assist_sanity: int = -5
