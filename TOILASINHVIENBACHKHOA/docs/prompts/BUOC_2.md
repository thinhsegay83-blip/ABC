# BƯỚC 2 — THẾ GIỚI ĐI LẠI ĐƯỢC + ĐỒ HỌA PLACEHOLDER

> Prompt cho AI code. Dựa trên bản nháp `PROMPT_BUOC2_MAP.md` đã đưa người dùng, chỉnh theo ràng buộc môi trường (không có Godot, không tải được asset).
> Trạng thái hàng đợi: xem `docs/TASKS.md`.

Dự án: game 2D nhập vai mô phỏng đời sinh viên "Tôi Là Sinh Viên Bách Khoa". Godot 4.4+ (GDScript, kiểu tĩnh), PC trước. Góc nhìn từ trên xuống, pixel art hiện đại (tinh thần Stardew Valley / Eastward, KHÔNG sao chép asset của họ). Thế giới hư cấu, tông bí ẩn nhẹ — KHÔNG kinh dị.

Project: `/home/user/BachKhoaRPG`. Bước 1 (nền tảng) phải xong trước.

---

## [CẦN QUYẾT ĐỊNH] — người dùng chốt trước khi AI code bắt đầu

Nếu người dùng chưa trả lời: dùng phương án **khuyến nghị**, ghi rõ trong báo cáo, và thiết kế sao cho đổi phương án chỉ phải sửa dữ liệu hoặc một chỗ.

| Mã | Câu hỏi | Phương án | Khuyến nghị |
|---|---|---|---|
| QĐ-2.1 | Dựng bản đồ bằng cách nào khi AI không mở được Godot Editor? | **A.** Bản đồ dạng lưới ký tự (ASCII) trong file `.tres` (`MapData`), script `@tool` dựng TileMapLayer + TileSet bằng code lúc chạy (và hiện được trong Editor). AI viết, đọc, test được; muốn vẽ tay thì sửa lưới ký tự. **B.** Python sinh sẵn TileSet `.tres` + `.tscn` có `tile_map_data` (mảng byte nhị phân). Mở Editor là chỉnh tay được, nhưng định dạng nhị phân không kiểm chứng được khi thiếu Godot [CẦN KIỂM TRA], dễ hỏng âm thầm. **C.** AI chỉ dựng khung + TileSet, người dùng tự vẽ bản đồ trong Editor theo checklist. | **A** (có thể làm thêm công cụ "bake" sang TileMapLayer thật ở bước sau nếu muốn vẽ tay) |
| QĐ-2.2 | FEATURES D1 có 2 việc (phụ quán cơm, bưng cà phê) nhưng F4 chỉ có 1 "quán làm thêm". Xử lý thế nào? | **A.** Một khu "quán cơm – cà phê": sáng/chiều bán cơm, tối bán cà phê (2 quầy trong 1 scene). **B.** Tách 2 khu: `food_shop` + `cafe`. **C.** Chỉ làm quán cơm, cà phê để sau. | **A** (đúng danh sách 5 địa điểm của F4, ít đồ họa) |
| QĐ-2.3 | Nguồn đồ họa lâu dài (không chặn bước này) | **A.** Giữ placeholder tự vẽ tới khi chơi thử MVP xong rồi mới thay. **B.** Thay sớm bằng gói CC0 (ví dụ Kenney) — người dùng tự tải trên máy vì AI không tải được. **C.** Gói trả phí phong cách nội thất/đô thị hiện đại (kiểm tra giấy phép dùng thương mại). | **A**. Nếu chọn B/C: ghi nguồn + giấy phép vào `CREDITS.md`, kèm file license trong thư mục asset; không dùng asset trích từ game thương mại; chỗ không chắc giấy phép ghi [CẦN KIỂM TRA]. |

---

## Ràng buộc môi trường của AI code (đọc kỹ)

- Project ở `/home/user/BachKhoaRPG`. **Không có Godot binary** → không chạy được game, không chạy được test, không `--import`. Chỉ có **gdtoolkit** (`gdparse`, `gdlint`) để kiểm tra cú pháp `.gd`.
- Mạng **chặn** github.com, godotengine.org, fonts.google.com → không tải được addon hay asset. **pypi/npm thì được**. Python 3 + **Pillow đã có sẵn** (12.x); nếu thiếu thì `pip install pillow`.
- Vì vậy toàn bộ đồ họa bước này là **placeholder tự tạo bằng script Python Pillow**, theo quy chuẩn: tile 16×16, nhân vật 16×32, **một bảng màu thống nhất**.
- `.tscn`/`.tres` viết tay dạng text, theo mẫu ở `docs/ARCHITECTURE.md` mục 4 (không ghi `uid=`; Godot tự sinh khi mở Editor). File ảnh mới chưa có `.import` — Godot tự import khi người dùng mở Editor.
- Test viết theo bộ chạy test tự viết của bước 1 (`tests/test_case.gd`, `tests/run_tests.gd`); người dùng chạy trên máy họ.
- Không cài gói lớn, không xóa file khi chưa hỏi.

## Đọc trước, theo thứ tự

1. `docs/ARCHITECTURE.md` — hợp đồng code bước 1. Dùng đúng tên autoload, class, signal, input action. Nếu mục bước 1 đã được AI code cập nhật khác với prompt này thì **theo ARCHITECTURE.md** và ghi chú chỗ lệch trong báo cáo.
2. `FEATURES.md` (mã tính năng, "Quyết định đã chốt" — đặc biệt dòng **Tông truyện**), `STORY_MVP.md` (NPC, địa điểm, cờ), `BALANCE.md`.
3. Code bước 1: `scripts/ui/game_scene.gd`, `scenes/game.tscn`, `scripts/autoload/game.gd`, `scripts/core/game_state.gd`, `tests/test_case.gd`.

---

## 1. Mục tiêu

Người chơi điều khiển nhân vật đi lại trong 6 scene khu vực (phòng KTX, hành lang KTX, cầu thang KTX, giảng đường, thư viện, quán cơm – cà phê), va chạm đúng, camera bám theo, tương tác bằng E, chuyển khu có fade, bản đồ đổi màu theo khung giờ (ngày/đêm), vị trí khu vực được lưu vào save.

Mã tính năng: **F1, F2, F4, F6** (+ chuẩn bị cho **F3**, **G3**).

### KHÔNG làm ở bước này
- Hội thoại (bước 3), cờ cốt truyện mới, đặt tên nhân vật.
- Hành động học / làm thêm / ăn / ngủ, tốn khung giờ khi đi lại (bước 4).
- Lịch trình NPC, NPC đổi trạng thái (bước 5). NPC bước này đứng yên một chỗ.
- Radar, âm báo, dị tượng, vòng lặp cầu thang (bước 6) — chỉ **để chỗ**.
- Chọn KTX Khu A/B (bước 7) — chỉ để biến thể `@export`.
- Không đổi chữ ký API bước 1. Nếu bắt buộc sửa file bước 1 thì sửa tối thiểu và liệt kê trong báo cáo.

---

## 2. Phụ thuộc

Cần **Bước 1 xong**. Dùng các API sau (tên đúng như `docs/ARCHITECTURE.md`):

| Thành phần | Dùng gì |
|---|---|
| `Game` (autoload) | `state: GameState`, `has_active_game()`, signal `state_replaced`, `time_changed(day, slot)`, `_ensure_input_actions()` (mở rộng thêm action di chuyển) |
| `GameState` | thêm trường `current_area`, `current_spawn`; `to_dict()` / `from_dict()` / `setup_new_game()` |
| `GameClock` | `enum Slot { MORNING, AFTERNOON, EVENING, NIGHT }`, `slot` |
| `SceneLoader` | `is_transitioning`; thêm 2 hàm mới `fade_out(duration)` / `fade_in(duration)` (xem 3.9) |
| `Toast` | `show_message(text, duration)` |
| `SaveCodec` | `SAVE_VERSION` giữ nguyên = 1; save cũ thiếu trường mới phải tải được |
| Input action | `interact` (E), `pause` (Esc) |
| `scenes/game.tscn` | thay `Placeholder` (chữ "Bản đồ sẽ có ở bước 2") bằng node `World`; giữ `Hud`, `PauseMenu` |

---

## 3. Yêu cầu cụ thể

### 3.1 Cấu trúc thư mục mới

```
art/tiles/  art/characters/  art/props/  art/ui/
tools/gen_art.py           # sinh toàn bộ placeholder
tools/check_project.py     # kiểm chứng tĩnh (mục 3.13)
scenes/areas/              # 6 scene khu vực
scenes/world/              # player.tscn, interactable.tscn, npc.tscn, door.tscn, prop.tscn
scenes/ui/travel_menu.tscn
scripts/world/             # player, interactable, npc, door, area_manager, game_area, map_builder, day_night, slot_light…
scripts/core/              # input_lock.gd, interaction_picker.gd, map_parser.gd (logic thuần, test được)
scripts/data/              # map_data.gd, tile_catalog.gd, prop_catalog.gd, area_info.gd, day_night_config.gd
data/maps/  data/areas/  data/tiles/  data/props/
data/day_night.tres
docs/ART_STYLE.md
```

### 3.2 Đồ họa placeholder — `tools/gen_art.py`

- Chạy từ gốc project: `python3 tools/gen_art.py`. **Tất định** (không random, hoặc seed cố định) — chạy lại ra đúng file cũ. In danh sách file đã ghi.
- **Bảng màu** "BK-24" (ghi y hệt vào `docs/ART_STYLE.md`, script chỉ dùng các màu này, có thể thêm alpha):

  | # | Hex | Dùng cho | # | Hex | Dùng cho |
  |---|---|---|---|---|---|
  | 0 | `#1a1c2c` | viền, bóng tối nhất | 12 | `#2a9d8f` | xanh ngọc (ghế nhựa, biển) |
  | 1 | `#3b3f5c` | xám tối | 13 | `#3e7c59` | xanh lá |
  | 2 | `#5d6b8a` | xám xanh (sắt, giường tầng) | 14 | `#8ab17d` | xanh lá nhạt (cây) |
  | 3 | `#94a3b8` | xám nhạt (gạch men) | 15 | `#264653` | xanh đậm (bảng đen) |
  | 4 | `#e2e8f0` | trắng ngà | 16 | `#4d7ea8` | xanh dương (áo, Khu B) |
  | 5 | `#f4e4c1` | vàng kem (tường vôi Khu A) | 17 | `#9fc5e8` | xanh trời (kính, Khu B nhạt) |
  | 6 | `#e9c46a` | vàng nghệ | 18 | `#c9a7eb` | **tím nhạt — chỉ dành cho dị tượng** |
  | 7 | `#f4a261` | cam (đèn tối) | 19 | `#7b5ea7` | **tím — chỉ dành cho dị tượng** |
  | 8 | `#e76f51` | đỏ gạch (ghế nhựa đỏ) | 20 | `#f2c6b4` | da sáng |
  | 9 | `#9c3d2e` | nâu đỏ | 21 | `#c68863` | da |
  | 10 | `#6b4f3a` | nâu gỗ | 22 | `#2b2b2b` | tóc |
  | 11 | `#a47551` | gỗ sáng | 23 | `#ffd166` | ánh đèn vàng |

  Quy tắc thị giác: màu tím (18, 19) **chỉ** xuất hiện ở dị tượng (bước 6) → người chơi học được "tím = lạ".
- **Kích thước**: tile 16×16; nhân vật 16×32 (gốc tọa độ = giữa chân, đáy khung); chân dung (bước 3) 64×64.
- **Atlas tile** `art/tiles/tiles_interior.png`: lưới 16×16, ít nhất: sàn gạch men KTX, sàn gỗ thư viện, sàn gạch bông quán, sàn giảng đường, nền xi măng ngoài quán, tường mặt trên / mặt đứng (vài biến thể), chân tường, cửa, bậc cầu thang (lên/xuống, đủ để ghép đợt 12 bậc và biến thể 13 bậc cho bước 6), chiếu nghỉ.
- **Nhân vật** `art/characters/chr_<id>.png`: sheet 5 cột × 4 hàng khung 16×32 (hàng: xuống, trái, phải, lên; cột 0 = đứng yên, 1–4 = đi bộ) → ảnh 80×128. Cùng một dáng người, đổi màu tóc/áo để tiết kiệm: `chr_player`, `chr_minh`, `chr_chu_quan`, `chr_thu_khoa`, `chr_tien_boi`, `chr_k`, `chr_giang_vien`.
- **Đồ vật** `art/props/prop_<id>.png` (kích thước bội số 16): giường tầng, bàn học, tủ sắt, cửa sổ, quạt trần (2 khung quay), ổ điện nhiều phích, thùng mì gói, dây phơi đồ, dép, bảng thông báo dán đầy giấy, bình chữa cháy, biển tầng (số vẽ bằng font pixel 3×5 tự vẽ: chữ số 0–9 và dấu `'`), bảng chỉ đường, đèn hành lang, kệ sách, bàn đọc, đèn bàn, bục giảng, bảng đen, dãy bàn giảng đường, bàn + ghế nhựa đỏ/xanh, quầy, bếp, bảng hiệu quán, xe máy dựng, máy bán nước (dùng ở bước 4), kết cấu ánh sáng tròn `art/props/light_radial.png` (gradient trắng → trong suốt, 64×64) cho PointLight2D.
- Vẽ kiểu pixel art gọn: viền 1 px màu 0, đổ bóng 1 tông, không chữ trong tile (trừ biển số tầng).
- **`docs/ART_STYLE.md`**: bảng màu, kích thước, gốc tọa độ/neo, quy tắc tên file (`tiles_`, `chr_`, `prop_`, `por_`, `ui_`; snake_case), quy tắc "tím = dị tượng", cách chạy lại `gen_art.py`, cách thay bằng asset thật sau này (giữ nguyên tên file + kích thước).

### 3.3 Input Map + khóa điều khiển

- Thêm action `move_up` (W, ↑), `move_down` (S, ↓), `move_left` (A, ←), `move_right` (D, →) vào `project.godot`; mở rộng `Game._ensure_input_actions()` để tự thêm nếu thiếu (sửa hàm phụ để nhận nhiều phím). Ghi vào ARCHITECTURE.md.
- Đặt tên lớp vật lý trong `project.godot` (`[layer_names]`): `2d_physics/layer_1="world"`, `layer_2="player"`, `layer_3="interact"`, `layer_4="trigger"`.
- `scripts/core/input_lock.gd` — `class_name InputLock extends RefCounted`, chỉ hàm/biến static:
  ```
  static func lock(reason: StringName) -> void
  static func unlock(reason: StringName) -> void
  static func is_locked() -> bool
  static func clear() -> void           # GameScene._ready gọi để dọn khóa sót
  static func get_reasons() -> PackedStringArray   # cho debug
  ```
  Nhiều lý do cùng lúc được (dùng Dictionary lý do → true). Bước 3–6 dùng chung (hội thoại, menu, điện thoại, sự kiện).

### 3.4 Player (F1) — `scripts/world/player.gd`, `scenes/world/player.tscn`

- `class_name Player extends CharacterBody2D`; `@export var walk_speed: float = 80.0` (px/giây theo tọa độ thế giới ≈ 5 ô/giây).
- 8 hướng bằng `Input.get_vector("move_left", "move_right", "move_up", "move_down")` (đi chéo không nhanh hơn). Va chạm bằng hình chữ nhật nhỏ ở chân (khoảng 10×6 px) để có cảm giác top-down.
- `AnimatedSprite2D`: SpriteFrames **dựng bằng code** từ sheet (hàm static dùng chung cho NPC, ví dụ `CharacterSprite.build_frames(texture: Texture2D) -> SpriteFrames` tạo `idle_down/left/right/up`, `walk_*`). Hướng nhìn = hướng di chuyển cuối; |x| > |y| thì ưu tiên trái/phải.
- `func can_move() -> bool`: false khi `get_tree().paused`, `SceneLoader.is_transitioning`, hoặc `InputLock.is_locked()`. Khi không đi được thì đứng yên, phát `idle_*`.
- Camera2D là con của Player: `zoom = Vector2(3, 3)` (mỗi tile ≈ 48 px trên màn hình 1280×720), `position_smoothing_enabled = true`, giới hạn camera theo biên bản đồ (khu vực nhỏ hơn màn hình thì căn giữa bản đồ, không lộ khoảng đen lệch một bên). Chỗ nào nghi rung hình khi bật/tắt pixel snap → ghi [CẦN KIỂM TRA] vào checklist cho người dùng thử.
- Tương tác (F2): con `InteractionArea` (Area2D, mask = lớp `interact`). Khi có nhiều Interactable trong vùng → chọn **gần nhất** bằng `InteractionPicker`. Nhấn `interact` → gọi `interact()` của vật đang chọn. Chỉ hoạt động khi `can_move()`.

### 3.5 Interactable (F2)

- `scripts/world/interactable.gd` — `class_name Interactable extends Area2D`:
  ```
  @export var id: String = ""
  @export var display_name: String = ""
  @export var enabled: bool = true
  @export var prompt_offset: Vector2 = Vector2(0, -24)
  signal interacted(interactable: Interactable)
  func interact() -> void        # emit nếu enabled
  ```
  Lớp va chạm `interact`; `monitoring = false`, `monitorable = true`.
- `scripts/core/interaction_picker.gd` — `class_name InteractionPicker`, static:
  `static func pick_nearest(origin: Vector2, positions: Array[Vector2]) -> int` (trả chỉ số, `-1` nếu rỗng; khoảng cách bằng nhau thì lấy chỉ số nhỏ hơn).
- Gợi ý "E — <display_name>": một `CanvasLayer` (layer 5) `InteractionPrompt` vẽ chữ ở vị trí màn hình của vật đang chọn (đổi tọa độ thế giới → màn hình), để chữ sắc nét không bị zoom ×3 làm nhòe.

### 3.6 NPC tĩnh

- `scripts/world/npc.gd` — `class_name Npc extends Node2D`: `@export var npc_id: String`, `@export var display_name: String`, `@export var sprite_sheet: Texture2D`, `@export var facing: String = "down"`; con: AnimatedSprite2D, StaticBody2D (va chạm chân), Interactable (`id = npc_id`).
- Đặt sẵn: **Minh** (phòng KTX), **chủ quán** (quán), **nữ thủ khoa** (giảng đường), **tiền bối năm n** (thư viện). Tương tác: `Toast.show_message("<Tên>: (hội thoại ở bước 3)")`.

### 3.7 Bản đồ (F4) — định dạng `MapData` (theo QĐ-2.1 = A)

- `scripts/data/map_data.gd` — `class_name MapData extends Resource`:
  ```
  @export var area_id: String = ""
  @export_multiline var grid: String = ""     # mỗi ký tự = 1 ô 16×16; các hàng dài bằng nhau
  @export var legend: Dictionary = {}         # ký tự → tile_id (ô nền/tường), ví dụ {"#": "wall", ".": "floor_ktx"}
  @export var objects: Dictionary = {}        # ký tự → mô tả đối tượng (chuỗi), ô bên dưới vẽ tile nền mặc định
  @export var default_floor: String = ""      # tile nền cho ô có đối tượng
  ```
  File `data/maps/<area_id>.tres`. Chuỗi `grid` viết nhiều dòng trong `.tres` được; **không dùng ký tự `"` và `\`** trong lưới.
- Cú pháp mô tả đối tượng (tách theo khoảng trắng, chuỗi có dấu cách để trong ngoặc kép):
  | Mô tả | Ý nghĩa |
  |---|---|
  | `spawn <spawn_id>` | Marker2D điểm xuất hiện |
  | `door <target_area> <target_spawn>` | Cửa tự kích khi bước vào; `target_area = @travel` → mở menu đi lại |
  | `prop <prop_id>` | Đồ vật theo `data/props/prop_catalog.tres` |
  | `npc <npc_id> "<Tên hiển thị>"` | NPC tĩnh |
  | `interact <id> "<Tên hiển thị>"` | Interactable trơn (Giường, Bàn học, Bảng thông báo…) |
  | `sign_travel "<Tên hiển thị>"` | Bảng chỉ đường → mở menu đi lại |
  | `light <light_id>` | SlotLight (mục 3.10) |
  | `stair_exit up` / `stair_exit down` | Vùng kích ở đầu/cuối đợt cầu thang (mục 3.11) |
  | `anchor <anchor_id>` | Marker2D có tên, để bước sau đặt đồ/NPC/dị tượng |
- `scripts/core/map_parser.gd` — `class_name MapParser`, static, logic thuần:
  `static func parse(map: MapData) -> Dictionary` trả `{"size": Vector2i, "cells": Array (mỗi phần tử {cell: Vector2i, tile_id: String}), "objects": Array ({cell, kind, args: PackedStringArray}), "errors": PackedStringArray}`. Lỗi ghi rõ hàng/cột: ký tự không có trong legend/objects, hàng lệch độ dài, ký tự vừa ở legend vừa ở objects, thiếu `spawn default`, trùng spawn id.
- `scripts/data/tile_catalog.gd` (`TileCatalog`: atlas texture, tile_size = 16, `tiles: Dictionary` tile_id → Vector2i tọa độ atlas, `solid: Array[String]` tile có va chạm) + `data/tiles/tile_catalog.tres`.
- `scripts/data/prop_catalog.gd` (`PropCatalog`: Dictionary prop_id → `PropDef` sub-resource gồm texture, kích thước, hình va chạm, có đèn không) + `data/props/prop_catalog.tres`; `scenes/world/prop.tscn` là prop chung (Sprite2D + StaticBody2D).
- `scripts/world/map_builder.gd` — `class_name MapBuilder`, dựng từ kết quả `MapParser`: `TileMapLayer` "Floor" (không va chạm) + `TileMapLayer` "Walls" (TileSet dựng bằng code có physics layer, polygon vuông 16×16 cho tile `solid`), node `YSort` (`y_sort_enabled = true`) chứa prop/NPC/Player, node `Markers`. **Dùng TileMapLayer, KHÔNG dùng TileMap đã lỗi thời.**
- `scripts/world/game_area.gd` — `@tool`, `class_name GameArea extends Node2D`:
  ```
  @export var area_id: String = ""
  @export var map: MapData
  @export var variant: String = "A"           # F3: "A" / "B" (bước 7 đọc cờ ktx_khu)
  signal stair_exit_reached(direction: String) # "up" / "down" (G3)
  func build() -> void
  func get_spawn_position(spawn_id: String) -> Vector2   # không có thì dùng "default"
  func get_anchor(anchor_id: String) -> Marker2D         # null nếu không có
  func get_map_rect() -> Rect2
  ```
  Trong Editor (`Engine.is_editor_hint()`): chỉ dựng phần hình để xem, **không gán `owner`** cho node sinh ra (để không bị lưu vào .tscn), **không chạm autoload**. Mọi script mà GameArea gọi trong Editor (MapParser, MapBuilder, các catalog) cũng phải `@tool`.
- **Biến thể F3**: `variant = "B"` đổi màu tường (Khu A vàng kem #5, Khu B xanh nhạt #17) và biển "KTX KHU A/B". Bước 2 luôn dùng "A".

### 3.8 Sáu khu vực (F4) — `scenes/areas/<area_id>.tscn` + `data/maps/<area_id>.tres` + `data/areas/<area_id>.tres`

| area_id | Tên hiển thị | Gợi ý kích thước (ô) | Nội dung | Spawn bắt buộc |
|---|---|---|---|---|
| `ktx_room` | Phòng KTX | 12×9 | Phòng 4 người: 2 giường tầng, bàn học, tủ sắt, cửa sổ, quạt trần, ổ điện nhiều phích, thùng mì gói, dây phơi. Interactable "Giường" (`bed_player`), "Bàn học" (`desk_player`). NPC Minh. | `default`, `from_hallway`, `bed` |
| `ktx_hallway` | Hành lang KTX | ~30×7 | Dãy cửa phòng (chỉ cửa phòng mình vào được, các cửa khác là prop), bảng thông báo dán đầy giấy (`notice_board`), bình chữa cháy, đèn hành lang, **bảng chỉ đường** (`sign_travel`), cửa xuống cầu thang. Anchor `vending` (máy bán nước — bước 4). | `from_room`, `from_stairs`, `entrance` |
| `ktx_stairwell` | Cầu thang KTX | ~10×12 | **Một module chiếu nghỉ**: đợt thang lên + đợt thang xuống, biển tầng, cửa sổ thông gió, bình chữa cháy, dép, dây phơi áo, đồng hồ treo tường, bảng nội quy. `stair_exit up`, `stair_exit down`. Anchor cho bước 6: `floor_sign`, `notice`, `extinguisher`, `window`, `shoes`, `laundry`, `clock`, `stairs_flight`. | `bottom`, `top`, `loop_start` |
| `lecture_hall` | Giảng đường | ~20×14 | Bục giảng, bảng đen, 5–6 dãy bàn, cửa "Lối ra" (`door @travel`). NPC nữ thủ khoa. Anchor `seat_player`, `kiosk` (bước 4). | `entrance` |
| `library` | Thư viện | ~18×12 | Kệ sách, bàn đọc + đèn bàn, quầy thủ thư (chưa có NPC), "Lối ra". NPC tiền bối. Anchor `study_desk`, `photo_counter` (bước 4). | `entrance` |
| `food_shop` | Quán cơm – cà phê (theo QĐ-2.2) | ~16×10 | Bàn + ghế nhựa đỏ/xanh, quầy, bếp, góc pha cà phê, bảng hiệu (đèn), dải vỉa hè có xe máy dựng, "Lối ra". NPC chủ quán. Anchor `counter`, `coffee_bar`. | `entrance` |

- Đồ trang trí mang chất sinh viên Việt Nam: quạt trần, ổ điện nhiều phích, mì gói, xe máy dựng ngoài quán, bảng thông báo dán đầy giấy, dép trước cửa phòng.
- Tên phòng/tòa **hư cấu** (ví dụ "Phòng 412" — phòng của nhân vật ở Tầng 4, "Giảng đường H1"), không dùng mã tòa nhà thật của trường thật.
- `scripts/data/area_info.gd` — `class_name AreaInfo extends Resource`: `id`, `display_name`, `scene_path: String`, `show_in_travel: bool`, `travel_spawn: String = "entrance"`, `open_slots: Array[int]` (mặc định cả 4; Thư viện và Quán đóng lúc Đêm — đây là phần "phiên bản ngày/đêm" F6 của bản đồ), `music_path: String = ""`.
- `scripts/world/area_registry.gd` — `class_name AreaRegistry`, static, danh sách **hằng** đường dẫn `data/areas/*.tres` (không dùng DirAccess để liệt kê — bản export đổi tên file thành `.remap`). Hàm: `get_info(id) -> AreaInfo`, `all() -> Array[AreaInfo]`, `has_area(id) -> bool`.

### 3.9 Chuyển khu vực — `AreaManager`

- `scenes/game.tscn`: bỏ `Placeholder`, thêm `World` (Node2D, script `scripts/world/area_manager.gd`, nhóm `"area_manager"`), giữ `Hud`, `PauseMenu`. `game_scene.gd` gọi `InputLock.clear()` trong `_ready`.
- `class_name AreaManager extends Node2D`:
  ```
  const DEFAULT_AREA: String = "ktx_room"
  const DEFAULT_SPAWN: String = "default"
  signal area_change_started(area_id: String)
  signal area_changed(area_id: String)
  func change_area(area_id: String, spawn_id: String = "", fade: bool = true) -> void   # async
  func get_current_area() -> GameArea
  func get_current_area_id() -> String
  func get_player() -> Player
  ```
  Trình tự: khóa `InputLock` lý do `&"area_change"` → `SceneLoader.fade_out()` → bỏ khu cũ → nạp khu mới vào World → đặt Player ở spawn → cập nhật `Game.state.current_area/current_spawn` → `SceneLoader.fade_in()` → mở khóa → emit `area_changed`. Id không hợp lệ → `push_warning` + về `DEFAULT_AREA`. Bỏ qua nếu đang chuyển.
- Khi `GameScene` sẵn sàng: nạp khu theo `Game.state.current_area`/`current_spawn`. Khi `Game.state_replaced` (tải game từ menu tạm dừng): nạp lại theo state mới.
- **SceneLoader** (sửa tối thiểu file bước 1): thêm `func fade_out(duration: float = 0.25) -> void` và `func fade_in(duration: float = 0.25) -> void` (dùng lại ColorRect sẵn có, có thể `await`). Ghi vào ARCHITECTURE.md.
- **Door** — `scripts/world/door.gd`, `class_name Door extends Area2D`: `@export var target_area: String`, `@export var target_spawn: String`; lớp `trigger`, phát hiện Player khi bước vào; `target_area == "@travel"` → mở menu đi lại. Có thời gian chờ ~0,3 giây sau khi xuất hiện để không kích lại ngay; spawn đặt ngoài vùng cửa.
- **Menu đi lại** — `scenes/ui/travel_menu.tscn` + `scripts/ui/travel_menu.gd` (CanvasLayer layer 45): liệt kê `AreaRegistry.all()` có `show_in_travel` (KTX → `ktx_hallway/entrance`, Giảng đường, Thư viện, Quán), trừ khu hiện tại; khu đóng cửa theo khung giờ hiện mờ kèm "(Đóng cửa)". Mở menu thì `InputLock.lock(&"travel_menu")`, Esc/nút "Hủy" đóng. Chọn → `AreaManager.change_area(id, info.travel_spawn)`.
- `scripts/core/travel_rules.gd` — `class_name TravelRules`, static: `slot_cost(from_id, to_id) -> int` (bước 2 trả 0; **API dự kiến bước 4** dùng lại), `is_open(info: AreaInfo, slot: int) -> bool`, `destinations(current_id, slot) -> Array[Dictionary]`.

### 3.10 Ngày / đêm (F6)

- `scripts/data/day_night_config.gd` (`DayNightConfig`: `@export var slot_colors: Array[Color]` đủ 4 phần tử, `@export var transition_time: float = 1.5`) + `data/day_night.tres`: Sáng `Color(1, 1, 1)`, Chiều `Color(1, 0.97, 0.92)`, Tối (ám cam) `Color(1.0, 0.8, 0.62)`, Đêm (tối xanh) `Color(0.42, 0.47, 0.72)`. Hàm static `color_for_slot(config, slot) -> Color` (slot sai → màu Sáng).
- `scripts/world/day_night.gd` — `class_name DayNight extends CanvasModulate`, con của World: nghe `Game.time_changed` → tween màu; khi nạp khu / `state_replaced` → đặt màu ngay không tween. HUD/menu nằm trong CanvasLayer riêng nên không bị nhuộm.
- `scripts/world/slot_light.gd` — `class_name SlotLight extends PointLight2D`: `@export var active_slots: Array[int] = [2, 3]` (Tối, Đêm), texture `light_radial.png`, màu ấm `#ffd166`; bật/tắt có fade. Đặt ở đèn bàn thư viện, đèn hành lang, bảng hiệu quán, đèn phòng.
- **gl_compatibility**: PointLight2D 2D được hỗ trợ ở renderer Compatibility — [CẦN KIỂM TRA trên máy người dùng]. Nếu đèn không hiện: phương án dự phòng là Sprite2D phát sáng (CanvasItemMaterial blend Add) đặt trong một `CanvasLayer` riêng có `follow_viewport_enabled = true` (CanvasModulate chỉ nhuộm canvas của chính nó). Ghi cách đã chọn vào ARCHITECTURE.md.
- `scripts/world/slot_visibility.gd` (`SlotVisibility extends Node`): `@export var visible_slots: Array[int]` — ẩn/hiện node cha (kèm tắt va chạm) theo khung giờ. Dùng cho: bảng hiệu "Đã đóng cửa" lúc Đêm, NPC chủ quán vắng lúc Đêm. Bước 5 dùng lại.

### 3.11 Chuẩn bị cho G3 (cầu thang vô tận) — chỉ để chỗ

- `ktx_stairwell` là **một module** chiếu nghỉ lặp được: đi hết đợt lên ở mép trên và hết đợt xuống ở mép dưới đều chạm `stair_exit` → `GameArea.stair_exit_reached(direction)`.
- Xử lý mặc định bước 2 (`scripts/world/stairwell.gd` gắn vào scene, có thể bị bước 6 thay): `down` → `change_area("ktx_hallway", "from_stairs")`; `up` → `Toast.show_message("Lối lên tầng trên đang khóa.")`.
- Các anchor ở bảng 3.8 phải có thật trong map để bước 6 thay đồ vật "bất thường". Biển tầng mặc định hiện "4" (hành lang là Tầng 4).

### 3.12 Lưu vị trí khu vực

- `GameState`: thêm `var current_area: String = "ktx_room"`, `var current_spawn: String = "default"`; `setup_new_game()` đặt lại 2 giá trị này; `to_dict()` thêm khóa `"current_area"`, `"current_spawn"`; `from_dict()` thiếu khóa hoặc sai kiểu → mặc định. **Không tăng `SAVE_VERSION`.**
- Lưu theo **spawn id** (không lưu tọa độ chính xác): tải game → xuất hiện ở spawn gần nhất đã ghi. Khi chuyển khu, `current_spawn` = spawn đích.
- Cập nhật ARCHITECTURE.md (mục GameState + dạng save).

### 3.13 Kiểm chứng tĩnh — `tools/check_project.py`

Script Python chạy được trong môi trường AI (không cần Godot), các bước sau sẽ mở rộng:
1. Chạy `gdparse` (và `gdlint` nếu cấu hình được) cho mọi `.gd`.
2. Đọc mọi `.tscn`/`.tres`: mỗi `ext_resource` có `path` tồn tại; `id` không trùng; mọi `ExtResource("…")`/`SubResource("…")` trỏ tới id có thật; `parent=` của node trỏ tới node có thật.
3. Mọi chuỗi `res://…` trong `.gd` (preload/load/const) trỏ tới file có thật (trừ font người dùng tự tải).
4. Đọc `data/maps/*.tres`, kiểm tra như `MapParser` (độ dài hàng, ký tự hợp lệ, spawn bắt buộc theo bảng 3.8, cửa trỏ tới khu + spawn có thật, prop_id có trong catalog).
5. In tổng kết; mã thoát ≠ 0 nếu có lỗi.

---

## 4. Test bắt buộc (`tests/`, theo bộ chạy test bước 1)

Mỗi file `extends "res://tests/test_case.gd"`, nạp class bằng `preload(...)`, không phụ thuộc autoload:

| File | Kiểm tra |
|---|---|
| `test_map_parser.gd` | bản đồ hợp lệ → đúng kích thước, số ô, danh sách đối tượng; ký tự lạ → lỗi có hàng/cột; hàng lệch độ dài; thiếu `spawn default`; trùng spawn; chuỗi có ngoặc kép trong mô tả đối tượng |
| `test_maps_content.gd` | mọi `data/maps/*.tres` parse không lỗi; đủ spawn bắt buộc; mọi cửa trỏ tới khu + spawn có thật; mọi prop_id có trong catalog; `ktx_stairwell` có đủ anchor bước 6 cần |
| `test_interaction_picker.gd` | chọn gần nhất; bằng nhau lấy chỉ số nhỏ; mảng rỗng → -1 |
| `test_game_state_location.gd` | ván mới = `ktx_room`/`default`; `to_dict` → `json_round_trip` → `from_dict` giữ đúng; save thiếu trường → mặc định; `SaveCodec.from_json(SaveCodec.to_json(...))` giữ `current_area` |
| `test_day_night.gd` | `color_for_slot` đúng 4 khung; slot sai → màu Sáng |
| `test_input_lock.gd` | khóa/mở theo lý do; nhiều lý do; `clear()` |
| `test_travel_rules.gd` | `slot_cost` = 0; danh sách đích không có khu hiện tại; Thư viện/Quán đóng lúc Đêm |

Ngoài ra chạy `python3 tools/check_project.py` → 0 lỗi (ghi kết quả vào báo cáo).

---

## 5. Checklist cho người dùng khi mở Godot

1. Mở project bằng Godot 4.4+ → đợi import ảnh trong `art/`. Bảng Output không có lỗi đỏ. (Muốn chạy test bằng dòng lệnh lần đầu: `godot --headless --path . --import`.)
2. Mở `scenes/areas/ktx_room.tscn` trong Editor → thấy phòng KTX vẽ sẵn (nhờ `@tool`).
3. F5 → Chơi mới → chọn "Khó" → thấy phòng KTX pixel art, nhân vật đứng giữa, HUD góc trên trái như bước 1.
4. WASD/mũi tên: đi 8 hướng, đi chéo không nhanh hơn; va tường/giường/bàn không xuyên; camera bám mượt, không lộ khoảng đen ngoài bản đồ; điểm ảnh sắc nét (không nhòe). Nếu thấy rung hình: ghi lại để AI chỉnh pixel snap [CẦN KIỂM TRA].
5. Đến gần Minh → hiện "E — Minh"; nhấn E → toast "Minh: (hội thoại ở bước 3)". Đứng giữa 2 vật → gợi ý ở vật gần hơn.
6. Ra cửa phòng → fade → hành lang. Bảng chỉ đường → menu: Giảng đường / Thư viện / Quán (khu đang đứng không có trong danh sách). Ở các khu khác, đi vào "Lối ra" → menu đi lại.
7. Cầu thang: đi hết đợt xuống → về hành lang; đi hết đợt lên → toast "Lối lên tầng trên đang khóa."
8. Esc khi đang đi → nhân vật dừng, menu tạm dừng hiện; không đi được tới khi đóng menu.
9. F1 → "Qua khung giờ" 2 lần → Tối: ám cam, đèn bàn/đèn hành lang/bảng hiệu bật dần. Thêm 1 lần → Đêm: tối xanh; menu đi lại hiện "Thư viện (Đóng cửa)". Sang Sáng → đèn tắt. HUD không bị nhuộm màu. Nếu đèn không sáng → báo AI dùng phương án dự phòng [CẦN KIỂM TRA].
10. Đứng ở thư viện → Esc → Lưu ô 1 → Về menu chính → Tải game ô 1 → xuất hiện ở thư viện.
11. Tải một save cũ tạo từ bước 1 → vào phòng KTX, không lỗi.
12. Chạy test: `godot --headless --path . -s res://tests/run_tests.gd` → tất cả PASS.

---

## 6. Cách làm việc

- Trả lời tiếng Việt. Trước khi code: xác nhận các [CẦN QUYẾT ĐỊNH] đã chốt (hoặc nói rõ sẽ dùng khuyến nghị), liệt kê kế hoạch + danh sách file sẽ tạo/sửa, **CHỜ NGƯỜI DÙNG DUYỆT**. Đổi trạng thái bước 2 trong `docs/TASKS.md` thành "Đang code".
- Quy trình bắt buộc: **viết song song → rà chéo nhiều góc nhìn → kiểm chứng → sửa**.
  - Viết song song các phần độc lập: (a) `gen_art.py` + ART_STYLE.md, (b) logic thuần + test (MapParser, InteractionPicker, InputLock, TravelRules, DayNightConfig, GameState), (c) scene/script thế giới, (d) `check_project.py`.
  - Rà chéo theo các góc nhìn: hợp đồng ARCHITECTURE.md (tên, signal, thứ tự autoload); GDScript 4.4 kiểu tĩnh, không typed Dictionary; định dạng `.tscn`/`.tres` (layout_mode, ext_resource, không uid); `@tool` an toàn trong Editor; lưu/tải (JSON trả float, save cũ); trải nghiệm người chơi (va chạm, camera, chữ gợi ý); tông game.
  - Kiểm chứng: `gdparse`/`gdlint` mọi `.gd`, `python3 tools/check_project.py`, chạy `gen_art.py` và mở thử vài ảnh để chắc đúng kích thước.
- Chia 4 phần, xong mỗi phần thì báo cáo ngắn để người dùng chạy thử: (1) art + Player + `ktx_room` + va chạm; (2) 5 khu còn lại + chuyển khu + menu đi lại + lưu khu vực; (3) ngày/đêm + đèn; (4) NPC tĩnh + tương tác.
- Không cài addon/gói lớn, không xóa file khi chưa hỏi. Không sửa `FEATURES.md`/`STORY_MVP.md`/`BALANCE.md` ngoài việc đánh dấu ✅.
- Cập nhật `docs/ARCHITECTURE.md`: thêm mục "Bước 2 — Thế giới" (class, signal, định dạng MapData, lớp vật lý, input action mới, trường save mới, hàm mới của SceneLoader).
- Mỗi lần báo cáo: file tạo/sửa; mã tính năng đã xong; kết quả kiểm chứng tĩnh; cách kiểm tra (chạy game thấy gì, chạy test thế nào). Trong `FEATURES.md`, thêm ✅ vào đầu ô "Tính năng" của các mã đã xong (F1, F2, F4, F6). Xong cả bước → `docs/TASKS.md` đổi thành "Xong".
