# BƯỚC 5 — NPC & SỰ KIỆN

> Prompt cho AI code. Trạng thái hàng đợi: `docs/TASKS.md`.

Dự án: "Tôi Là Sinh Viên Bách Khoa" — Godot 4.4+, GDScript kiểu tĩnh, PC trước. Thế giới hư cấu, tông bí ẩn nhẹ — KHÔNG kinh dị. Project: `/home/user/BachKhoaRPG`.

---

## [CẦN QUYẾT ĐỊNH] — người dùng chốt trước khi AI code bắt đầu

Nếu chưa có câu trả lời: dùng **khuyến nghị**, ghi rõ trong báo cáo.

| Mã | Câu hỏi | Phương án | Khuyến nghị |
|---|---|---|---|
| QĐ-5.1 | Mức dính líu với K. (A8) có hiện cho người chơi thấy không? | **A.** Ẩn con số; chỉ gợi bằng lời (K. thân mật dần, tin nhắn của K. dày lên, dòng mô tả trong danh bạ "K. rất tin tưởng bạn"). **B.** Hiện thanh 0–100 trong điện thoại. **C.** Chỉ hiện trong menu debug. | **A** (giữ bí ẩn; màn "Còn tiếp…" ở bước 7 mới nói rõ) |
| QĐ-5.2 | D4 "quỹ chung — các thành viên góp tiền" nhưng STORY chỉ có Minh là bạn cùng phòng | **A.** Thêm 2 bạn cùng phòng "nền" có tên, mỗi người 1–2 câu thoại, cũng góp quỹ. **B.** Phòng chỉ có bạn và Minh. | **A** (phòng 4 người như bản đồ bước 2; quỹ có ý nghĩa hơn cho H5 ở C1) |
| QĐ-5.3 | Gọi điện về quê: E7 (gọi tự do) là C1, nhưng STORY tuần 1 có cuộc gọi và A3 ghi "hồi Sanity khi gọi về nhà" | **A.** MVP chỉ có cuộc gọi theo kịch bản (sự kiện), nút "Gọi" chỉ sáng khi có cuộc gọi kịch bản. **B.** Làm luôn gọi tự do: 1 lần/ngày, tốn 1 khung Tối, Sanity +8. | **A** (E7 đầy đủ để C1) |

---

## Ràng buộc môi trường của AI code

- Project ở `/home/user/BachKhoaRPG`. **Không có Godot binary** → không chạy được game/test. Chỉ có **gdtoolkit** (`gdparse`, `gdlint`).
- Mạng chặn github.com, godotengine.org, fonts.google.com → không tải addon/asset. pypi/npm được; Pillow có sẵn. Sprite biến thể của Minh, khung điện thoại, icon ứng dụng là placeholder vẽ bằng `tools/gen_art.py` theo `docs/ART_STYLE.md`.
- `.tscn`/`.tres` viết tay theo mẫu ARCHITECTURE.md. Test theo bộ chạy test tự viết, người dùng chạy trên máy.
- Kiểm chứng trong môi trường AI: `gdparse`/`gdlint`, `python3 tools/check_project.py` (mở rộng cho metadata sự kiện, NPC, nhiệm vụ — mục 3.11), `python3 tools/sim_cashflow.py` (thêm việc tờ rơi + quỹ phòng).

## Đọc trước

1. `docs/ARCHITECTURE.md` (bước 1–4). Tên thực tế khác "API dự kiến" bên dưới → theo ARCHITECTURE.md, ghi chú chỗ lệch.
2. `STORY_MVP.md` (NPC, cờ, diễn biến tuần), `FEATURES.md` (E2, E3, E6, D3, D4, A8, H2, I1, I2), `BALANCE.md` (tờ rơi 350.000/ca + A8 +10; quỹ phòng 200.000/tháng).
3. Ghi chú nghiên cứu (chỉ lấy ý hợp tông, không kinh dị): `/home/user/research_notes/Tư liệu cốt truyện Chapter 1/da_cap_lua_dao_sinh_vien.md` (mục 1 và 4: chiêu tuyển mộ, dấu hiệu nhận biết — để viết tờ rơi và lời K.), `truyen_thuyet_di_tuong.md` (mục Câu hỏi 1 phần Inferences về "người đứng quay mặt vào tường đọc công thức"; mục Câu hỏi 4 về cách thể hiện kiệt sức không kỳ thị).

---

## 1. Mục tiêu

Thế giới có người sống: NPC xuất hiện theo lịch khung giờ (E2), Minh đổi dáng vẻ theo cốt truyện (E3), sự kiện tự kích theo ngày/khu vực/tương tác (nền cho bước 7), đi chơi với bạn (E6), việc phát tờ rơi cho K. (D3) cùng Mức dính líu (A8), quỹ phòng (D4), sổ nhiệm vụ (H2), túi đồ (I1) và điện thoại (I2: tin nhắn, ví, thời khóa biểu, nhiệm vụ, danh bạ, chỗ cho radar).

Mã tính năng: **E2, E3, E6, D3, D4, A8, H2, I1, I2**.

### KHÔNG làm ở bước này
- Radar hoạt động thật, âm báo, dị tượng, sự kiện đêm, cầu thang vô tận (bước 6). Điện thoại chỉ có **màn hình chờ** của ứng dụng Radar.
- Nội dung cốt truyện thật tuần 1–4, tutorial, chọn KTX (bước 7). Chỉ viết **demo** để thử từng cơ chế.
- Minh mất tích (H5), hộp đêm (D3 phần C1), hội thảo của K. (H3), cảnh báo Minh sớm ảnh hưởng kết quả (E5), gọi điện tự do (E7, trừ khi QĐ-5.3 = B), Uy tín (A7).

---

## 2. Phụ thuộc

Cần **Bước 1–4 xong**.

| Nguồn | API dùng |
|---|---|
| Bước 1 | `Game` (`state`, `time_changed`, `new_day`, `state_replaced`), `GameState` (`stats`, `clock`, `flags`), `FlagStore.flag_changed`, `PlayerStats` (quan hệ A6), `Toast`, `SaveCodec` |
| Bước 2 (API dự kiến) | `AreaManager` (`area_changed`, `get_current_area()`), `GameArea.get_anchor()`, `Npc`, `Interactable` (`interacted`, `dialogue_node`), `CharacterSprite.build_frames()`, `SlotVisibility`, `InputLock`, `MapData`/anchor |
| Bước 3 (API dự kiến) | `DialogueSystem` (`start`, `is_active`, `register_command`, `dialogue_finished`, `dialogue_event`); node `.meta` (Dictionary khóa → mảng chuỗi) từ `@trigger/@when/@priority/@once`; `DialogueCondition.evaluate()`; `CharacterData`; `StoryFlagRegistry` |
| Bước 4 (API dự kiến) | `StudentLife` (`perform_action`, `buy_item`, `pay_tuition`, `add_sleep_interrupter`, `day_summary_ready`), `LifeState` (`inventory`, `ledger_today`, `schedule`), `Economy` (`earn/spend/charge`), `RecurringCharges.register()`, `ActionData` (`requires`, `counts_as_shift`), `Inventory`, `AcademicRecord`, schedule/grade panel, `EconomyConfig` (`room_fund_fee`, `month_length_days`) |

**Thứ tự lớp giao diện (CanvasLayer)** — ghi vào ARCHITECTURE.md, giữ cho mọi bước sau: InteractionPrompt 5 · Hud 10 · DialogueBox 30 · ActionMenu/Shop/TKB 40 · DaySummary 42 · TravelMenu 45 · **Phone 48** · PauseMenu 50 · Toast 90 · SceneLoader 100 · DebugMenu 120. Mở hội thoại từ điện thoại/menu thì **đóng điện thoại/menu trước**.

---

## 3. Yêu cầu cụ thể

### 3.1 Trạng thái cốt truyện trong save

- `scripts/core/story_state.gd` — `class_name StoryState` (`to_dict/from_dict`), giữ trong `GameState.story`, khóa save `"story"`; save cũ thiếu → mới. Gồm: `events_fired` (event id → ngày kích gần nhất), `quests` (id → {state, step, started_day}), `messages` (mảng {id, sender, text, day, slot, read}), `known_npcs` (danh sách id đã gặp). Không tăng `SAVE_VERSION`.

### 3.2 NPC theo lịch khung giờ (E2)

- `scripts/data/npc_data.gd` (`NpcData`: `id`, `character_id` (CharacterData), `display_name`, `sprite_sheet`, `state_sprites: Dictionary` (giá trị cờ trạng thái → Texture2D), `state_flag: String`, `default_dialogue: String`, `schedule: Array[NpcScheduleEntry]`) + `scripts/data/npc_schedule_entry.gd` (`day_from`, `day_to` (0 = không giới hạn), `weekdays: Array[int]` (rỗng = mọi ngày), `slots: Array[int]`, `area_id`, `anchor_id`, `condition: String`, `behavior: String` = `"stand"` / `"face_wall"` / `"sit"`). File `data/npcs/<id>.tres`.
- `scripts/world/npc_schedule.gd` (static, thuần): `resolve(npc: NpcData, day, slot, state) -> Dictionary` (`{}` nếu NPC không xuất hiện; **mục đầu tiên khớp thắng**). Có biến điều kiện đặc biệt `class_now` (bước 4) để đặt NPC vào lớp đúng tiết.
- `scripts/world/npc_director.gd` (con của World): khi `area_changed`, `time_changed`, `flag_changed` → tính lại, sinh/xóa NPC ở anchor tương ứng của khu hiện tại. NPC tĩnh đặt cứng ở bước 2 chuyển sang dùng lịch (bỏ khỏi `MapData`, giữ anchor).
- Lịch **[ĐX]** (bước 7 có thể chỉnh), thêm anchor còn thiếu vào map:

  | NPC | Lịch |
  |---|---|
  | Minh | Thứ 2–6 lúc có tiết: giảng đường `seat_minh`; Tối: phòng `minh_desk`; Đêm: phòng `minh_bed`; cuối tuần Sáng/Chiều: phòng |
  | Chủ quán | Sáng/Chiều/Tối: quán `counter`; Đêm: vắng (quán đóng) |
  | Anh K. | từ ngày 9: giảng đường `k_spot` Chiều Thứ 3, Thứ 5; thư viện `k_library` Tối Thứ 6; từ ngày 15: sảnh giảng đường `flyer_spot` Sáng/Chiều Thứ 2–6 |
  | Tiền bối năm n | thư viện `senior_spot` Tối Thứ 2–6 |
  | Nữ thủ khoa | giảng đường `seat_front` lúc có tiết; thư viện Chiều Thứ 7 |
  | Giảng viên | giảng đường `podium` lúc có tiết |
  | 2 bạn cùng phòng (QĐ-5.2 = A) | phòng KTX Tối/Đêm; gợi ý tên "Tuấn" (miền Tây) và "Khoa" (Tây Nguyên) — đổi được |
- NPC trong lịch được thêm vào `known_npcs` lần đầu nói chuyện.

### 3.3 Minh đổi trạng thái (E3)

- Cờ `minh_trang_thai` (0/không có → 1). `NpcData.state_flag = "minh_trang_thai"`:
  - **1** — bình thường: `chr_minh`.
  - **2** — thâm quầng: `chr_minh_tired` (thêm vào `gen_art.py`: quầng mắt tối, dáng hơi cúi), tốc độ hoạt ảnh 0,7×.
  - **3** — úp mặt vào tường: lịch Tối/Đêm đổi sang hành lang anchor `minh_wall`, `behavior = "face_wall"` (đứng sát tường, quay lưng ra), có **bong bóng lẩm bẩm** nhỏ đổi câu mỗi vài giây — trộn công thức đại cương với khẩu hiệu đa cấp, kỳ lạ nhưng **không đáng sợ**, ví dụ: "…đạo hàm của thành công theo thời gian…", "…tích phân từ không tới triệu phú…", "…đầu tư vào chính mình, đầu tư vào chính mình…". Bong bóng là dữ liệu trong `NpcData` (mảng câu), không viết cứng.
  - Chừa giá trị **4** (mất tích — H5, C1): NPC không xuất hiện.
- Cách thể hiện: Minh là **nạn nhân**, không nguy hiểm, không dùng làm jumpscare; không gắn nhãn bệnh tâm thần ("điên", "loạn trí"…). Hồi phục được bằng việc đời thường (ngủ, ăn, có bạn) — nội dung ở bước 7.

### 3.4 Bộ điều phối sự kiện (storylet) — nền cho bước 6–7

- Sự kiện = **node hội thoại có metadata** (định dạng `.dlg` bước 3):
  ```
  == t2_to_roi_bang_tin
  @trigger day_start
  @when day == 8
  @once
  @priority 10
  narrator: Bảng thông báo hành lang có tờ rơi mới, màu vàng chóe.
  ~ set thay_to_roi 1
  ```
- Trigger hỗ trợ:

  | `@trigger` | Khi nào |
  |---|---|
  | `day_start` | đầu ngày, **sau khi** người chơi đóng màn tổng kết ngày |
  | `slot_start` | đầu mỗi khung giờ (sau xử lý của bước 4) |
  | `enter_area <area_id>` | sau khi chuyển khu xong (fade xong) |
  | `interact <id>` | khi tương tác Interactable/NPC có id đó — **chỉ sự kiện ưu tiên cao nhất chạy**, thay cho `default_dialogue` |
  | `sleep` | khi đi ngủ (đăng ký qua `StudentLife.add_sleep_interrupter`) — bước 6 dùng cho G4 |
  | `phone_call <contact_id>` | khi bấm "Gọi" trong điện thoại (QĐ-5.3) |
- `@when <điều kiện>` (cú pháp bước 3, nhiều dòng `@when` = nối `and`), `@priority <số>` (mặc định 0, lớn chạy trước), `@once` (chạy một lần cả ván), `@daily` (tối đa 1 lần/ngày).
- `scripts/story/event_selector.gd` (static, thuần): `select(candidates, trigger, arg, state, story) -> Array[String]` — lọc theo trigger + điều kiện + once/daily, sắp theo priority (bằng nhau → thứ tự file/dòng).
- `scripts/autoload/event_director.gd` (autoload `EventDirector`, sau `StudentLife`): lập chỉ mục mọi node có `@trigger` lúc nạp nội dung; với `day_start`/`slot_start`/`enter_area` → chạy **lần lượt tất cả** sự kiện khớp (hàng đợi, đợi hội thoại trước xong và `InputLock` không còn khóa nào ngoài của chính nó); với `interact` → chỉ cái đầu tiên. Ghi `events_fired`.
- Lỗi metadata (trigger lạ, `@when` sai cú pháp, area/npc id không tồn tại) → lỗi nội dung (test + `check_project.py` bắt).

### 3.5 Việc phát tờ rơi cho K. (D3) + Mức dính líu (A8)

- Cờ mới trong `data/story_flags.tres`: `nhan_viec_to_roi` (0 = chưa mời/từ chối, 1 = đang làm, 2 = đã nghỉ), `dinh_lieu_k` (0–100, A8), `thay_to_roi`, `gap_k`.
- `data/actions/phat_to_roi.tres`: "Phát tờ rơi cho K.", nơi `flyer_spot` (sảnh giảng đường), Sáng/Chiều/Tối, 1 khung, `counts_as_shift = true` (tính vào giới hạn 2 ca/ngày), `requires = "flag.nhan_viec_to_roi == 1 and week >= 3"`, lương **350.000/ca × hệ số chế độ** (BALANCE, chốt), Thể lực −10 [ĐX], **`dinh_lieu_k` +10/ca** (BALANCE, chốt). Không trừ Sanity (BALANCE không ghi) — áy náy thể hiện bằng lời thoại.
- `scripts/story/story_vars.gd` (static): `add_k_involvement(state, n)` kẹp 0–100; `k_involvement_band(value) -> String` ("thấp" < 30, "vừa" 30–59, "cao" ≥ 60 [ĐX], C1 dùng cho Bad Ending "con rối").
- Nhận việc (qua hội thoại, nội dung thật ở bước 7): `~ set nhan_viec_to_roi 1`, `~ k_involve 5` (nhận việc của K. cũng tăng A8 theo FEATURES — +5 [ĐX]), `~ give xap_to_roi`. Nghỉ việc: `~ set nhan_viec_to_roi 2`, `~ take xap_to_roi`.
- `data/items/xap_to_roi.tres` (vật phẩm cốt truyện, `category = "story"`): nội dung tờ rơi CLB "Tương Lai Vàng" viết **trong thế giới game**, lồng các dấu hiệu cảnh báo có thật (việc nhẹ lương cao, "khởi nghiệp không cần vốn", "chỉ cần đóng phí thành viên", "rủ càng đông thu nhập càng khủng", phỏng vấn ở quán cà phê) — không chế giễu người bị lôi kéo, không dùng tên tổ chức/người thật.
- Hiển thị A8 theo QĐ-5.1.

### 3.6 Quỹ phòng (D4)

- Khi `da_gop_quy` chuyển 0 → 1 (lắng nghe `flag_changed`, hoặc lệnh `~ join_room_fund`): thu ngay 200.000 ("Góp quỹ phòng tháng này") qua `Economy`, rồi `RecurringCharges.register({id: "quy_phong", amount: room_fund_fee, period_days: 28, first_day: <hôm nay + 28>, condition: "flag.da_gop_quy == 1"})`.
- Cờ `quy_phong` = số dư quỹ (VND): + phần của bạn, + phần của Minh và 2 bạn cùng phòng nền (mỗi người 200.000 khi bạn tham gia và mỗi kỳ; nếu QĐ-5.2 = B thì chỉ bạn + Minh) — để C1 làm "Minh mất tích cùng quỹ chung" (H5). Ví điện thoại hiện "Quỹ phòng: 800.000 đ" (4 người × 200.000).
- Từ chối góp: được hỏi lại về sau (nội dung bước 7); không phạt cơ học, chỉ đổi lời thoại/quan hệ.
- **Không trừ tiền hai lần**: từ bước này, nội dung chỉ đặt cờ `da_gop_quy` (hoặc gọi `~ join_room_fund`), **không** kèm `~ money -200000`. Sửa đoạn demo góp quỹ của bước 3 cho đúng. Cơ chế phải idempotent (đặt cờ lại khi đã là 1 không thu thêm).

### 3.7 Đi chơi với bạn (E6)

- `data/actions/di_choi.tres` [ĐX]: "Đi ăn vặt", 1 khung **Tối**, 50.000 đ (chi qua `Economy`, không đủ tiền thì không đi được), Sanity +15, Quan hệ với người đi cùng +5, tối đa 1 lần/ngày (mỗi NPC). Gọi từ hội thoại: `~ action di_choi minh` (tham số = NPC đi cùng).
- Có màn chuyển cảnh ngắn: fade + 2–3 dòng narrator ngẫu nhiên từ danh sách trong dữ liệu (quán lẩu, bánh tráng nướng, trà sữa ven đường…).

### 3.8 Sổ nhiệm vụ (H2)

- `scripts/data/quest_data.gd` (`QuestData`: `id`, `title`, `description`, `start_condition` (tự bắt đầu khi đúng; rỗng = chỉ bắt đầu bằng lệnh), `steps: Array[QuestStep]` (`text`, `done_condition`), `deadline_day` (0 = không), `optional: bool`) → `data/quests/<id>.tres`.
- `scripts/story/quest_log.gd` (thuần): `start`, `evaluate(state, story)` (tự đánh dấu bước xong theo điều kiện), `complete`, `fail`, `active() -> Array`, `days_left(quest, day)`. Đánh giá lại khi `flag_changed`, `time_changed`, `new_day`.
- Lệnh: `~ quest start <id>`, `~ quest done <id>`, `~ quest fail <id>`. Toast "Nhiệm vụ mới: …" / "Hoàn thành: …".
- Nhiệm vụ MVP (định nghĩa dữ liệu; bước 7 nối nội dung): `q_hoc_phi` (Đóng học phí HK1 — hạn ngày 14, gia hạn ngày 28; xong khi `flag.da_dong_hoc_phi == 1`), `q_viec_lam` (Tìm việc làm thêm — xong khi `flag.lam_them_quan == 1`), `q_quy_phong` (Góp quỹ phòng — tùy chọn), `q_minh` (Chuyện của Minh — các bước: để ý quầng thâm; thấy Minh ra ngoài lúc đêm; nói chuyện với Minh), `q_truyen_thuyet` (Truyền thuyết cầu thang — xong khi `flag.nghe_truyen_thuyet == 1`).

### 3.9 Túi đồ (I1)

- Giao diện cho `Inventory` (bước 4): danh sách icon + tên + số lượng + mô tả; nút "Dùng" cho đồ dùng được; đồ cốt truyện chỉ "Xem" (ví dụ đọc nội dung tờ rơi).
- `ItemData` thêm `can_carry: bool`: cửa hàng có thêm nút **"Mua mang về"** cho món mang được (bánh mì, mì gói, nước tăng lực) → vào túi, dùng lúc nào cũng được (không tốn khung giờ).
- Mở từ điện thoại (ứng dụng "Túi đồ") hoặc phím `inventory` (I).

### 3.10 Điện thoại (I2)

- `scenes/ui/phone.tscn` + `scripts/ui/phone.gd` (CanvasLayer **48**). Action `phone` = **Tab** (thêm vào `project.godot` + `_ensure_input_actions`); Tab/Esc đóng. Mở thì `InputLock.lock(&"phone")`, thời gian **không trôi**. Không mở được khi đang hội thoại/menu/chuyển khu.
- Khung `art/ui/ui_phone_frame.png` (vẽ bằng `gen_art.py`, hiển thị ×3, cao ≤ 600 px). Màn hình chính: lưới icon ứng dụng + thanh trạng thái (giờ theo khung: "Sáng", pin, sóng — **ô sóng để bước 6 làm nhiễu**).
- Ứng dụng:

  | Ứng dụng | Nội dung |
  |---|---|
  | **Tin nhắn** | hộp thư theo người gửi (Mẹ, Minh, K., "Nhóm lớp", "Ban quản lý KTX"); lệnh `~ message <sender_id> "<chữ>"` thêm tin; tin mới → toast "[Tin nhắn] Mẹ: …" + chấm đỏ trên icon điện thoại ở HUD; đánh dấu đã đọc |
  | **Ví** | số dư, thu/chi hôm nay (`ledger_today`), khoản định kỳ sắp tới, tình trạng học phí + nút **"Đóng học phí"** (`StudentLife.pay_tuition()`), số dư quỹ phòng |
  | **Lịch học** | TKB + bảng điểm tạm tính (dùng lại panel bước 4) |
  | **Nhiệm vụ** | nhiệm vụ đang làm (bước đang ở, "còn N ngày"), đã xong |
  | **Danh bạ** | NPC đã gặp + mức quan hệ A6 theo 5 bậc: 0–19 Người lạ · 20–39 Quen · 40–59 Bạn · 60–79 Thân · 80–100 Rất thân (kèm số hoặc tim); dòng mô tả A8 dưới K. theo QĐ-5.1; nút **"Gọi"** theo QĐ-5.3. **Cuộc gọi đến**: lệnh `~ ring <contact_id>` làm điện thoại đổ chuông (toast "[Cuộc gọi] Mẹ đang gọi…", icon HUD rung, Danh bạ hiện "Nghe"); bấm Nghe (hoặc Gọi lại sau) → chạy sự kiện `@trigger phone_call <contact_id>` khớp |
  | **Túi đồ** | I1 |
  | **Radar** | màn chờ "Không phát hiện tín hiệu lạ." (bước 6 thay) |
- HUD: icon điện thoại nhỏ góc dưới phải (bấm chuột mở được), có chấm tin nhắn mới.

### 3.11 Lệnh hội thoại mới + kiểm chứng

- Đăng ký: `~ message`, `~ ring <contact_id>`, `~ quest start|done|fail`, `~ k_involve <±n>`, `~ join_room_fund`, `~ npc_state <npc_id> <giá trị>` (đặt cờ trạng thái NPC), `~ meet <npc_id>` (thêm vào danh bạ). Điều kiện mới: `quest.<id>` (0 chưa nhận, 1 đang làm, 2 xong, 3 thất bại), `npc_here.<id>` (1 nếu NPC đang ở khu hiện tại).
- `tools/check_project.py`: kiểm tra `@trigger` hợp lệ + id area/npc/contact tồn tại; `@when` hợp lệ; `data/npcs/*.tres` có anchor tồn tại trong map của khu tương ứng; `data/quests/*.tres` điều kiện hợp lệ; lệnh mới có trong danh sách.

### 3.12 Nội dung demo

`content/dialogue/demo_buoc5.dlg` (đánh dấu DEMO): mỗi trigger 1 sự kiện mẫu; K. mời phát tờ rơi (nhận/từ chối); Minh rủ góp quỹ + rủ đi ăn vặt; một nhiệm vụ bắt đầu và hoàn thành; 2 tin nhắn (Mẹ, Nhóm lớp); Minh ở trạng thái 3 có câu thoại riêng. Bước 7 thay toàn bộ.

---

## 4. Test bắt buộc

| File | Kiểm tra |
|---|---|
| `test_npc_schedule.gd` | mục đầu tiên khớp thắng; lọc ngày/thứ/khung; `day_from/day_to`; điều kiện cờ; `class_now`; không khớp → `{}` |
| `test_minh_state.gd` | cờ thiếu → trạng thái 1; 2 → sprite mệt; 3 → lịch Tối/Đêm ra `minh_wall` + `face_wall`; 4 → không xuất hiện |
| `test_event_selector.gd` | lọc trigger + đối số; nhiều `@when`; priority + thứ tự ổn định; `@once` không chạy lại (kể cả sau lưu/tải `StoryState` qua JSON); `@daily`; `interact` chỉ trả 1 |
| `test_flyer_job.gd` | chặn trước tuần 3 hoặc khi chưa nhận việc; 350.000 × hệ số; `dinh_lieu_k` +10/ca và kẹp ≤ 100; tính vào giới hạn 2 ca/ngày; nhận việc +5 |
| `test_room_fund.gd` | bật `da_gop_quy` → trừ 200.000 ngay + đăng ký khoản 28 ngày; `quy_phong` tăng đúng; tắt cờ → không thu nữa |
| `test_outing.gd` | `di_choi`: chỉ Tối, đủ tiền, 1 lần/ngày/NPC, Sanity +15, quan hệ +5 |
| `test_quest_log.gd` | tự bắt đầu theo điều kiện; bước tự xong theo cờ; `days_left`; lệnh done/fail; round-trip save |
| `test_messages.gd` | thêm tin, đếm chưa đọc, đánh dấu đã đọc, round-trip save |
| `test_inventory_ui_model.gd` | mua mang về → vào túi; dùng → áp hiệu ứng + trừ số lượng; đồ cốt truyện không "Dùng" được |
| `test_relationship_bands.gd` | 5 bậc ở các mốc 19/20/39/40/59/60/79/80 |
| `test_story_state_save.gd` | save thiếu `"story"` → mặc định; mọi số sau JSON là int |
| `test_event_content.gd` | mọi node có `@trigger` trong `content/dialogue/` hợp lệ; id NPC/area tồn tại; mọi `data/quests`, `data/npcs` hợp lệ |

Chạy thêm `python3 tools/check_project.py` và `python3 tools/sim_cashflow.py` (thêm kịch bản: nhận việc K. từ tuần 3, có/không góp quỹ) — dán kết quả vào báo cáo.

---

## 5. Checklist cho người dùng khi mở Godot

1. Ngày 1: phòng KTX Sáng không có Minh nếu Minh đang có tiết (xem TKB), Tối thì Minh ngồi ở bàn. Đi giảng đường đúng tiết → thấy Minh, giảng viên, nữ thủ khoa trong lớp.
2. Quán buổi Đêm: không có chủ quán, bảng hiệu "Đã đóng cửa".
3. Ngày 9 Chiều (F1 nhảy ngày) ở giảng đường → K. xuất hiện; nói chuyện được (demo). Trước ngày 9 không thấy K.
4. Nhấn Tab → điện thoại: thanh trạng thái, các ứng dụng. Thời gian không trôi khi mở. Tab/Esc đóng.
5. Tin nhắn demo: toast "[Tin nhắn] Mẹ: …", chấm đỏ trên icon điện thoại; mở đọc → chấm mất.
6. Ví: số dư, thu/chi hôm nay; nút "Đóng học phí" hoạt động như máy ở giảng đường.
7. Nhiệm vụ: thấy "Đóng học phí HK1 — còn N ngày"; đóng xong → toast "Hoàn thành".
8. Demo Minh rủ góp quỹ → đồng ý: −200.000 đ, Ví hiện "Quỹ phòng: 800.000 đ" (4 người; nếu QĐ-5.2 = B thì 400.000 đ). Rủ đi ăn vặt buổi Tối → fade, −50.000 đ, Sanity +15; lần 2 cùng ngày bị chặn.
9. F1 đặt `minh_trang_thai = 2` → Minh có quầng thâm; `= 3` → buổi Tối Minh đứng quay mặt vào tường ở hành lang, bong bóng lẩm bẩm đổi câu; cảm giác lạ nhưng không đáng sợ.
10. Demo K. mời phát tờ rơi (ngày ≥ 15) → nhận → túi đồ có "Xấp tờ rơi", đọc được nội dung. Làm 1 ca ở sảnh giảng đường → +350.000 đ (Cực khó 315.000 đ); ca thứ 3 trong ngày bị chặn. F1 thấy `dinh_lieu_k` tăng 10/ca; trong game không thấy con số (nếu QĐ-5.1 = A), danh bạ có dòng mô tả.
11. Mua mang về Mì gói → túi đồ → "Dùng" lúc đang ở phòng → Đói tăng.
12. Lưu/tải giữa chừng → tin nhắn, nhiệm vụ, sự kiện đã chạy, danh bạ còn nguyên; sự kiện `@once` không chạy lại.
13. Chạy test: `godot --headless --path . -s res://tests/run_tests.gd` → tất cả PASS.

---

## 6. Cách làm việc

- Trả lời tiếng Việt. Trước khi code: xác nhận QĐ-5.1 → QĐ-5.3; liệt kê kế hoạch + danh sách file; **CHỜ NGƯỜI DÙNG DUYỆT**. Đổi trạng thái bước 5 trong `docs/TASKS.md` thành "Đang code".
- Quy trình bắt buộc: **viết song song → rà chéo nhiều góc nhìn → kiểm chứng → sửa**.
  - Song song: (a) NPC + lịch + Minh; (b) EventDirector + metadata + test; (c) kinh tế phụ: tờ rơi, A8, quỹ, đi chơi; (d) điện thoại + túi đồ + nhiệm vụ + tin nhắn.
  - Rà chéo: hợp đồng ARCHITECTURE.md + thứ tự autoload + lớp giao diện; sự kiện không chạy trùng/không kẹt hàng đợi khi lưu/tải hoặc khi có màn tổng kết ngày; khóa điều khiển luôn được mở lại; số liệu BALANCE (350.000, +10, 200.000) đúng từng chữ số; tông truyện (đa cấp không chế giễu nạn nhân, Minh không đáng sợ, không nhãn bệnh tâm thần); UI 1280×720 không tràn chữ.
  - Kiểm chứng: `gdparse`/`gdlint`, `check_project.py`, `sim_cashflow.py`; "chạy khô" EventSelector bằng tay cho ngày 8, 9, 15 với nội dung demo và ghi kết quả mong đợi vào báo cáo.
- Không cài gói lớn, không xóa file khi chưa hỏi. Sửa file bước 1–4 ở mức tối thiểu, liệt kê trong báo cáo.
- Cập nhật `docs/ARCHITECTURE.md`: mục "Bước 5 — NPC & sự kiện" (StoryState + khóa save, NpcData/lịch, metadata sự kiện + trigger, EventDirector + thứ tự autoload, lệnh/điều kiện mới, bảng lớp CanvasLayer, điện thoại + action `phone`/`inventory`).
- Báo cáo: file tạo/sửa; mã đã xong; kết quả kiểm chứng; cách kiểm tra. Thêm ✅ vào `FEATURES.md` cho E2, E3, E6, D3 (ghi chú: phần hộp đêm là C1), D4, A8, H2, I1, I2. Xong → `docs/TASKS.md` đổi thành "Xong".
