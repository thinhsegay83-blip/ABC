class_name EconomyConfig
extends Resource
## Cấu hình kinh tế + lịch học (J13). Số liệu theo BALANCE.md; số [ĐX] ghi trong mục "Đề xuất bước 4".

@export_group("Học phí HK1")
@export var tuition_amount: int = 16000000
## Hết ngày này mà chưa đóng → đầu ngày hôm sau xử lý trễ hạn.
@export var tuition_due_day: int = 14
@export var tuition_extended_due_day: int = 28
## Phạt cộng vào khoản phải đóng (QĐ-4.2 = A).
@export var tuition_late_penalty: int = 500000
@export var tuition_late_sanity: int = -10
@export var tuition_reminder_days: Array[int] = [8, 12, 13, 14]
@export var tuition_extended_reminder_days: Array[int] = [22, 26, 27, 28]

@export_group("Phí định kỳ")
@export var ktx_fee: int = 300000
@export var room_fund_fee: int = 200000
@export var month_length_days: int = 28

@export_group("Làm thêm")
@export var max_shifts_per_day: int = 2
@export var wage_round_to: int = 1000

@export_group("Học tập")
## Ngày 1 là ngày nhận phòng, chưa có tiết.
@export var classes_start_day: int = 2
## Đói dưới ngưỡng này: học ×0,5, Thể lực tụt thêm, ngủ hồi một nửa.
@export var hungry_threshold: int = 20
@export var hungry_stamina_per_slot: int = 3
@export var starving_stamina_per_slot: int = 6

@export_group("Ngủ")
## Đi ngủ từ buổi Tối (sớm) hồi thêm Thể lực so với ngủ lúc Đêm.
@export var early_sleep_bonus_stamina: int = 15

@export_group("Hậu quả")
@export var faint_stamina: int = 30
@export var faint_sanity: int = -5
@export var rest_sanity: int = 30
@export var rest_stamina: int = 60
