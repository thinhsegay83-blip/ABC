# Kiến trúc — Bước 1 (Nền tảng)

Đây là **hợp đồng chung** giữa các file. Mọi tên class, hàm, signal, đường dẫn, tên node dưới đây phải dùng đúng y hệt.

- Engine: **Godot 4.4+** (viết tương thích 4.4, chạy được trên bản mới hơn). Ngôn ngữ: **GDScript, có kiểu tĩnh** (`var x: int`, `-> void`).
- Renderer: `gl_compatibility`. Cửa sổ 1280×720, stretch `canvas_items`, aspect `expand`. Lọc texture mặc định: nearest (pixel art).
- Văn bản hiển thị: **tiếng Việt có dấu**. Tên biến/hàm: tiếng Anh, snake_case.
- KHÔNG dùng typed Dictionary (`Dictionary[String, int]`) — dùng `Dictionary` thường.
- Mã tính năng (A1, J2…) tham chiếu `FEATURES.md`. Số liệu chế độ chơi lấy từ `BALANCE.md`.

## Cây thư mục

```
project.godot
scripts/core/        logic thuần (extends RefCounted), không cần scene tree
  player_stats.gd    class_name PlayerStats
  game_clock.gd      class_name GameClock
  flag_store.gd      class_name FlagStore
  game_state.gd      class_name GameState
  money_format.gd    class_name MoneyFormat
  save_codec.gd      class_name SaveCodec
scripts/data/
  difficulty_config.gd   class_name DifficultyConfig (extends Resource)
  time_decay_config.gd   class_name TimeDecayConfig (extends Resource)
scripts/autoload/    KHÔNG khai báo class_name (tránh trùng tên autoload)
  audio_manager.gd  settings.gd  save_system.gd  game.gd
  scene_loader.gd   toast.gd     debug_menu.gd
scripts/ui/
  main_menu.gd  new_game_dialog.gd  save_slots_panel.gd
  settings_panel.gd  pause_menu.gd  hud.gd  game_scene.gd
scenes/
  main_menu.tscn  game.tscn
  ui/new_game_dialog.tscn  ui/save_slots_panel.tscn  ui/settings_panel.tscn
  ui/pause_menu.tscn  ui/hud.tscn
data/
  difficulty_easy.tres  difficulty_hard.tres  difficulty_extreme.tres
  time_decay.tres
fonts/               (người dùng tự tải BeVietnamPro-Regular.ttf, BeVietnamPro-Bold.ttf + OFL.txt)
tests/
  test_case.gd       class cơ sở cho test (extends RefCounted)
  run_tests.gd       extends SceneTree — chạy: godot --headless --path . -s res://tests/run_tests.gd
  test_player_stats.gd  test_game_clock.gd  test_flag_store.gd
  test_game_state.gd    test_money_format.gd  test_save.gd
```

---

## 1. Logic thuần — `scripts/core/`

### PlayerStats (`extends RefCounted`) — A1–A6
```
enum Stat { STAMINA, HUNGER, SANITY, KNOWLEDGE }
const MIN_VALUE: int = 0
const MAX_VALUE: int = 100
signal stats_changed

func get_stat(stat: int) -> int
func set_stat(stat: int, value: int) -> void        # clamp 0–100, chỉ emit khi giá trị đổi
func change_stat(stat: int, delta: int) -> void
func get_money() -> int
func set_money(value: int) -> void                  # KHÔNG clamp, cho phép âm
func change_money(delta: int) -> void
func get_relationship(npc_id: String) -> int        # mặc định 0 nếu chưa có
func set_relationship(npc_id: String, value: int) -> void   # clamp 0–100
func change_relationship(npc_id: String, delta: int) -> void
func get_relationships() -> Dictionary              # bản sao
func to_dict() -> Dictionary
func from_dict(data: Dictionary) -> void            # ép int() mọi số (JSON trả float!)
static func stat_display_name(stat: int) -> String  # "Thể lực", "Đói", "Sanity", "Trí tuệ"
```
- **Ngữ nghĩa HUNGER:** giá trị = **độ no**. 100 = no căng, 0 = đói lả. Tụt theo thời gian, ăn thì tăng. HUD hiển thị nhãn "Đói".
- `to_dict()` dạng: `{"stamina":int,"hunger":int,"sanity":int,"knowledge":int,"money":int,"relationships":{id:int}}`.

### GameClock (`extends RefCounted`) — B1
```
enum Slot { MORNING, AFTERNOON, EVENING, NIGHT }
const SLOT_COUNT: int = 4
const DAYS_PER_WEEK: int = 7
signal time_changed(day: int, slot: int)
signal new_day(day: int)

var day: int = 1          # ngày 1 = Thứ Hai tuần 1
var slot: int = Slot.MORNING

func advance() -> void    # slot+1; qua NIGHT → MORNING và day+1.
                          # Thứ tự: cập nhật biến → emit time_changed → (nếu sang ngày) emit new_day
func set_time(new_day_value: int, new_slot: int) -> void   # dùng cho tải game/debug; day >= 1; chỉ emit time_changed
func get_week() -> int    # (day-1)/7 + 1  (dùng @warning_ignore("integer_division"))
func get_weekday() -> int # 0 = Thứ Hai … 6 = Chủ Nhật
func to_dict() -> Dictionary      # {"day":int,"slot":int}
func from_dict(data: Dictionary) -> void
static func slot_display_name(slot_value: int) -> String     # "Sáng","Chiều","Tối","Đêm"
static func weekday_display_name(weekday: int) -> String     # "Thứ Hai" … "Chủ Nhật"
```

### FlagStore (`extends RefCounted`) — cờ cốt truyện
```
signal flag_changed(key: String, value: int)
func get_flag(key: String, default_value: int = 0) -> int
func set_flag(key: String, value: int) -> void
func has_flag(key: String) -> bool
func clear() -> void
func to_dict() -> Dictionary
func from_dict(data: Dictionary) -> void      # ép int()
```

### MoneyFormat (`extends RefCounted`, chỉ hàm static)
```
static func format_vnd(amount: int) -> String
```
`0 → "0 đ"`, `1500000 → "1.500.000 đ"`, `-250000 → "-250.000 đ"`, `999 → "999 đ"`, `1000 → "1.000 đ"`.

### GameState (`extends RefCounted`)
```
const START_STAMINA: int = 100
const START_HUNGER: int = 80
const START_SANITY: int = 80
const START_KNOWLEDGE: int = 10

var stats: PlayerStats
var clock: GameClock
var flags: FlagStore
var difficulty_id: String = "hard"
var decay_multiplier: float = 1.0
var wage_multiplier: float = 1.0

func _init() -> void                                   # tạo stats/clock/flags mới
func setup_new_game(difficulty: DifficultyConfig) -> void
    # reset stats về START_*, tiền = difficulty.starting_money, clock về ngày 1 sáng,
    # xóa flags, chép id + 2 hệ số
func apply_decay(decay: TimeDecayConfig) -> void
    # trừ hunger/stamina/sanity = roundi(x_per_slot * decay_multiplier)
func advance_time(decay: TimeDecayConfig) -> void      # apply_decay(decay) rồi clock.advance()
func to_dict() -> Dictionary
    # {"difficulty_id","decay_multiplier","wage_multiplier","stats":{},"clock":{},"flags":{}}
func from_dict(data: Dictionary) -> void
```
- GameState lưu cả 2 hệ số trong save → tải game không phụ thuộc file .tres.

### SaveCodec (`extends RefCounted`, chỉ hàm static) — J2
```
const SAVE_VERSION: int = 1
static func encode(state: GameState, saved_at_unix: float) -> Dictionary
    # {"version":SAVE_VERSION,"saved_at":saved_at_unix,"state":state.to_dict()}
static func decode(data: Dictionary) -> GameState
    # trả null nếu thiếu "state", thiếu "version", hoặc version > SAVE_VERSION.
    # version < SAVE_VERSION → gọi _migrate (hiện chưa có gì, để sẵn chỗ)
static func to_json(state: GameState, saved_at_unix: float) -> String   # JSON.stringify(..., "\t")
static func from_json(text: String) -> GameState                        # null nếu JSON lỗi
```
**Bẫy quan trọng:** `JSON.parse_string` trả mọi số dạng `float`. Mọi `from_dict` phải `int(...)` / `float(...)` rõ ràng.

---

## 2. Dữ liệu — `scripts/data/` + `data/` — J13, J18

### DifficultyConfig (`extends Resource`)
```
@export var id: String = ""
@export var display_name: String = ""
@export var starting_money: int = 0
@export var decay_multiplier: float = 1.0
@export var wage_multiplier: float = 1.0
@export_multiline var description: String = ""
```
| file | id | display_name | starting_money | decay | wage |
|---|---|---|---|---|---|
| data/difficulty_easy.tres | easy | Dễ | 15000000 | 0.75 | 1.0 |
| data/difficulty_hard.tres | hard | Khó | 14000000 | 1.0 | 1.0 |
| data/difficulty_extreme.tres | extreme | Cực khó | 12000000 | 1.25 | 0.9 |

### TimeDecayConfig (`extends Resource`)
```
@export var hunger_per_slot: int = 8
@export var stamina_per_slot: int = 5
@export var sanity_per_slot: int = 0
```
`data/time_decay.tres` dùng đúng các giá trị mặc định trên (chưa cân bằng).

Mẫu `.tres`:
```
[gd_resource type="Resource" script_class="DifficultyConfig" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/data/difficulty_config.gd" id="1_cfg"]

[resource]
script = ExtResource("1_cfg")
id = "easy"
...
```

---

## 3. Autoload — `scripts/autoload/`

Thứ tự trong `project.godot` (quan trọng, `_ready` chạy theo thứ tự này):
```
[autoload]
AudioManager="*res://scripts/autoload/audio_manager.gd"
Settings="*res://scripts/autoload/settings.gd"
SaveSystem="*res://scripts/autoload/save_system.gd"
Game="*res://scripts/autoload/game.gd"
SceneLoader="*res://scripts/autoload/scene_loader.gd"
Toast="*res://scripts/autoload/toast.gd"
DebugMenu="*res://scripts/autoload/debug_menu.gd"
```
Các autoload có giao diện (SceneLoader, Toast, DebugMenu) và Game đặt `process_mode = PROCESS_MODE_ALWAYS` để chạy được khi game tạm dừng.

### AudioManager (`extends Node`) — J5
```
const MUSIC_BUS: String = "Music"
const SFX_BUS: String = "SFX"
func _ready()  # tạo bus Music, SFX (send về "Master") nếu chưa có; tạo 1 AudioStreamPlayer nhạc + pool 8 player SFX
func play_music(stream: AudioStream, fade_time: float = 0.5) -> void   # stream null → bỏ qua
func stop_music(fade_time: float = 0.5) -> void
func play_sfx(stream: AudioStream) -> void
func set_bus_volume_linear(bus_name: String, value: float) -> void      # 0..1; 0 → mute
func get_bus_volume_linear(bus_name: String) -> float
```

### Settings (`extends Node`) — J1 phần Cài đặt
```
const SETTINGS_PATH: String = "user://settings.cfg"
const RESOLUTIONS: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
signal settings_changed
var music_volume: float = 0.8
var sfx_volume: float = 0.8
var fullscreen: bool = false
var resolution_index: int = 0
func _ready()                 # load_settings() rồi apply()
func load_settings() -> void  # ConfigFile, section "audio"/"display"
func save_settings() -> void
func apply() -> void          # gọi AudioManager.set_bus_volume_linear; DisplayServer window mode/size; emit settings_changed
```
- Không đổi kích thước cửa sổ khi chạy `--headless` (`DisplayServer.get_name() == "headless"`).

### SaveSystem (`extends Node`) — J2
```
const SAVE_DIR: String = "user://saves/"
const AUTO_SLOT: int = 0
const MANUAL_SLOT_COUNT: int = 3            # ô 1, 2, 3
var save_dir: String = SAVE_DIR             # test có thể đổi sang thư mục khác
func get_slot_path(slot: int) -> String     # 0 → "autosave.json", n → "slot_n.json"
func save_to_slot(slot: int, state: GameState) -> bool   # ghi file tạm rồi đổi tên; tạo thư mục nếu chưa có
func load_from_slot(slot: int) -> GameState               # null nếu không có/hỏng
func autosave(state: GameState) -> bool                   # = save_to_slot(AUTO_SLOT, state)
func has_save(slot: int) -> bool
func get_slot_info(slot: int) -> Dictionary
    # {"exists":bool, "slot":int, "day":int, "week":int, "slot_name":String,
    #  "difficulty_name":String, "money":int, "saved_at":float, "saved_at_text":String}
func get_latest_slot() -> int               # ô có saved_at mới nhất, -1 nếu không có
```
SaveSystem phải dùng được khi chỉ `new()` mà không thêm vào scene tree (để test).

### Game (`extends Node`) — trung tâm, giữ GameState
```
signal state_replaced                         # có ván mới hoặc vừa tải game
signal stats_changed                          # chuyển tiếp từ state.stats
signal time_changed(day: int, slot: int)      # chuyển tiếp từ state.clock
signal new_day(day: int)
const DIFFICULTY_PATHS: Array[String] = ["res://data/difficulty_easy.tres", "res://data/difficulty_hard.tres", "res://data/difficulty_extreme.tres"]
const TIME_DECAY_PATH: String = "res://data/time_decay.tres"
const FONT_REGULAR_PATH: String = "res://fonts/BeVietnamPro-Regular.ttf"
var state: GameState = null
var time_decay: TimeDecayConfig

func _ready()           # nạp time_decay; _ensure_input_actions(); _apply_font()
func get_difficulties() -> Array[DifficultyConfig]
func get_difficulty(id: String) -> DifficultyConfig      # null nếu không có
func new_game(difficulty_id: String) -> void             # tạo GameState, setup_new_game, _bind_state, emit state_replaced
func load_game(new_state: GameState) -> void              # _bind_state, emit state_replaced
func end_game() -> void                                   # state = null (về menu chính)
func has_active_game() -> bool
func advance_time() -> void                               # state.advance_time(time_decay)
func _bind_state(new_state)  # ngắt kết nối state cũ, nối signal của state mới để chuyển tiếp
func _on_new_day(day)        # SaveSystem.autosave(state); Toast.show_message("Đã tự lưu — Ngày %d" % day)
func _ensure_input_actions() # nếu InputMap thiếu "pause"(Esc)/"debug"(F1)/"interact"(E) thì thêm bằng code
func _apply_font()           # nếu ResourceLoader.exists(FONT_REGULAR_PATH) → ThemeDB.fallback_font = load(...)
                             # không có font thì bỏ qua, game vẫn chạy
```

### SceneLoader (`extends CanvasLayer`, layer 100) — J4
```
const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const GAME_SCENE: String = "res://scenes/game.tscn"
signal scene_changed(path: String)
var is_transitioning: bool = false
func _ready()       # tạo ColorRect đen full màn hình, alpha 0, mouse_filter IGNORE
func change_scene(path: String, fade_time: float = 0.3) -> void
    # bỏ qua nếu đang chuyển; chặn chuột; fade 0→1; get_tree().paused = false;
    # get_tree().change_scene_to_file(path); await process_frame; fade 1→0; mở chuột; emit scene_changed
```

### Toast (`extends CanvasLayer`, layer 90) — J8
```
func show_message(text: String, duration: float = 2.5) -> void
```
Hiện ở góc trên bên phải, nhiều toast xếp chồng (VBoxContainer), mờ dần rồi tự xóa. Tween dùng `TWEEN_PAUSE_PROCESS` để chạy cả khi pause.

### DebugMenu (`extends CanvasLayer`, layer 120) — J12
- Chỉ hoạt động khi `OS.is_debug_build()`; ngược lại `_ready` tự `queue_free()`.
- Phím `debug` (F1) bật/tắt; chỉ mở được khi `Game.has_active_game()`.
- Dựng UI bằng code (PanelContainer bên trái): mỗi chỉ số A1–A4 có nút −10/+10; tiền −100.000/+100.000; nút "Qua khung giờ" (`Game.advance_time()`); nút "Nhảy 1 ngày (không tụt chỉ số)" (`clock.set_time(day+1, MORNING)`); ô nhập tên cờ + SpinBox giá trị + nút "Đặt cờ"; một Label hiện tóm tắt trạng thái, tự cập nhật.

---

## 4. Giao diện — `scenes/` + `scripts/ui/`

Quy ước: node được script truy cập đặt `unique_name_in_owner = true` và lấy bằng `%TenNode`. Mọi chữ hiển thị tiếng Việt.

### scenes/main_menu.tscn — `main_menu.gd` (J1)
Root `Control` "MainMenu" full màn hình. Con:
- `ColorRect` nền tối.
- `VBoxContainer` căn giữa: `Label` %TitleLabel "TÔI LÀ SINH VIÊN BÁCH KHOA"; các `Button`: %NewGameButton "Chơi mới", %ContinueButton "Tiếp tục", %LoadButton "Tải game", %SettingsButton "Cài đặt", %QuitButton "Thoát".
- Instance ẩn: %NewGameDialog (new_game_dialog.tscn), %SaveSlotsPanel (save_slots_panel.tscn), %SettingsPanel (settings_panel.tscn).
- Hành vi: Tiếp tục bị disable nếu `SaveSystem.get_latest_slot() == -1`; bấm thì tải ô mới nhất → `Game.load_game` → `SceneLoader.change_scene(GAME_SCENE)`. Tải game mở SaveSlotsPanel chế độ "load". Chơi mới mở NewGameDialog; khi chọn chế độ → `Game.new_game(id)` → chuyển scene. Thoát → `get_tree().quit()`.

### scenes/ui/new_game_dialog.tscn — `new_game_dialog.gd` (J18)
Root `Control` full màn hình (nền mờ) + `PanelContainer` giữa. Tiêu đề "Chọn chế độ chơi"; %DifficultyList (VBoxContainer) — script tự tạo 1 nút cho mỗi `Game.get_difficulties()`, chữ = display_name + description + "Tiền ban đầu: " + MoneyFormat; %CancelButton "Hủy".
```
signal difficulty_chosen(difficulty_id: String)
signal cancelled
func open() -> void
```

### scenes/ui/save_slots_panel.tscn — `save_slots_panel.gd` (J2)
Root `Control` full màn hình + `PanelContainer`. %TitleLabel, %SlotList (VBoxContainer), %CloseButton "Đóng".
```
enum Mode { SAVE, LOAD }
signal slot_chosen(slot: int)
signal closed
func open(mode: int) -> void
```
- Liệt kê: ô tự lưu (chỉ hiện ở chế độ LOAD) + ô 1–3. Mỗi ô là Button: "Ô 1 — Ngày 3 (Tuần 1, Chiều) · Khó · 13.850.000 đ · 18/10/2026 21:30" hoặc "Ô 2 — Trống".
- LOAD: ô trống bị disable. SAVE: ghi đè được.
- Panel chỉ emit `slot_chosen`; việc lưu/tải do màn hình cha làm.

### scenes/ui/settings_panel.tscn — `settings_panel.gd` (J1)
%MusicSlider, %SfxSlider (HSlider 0–1, step 0.05), %ResolutionOption (OptionButton, liệt kê `Settings.RESOLUTIONS` dạng "1280 × 720"), %FullscreenCheck (CheckBox), %CloseButton "Đóng". Đổi là áp dụng ngay (`Settings.apply()`); đóng thì `Settings.save_settings()`.
```
signal closed
func open() -> void
```

### scenes/game.tscn — `game_scene.gd`
Root `Node2D` "GameScene". Con: `Label` tạm "Bản đồ sẽ có ở bước 2" (trong một CanvasLayer hoặc Control), instance `Hud` (hud.tscn), instance `PauseMenu` (pause_menu.tscn).
- `_ready`: nếu `not Game.has_active_game()` (chạy thẳng scene khi test) → `Game.new_game("hard")`.

### scenes/ui/hud.tscn — `hud.gd` (J3)
Root `CanvasLayer` "Hud" (layer 10). `MarginContainer` góc trên trái chứa:
- %TimeLabel: "Ngày 3 · Tuần 1 · Thứ Tư · Chiều"
- %MoneyLabel: "13.850.000 đ"
- 4 dòng (Label + ProgressBar 0–100): %StaminaBar "Thể lực", %HungerBar "Đói", %SanityBar "Sanity", %KnowledgeBar "Trí tuệ"; ProgressBar có `show_percentage = false`, kèm %StaminaValue… hoặc chữ số bên cạnh.
- %AdvanceButton "Nghỉ (qua khung giờ)" — **tạm thời** để test tới khi có hành động thật ở bước 4.
- Cập nhật khi `Game.stats_changed`, `Game.time_changed`, `Game.state_replaced`.
- A6 Quan hệ chưa hiện trên HUD (chưa có NPC) — sẽ hiện trong điện thoại (I2).

### scenes/ui/pause_menu.tscn — `pause_menu.gd` (J1)
Root `CanvasLayer` "PauseMenu" (layer 50, `process_mode = 3` ALWAYS). %Root (Control, nền mờ, ẩn mặc định) chứa `PanelContainer` với nút: %ResumeButton "Tiếp tục", %SaveButton "Lưu game", %LoadButton "Tải game", %SettingsButton "Cài đặt", %MainMenuButton "Về menu chính", %QuitButton "Thoát game". Instance ẩn %SaveSlotsPanel, %SettingsPanel.
- `_unhandled_input`: action "pause" → nếu đang mở panel con thì đóng panel con; không thì bật/tắt pause (`get_tree().paused`).
- Lưu: SaveSlotsPanel SAVE → `SaveSystem.save_to_slot` → Toast "Đã lưu vào ô N". Tải: LOAD → `Game.load_game` → bỏ pause, đóng menu. Về menu chính: bỏ pause → `Game.end_game()` → `SceneLoader.change_scene(MAIN_MENU_SCENE)`.

### Mẫu `.tscn`
```
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/ui/main_menu.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/ui/settings_panel.tscn" id="2_settings"]

[node name="MainMenu" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1_script")

[node name="Center" type="CenterContainer" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="Menu" type="VBoxContainer" parent="Center"]
layout_mode = 2

[node name="NewGameButton" type="Button" parent="Center/Menu"]
unique_name_in_owner = true
layout_mode = 2
text = "Chơi mới"

[node name="SettingsPanel" parent="." instance=ExtResource("2_settings")]
unique_name_in_owner = true
visible = false
layout_mode = 1
```
- Không ghi `uid=` (Godot tự sinh khi mở Editor).
- Con của Container: `layout_mode = 2`. Con của Control thường: `layout_mode = 1` + anchors. Control gốc / con trực tiếp của CanvasLayer: `layout_mode = 3` + anchors.

---

## 5. project.godot
```
config_version=5

[application]
config/name="Tôi Là Sinh Viên Bách Khoa"
run/main_scene="res://scenes/main_menu.tscn"
config/features=PackedStringArray("4.4", "GL Compatibility")

[autoload]  (như mục 3)

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"

[input]
pause / debug / interact  (Esc = physical_keycode 4194305, F1 = 4194332, E = 69)

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/canvas_textures/default_texture_filter=0
```
Mẫu một action:
```
pause={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194305,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
```

---

## 6. Test — `tests/`
- Không dùng addon (GUT bị chặn tải). Tự viết:
  - `test_case.gd` (`extends RefCounted`, class_name TestCase): `assert_eq(actual, expected, msg := "")`, `assert_true`, `assert_false`, `assert_null`, `assert_not_null`; ghi lỗi vào mảng `failures`.
  - `run_tests.gd` (`extends SceneTree`): trong `_initialize()` duyệt `res://tests/test_*.gd`, với mỗi file `load().new()`, gọi mọi method tên bắt đầu `test_` (lấy qua `get_method_list()`), gọi `before_each()` nếu có; in "PASS/FAIL tên_test"; cuối cùng in tổng và `quit(0)` nếu không lỗi, `quit(1)` nếu có lỗi.
- Test chỉ dùng logic thuần + SaveSystem tạo bằng `load("res://scripts/autoload/save_system.gd").new()` với `save_dir = "user://test_saves/"` (dọn dẹp sau test). Không phụ thuộc autoload.
- Trong test, nạp class bằng `preload("res://scripts/core/...")` thay vì class_name để chạy được cả khi cache class chưa dựng.
- Trước khi chạy test lần đầu cần `godot --headless --path . --import` (hoặc mở project bằng Editor một lần).

---

## Bước 4 — Đời sinh viên (đã làm)

Logic thuần trong `scripts/life/` (test được không cần autoload); autoload `StudentLife` chỉ nối signal.

### Dữ liệu (`scripts/data/` + `data/`)
- `EconomyConfig` → `data/economy.tres` (học phí, phí KTX, số ca tối đa, ngưỡng đói, hậu quả…)
- `ActionData` → `data/actions/*.tres` (`place_id`, `category`: class/study/work/rest/sleep/special, `allowed_slots`, `requires` dạng `flag.x == 1`, delta chỉ số, lương)
- `ItemData` → `data/items/*.tres`, `ShopData` → `data/shops/*.tres`, `SubjectData` → `data/subjects/*.tres`, `StatusEffectData` → `data/effects/cafein.tres`
- `LifeCatalog.load_default()` nạp tất cả (danh sách id cố định trong `life_catalog.gd` — thêm dữ liệu mới thì thêm id ở đó).

### Trạng thái lưu
- `GameState.life: LifeState` (khóa save `"life"`). Save cũ thiếu khóa → `LifeState` mới với `initialized = false` → `StudentLife` khởi tạo (TKB, thu phí ngày đầu). Không tăng `SAVE_VERSION`.
- `Inventory` (mô hình túi đồ) nằm trong `LifeState.inventory`.

### Autoload
Thứ tự: `AudioManager, Settings, SaveSystem, Game, StudentLife, SceneLoader, Toast, DebugMenu`.
```
StudentLife:
  signal day_summary_ready(summary), action_performed(action_id, result), collapsed(kind)
  var catalog: LifeCatalog, sim: LifeSim
  has_game(), get_place_actions(place_id), perform_action(id, params), get_shop_items(shop_id),
  buy_item(shop_id, item_id), pay_tuition()
```

### Trình tự xử lý
- `Game.state_replaced` → `sim.bind(state)`; nếu `life.initialized == false` → `start_new_life()`.
- `Game.time_changed(day, slot)` → nếu là khung kế tiếp đúng thứ tự → xử lý khung vừa hết (vắng tiết, hiệu ứng hết hạn, hậu quả đói); nhảy giờ (tải game/debug) → chỉ đồng bộ. Sau đó `check_collapse` chạy deferred.
- `Game.new_day(day)` → tổng kết ngày cũ (`day_summary_ready`) → xóa sổ ngày → chụp chỉ số đầu ngày → thu phí định kỳ → kiểm hạn học phí. Tất cả chạy **trước** khi `Game` tự lưu.

### Nơi chốn & UI
- `place_id`: `ktx_room`, `ktx_hallway`, `lecture_hall`, `library`, `food_shop` (khớp id khu vực bước 2).
- `scripts/ui/life_ui.gd` (CanvasLayer 40, group `life_ui`, đặt sau PauseMenu): `open_place(place_id)`, `toggle_actions()`, `close_all()`. **Bước 2 gắn Interactable → `get_tree().call_group(&"life_ui", &"open_place", "<place_id>")`.** Hiện tạm mở bằng nút "Hành động"/phím Tab trên HUD.
- HUD có thêm `%NextClassLabel`, `%TuitionLabel`, `%ActionButton` (thay `%AdvanceButton`).

### API cho bước 5–6
- `sim.charges.register({id, label, amount, period_days, first_day, condition_flag})` — vd. quỹ phòng (D4) với `condition_flag = "da_gop_quy"`.
- `Economy.earn/spend/charge(state, amount, label)` — mọi thay đổi tiền phải qua đây để vào sổ thu chi.
- Cờ học phí: `da_dong_hoc_phi`, `hoc_phi_tre_han`, `hoc_phi_qua_han`; việc làm: `lam_them_quan`.
- `LifeSim.collapsed(kind)` ("faint"/"rest") — bước 2 dùng để đưa nhân vật về giường.

### Công cụ
- `python3 tools/sim_cashflow.py` — mô phỏng dòng tiền 14 ngày cho 3 chế độ (đọc số từ `data/*.tres`).

---

## Bước 3 — Hội thoại (đã làm)

Logic thuần trong `scripts/dialogue/`; autoload `DialogueSystem` (ngay sau `Game`); UI `scripts/ui/dialogue_box.gd` (CanvasLayer 30, node `DialogueBox` cuối `game.tscn`).

Thứ tự autoload hiện tại: `AudioManager, Settings, SaveSystem, Game, DialogueSystem, StudentLife, SceneLoader, Toast, DebugMenu`.

### Định dạng `.dlg` (`content/dialogue/*.dlg`, UTF-8)
| Dòng | Cú pháp |
|---|---|
| Node | `== node_id` (a-z0-9_, duy nhất toàn bộ thư mục) |
| Metadata | `@khóa giá trị` ngay sau `==` (khóa lặp được → mảng) — `@trigger`, `@when`, `@priority`, `@once`, `@daily` dùng ở bước 5 |
| Lời thoại | `speaker: chữ` hoặc `speaker (bieu_cam): chữ`; speaker = id trong `data/characters/`, `player`, `narrator` |
| Lựa chọn | `* chữ -> node_id` (các dòng `*` liền nhau = 1 nhóm) |
| Lệnh | `~ lệnh tham số…` (cụm có dấu cách đặt trong "…") |
| Đuôi | `[if đk]` (lời thoại/lựa chọn/lệnh), `[need đk | lý do]` (lựa chọn: hiện mờ kèm lý do) |

Hết node mà không `~ goto`/`~ end` → kết thúc. Thay biến: `{player_name} {money} {day} {week}`.

Lệnh có sẵn: `set add stat money rel goto end toast emit`. Bước 4 thêm: `action <id> [môn/npc]`, `give <item> [n]`, `take <item> [n]`, `pay_tuition`, `pass_slots <n>`. `~ money` đi qua `Economy` (vào sổ thu chi).

Điều kiện: `biến op giá trị` nối `and`/`or` (and ưu tiên). Biến: `flag.x stat.(stamina|hunger|sanity|knowledge) money rel.npc day week weekday slot`; hằng `SANG CHIEU TOI DEM`. Bước 4 thêm: `item.<id>`, `class_now`, `shifts_today`. Bước sau thêm biến bằng `DialogueCondition.register_variable(tên_hoặc_tiền_tố, Callable(variable, state) -> int)` và gỡ khi autoload rời cây.

### API
```
DialogueSystem:
  signal dialogue_started(node_id), dialogue_finished(node_id), dialogue_event(name, args)
  signal line_shown(line), choices_shown(choices)      # cho UI
  start(node_id) -> bool, is_active(), has_dialogue(node_id), advance(), choose(index, text)
  register_command(name, Callable(args: PackedStringArray, state: GameState))
  reload_content(), get_errors(), get_library() -> DialogueLibrary, get_character(id)
  var history (200 câu), read_log (user://dialogue_read.cfg), last_started_msec, last_finished_msec
```
- Bước 2 nối Interactable: `DialogueSystem.start(node_id)`; khóa di chuyển khi `DialogueSystem.is_active()`; bỏ qua phím E trong ~0,2 s sau `last_finished_msec`.
- Phím: `dialogue_next` (Space/Enter/E/chuột trái), `dialogue_skip` (giữ Ctrl), `dialogue_auto` (T), `dialogue_history` (L/cuộn lên), `phone` (Tab), `inventory` (I).
- Cài đặt `[dialogue]` trong `settings.cfg`: `text_speed` (20/40/80/0), `auto_delay` (0,5–3,0), `skip_unread`.
- Save: `GameState.player_name` (khóa `"player_name"`); thiếu → `PlayerDefaults.name_or_default()`. `SaveSystem.get_slot_info()` có thêm `"player_name"`.
- Dữ liệu: `CharacterData` (`data/characters/*.tres`, chân dung để trống tới khi có đồ họa), `StoryFlagRegistry` (`data/story_flags.tres`), `PlayerDefaults` (`data/player_defaults.tres`).
- **Export**: thêm `*.dlg` vào *Export → Resources → Filters to export non-resource files*.
- Giọng thoại: trung tính, câu ngắn, xưng "mình/bạn" (tham khảo Stardew Valley, Kindergarten, Punch Club).

---

## Bước 5 — NPC & sự kiện (đã làm)

Thứ tự autoload: `AudioManager, Settings, SaveSystem, Game, DialogueSystem, StudentLife, EventDirector, SceneLoader, Toast, DebugMenu`.

Lớp CanvasLayer: Hud 10 · DialogueBox 30 · LifeUI (menu hành động/quầy/TKB/tổng kết) 40 · Phone 48 · PauseMenu 50 · Toast 90 · SceneLoader 100 · DebugMenu 120. Trong `game.tscn`, LifeUI/DialogueBox/Phone đặt **sau** PauseMenu để nhận phím trước.

### Save
`GameState.story: StoryState` (khóa `"story"`): `events_fired`, `quests`, `messages`, `known_npcs`, `pending_calls`. `LifeState.outings_today`. Save cũ thiếu → mặc định.

### NPC theo lịch (E2, E3)
- `NpcData` (`data/npcs/*.tres`): `schedule: Array[Dictionary]` — mỗi mục `{day_from, day_to, weekdays, slots, place, anchor, condition, behavior}`, **mục đầu tiên khớp thắng**, `place = ""` = vắng mặt. `state_flag`, `default_dialogue`, `murmurs`.
- `NpcSchedule.resolve(npc, state)` → `{place, anchor, behavior}` hoặc `{}`. `place` = id khu (`ktx_room`, `ktx_hallway`, `lecture_hall`, `library`, `food_shop`), `anchor` = điểm đứng trên bản đồ (bước 2 đặt Marker2D cùng tên: `seat_minh, minh_desk, minh_bed, minh_wall, counter, flyer_spot, k_spot, k_library, senior_spot, seat_front, podium, bed_tuan, bed_khoa`).
- Minh: `minh_trang_thai` 1 bình thường · 2 thâm quầng (bước 2 đổi sprite) · 3 Tối/Đêm đứng quay mặt vào tường ở hành lang (`behavior = face_wall`, bong bóng `murmurs`) · 4 vắng mặt (C1).
- `EventDirector.npcs_at(place_id)`; bước 2 dùng để sinh NPC ở anchor khi `Game.time_changed`/chuyển khu/cờ đổi.

### Sự kiện (storylet)
Node `.dlg` có metadata: `@trigger day_start | slot_start | enter_area <khu> | interact <npc> | sleep | phone_call <liên_lạc>`, `@when <đk>` (nhiều dòng = and), `@priority <số>`, `@once`, `@daily`.
- `EventSelector.select(...)` lọc + sắp ưu tiên (bằng nhau → thứ tự file/dòng); `conditions_hold` kiểm tra lại lúc thật sự chạy.
- `EventDirector`: `day_start` chạy **sau khi** đóng màn tổng kết (LifeUI gọi `block("summary")`/`unblock`); `interact` chỉ chạy sự kiện ưu tiên cao nhất, không có thì `default_dialogue`; `sleep`: có sự kiện → giấc ngủ dừng ở khung Đêm, sự kiện xong tự ngủ tiếp (`StudentLife.complete_sleep()` / lệnh `~ sleep [hệ số]`).
- API: `interact(id)`, `enter_area(area_id)` (cập nhật `current_place`), `phone_call(contact_id)`, `block/unblock(key)`, `refresh_quests()`; signal `messages_changed`, `quests_changed`, `calls_changed`.
- **Bước 2 cần gọi**: Interactable của NPC → `EventDirector.interact(npc_id)`; sau khi chuyển khu → `EventDirector.enter_area(area_id)`.

### Kinh tế phụ
- Phát tờ rơi cho K. (`data/actions/phat_to_roi.tres`): sảnh giảng đường, 350.000 × hệ số, tính vào 2 ca/ngày, `dinh_lieu_k +10/ca` (kẹp 0–100). Nhận việc qua hội thoại: `~ set nhan_viec_to_roi 1`, `~ k_involve 5`, `~ give xap_to_roi`.
- A8 ẩn (QĐ-5.1 = A): danh bạ hiện câu mô tả theo bậc (`StoryVars.k_contact_note`).
- Quỹ phòng (`RoomFund`): cờ `da_gop_quy` → 1 (hoặc `~ join_room_fund`) → thu 200.000 ngay + khoản 28 ngày; quỹ (`quy_phong`) += 4 × 200.000 mỗi kỳ (bạn + Minh + Tuấn + Khoa). **Nội dung chỉ đặt cờ, không `~ money`.**
- Đi chơi (`di_choi`, gọi từ hội thoại `~ action di_choi <npc>`): Tối, 50.000 đ, Sanity +15, quan hệ +5, 1 lần/ngày/NPC.
- Mua mang về (`ItemData.can_carry`) + dùng từ túi (`StudentLife.use_item`).

### Nhiệm vụ, tin nhắn, điện thoại
- `QuestData` (`data/quests/*.tres`): `start_condition`, `steps: [{text, done_condition}]`, hạn + hạn gia hạn theo cờ. `QuestLog.evaluate()` chạy khi cờ/thời gian đổi và sau mỗi hội thoại.
- Lệnh: `~ message <người_gửi> "chữ"`, `~ ring <liên_lạc>`, `~ quest start|done|fail <id>`, `~ k_involve <±n>`, `~ join_room_fund`, `~ npc_state <npc> <giá_trị>`, `~ meet <npc>`, `~ sleep [hệ số]`. Biến: `quest.<id>` (0/1/2/3), `npc_here.<id>`.
- Điện thoại (`scripts/ui/phone.gd`, Tab; I mở Túi đồ): Tin nhắn, Ví (đóng học phí, quỹ phòng), Lịch học, Nhiệm vụ, Danh bạ (5 bậc quan hệ, Nghe/Gọi), Túi đồ, Radar (màn chờ — bước 6). `_signal_label` để bước 6 làm nhiễu.
- Phím: Q = menu hành động (tạm, tới khi có bản đồ), Tab = điện thoại.

---

## Bước 6 — Dị tượng (đã làm)

Thứ tự autoload: `…, StudentLife, EventDirector, AnomalyDirector, SceneLoader, Toast, DebugMenu`. Lớp mới: StairLoopUI 41, lớp phủ nhiễu + phụ đề 85 (trong AnomalyDirector).

Chưa có bản đồ nên radar/vùng tính theo **nơi đang đứng** (`EventDirector.current_place`). Bước 2 có thể thay bằng vị trí thật: `RadarMath.signal_at(pos, [{position, strength, radius}])`.

### Logic thuần (`scripts/anomaly/`)
- `RadarMath.signal_at()`, `bars()` (ngưỡng 0,10/0,30/0,55/0,80), `describe()`.
- `DrainCounter.update(delta, inside, controllable)` → Sanity cần trừ (1 mỗi 5 s, trần 10 mỗi lần vào vùng).
- `StairPhysics`: v = 331 + 0,6·t (20 °C → 343 m/s); `closed_pipe_hz(L)` = v/(4L) làm tròn 0,1; gốc 3,43 m → 25,0 Hz; lệch ≥ 1 Hz = "méo".
- `StairLoopState`: luật lệch → xuống / gốc → lên, đúng 4 lần liền → thoát; chiếu nghỉ đầu luôn gốc; ≤ 2 gốc liên tiếp; không lặp chỗ lệch tới khi hết danh sách, không 2 lần liền; `hint_level()` (Trí tuệ < 25 → 1, < 50 → 2, còn lại 3; +1 mỗi 3 lần sai liên tiếp, trần 3); `should_offer_assist()` sau 8 lần sai.
- `SaveGate` (static `block/unblock/is_blocked/clear`) — PauseMenu làm mờ "Lưu game"; `GameScene._ready` gọi `clear()`.

### Dữ liệu
- `data/anomalies/stair_anomalies.tres` (`StairAnomalyCatalog`): `base_order`, `base_lines` (8 chi tiết chiếu nghỉ), `tech_plate`, `anomalies: [{id, element, text, hum_length_m, mo_ta}]`. Tần số **tính** từ `hum_length_m`.
- `data/puzzle_hints.tres` (`PuzzleHintConfig`): ngưỡng gợi ý, số lần sai, phạt Sanity.
- Âm thanh `audio/sfx/` do `python3 tools/gen_audio.py` tạo (44,1 kHz, mono, 16 bit, đỉnh −6 dBFS): `hum_25hz_tuong_trung.wav` (sóng mang 200 Hz điều biên 25 Hz → 175/200/225 Hz, đúng 1,00 s, lặp bằng code), `radar_tick.wav`, `nhieu_nhe.wav`.

### AnomalyDirector (API)
```
signal radar_changed(bars, hum_hz), stair_loop_started, stair_landing_changed(index), stair_loop_ended(escaped)
signal night_scene(active), npc_moved(npc_id, anchor_id, seconds), npc_hidden(npc_id)   # cho bản đồ
var bars, hum_hz, in_zone, loop: StairLoopState, catalog, hints
begin_stair_loop(), stair_choose("up"/"down"), show_hint(), call_senior(), ask_physics_question(), abort_loop()
```
- Nguồn MVP: Minh (trạng thái ≥ 2: 0,3; quay mặt vào tường: 0,5 + vùng 25,0 Hz), K. (tuần ≥ 3: 0,35), cửa cầu thang ở hành lang (tuần ≥ 3, Đêm: 0,5 + vùng 25,0 Hz). Trong vòng lặp: radar = 4 − số lần đúng liên tiếp, không trừ Sanity theo giây (đã phạt −3 mỗi lần sai).
- Lần đầu radar ≥ 1 vạch → cờ `radar_lan_dau`. Trigger mới **`flag_set <cờ>`** (EventDirector) kích khi cờ chuyển từ 0 sang khác 0.
- Lệnh: `~ stair_loop start|escape`, `~ night_wake`, `~ change_area <khu> [spawn]`, `~ npc_move <npc> <anchor> [giây]`, `~ npc_hide <npc>`, `~ sleep_resume <hệ_số>`. Biến: `stair.anomaly`, `stair.active`, `stair.hint`.
- Cài đặt mới `[accessibility]`: `reduce_screen_noise`, `audio_subtitles`. Phím `hint` = G.
- Nội dung lõi: `content/dialogue/truyen_thuyet.dlg` (tiền bối, đủ 3 ý lời giải), `cau_thang.dlg` (bắt đầu/sai/đúng/thoát, gợi ý 3 mức, gọi tiền bối, câu hỏi Vật lý), `g4_dem_tuan3.dlg` (sự kiện đêm ngày 18 + sáng hôm sau).
- Giao diện cầu thang hiện là **bản chữ** (`scripts/ui/stair_loop_ui.gd`): liệt kê 8 chi tiết chiếu nghỉ, so với bản gốc; bước 2 thay bằng cảnh thật dùng cùng `AnomalyDirector`.

---

## Bước 7 — Ghép nội dung tuần 1–4 (đã làm)

MVP chơi được từ "Chơi mới" tới màn "Còn tiếp…" bằng menu chữ (Q / Tab / cầu thang dạng chữ). Lớp mới: TutorialHints 15, EndingScreen 95 (đều trong `game.tscn`).

### Nội dung (`content/dialogue/`)
- `tuan1.dlg` … `tuan4.dlg`, `chung.dlg` (thoại mặc định NPC + Minh rủ đi ăn), `tin_nhan.dlg` (tin nhắn theo ngày), `ket_thuc.dlg` (cảnh sau khi thoát cầu thang → `~ set mvp_hoan_thanh 1`, `~ emit to_be_continued`). Nội dung lõi bước 6 giữ nguyên luật; chỉ thêm `day >= 10` cho truyền thuyết (tuần 2).
- Demo bước 3/5 chuyển vào `content/dialogue/_demo/` — `DialogueLibrary.load_dir` không quét thư mục con nên không còn được nạp.
- Màn mở đầu `intro_mo_dau`: dòng tuyên bố hư cấu (J15) + chọn KTX → cờ `ktx_khu` (1 = A, 2 = B). QĐ-7.1 tạm = A: hai khu chỉ khác lời mô tả.

### Lịch beat bắt buộc
- Metadata mới **`@required <ngày>`**: beat phải chạy. `EventDirector.overdue_required(day)` trả beat chưa chạy mà `day > ngày` → được xếp hàng ở `new_day` và chạy **bỏ qua @when** (vẫn chỉ một lần). Beat bắt buộc: `intro_mo_dau`, `t1_gap_minh` (1), `t2_to_roi_bang_tin` (8), `t3_minh_tham_quang` (16), `t4_minh_up_mat` (24), `t4_cao_trao_dem` (28). Beat khác có node dự phòng (`*_du_phong`, tin nhắn).
- Cao trào: `t4_cao_trao_dem` (slot_start Đêm ngày 28) hoặc `t4_cao_trao_ngu` (trigger sleep ngày 28, khi ngủ sớm từ Tối) → `t4_cao_trao_noi_dung` → `~ stair_loop start`.
- **`LifeSim.time_barriers: Array[int]`** (khóa `day*4+slot`): ngủ li bì do kiệt sức tinh thần dừng ở mốc. EventDirector thêm `CLIMAX_KEY = 28*4+3`.
- `EventDirector.pump()` (gọi trong `_process`; bot gọi trực tiếp): chạy sự kiện kế tiếp trong hàng đợi; hết hàng đợi thì hoàn tất giấc ngủ bị ngắt — trừ khi đang ở cầu thang, có lệnh vào cầu thang đang chờ, hoặc đã `mvp_hoan_thanh`. `has_pending()`.
- `AnomalyDirector.pending_start` + `start_pending()`: `~ stair_loop start` chỉ đặt cờ chờ; vào vòng lặp khi hội thoại hiện tại kết thúc (đã về menu thì bỏ).
- `AnomalyDirector.area_change_requested(area_id, spawn_id)`: phát khi kịch bản đổi khu (`~ change_area`, thoát cầu thang, `~ sleep_resume`) — bản đồ nghe để dịch chuyển nhân vật.
- `_on_state_replaced` (ván mới, ngày 1 Sáng, chưa có sự kiện nào) tự xếp hàng `day_start` ngày 1 (không có signal `new_day` cho ngày đầu). Liên lạc mới `phong_dao_tao`.

### Màn "Còn tiếp…" — `scripts/ui/ending_screen.gd` (CanvasLayer 95, group `ending`)
- Bắt `dialogue_event("to_be_continued")` → khi hội thoại xong: đặt `mvp_hoan_thanh = 1`, ghi ô Tự lưu, hiện tổng kết, nút "Về menu chính" (QĐ-7.4).
- Hàm thuần (test được): `build_summary(state) -> [{text, size?, color?}]`, `tuition_line(state)` (đúng hạn / gia hạn / CHƯA ĐÓNG), `choices_recap(state)`.
- `GameScene._ready`: tải bản lưu có `mvp_hoan_thanh == 1` → hiện lại tổng kết (không ghi lưu).

### Hướng dẫn chơi (J11) — `scripts/ui/tutorial_hints.gd` (CanvasLayer 15)
- `data/tutorial_hints.tres` (`TutorialHintSet.hints: [{id, text}]`, 13 gợi ý). `trigger(id)`: đặt cờ `tut_<id>` (lưu cùng save), chỉ xếp hàng hiển thị khi `Settings.show_tutorial`; mỗi gợi ý hiện 1 lần, ~6 giây, không chen giữa hội thoại.
- Điều kiện hiện nằm trong code (nối signal: hội thoại, tin nhắn, tổng kết ngày, đổi giờ, chỉ số, vào cầu thang).
- Cài đặt mới `[accessibility] show_tutorial` (checkbox "Hiện hướng dẫn").

### Test & bot chơi thử
- `tests/mvp_bot.gd` (không phải file test): bot chơi trọn một ván bằng autoload thật, đồng bộ (tự gọi `pump()`, `start_pending()`, `check_collapse()`), 3 chiến lược "Chăm học" / "Chăm làm" / "Theo K.", chọn lựa chọn theo chuỗi con của nội dung.
- `test_playthrough_mvp.gd` (3 × 3 chế độ: tới "Còn tiếp…" ngày 28, đủ beat bắt buộc, ý đồ học phí BALANCE), `test_calendar_content.gd` (gồm cờ chỉ đọc mà không ai đặt), `test_required_beats.gd`, `test_ktx_choice.gd`, `test_ending_summary.gd`, `test_tutorial_hints.gd`, `test_area_requests.gd`.
- `run_tests.gd` báo FAIL (không treo) khi một file test lỗi cú pháp.
- **Lưu ý xuất bản (export):** `.dlg` không phải resource → khi tạo export preset phải thêm `content/dialogue/*.dlg` vào "Filters to export non-resource files", nếu không bản build sẽ không có thoại.
