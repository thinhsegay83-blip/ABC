extends CanvasLayer
## HUD (J3): Ngày · Tuần · Thứ · Khung giờ, tiền, 4 chỉ số A1–A4 dạng thanh 0–100.
## A6 Quan hệ chưa hiện ở đây — sẽ nằm trong điện thoại (I2).

## Dưới ngưỡng này con số chuyển sang màu cảnh báo (chỉ với các chỉ số "thấp là xấu").
const LOW_THRESHOLD: int = 20
const WARN_STATS: Array[int] = [
	PlayerStats.Stat.STAMINA, PlayerStats.Stat.HUNGER, PlayerStats.Stat.SANITY
]
const VALUE_COLOR: Color = Color(0.92, 0.93, 0.96, 1.0)
const LOW_VALUE_COLOR: Color = Color(1.0, 0.42, 0.36, 1.0)
const MONEY_COLOR: Color = Color(0.98, 0.83, 0.42, 1.0)
const DEBT_COLOR: Color = Color(1.0, 0.42, 0.36, 1.0)

var _bars: Dictionary = {}  # PlayerStats.Stat (int) -> ProgressBar
var _value_labels: Dictionary = {}  # PlayerStats.Stat (int) -> Label

@onready var _time_label: Label = %TimeLabel
@onready var _money_label: Label = %MoneyLabel
@onready var _stamina_bar: ProgressBar = %StaminaBar
@onready var _hunger_bar: ProgressBar = %HungerBar
@onready var _sanity_bar: ProgressBar = %SanityBar
@onready var _knowledge_bar: ProgressBar = %KnowledgeBar
@onready var _stamina_value: Label = %StaminaValue
@onready var _hunger_value: Label = %HungerValue
@onready var _sanity_value: Label = %SanityValue
@onready var _knowledge_value: Label = %KnowledgeValue
@onready var _advance_button: Button = %AdvanceButton


func _ready() -> void:
	_bars = {
		PlayerStats.Stat.STAMINA: _stamina_bar,
		PlayerStats.Stat.HUNGER: _hunger_bar,
		PlayerStats.Stat.SANITY: _sanity_bar,
		PlayerStats.Stat.KNOWLEDGE: _knowledge_bar,
	}
	_value_labels = {
		PlayerStats.Stat.STAMINA: _stamina_value,
		PlayerStats.Stat.HUNGER: _hunger_value,
		PlayerStats.Stat.SANITY: _sanity_value,
		PlayerStats.Stat.KNOWLEDGE: _knowledge_value,
	}
	for bar: ProgressBar in _bars.values():
		bar.min_value = PlayerStats.MIN_VALUE
		bar.max_value = PlayerStats.MAX_VALUE
		bar.show_percentage = false

	Game.stats_changed.connect(_refresh_stats)
	Game.time_changed.connect(_on_time_changed)
	Game.state_replaced.connect(_refresh_all)
	_advance_button.pressed.connect(_on_advance_pressed)
	_refresh_all()


func _refresh_all() -> void:
	visible = Game.has_active_game()
	_refresh_time()
	_refresh_stats()


## "Ngày 3 · Tuần 1 · Thứ Tư · Chiều"
func _refresh_time() -> void:
	var state: GameState = Game.state
	if state == null:
		_time_label.text = ""
		return
	var clock: GameClock = state.clock
	_time_label.text = "Ngày %d · Tuần %d · %s · %s" % [
		clock.day,
		clock.get_week(),
		GameClock.weekday_display_name(clock.get_weekday()),
		GameClock.slot_display_name(clock.slot),
	]


func _refresh_stats() -> void:
	var state: GameState = Game.state
	if state == null:
		return
	var stats: PlayerStats = state.stats
	for stat: int in _bars.keys():
		var value: int = stats.get_stat(stat)
		var bar: ProgressBar = _bars[stat]
		bar.value = value
		var value_label: Label = _value_labels[stat]
		value_label.text = str(value)
		var is_low: bool = WARN_STATS.has(stat) and value <= LOW_THRESHOLD
		value_label.add_theme_color_override("font_color", LOW_VALUE_COLOR if is_low else VALUE_COLOR)

	var money: int = stats.get_money()
	_money_label.text = MoneyFormat.format_vnd(money)
	_money_label.add_theme_color_override("font_color", DEBT_COLOR if money < 0 else MONEY_COLOR)


func _on_time_changed(_day: int, _slot: int) -> void:
	_refresh_time()


## Nút tạm để thử nhịp thời gian, sẽ thay bằng hành động thật ở bước 4.
func _on_advance_pressed() -> void:
	if Game.has_active_game():
		Game.advance_time()
