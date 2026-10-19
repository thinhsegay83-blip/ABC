# BƯỚC 3 — HỘI THOẠI & CỜ CỐT TRUYỆN

> Prompt cho AI code. Trạng thái hàng đợi: `docs/TASKS.md`.

Dự án: "Tôi Là Sinh Viên Bách Khoa" — Godot 4.4+, GDScript kiểu tĩnh, PC trước. Thế giới hư cấu, tông bí ẩn nhẹ — KHÔNG kinh dị. Project: `/home/user/BachKhoaRPG`.

---

## [CẦN QUYẾT ĐỊNH] — người dùng chốt trước khi AI code bắt đầu

Nếu chưa có câu trả lời: dùng **khuyến nghị**, ghi rõ trong báo cáo.

| Mã | Câu hỏi | Phương án | Khuyến nghị |
|---|---|---|---|
| QĐ-3.1 | Hệ thống hội thoại | **A.** Tự viết hệ thống nhẹ, kịch bản là file văn bản thuần `.dlg` (định dạng ở mục 3.1) — AI đọc/viết/kiểm tra được, không phụ thuộc addon. **B.** Addon *Dialogue Manager 3* — người dùng tự cài trên máy (AI không tải được từ GitHub), AI viết file `.dialogue` nhưng không chạy thử được. **C.** Addon *Dialogic 2* — nặng, dữ liệu dạng timeline khó viết tay, cũng phải người dùng tự cài. | **A**. Nếu chọn B/C: AI code dừng sau phần cờ (H1) + đặt tên (J10), viết hướng dẫn cài addon từng bước cho người dùng, rồi mới làm tiếp. |
| QĐ-3.2 | Tên mặc định gợi ý trong ô đặt tên (J10) | **A.** Gợi ý sẵn một tên (ví dụ "Phong"), người chơi sửa được. **B.** Để trống, bắt buộc nhập. **C.** Nút "Ngẫu nhiên" chọn từ danh sách 10 tên nam phổ biến. | **A** (thêm C nếu rảnh). Tên gợi ý để trong `data/player_defaults.tres`, không viết cứng. |

---

## Ràng buộc môi trường của AI code

- Project ở `/home/user/BachKhoaRPG`. **Không có Godot binary** → không chạy được game/test. Chỉ có **gdtoolkit** (`gdparse`, `gdlint`).
- Mạng chặn github.com, godotengine.org, fonts.google.com → **không tải được addon (Dialogic, Dialogue Manager…) hay asset**. pypi/npm được; Pillow có sẵn.
- Chân dung nhân vật là **placeholder tự tạo** bằng `tools/gen_art.py` (bước 2), đúng bảng màu BK-24 trong `docs/ART_STYLE.md`.
- `.tscn`/`.tres` viết tay theo mẫu ARCHITECTURE.md. Test theo bộ chạy test tự viết, người dùng chạy trên máy.
- Kiểm chứng trong môi trường AI: `gdparse`/`gdlint` + `python3 tools/check_project.py` (mở rộng thêm phần kiểm tra `.dlg`, mục 3.10).

## Đọc trước

1. `docs/ARCHITECTURE.md` (bước 1 + mục bước 2 do AI code bước 2 viết). Nếu tên API bước 2 thực tế khác "API dự kiến" bên dưới → **theo ARCHITECTURE.md**, ghi chú chỗ lệch.
2. `FEATURES.md`, `STORY_MVP.md` (danh sách cờ, NPC), `BALANCE.md`.
3. `docs/ART_STYLE.md` (bảng màu, kích thước chân dung 64×64).

---

## 1. Mục tiêu

Có hệ thống hội thoại hoàn chỉnh: hộp thoại có **chân dung**, tên người nói, chữ chạy, **lựa chọn rẽ nhánh** đổi chỉ số/cờ (E1); quản lý **cờ cốt truyện** có danh mục kiểm tra được (H1); tiện ích **xem lại lịch sử, tua đoạn đã đọc, tự chạy chữ, chỉnh tốc độ chữ** (J9); **đặt tên nhân vật** khi bắt đầu ván (J10). Nối thử vào 4 NPC tĩnh của bước 2.

Mã tính năng: **E1, H1, J9, J10**.

### KHÔNG làm ở bước này
- Nội dung cốt truyện thật tuần 1–4 (bước 7). Chỉ viết hội thoại **demo** ngắn để thử hệ thống.
- Sự kiện tự kích theo ngày/khu vực, lịch trình NPC, sổ nhiệm vụ, điện thoại (bước 5) — nhưng parser **phải đọc và lưu** dòng metadata `@…` để bước 5 dùng.
- Hành động tốn khung giờ, tiền lương, cửa hàng (bước 4).
- Lồng tiếng, hiệu ứng rung/chớp màn hình.

---

## 2. Phụ thuộc

Cần **Bước 1 + Bước 2 xong**.

| Nguồn | API dùng |
|---|---|
| Bước 1 | `Game.state` (`GameState`: `stats`, `clock`, `flags`), `Game.state_replaced`, `Game.new_game(id)`; `PlayerStats` (`get_stat/change_stat`, `get_money/change_money`, `get_relationship/change_relationship`, `Stat` enum); `FlagStore` (`get_flag/set_flag/has_flag`, `flag_changed`); `GameClock` (`day`, `slot`, `get_week()`, `get_weekday()`); `MoneyFormat.format_vnd`; `Toast.show_message`; `Settings` (`load_settings/save_settings/apply`, `settings_changed`, `SETTINGS_PATH`); `SaveSystem.get_slot_info`; `main_menu.gd` + `NewGameDialog.difficulty_chosen`; `DebugMenu` |
| Bước 2 (API dự kiến) | `InputLock.lock/unlock/is_locked`; `Interactable` (`id`, `display_name`, signal `interacted`); `Npc` (`npc_id`, có con Interactable); `Player.can_move()`; `docs/ART_STYLE.md`, `tools/gen_art.py`, `tools/check_project.py` |

---

## 3. Yêu cầu cụ thể

### 3.1 Định dạng kịch bản `.dlg` (QĐ-3.1 = A)

File UTF-8 trong `content/dialogue/` (mỗi file một nhóm cảnh, ví dụ `demo_buoc3.dlg`; bước 7 sẽ có `tuan1.dlg`…). Mỗi dòng là một trong các loại sau:

```
# Chú thích: bỏ qua. Dòng trống: bỏ qua.

== minh_chao_hoi
@tag demo
@trigger interact minh          # metadata: bước 3 chỉ lưu vào node.meta, bước 5 mới dùng
minh: Ê, phòng 412 phải không? Tui là Minh.
minh (cuoi): Quạt trần phòng này kêu như máy cày, quen là ngủ ngon.
player: Chào Minh, mình là {player_name}.
narrator: Ngoài cửa sổ, ai đó rồ xe máy.
minh: Tối nay góp quỹ phòng nha ông? [if flag.da_gop_quy == 0]
* Góp 200.000 đ luôn -> minh_gop_quy [need money >= 200000 | Không đủ tiền]
* Để mai tính -> minh_de_mai
* (Im lặng) -> minh_im_lang [if stat.sanity < 30]

== minh_gop_quy
~ money -200000 "Góp quỹ phòng"
~ set da_gop_quy 1
~ rel minh 5
minh (cuoi): Chơi đẹp! Cuối tháng tui ghi sổ đàng hoàng.

== minh_de_mai
minh: Ừ, tùy ông.
~ end
```

Quy tắc:

| Loại dòng | Cú pháp | Ghi chú |
|---|---|---|
| Node | `== <node_id>` | `node_id` dạng `[a-z0-9_]+`, **duy nhất trong toàn bộ** `content/dialogue/` |
| Metadata | `@<khóa> <giá trị>` | chỉ ngay sau dòng `==`, trước dòng nội dung đầu tiên; lưu vào `node.meta` (Dictionary khóa → mảng chuỗi, vì một khóa có thể lặp). Khóa bước 5 sẽ dùng: `@trigger`, `@when`, `@priority`, `@once` |
| Lời thoại | `<speaker>: <text>` hoặc `<speaker> (<biểu_cảm>): <text>` | `speaker` = id trong `data/characters/` hoặc `player` / `narrator`. Biểu cảm mặc định `thuong` |
| Lựa chọn | `* <text> -> <node_id>` | các dòng `*` liền nhau = một nhóm lựa chọn; hội thoại dừng chờ chọn |
| Lệnh | `~ <lệnh> <tham số…>` | xem bảng lệnh |
| Đuôi điều kiện | `[if <đk>]` | gắn được vào cuối **lời thoại, lựa chọn, lệnh**: sai thì bỏ qua (lựa chọn thì ẩn) |
| Đuôi yêu cầu | `[need <đk> \| <lý do>]` | chỉ cho lựa chọn: sai thì **hiện mờ, không chọn được**, kèm lý do |

- Hết node mà không có `~ goto`/`~ end` → **kết thúc hội thoại** (không rơi xuống node kế tiếp).
- Chữ trong lời thoại/lựa chọn: thay `{player_name}`, `{money}` (định dạng `MoneyFormat`), `{day}`, `{week}`; BBCode cho phép: `[b] [i] [color=…]`. Biến lạ `{x}` giữ nguyên + cảnh báo (test bắt lỗi).
- Một dòng thoại nên ≤ ~90 ký tự (2 dòng trong hộp thoại); dài hơn chỉ cảnh báo, không lỗi.

**Lệnh có sẵn ở bước 3**:

| Lệnh | Tác dụng |
|---|---|
| `~ set <cờ> <số nguyên>` | `FlagStore.set_flag` |
| `~ add <cờ> <±số>` | cộng vào cờ (mặc định 0) |
| `~ stat <stamina\|hunger\|sanity\|knowledge> <±số>` | `PlayerStats.change_stat` (tự kẹp 0–100) |
| `~ money <±số> ["lý do"]` | `change_money`; bước 4 sẽ chuyển sang đi qua sổ thu chi kèm lý do |
| `~ rel <npc_id> <±số>` | `change_relationship` |
| `~ goto <node_id>` | nhảy node |
| `~ end` | kết thúc |
| `~ toast "<chữ>"` | `Toast.show_message` |
| `~ emit <tên_sự_kiện> [tham số…]` | phát `DialogueSystem.dialogue_event` cho hệ thống khác bắt (bước 4–7) |

Lệnh lạ → lỗi parser. Bước sau thêm lệnh qua `DialogueSystem.register_command()`; parser chấp nhận tên lệnh đã đăng ký (test nội dung chạy sau khi đăng ký đủ).

**Điều kiện** `<đk>`: các phép so sánh `<biến> <op> <giá trị>` nối bằng `and` / `or` (`and` ưu tiên hơn `or`; không có ngoặc). `op`: `== != >= <= > <`. Giá trị: số nguyên, hoặc hằng khung giờ `SANG CHIEU TOI DEM` (= 0–3).

| Biến | Lấy từ |
|---|---|
| `flag.<cờ>` | `flags.get_flag(cờ, 0)` |
| `stat.stamina` / `stat.hunger` / `stat.sanity` / `stat.knowledge` | `stats.get_stat(...)` |
| `money` | `stats.get_money()` |
| `rel.<npc_id>` | `stats.get_relationship(...)` |
| `day`, `week`, `weekday` (0 = Thứ Hai … 6 = Chủ Nhật), `slot` (0–3) | `clock` |

Biến lạ → đánh giá là **false** + ghi lỗi (không crash).

### 3.2 Logic thuần (test được, không cần scene tree)

Đặt ở `scripts/dialogue/`, `extends RefCounted`:

- `DialogueParser` (static): `parse(text: String, file_name: String) -> DialogueScript`. `DialogueScript` gồm `nodes: Dictionary` (node_id → node có `id`, `meta`, `entries`, `file`, `line`) và `errors: PackedStringArray` dạng `"tuan1.dlg:42: <mô tả>"`. Lỗi cần bắt: nội dung trước node đầu tiên, trùng node_id, lựa chọn thiếu `->`, lệnh lạ, điều kiện sai cú pháp, `[need …]` thiếu `|`, metadata đặt sai chỗ.
- `DialogueCondition` (static): `evaluate(expr: String, state: GameState, errors: PackedStringArray) -> bool` và `validate(expr) -> String` (chuỗi rỗng = hợp lệ).
- `DialogueLibrary`: nạp mọi `.dlg` trong `res://content/dialogue/` (DirAccess), gộp node, báo trùng id giữa các file. Có `has_dialogue(node_id) -> bool` (**không** đặt tên `has_node` — trùng hàm của Node).
- `DialogueRunner`: chạy một hội thoại trên một `GameState`:
  ```
  signal line_shown(entry: Dictionary)          # {speaker, display_name, expression, text, line_key}
  signal choices_shown(choices: Array)          # mỗi phần tử {text, enabled, reason, index}
  signal event_emitted(name: String, args: PackedStringArray)
  signal finished(node_id: String)
  func start(node_id: String) -> bool
  func advance() -> void                        # sang dòng kế (sau khi UI hiện xong)
  func choose(index: int) -> void
  func is_running() -> bool
  ```
  Lệnh áp dụng ngay khi chạy qua. Chống vòng lặp vô hạn: quá 1000 bước liên tiếp không có lời thoại/lựa chọn → dừng + lỗi.
- `line_key` cho tính năng "đã đọc" = `"<node_id>:<chỉ số lời thoại trong node>"`.
- `ReadLog`: `mark_read(key)`, `is_read(key) -> bool`, `load_from(path)`, `save_to(path)`. Lưu **chung cho mọi ván** (như visual novel) ở `user://dialogue_read.cfg` — không nằm trong save game.
- `PlayerName` (static): `sanitize(text) -> String` (cắt khoảng trắng 2 đầu, gộp khoảng trắng liên tiếp) và `validate(text) -> String` (chuỗi lỗi tiếng Việt, rỗng = hợp lệ): 1–16 ký tự Unicode, cho phép chữ tiếng Việt có dấu, số, dấu cách, `-` và `'`; cấm `{ } [ ] \ " : ` và ký tự điều khiển (tránh phá cú pháp thay biến/BBCode).

### 3.3 Dữ liệu nhân vật (E1)

- `scripts/data/character_data.gd` — `class_name CharacterData extends Resource`: `id`, `display_name`, `name_color: Color`, `portraits: Dictionary` (biểu cảm → Texture2D), `default_expression: String = "thuong"`.
- `data/characters/<id>.tres` cho: `minh`, `k` (hiển thị "Anh K."), `chu_quan` ("Cô Ba chủ quán" — tên gợi ý, đổi được), `giang_vien` ("Thầy"), `thu_khoa` (tên hiển thị gợi ý "Ngọc Hân"), `tien_boi` ("Anh năm n"), `me` ("Mẹ" — cho cuộc gọi bước 7), `player` (tên lấy từ `GameState.player_name`).
- Mở rộng `tools/gen_art.py`: chân dung `art/portraits/por_<id>_<biểu_cảm>.png` 64×64 (hiện ×3 = 192 px, lọc nearest). Biểu cảm tối thiểu: `thuong`, `cuoi`, `buon`, `ngac_nhien`; thêm `met` cho Minh (quầng thâm — bước 5 dùng). Không có chân dung đúng biểu cảm → dùng `default_expression`; không có cả hai → ẩn khung chân dung.

### 3.4 Autoload `DialogueSystem` — `scripts/autoload/dialogue_system.gd`

- Thêm vào `project.godot` **ngay sau `Game`** (không `class_name`); `process_mode = ALWAYS` không cần — hội thoại tạm dừng theo menu tạm dừng.
  ```
  signal dialogue_started(node_id: String)
  signal dialogue_finished(node_id: String)
  signal dialogue_event(event_name: String, args: PackedStringArray)
  func start(node_id: String) -> bool          # false nếu không có node hoặc đang có hội thoại khác
  func is_active() -> bool
  func has_dialogue(node_id: String) -> bool
  func register_command(command_name: String, handler: Callable) -> void   # handler(args: PackedStringArray, state: GameState)
  func reload_content() -> void                # đọc lại content/dialogue (nút trong DebugMenu)
  func get_errors() -> PackedStringArray
  ```
- Khi hội thoại chạy: `InputLock.lock(&"dialogue")`; kết thúc: mở khóa, lưu `ReadLog`.
- Lệnh thay đổi chỉ số/tiền/quan hệ → toast ngắn minh bạch: "Sanity −5", "Tiền −200.000 đ", "Quan hệ với Minh +5". Đổi cờ thì **không** toast (cờ là ẩn).
- **Xuất bản (export)**: `.dlg` không phải resource của Godot → phải thêm bộ lọc `*.dlg` vào *Export → Resources → Filters to export non-resource files*. Ghi vào ARCHITECTURE.md và checklist (file `export_presets.cfg` bị gitignore nên người dùng tự đặt trên máy). Kiểm tra DirAccess liệt kê được `.dlg` trong bản export → [CẦN KIỂM TRA khi export lần đầu].

### 3.5 Giao diện hộp thoại — `scenes/ui/dialogue_box.tscn` + `scripts/ui/dialogue_box.gd`

- `CanvasLayer` layer 30, instance trong `game.tscn`. Khung dưới màn hình: chân dung trái (192×192), tên người nói (màu `name_color`), `RichTextLabel` chữ chạy (`visible_characters`), mũi tên "▼" khi chờ.
- Lựa chọn: danh sách nút giữa màn hình; phím số 1–9, ↑/↓ + Enter, chuột. Lựa chọn khóa: mờ + lý do trong ngoặc.
- `narrator`: không tên, không chân dung, chữ nghiêng.
- Nút nhỏ trên khung: **Tự động**, **Tua**, **Lịch sử** (bấm chuột được).

### 3.6 Tiện ích hội thoại (J9)

| Tính năng | Phím (thêm action vào `project.godot` + `_ensure_input_actions`) | Hành vi |
|---|---|---|
| Tiếp | `dialogue_next`: Space, Enter, E, chuột trái | chữ đang chạy → hiện hết; đã hiện hết → câu tiếp. Bỏ qua lần nhấn E vừa dùng để mở hội thoại; sau khi hội thoại kết thúc, chặn `interact` ~0,2 giây để lần nhấn E cuối không mở lại chính hội thoại đó |
| Tua | `dialogue_skip`: **giữ** Ctrl (hoặc bật nút Tua) | chạy nhanh qua các câu **đã đọc**; dừng ở câu chưa đọc (trừ khi bật cài đặt "Tua cả đoạn chưa đọc") và **luôn dừng ở lựa chọn** |
| Tự động | `dialogue_auto`: phím T | bật/tắt; câu hiện xong thì chờ `auto_delay + 0,03 giây × số ký tự` rồi tự sang câu |
| Lịch sử | `dialogue_history`: phím L, cuộn chuột lên | bảng cuộn 200 câu gần nhất của phiên chơi (tên + nội dung; lựa chọn đã chọn ghi "→ …"); Esc/L đóng |

- **Cài đặt** (mở rộng `Settings` — sửa tối thiểu file bước 1, section mới `[dialogue]` trong `settings.cfg`): `text_speed` (ký tự/giây: 20 Chậm / 40 Vừa / 80 Nhanh / 0 Tức thì; mặc định 40), `auto_delay` (0,5–3,0 giây; mặc định 1,2), `skip_unread` (mặc định false). Thêm điều khiển vào `settings_panel.tscn`. Đổi là áp dụng ngay.
- Esc khi đang mở Lịch sử → đóng Lịch sử; không thì mở menu tạm dừng như bình thường (hội thoại giữ nguyên chỗ).

### 3.7 Cờ cốt truyện (H1)

- `scripts/data/story_flag_registry.gd` — `class_name StoryFlagRegistry extends Resource`: `@export var flags: Dictionary` (tên cờ → mô tả + ý nghĩa giá trị). File `data/story_flags.tres`.
- Đưa sẵn các cờ trong `STORY_MVP.md`: `ktx_khu` (1 = Khu A, 2 = Khu B, 0 = chưa chọn → coi như A), `da_gop_quy`, `da_dong_hoc_phi`, `nhan_viec_to_roi`, `canh_bao_minh`, `minh_trang_thai` (1–3; 0/không có → 1), `thoat_cau_thang`. Bước 4–7 thêm cờ của mình vào đây.
- Quy ước tên: snake_case tiếng Việt không dấu (như STORY_MVP.md); cờ hướng dẫn chơi bắt đầu bằng `tut_`; cờ hệ thống nội bộ bắt đầu bằng `sys_`.
- DebugMenu: ô nhập tên cờ có gợi ý từ danh mục (OptionButton hoặc tự hoàn thành); nút "Nạp lại hội thoại" (`DialogueSystem.reload_content()`); nút "Mở node…" để chạy thử node bất kỳ.
- `FlagStore` giữ nguyên API. Không emit `flag_changed` khi tải (đã đúng ở bước 1).

### 3.8 Đặt tên nhân vật (J10)

- `GameState`: thêm `var player_name: String = ""`; `to_dict()` thêm `"player_name"`; `from_dict()` thiếu/sai kiểu → `PlayerName` mặc định trong `data/player_defaults.tres` (`PlayerDefaults`: `default_name`, `random_names: Array[String]`). Không tăng `SAVE_VERSION`.
- `scenes/ui/name_dialog.tscn` + `scripts/ui/name_dialog.gd`: tiêu đề "Tên của bạn là gì?", `LineEdit` (max 16), dòng báo lỗi đỏ, nút "Bắt đầu" (disable khi không hợp lệ), "Quay lại". `signal name_confirmed(name: String)`, `signal cancelled`, `func open(default_name: String) -> void`.
- Luồng "Chơi mới" (sửa tối thiểu `main_menu.gd`): chọn chế độ → hộp đặt tên → `Game.new_game(id)` → `Game.state.player_name = tên` → chuyển scene. "Quay lại" về hộp chọn chế độ.
- Ô lưu hiện tên: thêm khóa `"player_name"` vào `SaveSystem.get_slot_info()` (mở rộng, không đổi khóa cũ), dòng ô lưu thành "Ô 1 — Phong — Ngày 3 (Tuần 1, Chiều) · Khó · …".
- `GameScene` chạy thẳng (F6) không có tên → dùng tên mặc định.

### 3.9 Nối vào thế giới + nội dung demo

- `Interactable`: thêm `@export var dialogue_node: String = ""`. Có giá trị → `interact()` gọi `DialogueSystem.start(dialogue_node)` thay cho toast; không có node đó → toast cảnh báo + `push_warning`.
- `content/dialogue/demo_buoc3.dlg`: 4 đoạn ngắn cho Minh (có lựa chọn đổi cờ `da_gop_quy` + quan hệ + tiền), chủ quán, nữ thủ khoa, tiền bối — mỗi đoạn 3–6 câu, có `[if]`, `[need]`, `~ emit demo_event` để thử. Ghi đầu file: `# DEMO bước 3 — bước 7 sẽ thay bằng nội dung thật`.
- Tông: đời thường, hài nhẹ; xưng hô sinh viên miền Nam tự nhiên (tui/ông, mình/bạn).

### 3.10 Mở rộng `tools/check_project.py`

Thêm phần kiểm tra `.dlg` (cùng luật với `DialogueParser`, mức cấu trúc): node trùng; `goto`/lựa chọn trỏ tới node có thật; speaker có `data/characters/<id>.tres` (hoặc `player`/`narrator`); cờ dùng trong `set/add/[if]/[need]` có trong `data/story_flags.tres`; lệnh có trong danh sách lệnh đã biết (khai báo trong script, bước sau bổ sung); chân dung tham chiếu có file.

---

## 4. Test bắt buộc

| File | Kiểm tra |
|---|---|
| `test_dialogue_parser.gd` | node + meta (khóa lặp) + lời thoại + biểu cảm + lựa chọn `[if]`/`[need … \| …]` + lệnh; lỗi có số dòng: nội dung trước node, trùng id, lựa chọn thiếu `->`, lệnh lạ, điều kiện sai, metadata sai chỗ |
| `test_dialogue_condition.gd` | 6 toán tử; `and` ưu tiên hơn `or`; hằng `SANG…DEM`; biến lạ → false + lỗi; `rel.minh`, `money`, `weekday` |
| `test_dialogue_runner.gd` | `start` node không có → false; thứ tự câu; `[if]` bỏ câu; lựa chọn ẩn/khóa có lý do; lệnh tác động `GameState` (cờ, chỉ số kẹp 0–100, tiền âm được, quan hệ); `goto`; kết thúc ngầm cuối node; thay `{player_name}`, `{money}`; `emit` ra signal; chống vòng lặp vô hạn |
| `test_read_log.gd` | đánh dấu/đọc/lưu/nạp với đường dẫn `user://test_read_log.cfg` (dọn sau test) |
| `test_player_name.gd` | `sanitize`/`validate` (rỗng, 17 ký tự, "Đức Anh" hợp lệ, có `[`, `{`, xuống dòng → lỗi); `GameState` lưu/tải `player_name`; save thiếu trường → tên mặc định |
| `test_flag_registry.gd` | đủ 7 cờ của STORY_MVP.md |
| `test_dialogue_content.gd` | mọi `.dlg` trong `content/dialogue/` parse **0 lỗi**; mọi đích `goto`/lựa chọn tồn tại; speaker có CharacterData; cờ có trong danh mục |

Chạy thêm `python3 tools/check_project.py` → 0 lỗi.

---

## 5. Checklist cho người dùng khi mở Godot

1. Mở Editor → đợi import `art/portraits/`. Không lỗi đỏ.
2. Chơi mới → chọn chế độ → hộp "Tên của bạn là gì?" có tên gợi ý. Xóa trắng → nút "Bắt đầu" mờ + báo lỗi; gõ "Đức Anh" → được; gõ có dấu `[` → báo lỗi. "Quay lại" về chọn chế độ.
3. Vào game, đến gần Minh, nhấn E → hộp thoại dưới màn hình: chân dung trái, tên màu, chữ chạy dần; có câu nhắc đúng tên bạn vừa đặt.
4. Nhấn Space/click khi chữ đang chạy → hiện hết câu; nhấn lần nữa → câu tiếp. Lúc này nhân vật không đi được.
5. Gặp lựa chọn: phím 1/2 hoặc chuột. Lựa chọn khóa hiện mờ kèm lý do ("Không đủ tiền" — thử bằng F1 giảm tiền). Chọn góp quỹ → toast "Tiền −200.000 đ", "Quan hệ với Minh +5"; F1 thấy cờ `da_gop_quy = 1`.
6. Nhấn T → bật tự chạy (nút sáng). Nhấn L hoặc cuộn chuột lên → bảng lịch sử; Esc đóng.
7. Nói chuyện lại với Minh → giữ Ctrl: tua vèo các câu đã đọc, dừng ở lựa chọn.
8. Esc → Cài đặt → đổi tốc độ chữ (Chậm/Nhanh/Tức thì), độ trễ tự chạy, "Tua cả đoạn chưa đọc" → có hiệu lực ngay; thoát game mở lại vẫn giữ.
9. Lưu ô 1 → menu chính → Tải game: ô 1 hiện tên nhân vật; tải xong tên vẫn đúng trong hội thoại.
10. Nói chuyện với chủ quán, nữ thủ khoa, tiền bối → có đoạn demo, không còn toast "(hội thoại ở bước 3)".
11. F1 → "Nạp lại hội thoại" sau khi sửa tay một câu trong `content/dialogue/demo_buoc3.dlg` → câu mới hiện ngay.
12. Chạy test: `godot --headless --path . -s res://tests/run_tests.gd` → tất cả PASS.
13. (Khi export lần đầu) Thêm `*.dlg` vào bộ lọc file không phải resource, chạy bản export → hội thoại vẫn hiện [CẦN KIỂM TRA].

---

## 6. Cách làm việc

- Trả lời tiếng Việt. Trước khi code: xác nhận QĐ-3.1, QĐ-3.2; liệt kê kế hoạch + danh sách file tạo/sửa; **CHỜ NGƯỜI DÙNG DUYỆT**. Đổi trạng thái bước 3 trong `docs/TASKS.md` thành "Đang code".
- Quy trình bắt buộc: **viết song song → rà chéo nhiều góc nhìn → kiểm chứng → sửa**.
  - Song song: (a) parser + điều kiện + runner + test; (b) UI hộp thoại + J9 + cài đặt; (c) J10 + GameState + luồng menu; (d) dữ liệu nhân vật + chân dung + nội dung demo + `check_project.py`.
  - Rà chéo: hợp đồng ARCHITECTURE.md; trường hợp biên của parser (dòng trống, khoảng trắng thừa, tiếng Việt có dấu, dấu `:` trong lời thoại, BBCode chèn từ tên người chơi); lưu/tải (save cũ thiếu `player_name`); trải nghiệm đọc (tốc độ chữ, không mất lần nhấn, không kẹt khóa điều khiển khi hội thoại lỗi); tông game.
  - Kiểm chứng: `gdparse`/`gdlint`, `python3 tools/check_project.py`; tự "chạy khô" parser bằng tay trên `demo_buoc3.dlg` (liệt kê kết quả mong đợi trong báo cáo).
- Không cài addon/gói lớn, không xóa file khi chưa hỏi. Sửa file bước 1–2 ở mức tối thiểu và liệt kê trong báo cáo.
- Cập nhật `docs/ARCHITECTURE.md`: mục "Bước 3 — Hội thoại" (định dạng `.dlg` đầy đủ, autoload mới + thứ tự, API, input action mới, section `[dialogue]` của settings, trường save `player_name`, bộ lọc export `*.dlg`).
- Báo cáo: file tạo/sửa; mã đã xong; kết quả kiểm chứng; cách kiểm tra. Thêm ✅ vào `FEATURES.md` cho E1, H1, J9, J10. Xong → `docs/TASKS.md` đổi thành "Xong".
