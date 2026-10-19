class_name GameState
extends RefCounted
## Toàn bộ trạng thái một ván chơi: chỉ số, đồng hồ, cờ cốt truyện, chế độ chơi.
## Lưu cả 2 hệ số chế độ trong save → tải game không phụ thuộc file .tres.

const START_STAMINA: int = 100
const START_HUNGER: int = 80
const START_SANITY: int = 80
const START_KNOWLEDGE: int = 10

const DEFAULT_DIFFICULTY_ID: String = "hard"

var stats: PlayerStats
var clock: GameClock
var flags: FlagStore
## Đời sinh viên (bước 4): TKB, điểm danh, túi đồ, sổ thu chi…
var life: LifeState
## Cốt truyện (bước 5): sự kiện đã chạy, nhiệm vụ, tin nhắn, danh bạ.
var story: StoryState
var difficulty_id: String = DEFAULT_DIFFICULTY_ID
## Tên nhân vật (J10). Save cũ thiếu → "" → nơi dùng thay bằng tên mặc định.
var player_name: String = ""
var decay_multiplier: float = 1.0
var wage_multiplier: float = 1.0


func _init() -> void:
	stats = PlayerStats.new()
	clock = GameClock.new()
	flags = FlagStore.new()
	life = LifeState.new()
	story = StoryState.new()
	# Ván "trắng" dùng sẵn chỉ số khởi đầu (tiền = 0 tới khi chọn chế độ).
	stats.from_dict(_start_stats_dict(0))


## Bắt đầu ván mới theo chế độ chơi đã chọn.
func setup_new_game(difficulty: DifficultyConfig) -> void:
	var money: int = 0
	if difficulty == null:
		push_warning("GameState: thiếu DifficultyConfig, dùng mặc định '%s'" % DEFAULT_DIFFICULTY_ID)
		difficulty_id = DEFAULT_DIFFICULTY_ID
		decay_multiplier = 1.0
		wage_multiplier = 1.0
	else:
		difficulty_id = difficulty.id
		decay_multiplier = difficulty.decay_multiplier
		wage_multiplier = difficulty.wage_multiplier
		money = difficulty.starting_money
	stats.from_dict(_start_stats_dict(money))  # cũng xóa quan hệ NPC
	clock.set_time(1, GameClock.Slot.MORNING)
	flags.clear()
	life = LifeState.new()  # StudentLife khởi tạo lại khi thấy initialized = false
	story = StoryState.new()


## Trừ chỉ số theo cấu hình × hệ số chế độ (làm tròn tới số nguyên gần nhất).
func apply_decay(decay: TimeDecayConfig) -> void:
	if decay == null:
		push_warning("GameState: thiếu TimeDecayConfig, bỏ qua tụt chỉ số")
		return
	stats.change_stat(PlayerStats.Stat.HUNGER, -_scaled(decay.hunger_per_slot))
	stats.change_stat(PlayerStats.Stat.STAMINA, -_scaled(decay.stamina_per_slot))
	stats.change_stat(PlayerStats.Stat.SANITY, -_scaled(decay.sanity_per_slot))


## Qua một khung giờ: tụt chỉ số trước rồi mới tăng đồng hồ.
func advance_time(decay: TimeDecayConfig) -> void:
	apply_decay(decay)
	clock.advance()


func to_dict() -> Dictionary:
	return {
		"difficulty_id": difficulty_id,
		"player_name": player_name,
		"decay_multiplier": decay_multiplier,
		"wage_multiplier": wage_multiplier,
		"stats": stats.to_dict(),
		"clock": clock.to_dict(),
		"flags": flags.to_dict(),
		"life": life.to_dict(),
		"story": story.to_dict(),
	}


## Nạp từ Dictionary (thường từ JSON). Ép kiểu rõ ràng mọi giá trị.
func from_dict(data: Dictionary) -> void:
	var id_value: Variant = data.get("difficulty_id", difficulty_id)
	difficulty_id = str(id_value) if id_value != null else DEFAULT_DIFFICULTY_ID
	var name_value: Variant = data.get("player_name", "")
	player_name = name_value if name_value is String else ""
	decay_multiplier = _to_float(data.get("decay_multiplier", decay_multiplier), 1.0)
	wage_multiplier = _to_float(data.get("wage_multiplier", wage_multiplier), 1.0)
	stats.from_dict(_get_dict(data, "stats"))
	clock.from_dict(_get_dict(data, "clock"))
	flags.from_dict(_get_dict(data, "flags"))
	# Save cũ (bước 1) thiếu "life" → LifeState mới, chưa khởi tạo.
	life = LifeState.new()
	life.from_dict(_get_dict(data, "life"))
	story = StoryState.new()
	story.from_dict(_get_dict(data, "story"))


# --- Nội bộ ---------------------------------------------------------------

func _scaled(per_slot: int) -> int:
	return roundi(per_slot * decay_multiplier)


static func _start_stats_dict(money: int) -> Dictionary:
	return {
		"stamina": START_STAMINA,
		"hunger": START_HUNGER,
		"sanity": START_SANITY,
		"knowledge": START_KNOWLEDGE,
		"money": money,
		"relationships": {},
	}


## Lấy Dictionary con; không có hoặc sai kiểu thì trả {}.
static func _get_dict(data: Dictionary, key: String) -> Dictionary:
	var value: Variant = data.get(key, {})
	if value is Dictionary:
		return value
	return {}


static func _to_float(value: Variant, fallback: float) -> float:
	match typeof(value):
		TYPE_INT, TYPE_FLOAT, TYPE_BOOL:
			return float(value)
		TYPE_STRING, TYPE_STRING_NAME:
			var text: String = str(value)
			if text.is_valid_float():
				return text.to_float()
	return fallback
