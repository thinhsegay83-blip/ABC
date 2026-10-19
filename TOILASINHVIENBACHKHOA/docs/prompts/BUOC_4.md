# BƯỚC 4 — VÒNG LẶP ĐỜI SINH VIÊN

> Prompt cho AI code. Trạng thái hàng đợi: `docs/TASKS.md`.

Dự án: "Tôi Là Sinh Viên Bách Khoa" — Godot 4.4+, GDScript kiểu tĩnh, PC trước. Thế giới hư cấu, tông bí ẩn nhẹ — KHÔNG kinh dị. Project: `/home/user/BachKhoaRPG`.

---

## [CẦN QUYẾT ĐỊNH] — người dùng chốt trước khi AI code bắt đầu

Nếu chưa có câu trả lời: dùng **khuyến nghị**, ghi rõ trong báo cáo; mọi con số đặt trong `.tres` để đổi sau không phải sửa code.

| Mã | Câu hỏi | Phương án | Khuyến nghị |
|---|---|---|---|
| QĐ-4.1 | F4 không có khu "cửa hàng" nhưng D6 cần chỗ mua đồ ăn/giáo trình. Mua ở đâu? | **A.** Không thêm khu: quầy trong quán (cơm, phở, bánh mì), góc cà phê (cà phê cóc, trà sữa), máy bán nước ở hành lang KTX (nước tăng lực, mì gói), quầy photo trong thư viện (giáo trình). **B.** Thêm khu "căn tin/tạp hóa KTX". **C.** Mua qua ứng dụng trên điện thoại (bước 5), có phí ship. | **A** |
| QĐ-4.2 | Phạt trễ hạn học phí 500.000 tính thế nào? | **A.** Cộng vào khoản phải đóng (còn phải đóng 16.500.000, tới hạn gia hạn cuối tuần 4). **B.** Trừ thẳng vào ví lúc trễ hạn (có thể âm tiền). | **A** (không bị âm tiền bất ngờ; vẫn đúng "gia hạn + phạt 500.000") |
| QĐ-4.3 | D7 "cà phê cóc = Thể lực tạm thời" cần trạng thái tạm thời, nhưng A9 (trạng thái tạm thời) là C1 | **A.** Làm bản rút gọn chỉ một hiệu ứng "cafein": +20 Thể lực ngay, hết tác dụng sau 2 khung giờ thì −10. **B.** Cà phê chỉ +Thể lực vĩnh viễn (đơn giản, mất ý "tạm thời"). **C.** Chờ A9. | **A** (khung hiệu ứng làm sẵn để C1 mở rộng thành A9) |
| QĐ-4.4 | A3 ghi "Sanity về 0 thì Bad Ending" nhưng Bad Ending (H11) và màn Game Over (J14) là C1. MVP xử lý sao? | **A.** Thất bại mềm: màn "Bạn cần nghỉ ngơi" — mất trọn ngày hôm sau (ngủ li bì), Sanity hồi về 30, có tin nhắn hỏi thăm (bước 5). **B.** Màn "Bad Ending (bản thử)" rồi cho tải lại tự lưu đầu ngày. **C.** Chỉ cảnh báo, không hậu quả. | **A** (đúng tinh thần thất bại mềm; Bad Ending thật để C1) |
| QĐ-4.5 | Giá và tác dụng giáo trình (BALANCE.md chưa có) | **A.** Bản photo 80.000/môn: tự học môn đó hiệu quả hơn (+5 điểm học thay vì +3). **B.** Sách gốc 150.000: như A + Trí tuệ +1 mỗi lần tự học. **C.** Không bán giáo trình trong MVP. | **A** (ghi vào BALANCE.md dạng [ĐX]) |
| QĐ-4.6 | "Tháng" trong game để thu tiền KTX/quỹ phòng | **A.** 1 tháng = 4 tuần = 28 ngày (thu ngày 1, 29, 57…). **B.** 30 ngày. | **A** (khớp lịch tuần, MVP 28 ngày thu đúng 1 lần) |
| QĐ-4.7 | BALANCE.md dùng giả định "làm tối đa 2 ca/ngày". Có biến thành luật không? | **A.** Có: mỗi ngày tối đa 2 ca làm thêm (tính chung mọi việc, kể cả tờ rơi bước 5). **B.** Không giới hạn, chỉ bị chặn bởi khung giờ mở cửa và Thể lực. | **A** (dòng tiền khớp BALANCE.md; số lấy từ `.tres`) |

---

## Ràng buộc môi trường của AI code

- Project ở `/home/user/BachKhoaRPG`. **Không có Godot binary** → không chạy được game/test. Chỉ có **gdtoolkit** (`gdparse`, `gdlint`).
- Mạng chặn github.com, godotengine.org, fonts.google.com → không tải addon/asset. pypi/npm được; Pillow có sẵn. Icon món ăn/vật phẩm là placeholder vẽ bằng `tools/gen_art.py` theo `docs/ART_STYLE.md`.
- `.tscn`/`.tres` viết tay theo mẫu ARCHITECTURE.md. Test theo bộ chạy test tự viết, người dùng chạy trên máy.
- Kiểm chứng trong môi trường AI: `gdparse`/`gdlint`, `python3 tools/check_project.py`, và **`python3 tools/sim_cashflow.py`** (mục 3.14) — chạy được ngay trong môi trường AI để kiểm tra cân bằng.

## Đọc trước

1. `docs/ARCHITECTURE.md` (bước 1–3). Tên thực tế khác "API dự kiến" bên dưới → theo ARCHITECTURE.md, ghi chú chỗ lệch.
2. **`BALANCE.md`** (giá đã chốt, 3 chế độ, học phí, luật gia hạn, bảng dòng tiền 14 ngày), `FEATURES.md` (A1–A3, B2–B4, B10, C1–C3, D1, D6, D7), `STORY_MVP.md`.

---

## 1. Mục tiêu

Người chơi sống được trọn một ngày sinh viên: xem thời khóa biểu, đi học (điểm danh), tự học ở thư viện, làm thêm ở quán, mua ăn uống có hiệu ứng riêng, ngủ; thời gian trôi theo hành động; tiền KTX thu định kỳ; có hạn học phí HK1 cuối tuần 2 (trễ thì gia hạn tới cuối tuần 4 + phạt 500.000); cuối ngày có màn tổng kết thu/chi/chỉ số. Hoàn thiện hậu quả của A1–A3 (ngất, đói lả, Sanity về 0).

Mã tính năng: **C1, C2, C3, D1, D6, D7, B2, B3, B4, B10** (+ hoàn thiện hiệu ứng A1, A2, A3).

### KHÔNG làm ở bước này
- Việc của K. (phát tờ rơi, D3), quỹ phòng (D4), đi chơi (E6), Mức dính líu K. (A8) — bước 5. (Nhưng hệ thống hành động/phí định kỳ phải **mở để bước 5 thêm bằng dữ liệu**.)
- Giao diện túi đồ (I1), điện thoại (I2), sổ nhiệm vụ (H2) — bước 5. Bước này chỉ làm **mô hình dữ liệu** `Inventory` vì D6 cần.
- Thi giữa kỳ (B6), bảng điểm cuối kỳ (C5), học bổng (C6), thức trắng (C4), học phí HK2 (B13), xe buýt (F7).
- Vật liệu chế tạo trong cửa hàng (chế tạo G10 là C1).
- Nội dung cốt truyện (bước 7). Chỉ thêm 1 đoạn demo "xin việc ở quán" để mở khóa việc làm khi thử.

---

## 2. Phụ thuộc

Cần **Bước 1, 2, 3 xong**.

| Nguồn | API dùng |
|---|---|
| Bước 1 | `Game` (`state`, `advance_time()`, `new_game()`, signal `new_day`, `time_changed`, `state_replaced`; `_on_new_day` tự lưu **sau khi** phát `new_day`), `GameState` (`stats`, `clock`, `flags`, `wage_multiplier`, `decay_multiplier`, `apply_decay`, `to_dict/from_dict`), `TimeDecayConfig` (`data/time_decay.tres`), `PlayerStats`, `GameClock` (`Slot`, `get_weekday()`, `get_week()`, `set_time()` chỉ phát `time_changed`), `FlagStore`, `MoneyFormat`, `Toast`, `DebugMenu`, `hud.gd` (`%AdvanceButton` tạm thời) |
| Bước 2 (API dự kiến) | `Interactable` (`id`, `interacted`), `GameArea.get_anchor()`, `AreaManager` (`change_area`, `get_current_area_id`), `TravelRules.slot_cost()` (vẫn 0), `AreaInfo.open_slots`, `InputLock`, `SlotVisibility`, anchor `seat_player`, `kiosk`, `study_desk`, `photo_counter`, `counter`, `coffee_bar`, `vending`, `bed_player`, `desk_player` |
| Bước 3 (API dự kiến) | `DialogueSystem.start()`, `register_command()`, `dialogue_event`; `DialogueCondition.evaluate()` (dùng lại cú pháp điều kiện cho `ActionData.requires`); `StoryFlagRegistry` (`data/story_flags.tres`) |

---

## 3. Yêu cầu cụ thể

### 3.1 Dữ liệu (J13) — mọi con số nằm trong `.tres`

Class trong `scripts/data/`, file trong `data/`. Số chưa có trong BALANCE.md là **[ĐX]** — ghi chúng vào một mục mới "Đề xuất bước 4 [ĐX]" trong `BALANCE.md` (không sửa giá đã chốt).

**`EconomyConfig`** → `data/economy.tres`

| Trường | Giá trị | Nguồn |
|---|---|---|
| `tuition_amount` | 16.000.000 | BALANCE (chốt) |
| `tuition_due_day` | 14 (hết Chủ Nhật tuần 2) | BALANCE (chốt) |
| `tuition_extended_due_day` | 28 (hết Chủ Nhật tuần 4) | FEATURES (chốt) |
| `tuition_late_penalty` | 500.000 (cách tính theo QĐ-4.2) | chốt |
| `tuition_late_sanity` | −10 | BALANCE ghi "Sanity giảm" — số [ĐX] |
| `tuition_reminder_days` | [8, 12, 13, 14]; gia hạn: [22, 26, 27, 28] | [ĐX] |
| `ktx_fee` | 300.000 / tháng | BALANCE [ĐX] |
| `room_fund_fee` | 200.000 / tháng (bước 5 dùng) | BALANCE [ĐX] |
| `month_length_days` | 28 | QĐ-4.6 |
| `max_shifts_per_day` | 2 | QĐ-4.7 |
| `wage_round_to` | 1.000 | [ĐX] |
| `classes_start_day` | 2 (ngày 1 là ngày nhận phòng, chưa có tiết) | [ĐX] |

**`ActionData`** → `data/actions/<id>.tres`: `id`, `display_name`, `slot_cost`, `allowed_slots: Array[int]`, `requires: String` (điều kiện cú pháp bước 3, rỗng = luôn được), `stamina`, `hunger`, `sanity`, `knowledge` (delta), `base_wage`, `tip_max`, `counts_as_shift: bool`, `category` ("study"/"work"/"rest").

| id | Tên | Nơi (anchor) | Khung | Tốn | Thể lực | Đói | Sanity | Trí tuệ | Tiền |
|---|---|---|---|---|---|---|---|---|---|
| `di_hoc` | Vào học | giảng đường `seat_player` | đúng tiết trong TKB | 1 | −8 | — | — | +2 | — |
| `tu_hoc` | Tự học | thư viện `study_desk` | Sáng/Chiều/Tối | 1 | −6 | — | −2 | +3 | — |
| `lam_quan_com` | Phụ quán cơm | quán `counter` | Sáng, Chiều | 1 | −15 | −5 | — | — | 120.000 (chốt) |
| `bung_ca_phe` | Bưng cà phê | quán `coffee_bar` | Tối | 1 | −12 | −5 | — | — | 100.000 + tip 0–30.000 (chốt) |
| `nghi` | Nghỉ ngơi | phòng `bed_player` | Sáng/Chiều/Tối | 1 | +10 | — | +3 | — | — |
| `ngu` | Đi ngủ | phòng `bed_player` | Tối, Đêm | tới Sáng hôm sau | +60 (ngủ từ Tối: +75) | — | +10 | — | — |

Ngoài số trong bảng là **[ĐX]**. Lương: `(base_wage + randi_range(0, tip_max)) × wage_multiplier`, làm tròn tới 1.000 đ (hệ số lương áp cho cả tip — ghi rõ trong BALANCE.md). Hai việc làm thêm `requires = "flag.lam_them_quan == 1"` (mở khóa sau khi chủ quán nhận — demo ở 3.12; bước 7 viết thật).

**`ItemData`** → `data/items/<id>.tres`: `id`, `display_name`, `description`, `icon`, `price`, `category` ("food"/"drink"/"book"/"story"), `hunger`, `stamina`, `sanity`, `effect_id` (ví dụ `cafein`), `consume_on_buy: bool`, `study_subject: String`.

| id | Tên | Giá | Đói | Thể lực | Sanity | Bán ở (QĐ-4.1 = A) |
|---|---|---|---|---|---|---|
| `banh_mi` | Bánh mì | 20.000 (chốt) | +15 | — | — | quầy quán |
| `com_tam` | Cơm tấm | 30.000 (chốt) | +25 | — | — | quầy quán |
| `pho` | Phở | 30.000 (chốt) | +25 | — | +2 | quầy quán |
| `ca_phe_coc` | Cà phê cóc | 15.000 (chốt) | — | +20, hiệu ứng `cafein` | — | góc cà phê |
| `nuoc_tang_luc` | Nước tăng lực | 15.000 (chốt) | — | +20, hiệu ứng `cafein` | −2 | máy bán nước KTX |
| `tra_sua` | Trà sữa | 25.000 (chốt) | +5 | — | +10 | góc cà phê |
| `mi_goi` | Mì gói | 8.000 [ĐX] | +12 | — | — | máy bán nước KTX |
| `giao_trinh_<môn>` | Giáo trình (bản photo) | 80.000 [QĐ-4.5] | — | — | — | quầy photo thư viện |

Đồ ăn/uống `consume_on_buy = true` (ăn ngay, không tốn khung giờ). Giáo trình vào `Inventory`.
**Mục tiêu cân bằng** (kiểm bằng mô phỏng 3.14): một ngày điển hình (1–2 buổi học, 2 ca làm) cần ăn khoảng **70.000 đ** để giữ Đói ≥ 40 — khớp giả định "ăn 70k/ngày" của BALANCE.md. Với Đói tụt 8/khung (`time_decay.tres`) + 5/ca làm → ~42/ngày → 2 suất cơm (50) + 1 cà phê ≈ 75.000 đ. Nếu phải chỉnh `time_decay.tres` thì ghi lý do vào BALANCE.md.

**`StatusEffectData`** → `data/effects/cafein.tres` (QĐ-4.3 = A): `id`, `display_name` "Cafein", `duration_slots` 2, `on_end_stamina` −10. Uống thêm khi đang có → đặt lại thời gian, không cộng dồn phần trừ.

**`SubjectData`** → `data/subjects/<id>.tres` [ĐX — tham khảo môn HK1 năm nhất ngành kỹ thuật]:

| id | Tên | Tín chỉ | Buổi/tuần |
|---|---|---|---|
| `giai_tich_1` | Giải tích 1 | 4 | 2 |
| `vat_ly_1` | Vật lý 1 | 4 | 2 |
| `hoa_dai_cuong` | Hóa đại cương | 3 | 1 |
| `nhap_mon_ky_thuat` | Nhập môn kỹ thuật (đồ án nhập môn) | 3 | 1 |

**`ShopData`** → `data/shops/<id>.tres`: `id`, `display_name`, `item_ids`, `open_slots`. Cửa hàng: `quay_quan`, `goc_ca_phe`, `may_ban_nuoc` (mở cả 4 khung), `quay_photo` (giờ thư viện).

### 3.2 Autoload `StudentLife` + móc vòng đời

- `Game` (sửa tối thiểu file bước 1): thêm `signal new_game_started`, phát trong `new_game()` sau `_bind_state()` và **trước** `state_replaced`.
- `scripts/autoload/student_life.gd` (không `class_name`), đăng ký **sau `DialogueSystem`**. Logic tính toán nằm ở các class thuần trong `scripts/life/` (test được không cần autoload); autoload chỉ nối signal + gọi chúng.
  ```
  signal day_summary_ready(summary: Dictionary)
  signal action_performed(action_id: String, result: Dictionary)
  signal sleep_started(from_slot: int)
  func get_available_actions(place_id: String) -> Array[Dictionary]   # {action, enabled, reason, preview}
  func perform_action(action_id: String, params: Dictionary = {}) -> Dictionary
  func buy_item(shop_id: String, item_id: String) -> Dictionary        # {ok, reason}
  func pay_tuition() -> Dictionary
  func add_sleep_interrupter(handler: Callable) -> void                # API cho bước 6 (G4): handler(context) -> bool
  func complete_sleep(recovery_multiplier: float = 1.0) -> void
  ```
- Trạng thái mới gom vào **một** class `LifeState` (`scripts/core/life_state.gd`, `to_dict/from_dict`) giữ trong `GameState.life`; `GameState.to_dict()` thêm khóa `"life"`; save cũ thiếu → `LifeState` mới. Không tăng `SAVE_VERSION`. Gồm: `schedule_seed`, `schedule` (mảng {weekday, slot, subject}), `academics` (môn → {attended, absent, study}), `inventory` (item → số lượng), `status_effects` (mảng {id, slots_left}), `shifts_today`, `ledger_today` (mảng {kind: "income"/"expense", label, amount}), `day_start_stats`, `last_processed_day`, `last_slot_key`.
- **Trình tự xử lý** (ghi vào ARCHITECTURE.md):
  - `new_game_started` → sinh TKB (seed ngẫu nhiên, lưu lại), chụp `day_start_stats`, xử lý phí định kỳ ngày 1.
  - `time_changed(day, slot)` → nếu là khung kế tiếp đúng thứ tự của `last_slot_key` thì xử lý "khung vừa hết": điểm danh vắng, giảm thời gian hiệu ứng, hậu quả đói. Nếu là bước nhảy (debug `set_time`, tải game) → **chỉ đồng bộ lại, không xử lý** (không đánh vắng hàng loạt).
  - `new_day(day)` → lập tổng kết ngày cũ → phát `day_summary_ready` → reset sổ ngày, `shifts_today` → thu phí định kỳ + kiểm hạn học phí cho ngày mới. Mọi việc này chạy **trước** khi `Game` tự lưu (vì `Game._on_new_day` phát `new_day` rồi mới lưu) → bản tự lưu đầu ngày đã sạch. Dùng `last_processed_day` để không xử lý 2 lần.
  - Ngất/hậu quả cần qua thêm khung giờ → `call_deferred`, không gọi `Game.advance_time()` lồng trong handler `time_changed`.

### 3.3 Tiền và sổ thu chi

- `scripts/life/economy.gd` (static): `earn(state, amount, label)`, `spend(state, amount, label) -> bool` (không đủ tiền → false, không trừ), `charge(state, amount, label)` (khoản bắt buộc như phí KTX: trừ dù âm tiền — A5 cho phép âm). Mọi thay đổi tiền ghi vào `ledger_today`.
- Lệnh hội thoại `~ money` (bước 3) chuyển sang đi qua `Economy` với nhãn trong ngoặc kép (âm = chi, dương = thu).

### 3.4 Hành động (C1, D1) + menu hành động

- `scripts/life/life_actions.gd`: `check(state, action, context) -> String` (lý do không làm được, rỗng = được), `preview(state, action) -> Dictionary`, `perform(state, action, rng) -> Dictionary`.
- Thứ tự khi làm: kiểm tra → áp delta chỉ số + lương (ghi sổ) → `shifts_today += 1` nếu là ca → `Game.advance_time()` × `slot_cost` (mỗi khung tự tụt chỉ số theo chế độ) → kiểm tra ngất.
- Lý do bị chặn (tiếng Việt, hiện trong menu): "Không có tiết lúc này", "Quán chỉ cần người buổi Sáng/Chiều", "Hôm nay bạn đã làm đủ 2 ca", "Thư viện đã đóng cửa", "Chưa xin được việc ở quán".
- Hiệu quả học: Đói < 20 → Trí tuệ và điểm học ×0,5 (làm tròn xuống, tối thiểu 1).
- `scenes/ui/action_menu.tscn` + `scripts/ui/action_menu.gd` (CanvasLayer 40, `InputLock`): tiêu đề nơi chốn; mỗi lựa chọn có **xem trước minh bạch**: "1 khung giờ · +120.000 đ · Thể lực −15 · Đói −5"; khóa thì mờ + lý do; nếu làm xong Thể lực ≤ 0 → dòng đỏ "Có thể ngất!".
- Gắn với Interactable theo anchor/id: `seat_player` → Vào học; `study_desk` → Tự học (chọn môn); `counter` → Phụ quán cơm + Mua (quầy quán); `coffee_bar` → Bưng cà phê + Mua (góc cà phê); `bed_player` → Nghỉ / Đi ngủ; `vending` (hành lang, thêm prop máy bán nước) → Mua; `photo_counter` → Mua giáo trình; `kiosk` (giảng đường) → Đóng học phí; `desk_player` → Xem thời khóa biểu & điểm.
- Làm xong hành động tốn giờ: fade ngắn ~0,3 giây + toast tóm tắt ("Phụ quán cơm: +120.000 đ").
- **Bỏ** nút tạm `%AdvanceButton` "Nghỉ (qua khung giờ)" trên HUD (thay bằng "Nghỉ ngơi" ở giường; DebugMenu vẫn có "Qua khung giờ"). HUD thêm 2 dòng nhỏ: "Tiết tiếp: Vật lý 1 — Chiều" và "Học phí: còn 9 ngày" (ẩn khi đã đóng).

### 3.5 Hậu quả chỉ số (hoàn thiện A1, A2, A3) [ĐX]

| Tình trạng | Hậu quả |
|---|---|
| Đói < 20 ("Đói lả") | học ×0,5; Thể lực −3 thêm mỗi khung giờ; ngủ chỉ hồi một nửa Thể lực |
| Đói = 0 | Thể lực −6 thêm mỗi khung giờ |
| Thể lực = 0 | **Ngất**: mất thêm 1 khung giờ, tỉnh ở `ktx_room/bed`, Thể lực = 30, Sanity −5, dòng narrator + toast. Không ngất 2 lần trong cùng khung |
| Sanity = 0 | theo QĐ-4.4 (khuyến nghị: màn "Bạn cần nghỉ ngơi", tua tới sáng ngày kế tiếp nữa, Sanity = 30, Thể lực = 60) |

Mọi hậu quả phải **báo trước được**: thanh chỉ số đổi màu (đã có ở HUD bước 1) + toast lần đầu chạm ngưỡng ("Bạn đói lả — học kém hẳn đi").

### 3.6 Thời khóa biểu ngẫu nhiên (B2)

- `scripts/life/schedule_generator.gd` (static): `generate(seed: int, subjects: Array[SubjectData]) -> Array[Dictionary]`. Ràng buộc: Thứ Hai–Thứ Sáu, chỉ Sáng/Chiều; mỗi môn ≤ 1 buổi/ngày; mỗi ngày ≤ 2 buổi; 2 buổi cùng môn cách nhau ≥ 1 ngày; mỗi tuần có ≥ 2 nửa ngày trống trong Thứ Hai–Thứ Sáu. Cùng seed → cùng kết quả. TKB lặp lại mỗi tuần; trước `classes_start_day` không có tiết.
- Lưu cả mảng TKB vào save (đổi thuật toán sau này không làm đổi ván cũ).
- `scenes/ui/schedule_panel.tscn`: lưới 5 ngày × 2 buổi + cột Thứ Bảy/Chủ Nhật trống; đánh dấu hôm nay, tiết đã học (✓), đã vắng (✗); mở từ `desk_player` (bước 5 chuyển vào điện thoại).

### 3.7 Điểm danh và điểm từng môn (C2, C3)

- `scripts/life/academic_record.gd` (logic thuần):
  - Hết một khung có tiết mà không "Vào học" → `absent += 1`, toast "Bạn đã vắng tiết Giải tích 1 — điểm chuyên cần bị trừ".
  - Vào học: `attended += 1`, `study += 2`. Tự học: `study += 3` (có giáo trình môn đó: +5, QĐ-4.5).
  - **Điểm quá trình (thang 10)** [ĐX] = 3 × tỉ lệ chuyên cần + 7 × mức nắm bài, với tỉ lệ chuyên cần = attended / (attended + absent) (chưa có buổi nào → 1), mức nắm bài = min(1, study / (3 × số buổi đã diễn ra)); làm tròn 0,1. Ví dụ: đi học đủ, không tự học → 3 + 7 × (2/3) = 7,7.
  - **Quy đổi thang 4**: 8,5–10 → 4,0 (A); 8,0–8,4 → 3,5 (B+); 7,0–7,9 → 3,0 (B); 6,5–6,9 → 2,5 (C+); 5,5–6,4 → 2,0 (C); 5,0–5,4 → 1,5 (D+); 4,0–4,9 → 1,0 (D); < 4,0 → 0 (F). Đây là thang phổ biến của đào tạo tín chỉ ở Việt Nam; trường trong game hư cấu nên dùng thang này [CẦN KIỂM TRA nếu muốn khớp quy chế một trường cụ thể].
  - **GPA tạm tính** = Σ(điểm thang 4 × tín chỉ) / Σ tín chỉ của các môn đã có ít nhất 1 buổi.
- `scenes/ui/grade_panel.tscn`: bảng môn — tín chỉ, có mặt/vắng, điểm 10, điểm 4, GPA tạm tính (ghi rõ "tạm tính, chưa có thi"). Mở từ `desk_player` cùng TKB.

### 3.8 Cửa hàng + món ăn (D6, D7) + mô hình túi đồ

- `scripts/core/inventory.gd` (`Inventory`: `add(id, n)`, `remove(id, n) -> bool`, `count(id)`, `to_dict/from_dict`) — dữ liệu nằm trong `LifeState.inventory`. Giao diện túi đồ là việc của bước 5.
- `scenes/ui/shop_panel.tscn`: danh sách món (icon, tên, giá, hiệu ứng "Đói +25"), nút "Mua"; không đủ tiền → mờ + "Thiếu 5.000 đ"; mua → `Economy.spend` → áp hiệu ứng ngay (đồ ăn/uống) hoặc vào túi (giáo trình) → toast.
- Hiệu ứng `cafein`: lúc hết → toast "Hết cafein — bạn thấy uể oải" + Thể lực −10.

### 3.9 Học phí HK1 (B3)

- `scripts/life/tuition.gd` (logic thuần, test được): `amount_due(state, config)`, `can_pay(state, config) -> String`, `pay(state, config) -> bool`, `process_day_start(state, config, day) -> Array[String]` (trả thông báo cần hiện).
- Luật (đã chốt trong FEATURES/BALANCE, chi tiết số [ĐX] ở 3.1):
  - Hạn chính: hết ngày 14 → kiểm tra **đầu ngày 15**.
  - Đóng đủ → `da_dong_hoc_phi = 1`, sổ "Học phí HK1 −16.000.000 đ", toast.
  - Đầu ngày 15 chưa đóng → `hoc_phi_tre_han = 1`, phạt 500.000 theo QĐ-4.2, Sanity −10, toast "Đã quá hạn học phí. Bạn được gia hạn tới hết Chủ Nhật tuần 4, kèm phạt 500.000 đ".
  - Đầu ngày 29 vẫn chưa đóng → MVP **chỉ cảnh báo** (`hoc_phi_qua_han = 1`); bản đầy đủ sẽ là Bad Ending "nghỉ học" (C1). Trong MVP thực tế ngày 28 là ngày cuối (bước 7), màn "Còn tiếp…" sẽ nhắc nếu chưa đóng.
  - Nhắc hạn: toast đầu các ngày trong `tuition_reminder_days` ("Còn 7 ngày tới hạn học phí — cần 16.000.000 đ, bạn đang có 12.340.000 đ").
- Chỉ đóng **một lần đủ** (không đóng từng phần). Nơi đóng: máy `kiosk` ở giảng đường (bảng xác nhận: số phải đóng, số dư, số dư sau khi đóng); bước 5 thêm nút trong ví điện thoại gọi cùng hàm.
- Thiết kế dữ liệu để sau thêm HK2 (B13) chỉ bằng `.tres` (ví dụ mảng kỳ học phí), chưa làm HK2.
- Thêm cờ vào `data/story_flags.tres`: `hoc_phi_tre_han`, `hoc_phi_qua_han`, `lam_them_quan`.

### 3.10 Phí định kỳ (B4)

- `scripts/life/recurring_charges.gd`: danh sách khoản {id, label, amount, period_days, first_day, condition}; `process_day(state, day)` thu các khoản đến hạn qua `Economy.charge`. Bước 4 có khoản `ktx` ("Tiền KTX tháng", 300.000, chu kỳ 28 ngày, từ ngày 1). Hàm `register(entry)` để bước 5 thêm quỹ phòng (D4).
- Ngày 1 thu ngay khi bắt đầu ván. (Bước 7 có thể dời khoản ngày 1 tới lúc chọn KTX ở F3 — để sẵn tùy chọn `defer_first_charge_until_flag` trong mục `ktx`.)
- Bị âm tiền vì phí → toast "Bạn đang thiếu tiền KTX — số dư âm".

### 3.11 Tổng kết cuối ngày (B10)

- Hiện mỗi khi sang ngày mới (ngủ hoặc thức qua Đêm), trước khi chơi tiếp buổi Sáng: `scenes/ui/day_summary.tscn` (CanvasLayer 42 — dưới PauseMenu 50 để Esc vẫn mở được menu tạm dừng; `InputLock`, nút "Tiếp tục").
- Nội dung: "Tổng kết Ngày 3 — Thứ Tư"; **Thu** (từng dòng + tổng); **Chi** (từng dòng + tổng); **Số dư**; **Chỉ số**: Thể lực 80 → 65 (−15)… cho 4 chỉ số (màu xanh/đỏ); **Học tập**: tiết đã học / đã vắng; **Sắp tới**: hạn học phí còn N ngày, phí KTX kỳ tới, tiết ngày mai.
- Dữ liệu tổng kết là `Dictionary` do logic thuần lập (`DaySummaryBuilder.build(...)`) → test được.

### 3.12 Lệnh hội thoại mới + demo

- Đăng ký qua `DialogueSystem.register_command()`: `~ action <action_id>` (làm hành động từ hội thoại), `~ give <item_id> [số]`, `~ take <item_id> [số]`, `~ pay_tuition`, `~ pass_slots <n>`. Điều kiện mới: `item.<id>` (số lượng), `class_now` (1 nếu đang có tiết), `shifts_today`. Cập nhật danh sách lệnh trong `tools/check_project.py` và ARCHITECTURE.md.
- `content/dialogue/demo_buoc4.dlg`: chủ quán nhận bạn làm thêm (`~ set lam_them_quan 1`), có lựa chọn hỏi giờ làm/lương (nói đúng: phụ quán Sáng/Chiều 120.000/ca; bưng cà phê buổi Tối 100.000/ca + tip). Đánh dấu DEMO, bước 7 thay.

### 3.13 DebugMenu

Thêm: tóm tắt TKB hôm nay, `shifts_today`, tình trạng học phí, hiệu ứng đang có; nút "Đóng học phí (debug)", "Tới ngày 14 — Tối", "Mở khóa việc làm thêm", "Hiện tổng kết ngày (thử)".

### 3.14 Mô phỏng dòng tiền + cập nhật BALANCE.md

- `tools/sim_cashflow.py` (Python thuần, chạy trong môi trường AI): đọc số từ `data/*.tres` (regex `khóa = giá trị`), mô phỏng 14 ngày cho **3 chế độ** với chiến lược "chăm chỉ": đi học đủ tiết, làm tối đa ca được phép trong khung trống, ăn rẻ nhất mà giữ Đói ≥ 40, ngủ lúc Đêm; chạy 2 biến thể **có/không góp quỹ phòng**; chạy 20 seed TKB. In bảng: tiền cuối ngày 14, thiếu/dư so với học phí, số ca đã làm, Thể lực thấp nhất, số lần ngất.
- Ghi kết quả vào `BALANCE.md`, mục mới "Kiểm tra dòng tiền 14 ngày — tính lại ở bước 4 (có TKB)" (giữ bảng cũ). Đây là việc của ghi chú "[CẦN KIỂM TRA ở bước 4]" trong BALANCE.md.
- **Ý đồ thiết kế phải giữ** (từ BALANCE.md): Dễ → kịp hạn thoải mái; Khó → hụt nhẹ, kịp nếu ăn tiết kiệm/thêm ca cuối tuần; Cực khó → gần như chắc phải gia hạn, áp lực dồn vào tuần 3. Nếu mô phỏng lệch ý đồ → **đề xuất** chỉnh núm nào (không tự đổi giá đã chốt), hỏi người dùng.

### 3.15 Lưu/tải

Mọi trạng thái mới đi qua `LifeState` (3.2). Test: save cũ (bước 1–3) tải được; mọi trường mới round-trip qua JSON (ép `int()` vì JSON trả float).

---

## 4. Test bắt buộc

| File | Kiểm tra |
|---|---|
| `test_schedule_generator.gd` | cùng seed → cùng TKB; khác seed → khác (thử nhiều seed); đủ số buổi mỗi môn; mọi ràng buộc 3.6; không tiết trước `classes_start_day` |
| `test_academic_record.gd` | vào học/tự học/vắng cộng đúng; công thức điểm 10 (ví dụ 7,7 ở 3.7); bảng quy đổi thang 4 ở các mốc biên (8,5 / 8,4 / 5,5 / 3,9); GPA có trọng số tín chỉ; môn chưa có buổi không tính |
| `test_life_actions.gd` | chặn đúng lý do (sai khung, không có tiết, đủ 2 ca, chưa xin việc, thư viện đóng); lương × hệ số chế độ, tip trong 0–30.000 (rng seed cố định), làm tròn 1.000; tốn đúng số khung giờ; đói lả → học ×0,5 |
| `test_status_effects.gd` | cafein +20 ngay, −10 sau đúng 2 khung; uống lại thì đặt lại thời gian |
| `test_faint_and_hunger.gd` | Thể lực về 0 → ngất (mất thêm 1 khung, Thể lực 30, Sanity −5); Đói < 20 / = 0 trừ thêm đúng; Sanity 0 theo QĐ-4.4 |
| `test_shop.gd` | không đủ tiền → không mua, không trừ; món ăn áp hiệu ứng ngay; giáo trình vào túi; sổ thu chi có dòng |
| `test_tuition.gd` | hạn ngày 14 (đầu ngày 15 mới xử lý); đóng trước hạn; trễ → cờ + phạt theo QĐ-4.2 + Sanity −10; đóng trong gia hạn đúng số tiền; đầu ngày 29 → chỉ cảnh báo; nhắc đúng các ngày; không xử lý 2 lần cùng ngày |
| `test_recurring_charges.gd` | KTX thu ngày 1, 29; cho phép âm; khoản có điều kiện chỉ thu khi điều kiện đúng (chuẩn bị cho quỹ phòng) |
| `test_day_summary.gd` | thu/chi/số dư/chênh lệch chỉ số đúng; tiết đã học/vắng; mục "Sắp tới" |
| `test_slot_processing.gd` | đi tuần tự từng khung → vắng tiết được ghi; nhảy ngày bằng `set_time` → **không** ghi vắng hàng loạt |
| `test_life_state_save.gd` | `LifeState` round-trip JSON; save thiếu `"life"` → mặc định; số trong mảng TKB vẫn là int sau khi tải |
| `test_cashflow_sim.gd` | mô phỏng như 3.14 bằng logic thật (seed cố định): Dễ đủ tiền đóng trước hạn; Cực khó không đủ; Khó in chênh lệch (không assert cứng) |

Chạy thêm `python3 tools/check_project.py` và `python3 tools/sim_cashflow.py`; dán bảng kết quả mô phỏng vào báo cáo.

---

## 5. Checklist cho người dùng khi mở Godot

1. Chơi mới (Khó) → ngày 1: tổng kết ngày đầu tiên chưa hiện; F1 thấy tiền đã trừ 300.000 tiền KTX. HUD có "Tiết tiếp: …" và "Học phí: còn 13 ngày". Nút "Nghỉ (qua khung giờ)" trên HUD đã biến mất.
2. Ở phòng KTX, tương tác Bàn học → thời khóa biểu (2–3 môn/ngày, Thứ Bảy/Chủ Nhật trống) và bảng điểm tạm tính.
3. Ngày 2, đến giảng đường đúng tiết → "Vào học": màn mờ nhanh, khung giờ tăng, Trí tuệ +2, toast. Vào lúc không có tiết → lựa chọn mờ "Không có tiết lúc này".
4. Bỏ một tiết (làm việc khác qua khung đó) → toast "Bạn đã vắng tiết …"; bảng điểm hiện ✗ và điểm chuyên cần giảm.
5. Đến quán khi chưa xin việc → "Chưa xin được việc ở quán". Nói chuyện chủ quán (demo) → được nhận. Phụ quán cơm buổi Sáng → +120.000 đ (Cực khó: 108.000 đ). Bưng cà phê buổi Tối → 100.000–130.000 đ. Ca thứ 3 trong ngày → "Hôm nay bạn đã làm đủ 2 ca".
6. Quầy quán mua Cơm tấm → −30.000 đ, Đói +25. Góc cà phê mua Cà phê cóc → Thể lực +20; 2 khung sau toast "Hết cafein" và Thể lực −10. Thiếu tiền → nút mờ "Thiếu … đ".
7. Thư viện: mua giáo trình ở quầy photo (−80.000 đ), Tự học môn đó → điểm học tăng nhiều hơn môn không có giáo trình.
8. Về giường "Đi ngủ" lúc Đêm → màn tổng kết ngày: thu, chi, số dư, chỉ số trước/sau, tiết đã học/vắng, hạn sắp tới → "Tiếp tục" → buổi Sáng, có toast "Đã tự lưu".
9. F1 hạ Thể lực về 5 rồi làm một ca → ngất: tỉnh ở giường, Thể lực 30, mất 1 khung giờ.
10. F1 "Tới ngày 14 — Tối", không đóng học phí, đi ngủ → sáng ngày 15: toast quá hạn + gia hạn + phạt; số phải đóng thành 16.500.000 đ (theo QĐ-4.2); Sanity −10. Máy đóng học phí ở giảng đường hiện đúng số tiền.
11. F1 cho đủ tiền → đóng học phí → cờ `da_dong_hoc_phi = 1`, HUD ẩn dòng học phí.
12. Lưu, thoát, tải lại → TKB, điểm danh, túi đồ, số ca hôm nay, hiệu ứng cafein còn nguyên.
13. Chạy test: `godot --headless --path . -s res://tests/run_tests.gd` → tất cả PASS.
14. Đọc mục mới trong `BALANCE.md` (dòng tiền tính lại) và trả lời AI nếu muốn chỉnh số.

---

## 6. Cách làm việc

- Trả lời tiếng Việt. Trước khi code: xác nhận QĐ-4.1 → QĐ-4.7; liệt kê kế hoạch + danh sách file; **CHỜ NGƯỜI DÙNG DUYỆT**. Đổi trạng thái bước 4 trong `docs/TASKS.md` thành "Đang code".
- Quy trình bắt buộc: **viết song song → rà chéo nhiều góc nhìn → kiểm chứng → sửa**.
  - Song song: (a) dữ liệu `.tres` + `sim_cashflow.py`; (b) logic thuần `scripts/life/` + test; (c) autoload `StudentLife` + nối signal; (d) giao diện (menu hành động, cửa hàng, TKB/điểm, tổng kết ngày, HUD).
  - Rà chéo: số liệu khớp BALANCE.md từng dòng (giá chốt không đổi); thứ tự signal (`new_day` → tổng kết → phí → **rồi** mới tự lưu); không xử lý trùng khi tải game/nhảy ngày; JSON float; minh bạch với người chơi (mọi hình phạt báo trước); tiếng Việt trong UI; không tràn chữ ở 1280×720.
  - Kiểm chứng: `gdparse`/`gdlint`, `check_project.py`, `sim_cashflow.py` (dán bảng), tự tính tay 1 ngày mẫu (số dư + chỉ số) và so với kết quả `DaySummaryBuilder` mong đợi trong test.
- Không cài gói lớn, không xóa file khi chưa hỏi. Sửa file bước 1–3 ở mức tối thiểu, liệt kê trong báo cáo.
- Cập nhật `docs/ARCHITECTURE.md`: mục "Bước 4 — Đời sinh viên" (autoload + thứ tự, `LifeState` + khóa save, trình tự xử lý ngày/khung, API cho bước 5–6, lệnh hội thoại mới, dữ liệu `.tres`).
- Báo cáo: file tạo/sửa; mã đã xong; bảng mô phỏng dòng tiền; cách kiểm tra. Thêm ✅ vào `FEATURES.md` cho C1, C2, C3, D1, D6, D7, B2, B3, B4, B10. Xong → `docs/TASKS.md` đổi thành "Xong".
