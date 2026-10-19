class_name TimeDecayConfig
extends Resource
## Lượng chỉ số tụt mỗi khung giờ (J13), trước khi nhân hệ số chế độ chơi.
## Giá trị trong data/time_decay.tres — chưa cân bằng.

## Độ no (HUNGER) giảm mỗi khung giờ.
@export var hunger_per_slot: int = 8
## Thể lực giảm mỗi khung giờ.
@export var stamina_per_slot: int = 5
## Sanity giảm mỗi khung giờ.
@export var sanity_per_slot: int = 0
