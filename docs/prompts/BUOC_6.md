# BƯỚC 6 — DỊ TƯỢNG

> Prompt cho AI code. Trạng thái hàng đợi: `docs/TASKS.md`.

Dự án: "Tôi Là Sinh Viên Bách Khoa" — Godot 4.4+, GDScript kiểu tĩnh, PC trước. Project: `/home/user/BachKhoaRPG`.

**Tông truyện (đã chốt trong FEATURES.md): bí ẩn / kỳ ảo đô thị nhẹ nhàng, KHÔNG phải game kinh dị** — không jumpscare, không máu me, không chết chóc, không ma quỷ đáng sợ. Dị tượng ở game này là "lệch nhỏ trên vật thân thuộc", gây tò mò và hơi bồn chồn, không gây sợ. Đây là ràng buộc số 1 của bước này.

---

## [CẦN QUYẾT ĐỊNH] — người dùng chốt trước khi AI code bắt đầu

Nếu chưa có câu trả lời: dùng **khuyến nghị**, ghi rõ trong báo cáo.

| Mã | Câu hỏi | Phương án | Khuyến nghị |
|---|---|---|---|
| QĐ-6.1 | Câu đố cầu thang vô tận (STORY_MVP.md còn mở: "đi ngược chiều? đếm bậc?") | **A. "Chiếu nghỉ lạ"**: mỗi vòng, chiếu nghỉ hoặc y như cũ hoặc có đúng 1 chỗ lệch. Luật từ truyền thuyết tiền bối: *khác → đi xuống, giống → đi lên*; đúng 4 lần liên tiếp thì thoát. Lớp Vật lý: tiếng ù của giếng cầu thang như **ống kín một đầu**, f = v/(4L); chiếu nghỉ đúng luôn 25,0 Hz, chiếu nghỉ lệch có "chiều cao méo" nên tần số khác → người chơi Trí tuệ cao dùng số đo thay cho mắt. **B. "Đếm bậc"**: đợt thang thật 12 bậc; khi lạc thì có đợt 13 bậc; truyền thuyết: "đếm được 13 thì quay lưng đi xuống". Ngắn, ít nội dung, ít chơi lại. **C. "Đi ngược chiều tiếng ù"**: nghe âm lập thể, đi về phía tiếng ù nhỏ dần. Phụ thuộc loa/tai nghe, khó với người nghe kém. | **A** (gộp luôn "13 bậc" của B làm một trong các chỗ lệch) |
| QĐ-6.2 | Người chơi bị kẹt ở câu đố thì sao? | **A.** Gợi ý tự tăng 1 mức sau mỗi 3 lần sai liên tiếp; sau 8 lần sai (tổng) hiện lựa chọn "Gọi cho tiền bối" — tiền bối nói chiếu nghỉ hiện tại có lệch hay không, Sanity −5. **B.** Không trợ giúp. **C.** Như A + tùy chọn "Bỏ qua câu đố" trong Cài đặt (trợ năng). | **A** (thêm C nếu muốn trợ năng) |
| QĐ-6.3 | Âm báo "tần số lạ": 25 Hz rất trầm, nhiều loa laptop không phát được | **A.** Phát âm **tượng trưng** nghe được (sóng mang 200 Hz điều biên ở 25 Hz — nghe như tiếng rè rung), luôn hiện **số Hz trên điện thoại** + phụ đề mô tả. **B.** Phát đúng 25 Hz (chân thực nhưng nhiều máy im lặng). | **A** |

---

## Ràng buộc môi trường của AI code

- Project ở `/home/user/BachKhoaRPG`. **Không có Godot binary** → không chạy được game/test. Chỉ có **gdtoolkit** (`gdparse`, `gdlint`).
- Mạng chặn github.com, godotengine.org, fonts.google.com → không tải addon/asset/âm thanh. pypi/npm được; Pillow có sẵn.
- Đồ họa biến thể dị tượng: thêm vào `tools/gen_art.py` (bảng màu BK-24; màu tím #18, #19 chỉ dùng cho dị tượng). **Âm thanh tự tạo** bằng `tools/gen_audio.py` (thư viện chuẩn Python: `wave`, `math`, `struct`, `random.Random(seed)`), tất định.
- `.tscn`/`.tres` viết tay theo mẫu ARCHITECTURE.md. Test theo bộ chạy test tự viết, người dùng chạy trên máy.
- Kiểm chứng trong môi trường AI: `gdparse`/`gdlint`, `python3 tools/check_project.py` (mở rộng mục 3.8), và một script Python tính lại toàn bộ số Vật lý ở mục 3.5 (in bảng, so với dữ liệu `.tres`).

## Đọc trước

1. `docs/ARCHITECTURE.md` (bước 1–5). Tên thực tế khác "API dự kiến" bên dưới → theo ARCHITECTURE.md, ghi chú chỗ lệch.
2. `FEATURES.md` (G1–G4, dòng Tông truyện, "Câu đố Vật lý: người chơi tự giải; Trí tuệ càng cao gợi ý càng rõ"), `STORY_MVP.md` (tuần 3–4).
3. Ghi chú nghiên cứu (tham khảo, chỉ lấy ý hợp tông):
   - `/home/user/research_notes/Tư liệu cốt truyện Chapter 1/vat_ly_cau_do.md` — Thẻ 2 (sóng dừng, ống kín một đầu) và Thẻ 11 (dải nghe, hạ âm). **Không** dùng Đá Cộng Hưởng 503 Hz ở bước này (đó là G9, C1).
   - `truyen_thuyet_di_tuong.md` — mục Câu hỏi 2–3 (cầu thang "bậc thứ 13", luật đơn giản trên không gian lặp, radar điện thoại là gợi ý trợ năng, giữ không gian ít chi tiết để chỗ lệch dễ nhận ra) và Câu hỏi 4 (không kỳ thị, Minh là nạn nhân). **Bỏ** các ý mang màu kinh dị trong ghi chú (bóng đè, "nghe gọi tên thì đừng quay lại", hồn ma).
   - `thiet_ke_tu_su.md` — mục 4 (thất bại mềm, có trần thiệt hại, báo trước).

---

## 1. Mục tiêu

Điện thoại thành "radar" nhiễu khi dị tượng ở gần (G1); vùng có "tần số lạ" phát âm báo và rút Sanity từ từ (G2); sự kiện đêm trong phòng tuần 3 — bị đánh thức, thấy Minh lén ra ngoài (G4); dị tượng **cầu thang vô tận** với câu đố logic + Vật lý, gợi ý 3 mức theo Trí tuệ, thoát được thì đặt cờ `thoat_cau_thang` (G3).

Mã tính năng: **G1, G2, G3, G4**.

### KHÔNG làm ở bước này
- Dị tượng mạnh dần theo tuần (G5), xe buýt sương mù (G6), hành lang méo (G7), câu đố mạch điện (G8), câu đố cộng hưởng 503 Hz (G9), chế tạo (G10), thực thể dị biến (G11) — C1.
- Màn mở đầu cao trào tuần 4, cảnh kết sau khi thoát, màn "Còn tiếp…", lịch kích hoạt theo ngày (bước 7). Bước này cung cấp **API bắt đầu/kết thúc** vòng lặp và **nội dung lõi** của câu đố + truyền thuyết (để luật giải đố và lời tiền bối khớp nhau).
- Bất kỳ yếu tố kinh dị nào (xem 3.7).

---

## 2. Phụ thuộc

Cần **Bước 1–5 xong**.

| Nguồn | API dùng |
|---|---|
| Bước 1 | `Game.state` (`stats` — Sanity, Trí tuệ; `flags`), `AudioManager.play_sfx` / bus `SFX`, `Settings` (thêm tùy chọn), `Toast`, `pause_menu.gd` (nút Lưu game) |
| Bước 2 (API dự kiến) | `ktx_stairwell` + anchor `floor_sign`, `notice`, `extinguisher`, `window`, `shoes`, `laundry`, `clock`, `stairs_flight`; `GameArea.stair_exit_reached(direction)`; `stairwell.gd` (xử lý mặc định); `AreaManager.change_area`; `InputLock`; `DayNight`; `MapData` (thêm loại đối tượng mới) |
| Bước 3 (API dự kiến) | `DialogueSystem` (`start`, `register_command`, `dialogue_finished`), điều kiện `stat.knowledge`, `CharacterData` (`tien_boi`, `minh`), `StoryFlagRegistry` |
| Bước 4 (API dự kiến) | `StudentLife.add_sleep_interrupter(handler)`, `StudentLife.complete_sleep(recovery_multiplier)`, `AcademicRecord` (số buổi Vật lý 1 đã học — tùy chọn ở 3.4) |
| Bước 5 (API dự kiến) | `EventDirector` (trigger `sleep`, `enter_area`; thêm trigger mới `flag_set`), `NpcDirector` + Minh (`minh_trang_thai`), điện thoại (ô sóng ở thanh trạng thái, ứng dụng **Radar** đang là màn chờ), HUD icon điện thoại, `StoryState`, nhiệm vụ `q_minh`, `q_truyen_thuyet` |

---

## 3. Yêu cầu cụ thể

### 3.1 G1 — Radar điện thoại

- `scripts/anomaly/anomaly_source.gd` — `class_name AnomalySource extends Node2D` (nhóm `"anomaly_source"`): `@export var source_id`, `@export var strength: float` (0–1), `@export var radius_px: float`, `@export var condition: String` (cú pháp điều kiện bước 3; rỗng = luôn bật). Thêm loại đối tượng `anomaly <source_id>` vào `MapData`; nguồn gắn theo NPC được tạo bởi `NpcDirector`.
- `scripts/anomaly/radar_math.gd` (static, thuần): `signal_at(pos: Vector2, sources: Array[Dictionary]) -> float` = **max** theo các nguồn của `strength × clamp(1 − d/radius, 0, 1)`; `bars(signal: float) -> int` [ĐX]: < 0,10 → 0; < 0,30 → 1; < 0,55 → 2; < 0,80 → 3; còn lại → 4.
- `scripts/anomaly/anomaly_radar.gd` (con của World): mỗi ~0,2 giây tính tín hiệu tại vị trí Player → cập nhật: ô sóng điện thoại (nhảy vạch), icon điện thoại ở HUD (rung nhẹ theo số vạch), ứng dụng **Radar** (kim + số vạch + mô tả "Tín hiệu lạ: yếu/vừa/mạnh" + dòng **"Tiếng ù: 25,0 Hz"** khi đang trong vùng có tần số), tiếng tick (`radar_tick.wav`, thưa/dày theo vạch).
- Hiệu ứng nhiễu màn hình: lớp phủ mép màn hình rất nhẹ (alpha ≤ 0,15 × vạch/4). Cài đặt mới: **"Giảm hiệu ứng nhiễu màn hình"** (tắt lớp phủ, giữ phần trong điện thoại).
- Lần đầu tín hiệu ≥ 1 vạch → đặt cờ `radar_lan_dau = 1` (STORY tuần 3 "Điện thoại nhiễu lần đầu"). Thêm trigger **`flag_set <cờ>`** vào `EventDirector` (kích khi cờ chuyển từ 0 sang khác 0) để bước 7 viết đoạn độc thoại.
- Nguồn MVP [ĐX] (bước 7 có thể chỉnh lịch):

  | source_id | Gắn ở | Bật khi | strength | radius |
  |---|---|---|---|---|
  | `src_minh` | Minh | `flag.minh_trang_thai >= 2` | 0,3 (trạng thái 3: 0,5) | 3 ô |
  | `src_to_roi` | Anh K. | `week >= 3` | 0,35 | 2,5 ô |
  | `src_cau_thang` | `ktx_stairwell` | `week >= 3 and slot == DEM` (vòng lặp: 1,0) | 0,5 | 6 ô |

### 3.2 G2 — Âm báo + vùng trừ Sanity

- `scripts/anomaly/anomaly_zone.gd` — `class_name AnomalyZone extends Area2D` (loại đối tượng `zone <zone_id>` trong `MapData`, hoặc gắn theo NPC): `@export var hum_hz_display: float` (số hiện trên điện thoại), `@export var sanity_per_tick: int = 1`, `@export var tick_seconds: float = 5.0`, `@export var max_drain_per_visit: int = 10`, `@export var condition: String`.
- Logic thuần `scripts/anomaly/drain_counter.gd`: cộng dồn thời gian trong vùng, trả số Sanity cần trừ, dừng ở trần mỗi lần vào; ra khỏi vùng thì đặt lại. **Thời gian chỉ tính khi người chơi điều khiển được** (không tính lúc pause, hội thoại, điện thoại).
- Vào vùng: âm báo fade-in 1 giây trên bus SFX, âm lượng trần −12 dB; ra vùng: fade-out. Lần đầu trừ Sanity trong vùng → toast "Tiếng ù làm bạn bồn chồn (Sanity −1)"; các lần sau chỉ đổi số trên HUD (tránh spam).
- **Phụ đề** (Cài đặt mới "Phụ đề âm thanh", mặc định bật): "(Tiếng ù rất trầm, như rung trong lồng ngực…)".
- Vùng MVP [ĐX]: `zone_minh_wall` (quanh Minh trạng thái 3, Tối/Đêm, `hum_hz_display` 25,0), `zone_cau_thang_dem` (cầu thang, `week >= 3 and slot == DEM`, 25,0). Trong vòng lặp G3: **tắt trừ theo giây** (đã có hình phạt theo lượt sai, tránh phạt chồng).
- `tools/gen_audio.py` (QĐ-6.3 = A), 44.100 Hz, 16 bit, mono, đỉnh ≤ −6 dBFS:
  - `audio/sfx/hum_25hz_tuong_trung.wav`: s(t) = (1 + 0,6·sin(2π·25·t))·sin(2π·200·t), dài **đúng 1,00 s** (chứa trọn 200 chu kỳ sóng mang và 25 chu kỳ điều biên → nối vòng không vấp). Phổ: 175, 200, 225 Hz (f_mang ± f_điều biên).
  - `audio/sfx/radar_tick.wav`: tiếng tách ngắn ~30 ms.
  - `audio/sfx/nhieu_nhe.wav`: nhiễu trắng lọc thấp, 1,00 s, rất nhỏ.
  - Bật lặp bằng code khi nạp (`AudioStreamWAV.loop_mode = LOOP_FORWARD`, `loop_begin = 0`, `loop_end = số mẫu`) cho chắc, không phụ thuộc thiết lập import [CẦN KIỂM TRA trên máy người dùng: nghe có vấp ở điểm nối không].

### 3.3 G4 — Sự kiện đêm trong phòng (tuần 3)

- Cơ chế: `EventDirector` đăng ký một sleep interrupter với `StudentLife` (bước 4): khi người chơi đi ngủ, nếu có sự kiện `@trigger sleep` khớp → chạy sự kiện thay vì tua thẳng tới sáng; sự kiện kết thúc bằng lệnh `~ sleep_resume <hệ_số_hồi>` (gọi `StudentLife.complete_sleep`).
- Lệnh hội thoại mới: `~ night_wake` (màn đêm: tông màu Đêm, đèn tắt, người chơi đứng cạnh giường, thời gian không trôi), `~ change_area <area_id> <spawn_id>`, `~ npc_move <npc_id> <anchor_id> [giây]` (tween vị trí), `~ npc_hide <npc_id>`, `~ sleep_resume <hệ_số>`.
- Thêm anchor vào `data/maps/ktx_hallway.tres`: `minh_dem_1` (cuối hành lang), `cua_cau_thang` (trước cửa cầu thang) — `check_project.py` kiểm tra anchor mà lệnh `npc_move` dùng có tồn tại.
- **Nội dung thật** (bước này viết, file `content/dialogue/g4_dem_tuan3.dlg`, node `t3_dem_minh_ra_ngoai`):
  - `@trigger sleep`, `@when week == 3 and day >= 18 and flag.minh_trang_thai >= 2`, `@once` → bình thường kích vào Đêm Thứ Năm tuần 3 (ngày 18); nếu đêm đó người chơi không ngủ ở phòng thì kích vào lần ngủ kế tiếp trong tuần 3. Lịch có thể chỉnh ở bước 7.
  - Diễn biến: "Bạn tỉnh giấc. Điện thoại báo 02:14." → giường Minh trống, cửa phòng khép hờ, điện thoại 1 vạch nhiễu → lựa chọn:
    - **"Đi xem sao"** → hành lang về đêm; Minh ở cuối hành lang đi chậm về phía cửa cầu thang rồi khuất (`npc_move` + `npc_hide`); người chơi tự đi tới cửa cầu thang → "Cửa cầu thang khép. Bên trong lạnh và im, chỉ có tiếng ù rất nhỏ." → về giường → `thay_minh_ra_ngoai = 1`, `~ sleep_resume 0.7`, Sanity −5.
    - **"Chắc Minh đi vệ sinh. Ngủ tiếp."** → `thay_minh_ra_ngoai = 2`, `~ sleep_resume 0.85`, Sanity −2.
  - Sáng hôm sau (node riêng, `@trigger day_start`, `@when flag.thay_minh_ra_ngoai >= 1`, `@once`): Minh đã nằm trên giường như chưa có gì, chối nhẹ ("Tui đi vệ sinh thôi mà"). Cập nhật bước của `q_minh`.
  - Tông: yên tĩnh, ánh trăng xanh, không âm thanh đột ngột, Minh không quay lại nhìn chằm chằm, không có bóng đen/bóng ma.

### 3.4 G3 — Cầu thang vô tận (QĐ-6.1 = A)

**Logic thuần** `scripts/anomaly/stair_loop_state.gd` — `class_name StairLoopState extends RefCounted`:
```
var active: bool
var streak: int                 # số lựa chọn đúng liên tiếp
var required_streak: int = 4
var mistakes_total: int
var mistakes_in_row: int
var landing_index: int
var current_anomaly: String     # "" = chiếu nghỉ bình thường
func start(seed: int) -> void
func next_landing() -> String   # quyết định chiếu nghỉ kế tiếp; trả id chỗ lệch hoặc ""
func choose(direction: String) -> String    # "up"/"down" → "correct" / "wrong" / "escaped"
func hint_level(knowledge: int, config: PuzzleHintConfig) -> int   # 1–3
func should_offer_assist() -> bool
func to_dict() -> Dictionary / from_dict(d)
```
- Đúng = (bình thường **và** đi lên) hoặc (có chỗ lệch **và** đi xuống). Đúng → `streak += 1`; sai → `streak = 0`, `mistakes_total += 1`, `mistakes_in_row += 1`, Sanity −3 [ĐX]. `streak == required_streak` → `"escaped"`.
- Chiếu nghỉ **đầu tiên luôn bình thường** (để người chơi ghi nhớ "bản gốc"). Sau đó mỗi chiếu nghỉ 50% có chỗ lệch, nhưng không quá 2 chiếu nghỉ bình thường liên tiếp; không lặp một chỗ lệch cho tới khi dùng hết danh sách (xáo lại theo seed); không bao giờ 2 lần liên tiếp cùng một chỗ lệch.
- Gợi ý (QĐ-6.2 = A): `hint_level` = mức theo Trí tuệ (`data/puzzle_hints.tres` — `PuzzleHintConfig`: ngưỡng [ĐX] Trí tuệ < 25 → 1; 25–49 → 2; ≥ 50 → 3) + `floor(mistakes_in_row / 3)`, tối đa 3. Tùy chọn [ĐX]: đã học ≥ 6 buổi Vật lý 1 → +1 mức. Sau 8 lần sai tổng → `should_offer_assist()`.

**Dữ liệu chỗ lệch** `data/anomalies/stair_anomalies.tres` (`StairAnomalyCatalog` gồm các `StairAnomaly`: `id`, `mo_ta` (cho debug/test), `anchor_changes: Dictionary` (anchor → biến thể sprite/ẩn/hiện), `text_cue: String` (câu narrator khi bước vào, nếu có), `hum_length_m: float`). Tần số hiện trên điện thoại **tính từ** `hum_length_m` theo 3.5, không gõ tay:

| id | Chỗ lệch (so với chiếu nghỉ gốc) | L "méo" (m) | f hiện trên điện thoại |
|---|---|---|---|
| (gốc) | — | 3,43 | **25,0 Hz** |
| `bien_tang_phay` | biển tầng ghi "4'" thay vì "4" | 3,63 | 23,6 Hz |
| `dep_doi_mau` | đôi dép trước cửa đổi từ xanh sang đỏ | 3,23 | 26,5 Hz |
| `binh_chua_chay_mat` | bình chữa cháy biến mất | 3,73 | 23,0 Hz |
| `ao_quay_vao` | áo trên dây phơi quay mặt vào tường | 3,13 | 27,4 Hz |
| `dong_ho_nguoc` | kim đồng hồ treo tường chạy ngược | 3,83 | 22,4 Hz |
| `noi_quy_dong_la` | bảng nội quy có thêm dòng "Điều 13: Không đếm bậc thang." | 3,03 | 28,3 Hz |
| `mi_tom_mat_mui` | mùi mì tôm quen thuộc biến mất (chỉ có câu narrator) | 3,93 | 21,8 Hz |
| `muoi_ba_bac` | đợt thang có 13 bậc thay vì 12 | 2,93 | 29,3 Hz |

Chỗ lệch bằng hình chỉ dùng **màu tím** của bảng màu ở chi tiết nhỏ (ví dụ ánh tím mờ trên biển tầng "4'"), giữ không gian ít chi tiết để dễ nhận ra.

**Bộ điều khiển** `scripts/anomaly/stair_loop_controller.gd` (gắn vào World hoặc thay `stairwell.gd` khi vòng lặp bật):
- `begin()` (lệnh `~ stair_loop start`): chuyển tới `ktx_stairwell/loop_start`, `StairLoopState.start(seed)`, tắt nhạc nền, bật âm báo, radar 4 vạch, khóa lưu tay (thêm `SaveGate.block(&"stair_loop")` — PauseMenu làm mờ nút "Lưu game" kèm lý do "Không thể lưu lúc này"), **thời gian không trôi** trong vòng lặp. Lần đầu bước vào chạy node `cau_thang_bat_dau`.
- Bắt `stair_exit_reached(direction)` → `choose()` → fade nhanh 0,2 giây → đặt người chơi ở đầu đối diện của **cùng module** (đi lên ra mép trên thì xuất hiện ở mép dưới và ngược lại — liền mạch) → `next_landing()` → áp `anchor_changes`, `text_cue`, tần số điện thoại.
- Phản hồi tiến độ: radar giảm vạch theo `streak` (4 → 3 → 2 → 1); sai → về 4 vạch + câu narrator nhẹ nhàng ngẫu nhiên từ node `cau_thang_sai_*` ("Tiếng ù trầm xuống một chút. Hình như mình lại về chỗ cũ.").
- Thoát (`"escaped"`): chiếu nghỉ cuối là chiếu nghỉ thật (đèn bình thường, tiếng ù tắt, radar 0 vạch) → cờ `thoat_cau_thang = 1` → phát `stair_loop_escaped` (signal + `DialogueSystem` event) → `SaveGate.unblock` → bước 7 nối cảnh kết. Trước bước 7, mặc định: chạy node `cau_thang_thoat` rồi đưa về `ktx_hallway/from_stairs`.
- Gợi ý do **người chơi chủ động mở**: ứng dụng Radar có nút **"Suy nghĩ"** (và phím `hint` = phím **G**) → chạy node `goi_y_<mức>` tương ứng. Không tự bật gợi ý (giữ quyền tự giải).
- Lối thoát (QĐ-6.2): khi `should_offer_assist()` → ứng dụng Danh bạ có "Gọi tiền bối" → node `goi_tien_boi`: tiền bối nói chiếu nghỉ hiện tại "có gì khác không", Sanity −5; dùng được mỗi chiếu nghỉ 1 lần.
- Câu hỏi Vật lý tùy chọn (nên làm): ở chiếu nghỉ thứ 2, nếu mức gợi ý ≥ 2, điện thoại hiện "Ghi chú Vật lý" (node `cau_thang_cau_hoi`) — xem 3.5. Trả lời đúng: cờ `hieu_vong_lap = 1`, Sanity +5. Sai: giải thích lỗi, cho trả lời lại, không phạt.
- `DebugMenu`: "Bắt đầu cầu thang vô tận", "Xem chiếu nghỉ hiện tại (có lệch không)", "Thoát ngay".

**Nội dung lõi** (bước này viết thật, `content/dialogue/cau_thang.dlg` và `content/dialogue/truyen_thuyet.dlg`; bước 7 chỉ đặt lịch kích hoạt):
- `tien_boi_truyen_thuyet` — tiền bối kể truyền thuyết (bước 7 gắn vào tuần 2). Giọng thân thiện, hơi bí ẩn, có chút đùa; **phải chứa đủ 3 ý của lời giải**:
  1. Luật: "Lỡ có lúc đi hoài không tới tầng nào, đừng chạy. Nhìn chiếu nghỉ cho kỹ. Thấy chỗ nào khác lúc nãy — dù nhỏ thôi — thì quay xuống. Thấy y như cũ thì cứ đi lên. Đúng liền bốn lần là ra."
  2. Vật lý: "Nghe tiếng ù trong đó. Giếng cầu thang giống cái ống bịt một đầu, chỉ ngân được ở tần số hợp với chiều dài của nó. Chiều dài đổi là tiếng đổi. Mắt có thể lừa, số đo thì không."
  3. Số liệu: "Tầng KTX mình cao 3,43 mét, biển kỹ thuật ở chiếu nghỉ có ghi đó."
  Kết thúc: `~ set nghe_truyen_thuyet 1`, `~ quest done q_truyen_thuyet`. Tiền bối nói như kể chuyện vui ("anh thấy nó giống bài tập Vật lý hơn là chuyện ma"), không dọa.
- `cau_thang_bat_dau`, `cau_thang_sai_1..3`, `cau_thang_dung_1..3`, `cau_thang_thoat`, `goi_y_1`, `goi_y_2`, `goi_y_3`, `goi_tien_boi`, `cau_thang_cau_hoi` (+ các nhánh giải thích).
- Ở chiếu nghỉ gốc đặt **biển kỹ thuật** (anchor `notice` hoặc thêm `tech_plate`): "Chiều cao tầng: 3,43 m". Ứng dụng điện thoại có **nhiệt kế**: trong cầu thang hiện "20 °C" ("mát lạnh lạ thường") — để v = 343 m/s khớp số liệu (xem 3.5).

### 3.5 Vật lý — nội dung phải đúng (đã kiểm tra lại bằng máy tính)

**Mô hình (đơn giản hóa cho game, ghi rõ trong giải thích):** giếng cầu thang trong vòng lặp xem như **ống kín một đầu** — sàn chiếu nghỉ là đầu kín, phía trên là đầu hở — dài L bằng chiều cao một tầng.

| Đại lượng | Công thức / giá trị | Đơn vị |
|---|---|---|
| Sóng dừng ống kín một đầu | f_n = n·v/(4L), **n = 1, 3, 5…** (chỉ họa âm lẻ); cơ bản λ₁ = 4L, f₁ = v/(4L) | Hz, m |
| Ống hở hai đầu (để so sánh/bẫy) | f_n = n·v/(2L), n = 1, 2, 3… | Hz |
| Tốc độ âm trong không khí | v ≈ 331 + 0,6·t (t tính bằng °C) → ở 20 °C: **v ≈ 343 m/s** | m/s |
| Chiếu nghỉ gốc | L = 3,43 m → f₁ = 343 / (4 × 3,43) = 343 / 13,72 = **25,0 Hz**; λ₁ = 13,72 m; họa âm kế tiếp 75,0 Hz, 125 Hz | |
| Chiếu nghỉ lệch | f = 343 / (4 × L_méo), làm tròn 0,1 Hz (bảng 3.4). Mọi chỗ lệch có \|f − 25,0\| ≥ 1,3 Hz → luật cho gợi ý mức 3: "**lệch từ 1 Hz trở lên là chiếu nghỉ đã bị méo**" | |
| Nhiệt độ | Ở 27 °C (đêm TP.HCM thường gặp) v ≈ 347 m/s → f₁ ≈ 25,3 Hz. Vì vậy game cố định nhiệt kế cầu thang 20 °C. **Không** dùng chi tiết nhiệt độ làm bẫy ở MVP | |
| Dải nghe | Tai người khoảng 20 Hz – 20 kHz; 25 Hz nằm sát ngưỡng dưới, thường cảm nhận như tiếng ù/rung; dưới 20 Hz là hạ âm | |
| Âm tượng trưng (QĐ-6.3 = A) | điều biên: (1 + m·sin 2πf_m t)·sin 2πf_c t với f_c = 200 Hz, f_m = 25 Hz, m = 0,6 → thành phần 175, 200, 225 Hz. Điện thoại vẫn hiện 25,0 Hz vì đó là tần số "của cầu thang" trong truyện | |

**Gợi ý 3 mức** (node `goi_y_1..3`; chữ có thể trau chuốt nhưng giữ đúng ý và số):
1. "Chiếu nghỉ này… giống hệt lúc nãy? Hay khác một chút? Anh tiền bối dặn: khác thì đi xuống, giống thì đi lên."
2. "Tiếng ù như phát ra từ một cái ống kín một đầu: nó chỉ ngân ở tần số f = v/(4L). Chiếu nghỉ bình thường thì L đúng bằng chiều cao một tầng — đo được tần số là biết chiều dài có bị 'kéo méo' không."
3. "Tầng cao L = 3,43 m, trong cầu thang 20 °C nên v ≈ 343 m/s → f = 343 / (4 × 3,43) = 25,0 Hz. Điện thoại đo lệch khỏi 25,0 Hz từ 1 Hz trở lên → chiếu nghỉ này đã bị méo → đi xuống. Đúng 25,0 Hz → đi lên."

**Câu hỏi tùy chọn** `cau_thang_cau_hoi`: "Tiếng ù đo được 25,0 Hz. Giếng cầu thang như ống kín một đầu, v = 343 m/s. Chiều dài 'ống' L bằng bao nhiêu?"
- **3,43 m** — đúng (L = v/(4f) = 343/100). Phản hồi: "L đúng bằng chiều cao một tầng! Mình đang đi vòng trong đúng một tầng."
- 6,86 m — sai: đó là v/(2f), công thức của ống **hở hai đầu**.
- 13,72 m — sai: đó là bước sóng λ = v/f = 4L, không phải L.
- 1,72 m — sai: chia nhầm cho 8 (v/(8f)).

**Hiểu lầm cần tránh trong mọi câu chữ**: nhầm ống kín với ống hở; nhầm λ với L; viết "25 Hz là tần số ma/tần số gây ảo giác" (không có cơ sở khoa học — dị tượng là hư cấu, Vật lý chỉ là công cụ đo); nói "hạ âm thôi miên được người" (không có bằng chứng). Chỗ nào AI code muốn thêm công thức/số mới chưa có ở bảng trên → ghi **[CẦN KIỂM TRA]** và hỏi người dùng.

### 3.6 Lưu và an toàn trạng thái

- `scripts/core/save_gate.gd` — `class_name SaveGate` (static `block(reason)`, `unblock(reason)`, `is_blocked()`, `clear()`): PauseMenu tôn trọng; không ảnh hưởng tự lưu đầu ngày (vòng lặp không làm sang ngày).
- `StairLoopState` không cần lưu vào save (không lưu được giữa vòng lặp). Thoát game giữa chừng → tải tự lưu đầu ngày, chơi lại tối đó.
- Mọi khóa (`InputLock`, `SaveGate`) phải được mở lại ở mọi nhánh kết thúc (thoát, về menu chính, tải game khác) — `GameScene._ready` gọi `clear()` cho cả hai.

### 3.7 Quy tắc tông (rà chéo bắt buộc)

| Được | Không được |
|---|---|
| Lệch nhỏ trên đồ vật thân thuộc, ánh tím mờ, tiếng ù trầm nhỏ, nhiệt độ mát lạ | Jumpscare, âm thanh to đột ngột, rung/chớp màn hình mạnh |
| Câu narrator nhẹ, có chút hài ("Mùi mì tôm quen thuộc… không còn nữa.") | Máu, xác, cái chết, bóng ma, quái vật, mặt người méo mó |
| Minh là nạn nhân, mơ hồ, đáng thương | Minh quay lại nhìn chằm chằm, đuổi theo, đe dọa |
| Từ ngữ trong thế giới game ("lệch nhịp", "méo") | Nhãn bệnh tâm thần ("điên", "loạn trí"), hình ảnh bệnh viện tâm thần |
| Sai thì quay lại nhẹ nhàng, có trần thiệt hại, luôn có lối thoát | Thua cuộc, Game Over, kẹt vĩnh viễn |

Âm lượng mọi âm báo ≤ −12 dB qua bus SFX, luôn fade-in; tôn trọng âm lượng người dùng đặt.

### 3.8 Mở rộng `tools/check_project.py`

Kiểm tra: mọi `StairAnomaly.anchor_changes` trỏ tới anchor có trong `data/maps/ktx_stairwell.tres`; mọi biến thể sprite có file; node `goi_y_1..3`, `cau_thang_*`, `tien_boi_truyen_thuyet` tồn tại; tần số tính từ `hum_length_m` khớp bảng 3.4 (±0,05) và |f − 25,0| ≥ 1,0; `wav` tồn tại, đúng 44.100 Hz/mono/16 bit, độ dài 1,00 s cho file lặp.

---

## 4. Test bắt buộc

| File | Kiểm tra |
|---|---|
| `test_radar_math.gd` | 1 nguồn: tại tâm = strength, tại biên = 0, ngoài biên = 0; nhiều nguồn lấy max; ngưỡng vạch ở các mốc 0,10 / 0,30 / 0,55 / 0,80 |
| `test_drain_counter.gd` | trừ 1 mỗi 5 giây; dừng ở trần 10; ra vùng đặt lại; không đếm khi bị khóa điều khiển |
| `test_stair_loop_state.gd` | chiếu nghỉ đầu luôn bình thường; luật đúng/sai cả 4 trường hợp; sai thì `streak = 0`; đúng 4 lần liên tiếp → `"escaped"`; không quá 2 chiếu nghỉ bình thường liên tiếp; không lặp chỗ lệch tới khi hết danh sách (seed cố định); không 2 lần liền cùng chỗ lệch; `hint_level` theo ngưỡng Trí tuệ và +1 mỗi 3 lần sai liên tiếp, trần 3; `should_offer_assist` sau 8 lần sai |
| `test_stair_physics.gd` | f(3,43) = 25,0; mọi chỗ lệch trong catalog: f = 343/(4L) làm tròn 0,1 khớp bảng 3.4 và \|f − 25,0\| ≥ 1,0; đáp án câu hỏi: L = v/(4f) = 3,43; các phương án sai đúng bằng 6,86 / 13,72 / 1,72 (`assert_almost_eq`) |
| `test_night_event.gd` | sự kiện `sleep` khớp ngày 18 (Thứ Năm tuần 3) khi `minh_trang_thai >= 2`; không khớp ngày 17 hoặc tuần 4; đêm 18 không ngủ thì khớp lần ngủ ngày 19–21; `@once`; `sleep_resume` gọi `complete_sleep` với hệ số đúng |
| `test_save_gate.gd` | block/unblock nhiều lý do; `clear()` |
| `test_anomaly_content.gd` | nội dung lõi tồn tại và parse 0 lỗi; `tien_boi_truyen_thuyet` chứa các từ khóa của lời giải ("đi xuống", "đi lên", "bốn", "ống", "3,43"); không có cụm từ cấm trong các `.dlg` của dị tượng (danh sách đặt trong test, ví dụ: "máu", "xác chết", "ma quỷ", "hồn ma", "điên", "loạn trí", "tâm thần"). Không cấm từ đơn "chết" vì thành ngữ đời thường ("chết rồi, trễ học!") hợp lệ |

Chạy thêm `python3 tools/check_project.py`, `python3 tools/gen_audio.py` và script tính lại số Vật lý; dán bảng số vào báo cáo.

---

## 5. Checklist cho người dùng khi mở Godot

1. F1 đặt `minh_trang_thai = 2`, ngày ≥ 15 → đến gần Minh: ô sóng điện thoại nhảy, icon điện thoại ở HUD rung nhẹ, có tiếng tách thưa. Lần đầu → cờ `radar_lan_dau = 1`.
2. Tab → ứng dụng Radar: kim + số vạch + "Tín hiệu lạ: yếu". Ra xa → về 0.
3. Cài đặt → bật "Giảm hiệu ứng nhiễu màn hình" → mất lớp phủ mép màn hình, điện thoại vẫn báo.
4. F1 `minh_trang_thai = 3`, buổi Tối ra hành lang chỗ Minh đứng quay mặt vào tường → nghe tiếng ù rè nhỏ (fade-in, không giật mình), phụ đề hiện, điện thoại "Tiếng ù: 25,0 Hz"; Sanity giảm 1 mỗi ~5 giây, tối đa 10 mỗi lần vào vùng. Mở điện thoại/pause → không bị trừ.
5. F1 nhảy tới Thứ Năm tuần 3 (ngày 18), `minh_trang_thai = 2`, đi ngủ → bị đánh thức lúc 02:14, giường Minh trống. Chọn "Đi xem sao" → hành lang đêm, Minh đi khuất vào cửa cầu thang; tới cửa → câu "Cửa cầu thang khép…" → về ngủ. Sáng hôm sau Minh chối "đi vệ sinh". Cả đoạn yên tĩnh, không có gì làm giật mình.
6. F1 → "Bắt đầu cầu thang vô tận": nhạc tắt, tiếng ù, radar 4 vạch, nhiệt kế 20 °C, biển kỹ thuật "Chiều cao tầng: 3,43 m". Esc → "Lưu game" bị mờ "Không thể lưu lúc này".
7. Đi lên ở chiếu nghỉ đầu (bình thường) → xuất hiện ở chân đợt thang, radar còn 3 vạch. Gặp chiếu nghỉ có chỗ lệch (ví dụ biển "4'") → đi xuống → đúng; đi lên → sai: radar về 4 vạch, câu narrator nhẹ, Sanity −3.
8. Điện thoại → Radar → "Suy nghĩ" (hoặc G): F1 chỉnh Trí tuệ 10 / 30 / 60 → thấy 3 mức gợi ý khác nhau; mức 3 có phép tính 343/(4 × 3,43) = 25,0 Hz. Sai liên tiếp 3 lần → gợi ý tự lên 1 mức.
9. Trí tuệ ≥ 25 → ở chiếu nghỉ thứ 2 có "Ghi chú Vật lý": chọn 6,86 m → giải thích "ống hở hai đầu"; chọn 3,43 m → đúng, Sanity +5.
10. Cố tình sai 8 lần → Danh bạ có "Gọi tiền bối" → tiền bối nói chiếu nghỉ này có lệch không.
11. Đúng 4 lần liên tiếp → chiếu nghỉ thật: đèn bình thường, tiếng ù tắt, radar 0 vạch → cờ `thoat_cau_thang = 1` → về hành lang; "Lưu game" dùng lại được.
12. Âm báo lặp không vấp ở điểm nối [CẦN KIỂM TRA]; chỉnh âm lượng SFX trong Cài đặt có tác dụng với tiếng ù.
13. Chạy test: `godot --headless --path . -s res://tests/run_tests.gd` → tất cả PASS.

---

## 6. Cách làm việc

- Trả lời tiếng Việt. Trước khi code: xác nhận QĐ-6.1 → QĐ-6.3; liệt kê kế hoạch + danh sách file; **CHỜ NGƯỜI DÙNG DUYỆT**. Đổi trạng thái bước 6 trong `docs/TASKS.md` thành "Đang code".
- Quy trình bắt buộc: **viết song song → rà chéo nhiều góc nhìn → kiểm chứng → sửa**.
  - Song song: (a) radar + nguồn + HUD/điện thoại; (b) vùng tần số + âm thanh `gen_audio.py` + phụ đề; (c) `StairLoopState` + controller + dữ liệu chỗ lệch + đồ họa biến thể; (d) nội dung lõi `.dlg` (truyền thuyết, gợi ý, câu hỏi, G4).
  - Rà chéo theo 4 góc nhìn bắt buộc: **Vật lý** (mọi công thức, đơn vị, số khớp bảng 3.5; chạy script tính lại), **Tông truyện** (bảng 3.7, đọc lại từng câu thoại), **Trợ năng** (chơi được khi tắt tiếng nhờ số trên điện thoại + phụ đề; chơi được khi không phân biệt màu nhờ chỗ lệch không chỉ dựa vào màu — ví dụ dép đổi màu thì kèm đổi kiểu), **Kỹ thuật** (khóa luôn được mở, không lưu được giữa vòng lặp, không trừ Sanity chồng, hàm thuần test được).
  - Kiểm chứng: `gdparse`/`gdlint`, `check_project.py`, script tính số Vật lý, `gen_audio.py` (kiểm tra thông số wav bằng module `wave`).
- Không cài gói lớn, không xóa file khi chưa hỏi. Sửa file bước 1–5 ở mức tối thiểu, liệt kê trong báo cáo.
- Cập nhật `docs/ARCHITECTURE.md`: mục "Bước 6 — Dị tượng" (AnomalySource/Zone, RadarMath, StairLoopState + controller + API `begin`/`stair_loop_escaped`, SaveGate, trigger `flag_set`, lệnh mới, Cài đặt mới, âm thanh). Cập nhật `STORY_MVP.md` mục "Còn mở": đánh dấu câu đố cầu thang đã chốt theo QĐ-6.1 (chỉ dòng đó).
- Báo cáo: file tạo/sửa; mã đã xong; bảng số Vật lý đã tính lại; cách kiểm tra. Thêm ✅ vào `FEATURES.md` cho G1, G2, G3, G4. Xong → `docs/TASKS.md` đổi thành "Xong".
