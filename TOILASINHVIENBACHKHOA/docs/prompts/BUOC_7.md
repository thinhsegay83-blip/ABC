# BƯỚC 7 — GHÉP NỘI DUNG TUẦN 1–4 (MVP CHAPTER 1)

> Prompt cho AI code. Trạng thái hàng đợi: `docs/TASKS.md`.

Dự án: "Tôi Là Sinh Viên Bách Khoa" — Godot 4.4+, GDScript kiểu tĩnh, PC trước. Thế giới hư cấu, **tông bí ẩn / kỳ ảo đô thị nhẹ nhàng — KHÔNG kinh dị**. Project: `/home/user/BachKhoaRPG`.

---

## [CẦN QUYẾT ĐỊNH] — người dùng chốt trước khi AI code bắt đầu

Nếu chưa có câu trả lời: dùng **khuyến nghị**, ghi rõ trong báo cáo.

| Mã | Câu hỏi | Phương án | Khuyến nghị |
|---|---|---|---|
| QĐ-7.1 | Chọn KTX Khu A hay Khu B (F3) khác nhau thế nào? | **A.** Chỉ khác trang trí (màu tường, biển tên) + 1–2 câu thoại. **B.** Khác nhỏ một thông số: Khu A gần giảng đường (như hiện tại); Khu B rẻ hơn (250.000/tháng thay vì 300.000) nhưng mỗi chuyến đi học/làm tốn thêm 3 Thể lực ("đi bộ xa"). **C.** Khác cả NPC/sự kiện (để C1). | **B** (lựa chọn có ý nghĩa mà rẻ; thêm số vào BALANCE.md dạng [ĐX]) |
| QĐ-7.2 | Dòng "Mọi nhân vật, tổ chức, sự kiện đều là hư cấu" (đã chốt trong FEATURES) — J15 lại để ưu tiên C1 | **A.** Làm luôn trong MVP (1 màn chữ trước cảnh mở đầu). **B.** Để C1. | **A** (rẻ, nên có ngay từ bản chơi thử vì game nhắc tên trường kiểu "Bách Khoa") |
| QĐ-7.3 | Cao trào cầu thang vô tận xảy ra lúc nào? | **A.** Cố định: Đêm Chủ Nhật tuần 4 (ngày 28), tự kích dù người chơi đang ở đâu. **B.** Người chơi tự kích khi đi cầu thang lúc Đêm trong tuần 4; hạn chót vẫn là Đêm ngày 28. | **A** (không ai bị lỡ; dùng trọn 4 tuần) |
| QĐ-7.4 | Sau màn "Còn tiếp…" | **A.** Về menu chính; giữ một bản lưu kết thúc (cờ `mvp_hoan_thanh`) để sau nhập sang bản đầy đủ. **B.** Cho chơi tự do tiếp sau tuần 4 (không có nội dung mới). | **A** |

---

## Ràng buộc môi trường của AI code

- Project ở `/home/user/BachKhoaRPG`. **Không có Godot binary** → không chạy được game/test. Chỉ có **gdtoolkit** (`gdparse`, `gdlint`).
- Mạng chặn github.com, godotengine.org, fonts.google.com → không tải addon/asset. pypi/npm được; Pillow có sẵn. Hình mới (thẻ chọn KTX, màn "Còn tiếp…") vẽ bằng `tools/gen_art.py` theo `docs/ART_STYLE.md`.
- Nội dung viết bằng định dạng `.dlg` (bước 3) + metadata sự kiện (bước 5). Vì AI không chơi thử được, "chơi thử" ở bước này = **bot chơi tự động ở tầng logic** (test headless, người dùng chạy) + mô phỏng Python chạy được ngay trong môi trường AI + phiếu chơi thử cho người dùng.
- Kiểm chứng trong môi trường AI: `gdparse`/`gdlint`, `python3 tools/check_project.py` (thêm kiểm tra lịch beat — mục 3.9), `python3 tools/sim_cashflow.py` (28 ngày).

## Đọc trước

1. `docs/ARCHITECTURE.md` (bước 1–6) — đặc biệt định dạng `.dlg`, trigger sự kiện, lệnh hội thoại, API vòng lặp cầu thang.
2. **`STORY_MVP.md`** (diễn biến tuần 1–4, NPC, cờ — nguồn chính), `FEATURES.md` (J11, F3, J15, dòng Tông truyện), `BALANCE.md`.
3. Nội dung lõi đã có từ bước 6: `content/dialogue/truyen_thuyet.dlg` (`tien_boi_truyen_thuyet`), `cau_thang.dlg`, `g4_dem_tuan3.dlg` — **không đổi luật giải đố**, chỉ gắn lịch.
4. Ghi chú nghiên cứu (chỉ lấy ý hợp tông, viết lại bằng lời của mình, không chép):
   - `/home/user/research_notes/Tư liệu cốt truyện Chapter 1/doi_song_tan_sinh_vien.md` — chi tiết đời sống: thùng xốp đồ quê gửi lên, mì gói 7–8 nghìn, tiết học sớm, chờ xe buýt, bạn cùng phòng khác tỉnh ăn chung, câu đùa "sinh viên Bách Khoa biết mọi thứ, trừ ngày ra trường", chữ "quái vật" (người qua môn ngay lần đầu).
   - `da_cap_lua_dao_sinh_vien.md` — mục 1 (kịch bản tuyển mộ) và mục 4 (dấu hiệu nhận biết) để viết lời K. và các "cờ đỏ" người chơi có thể nhận ra.
   - `thiet_ke_tu_su.md` — 60–70% đời thường; tuần 1–2 hoàn toàn bình thường; hứa ít trả đúng; thất bại mềm; chương 1 khép một vòng nhỏ, mở vòng lớn.
   - `truyen_thuyet_di_tuong.md` — Câu hỏi 4 (không người thật, không cái chết thật, Minh là nạn nhân, không nhãn bệnh tâm thần).

---

## 1. Mục tiêu

Bản chơi thử MVP hoàn chỉnh từ "Chơi mới" tới màn "Còn tiếp…": màn mở đầu + chọn KTX (F3), hướng dẫn chơi lồng vào sự kiện (J11), toàn bộ nội dung sự kiện/hội thoại tuần 1–4 theo `STORY_MVP.md`, cao trào cầu thang vô tận, màn "Còn tiếp…" có tổng kết, rồi chơi thử tự động + cân bằng.

Mã tính năng: **J11, F3** (+ J15 nếu QĐ-7.2 = A) + nội dung tuần 1–4 (dùng E1–E6, D1–D4, A8, B3, G1–G4, H1, H2 đã có).

### KHÔNG làm ở bước này
- Tính năng mới ngoài danh sách trên (mọi mã C1/PH/SAU). Nếu nội dung cần cơ chế chưa có → ghi vào báo cáo, **không tự thêm hệ thống lớn**.
- Bad Ending thật (H11), Minh mất tích (H5), hội thảo của K. (H3), hộp đêm, tuần 5–6.
- Đổi luật câu đố cầu thang hay số Vật lý của bước 6.
- Đổi giá đã chốt trong BALANCE.md (chỉ được **đề xuất**).

---

## 2. Phụ thuộc

Cần **Bước 1–6 xong**. Dùng (tên theo ARCHITECTURE.md; dưới đây là API dự kiến):

| Nguồn | API dùng |
|---|---|
| Bước 1 | `Game` (`new_game_started`, `state_replaced`), `SaveSystem`, `SceneLoader.change_scene`, `MAIN_MENU_SCENE`, `Toast`, `Settings` |
| Bước 2 | `GameArea.variant` ("A"/"B"), `AreaManager.change_area`, anchor các khu |
| Bước 3 | `.dlg` (lời thoại, lựa chọn `[if]`/`[need]`, lệnh `set/add/stat/money/rel/goto/end/toast/emit`), `DialogueSystem.dialogue_event`, `PlayerName`, `StoryFlagRegistry`, `CharacterData` |
| Bước 4 | `StudentLife` (hành động, `pay_tuition`, `day_summary_ready`), `RecurringCharges` (tùy chọn `defer_first_charge_until_flag`), `TuitionService` (cờ `da_dong_hoc_phi`, `hoc_phi_tre_han`), `AcademicRecord` (GPA tạm tính), lệnh `action/give/take/pass_slots` |
| Bước 5 | `EventDirector` (trigger `day_start`, `slot_start`, `enter_area`, `interact`, `sleep`, `phone_call`; `@when/@priority/@once/@daily`), `NpcData` + lịch, `minh_trang_thai`, lệnh `message/quest/k_involve/join_room_fund/npc_state/meet`, nhiệm vụ `q_hoc_phi`, `q_viec_lam`, `q_quy_phong`, `q_minh`, `q_truyen_thuyet`, điện thoại (Tin nhắn, Gọi), `StoryVars.k_involvement_band` |
| Bước 6 | trigger `flag_set`, cờ `radar_lan_dau`, `thay_minh_ra_ngoai`, `nghe_truyen_thuyet`, `hieu_vong_lap`, `thoat_cau_thang`; lệnh `stair_loop start`, `night_wake`, `change_area`, `npc_move`, `npc_hide`, `sleep_resume`; signal `stair_loop_escaped`; node `tien_boi_truyen_thuyet` |

---

## 3. Yêu cầu cụ thể

### 3.1 Màn mở đầu + chọn KTX (F3, J15)

- Luồng: menu chính → chọn chế độ → đặt tên (bước 3) → `game.tscn` → sự kiện `intro_mo_dau` (`@trigger day_start`, `@when day == 1`, `@once`, priority cao nhất):
  1. (QĐ-7.2 = A) màn chữ trên nền đen, 3 giây hoặc bấm để qua: **"Mọi nhân vật, tổ chức, sự kiện trong trò chơi đều là hư cấu."**
  2. Vài dòng narrator: tân sinh viên từ quê lên, xách vali và thùng xốp đồ mẹ gói.
  3. `~ emit choose_ktx` → **thẻ chọn KTX** (`scenes/ui/ktx_choice.tscn`): 2 thẻ "KTX Khu A" / "KTX Khu B" với mô tả theo QĐ-7.1 (giá/tháng, ưu/nhược). Chọn → `ktx_khu = 1/2`.
- `AreaManager`/`GameArea`: khu `ktx_*` đọc cờ `ktx_khu` để đặt `variant` ("B" khi = 2) — màu tường, biển tên.
- Tiền KTX tháng đầu: bật `defer_first_charge_until_flag = "ktx_khu"` của khoản `ktx` (bước 4) → thu đúng lúc chọn KTX, đúng giá theo khu (QĐ-7.1 = B: thêm khoản `ktx_b` 250.000 với điều kiện `flag.ktx_khu == 2`; Khu A giữ 300.000). Nếu QĐ-7.1 = B: hành động đi học/làm ở khu ngoài KTX tốn thêm 3 Thể lực khi `flag.ktx_khu == 2` (thêm vào `ActionData` hoặc `TravelRules`, ghi vào BALANCE.md [ĐX]).
- Cờ `minh_trang_thai = 1` đặt ở đây.

### 3.2 Hướng dẫn chơi (J11)

- `scripts/data/tutorial_hint.gd` + `data/tutorial_hints.tres`: mỗi gợi ý có `id`, `text` (có tên phím), `trigger` (sự kiện game: lần đầu vào khu, lần đầu có tiết, lần đầu đói < 40, lần đầu sang ngày, lần đầu radar…). Hiện **một lần** (cờ `tut_<id>`), bảng nhỏ góc dưới phải, tự ẩn sau ~6 giây hoặc khi người chơi làm đúng việc. Cài đặt mới "Hiện hướng dẫn" (mặc định bật; tắt thì không hiện, cờ vẫn ghi).
- Danh sách tối thiểu: `di_chuyen` (WASD/mũi tên), `tuong_tac` (E), `hoi_thoai` (Space/Ctrl/T/L), `dien_thoai` (Tab), `tkb` (xem thời khóa biểu ở điện thoại/bàn học), `di_hoc` (vào học đúng tiết, vắng bị trừ chuyên cần), `lam_them` (tối đa 2 ca/ngày), `an_uong` (Đói thấp học kém, Thể lực tụt), `ngu` (ngủ hồi Thể lực, Sanity), `tong_ket` (màn tổng kết ngày), `hoc_phi` (hạn cuối tuần 2, đóng ở máy giảng đường hoặc ví), `tui_do` (I), `radar` (điện thoại nhiễu = có gì đó lạ), `goi_y` (G — suy nghĩ khi bí).
- Lồng vào sự kiện tuần 1 theo `STORY_MVP.md` ("Tutorial lồng vào các sự kiện trên"): Minh chỉ chỗ, chủ quán giải thích ca làm, mẹ nhắc hạn học phí… Gợi ý bảng nhỏ chỉ bổ sung phím.

### 3.3 Lịch beat tuần 1–4 (nội dung chính)

Ngày 1 = Thứ Hai tuần 1 (đúng `GameClock`). Mỗi beat là một node sự kiện; **beat bắt buộc** có dự phòng để không ai bị lỡ. Thêm metadata **`@required <hạn_chót_ngày>`** vào `EventDirector`: quá hạn mà chưa chạy → chạy bù ở `day_start` kế tiếp (hoặc bằng node dự phòng ghi trong bảng). Mọi cơ chế tua giờ (ngất, Sanity 0, ngủ) **không được nhảy qua beat bắt buộc** — đặc biệt cao trào ngày 28.

| Ngày (thứ) | Khung / trigger | Beat (node) | Cờ / hiệu ứng | Bắt buộc? Dự phòng |
|---|---|---|---|---|
| 1 (T2) | `day_start` | `intro_mo_dau` → chọn KTX (3.1) | `ktx_khu`, thu KTX, `minh_trang_thai = 1` | Bắt buộc |
| 1 | `enter_area ktx_room` | `t1_gap_minh`: gặp Minh + 2 bạn cùng phòng; gợi ý di chuyển, tương tác | `~ meet minh`, quan hệ Minh +5 | Bắt buộc |
| 1 (Chiều) | `slot_start` | `t1_nhan_tkb`: tin nhắn "Nhóm lớp" gửi thời khóa biểu (B2) → gợi ý điện thoại | — | Bắt buộc |
| 1–3 (Tối) | `interact minh` | `t1_minh_gop_quy`: Minh rủ góp quỹ phòng (D4) | `da_gop_quy = 1` (−200.000) hoặc 0 | Không bắt buộc; Minh hỏi lại tới ngày 7 (`@daily`) |
| 2 (T3) | tiết đầu tiên | `t1_buoi_hoc_dau`: giảng viên (không tên), điểm danh, 1 câu "bất hủ" hư cấu | gợi ý đi học | Bắt buộc (nếu vắng → chạy ở tiết kế tiếp) |
| 2 | sau buổi học đầu | `t1_thu_khoa`: cảnh ngắn giới thiệu nữ thủ khoa (trả lời câu hỏi của thầy gọn gàng; 1 câu chào lạnh lùng với bạn) | `~ meet thu_khoa` | Bắt buộc |
| 2 (Tối) | `slot_start` chạy `~ ring me` → người chơi bấm "Nghe" → `@trigger phone_call me` | `t1_goi_ve_que`: mẹ gọi — đặt động lực (gia đình tần tảo), dặn hạn học phí **cuối tuần 2** (B3) | `~ quest start q_hoc_phi`, Sanity +5 | Bắt buộc; không nghe máy → ngày 3 mẹ nhắn tin cùng ý + vẫn gọi lại được |
| 3 (T4) | `interact notice_board` hoặc `enter_area food_shop` | `t1_xin_viec`: bảng thông báo "Quán Cô Ba cần người phụ"; chủ quán nhận việc, nói rõ giờ & lương (D1) | `~ quest start q_viec_lam`, `lam_them_quan = 1` | Bắt buộc; ngày 5 Minh nhắc chỗ quán |
| 4–7 | — | vòng lặp tự do; gợi ý ăn, ngủ, tổng kết ngày theo lần đầu xảy ra | — | — |
| 8 (T2) | `day_start` | `t2_to_roi_bang_tin`: tờ rơi CLB "Tương Lai Vàng" trên bảng thông báo | `thay_to_roi = 1` | Bắt buộc |
| 9 (T3, Chiều) | `interact k` (giảng đường) | `t2_gap_k`: K. xuất hiện lần đầu, nói chuyện làm giàu, mời ghé CLB. Lựa chọn: tò mò / lịch sự từ chối / hỏi thẳng "có phải đóng phí không?" (cờ đỏ) | `gap_k = 1`, `~ meet k`; "tò mò" → `k_involve 2` [ĐX] | Bắt buộc; dự phòng ngày 12 ở thư viện |
| 10–12 (Tối) | `interact tien_boi` (thư viện) | `tien_boi_truyen_thuyet` (bước 6) + màn giới thiệu "sinh viên năm n" | `nghe_truyen_thuyet = 1` | **Bắt buộc cho câu đố**; dự phòng ngày 21: tiền bối nhắn tin tóm đủ 3 ý của lời giải (`t3_truyen_thuyet_du_phong`) |
| 8, 12, 13, 14 | hệ thống bước 4 | nhắc hạn học phí | — | — |
| 14 (CN, Tối) | `slot_start`, `@when flag.da_dong_hoc_phi == 0` | `t2_me_hoi_hoc_phi`: mẹ nhắn hỏi đã đóng chưa | — | — |
| 15 (T2) | `day_start` | `t2_tre_han` (nếu `hoc_phi_tre_han == 1`: tin "Phòng Đào tạo" + mẹ động viên) hoặc `t2_da_dong` (mẹ mừng, Sanity +5) | — | — |
| 15 (Chiều) | `interact k` | `t3_k_moi_to_roi`: K. mời phát tờ rơi 350.000/ca (D3) — lồng 2–3 cờ đỏ (thu nhập từ "rủ thêm người", "đừng kể với gia đình vội") | nhận: `nhan_viec_to_roi = 1`, `k_involve 5`, `give xap_to_roi`; từ chối: K. "cửa luôn mở" | Bắt buộc (được mời); dự phòng ngày 17 |
| 16 (T3) | `day_start` | `t3_minh_tham_quang`: Minh có quầng thâm, nói "làm thêm buổi tối" | `minh_trang_thai = 2`, bước 1 của `q_minh` | Bắt buộc |
| ~17 | `flag_set radar_lan_dau` | `t3_radar_lan_dau`: "Điện thoại nhiễu sóng… chắc tại mạng KTX?" | — | Bắt buộc; dự phòng ngày 19: đứng gần Minh trong phòng lúc Tối thì radar tự kích |
| 18 (T5, Đêm) | `sleep` | G4 `t3_dem_minh_ra_ngoai` (bước 6) | `thay_minh_ra_ngoai` | Bắt buộc (bước 6 đã có dự phòng tới ngày 21) |
| 19 (T6) | `day_start` | Minh chối "đi vệ sinh" (bước 6) | — | — |
| 20–21 | `interact minh` / `message k` | nếu đang làm cho K.: K. khen, giao chỉ tiêu "dẫn thêm 2 bạn"; Minh lảng tránh khi hỏi về CLB | — | — |
| 23 (T3, Tối) | `enter_area ktx_hallway` hoặc `ktx_room` | `t4_minh_up_mat`: Minh đứng úp mặt vào tường, lẩm bẩm công thức trộn khẩu hiệu đa cấp | `minh_trang_thai = 3`, bước 2 của `q_minh` | Bắt buộc |
| 23–27 | `interact minh` (`@when flag.minh_trang_thai == 3 and flag.canh_bao_minh == 0`) | `t4_canh_bao_minh`: người chơi có thể cảnh báo Minh (chọn lời khuyên cụ thể: CLB thu tiền, đừng vay, nói với gia đình/phòng công tác sinh viên) | `canh_bao_minh = 1`, quan hệ Minh +5 | Không bắt buộc (là lựa chọn) |
| 24–27 | `interact k` / `message k` | nếu `nhan_viec_to_roi == 1`: K. ép "nâng cấp thành viên"; lựa chọn nghỉ việc | nghỉ: `nhan_viec_to_roi = 2` | — |
| 28 (CN, Đêm) | `slot_start` (`@when day == 28 and slot == DEM`), priority cao nhất — **và** bản `@trigger sleep` (`@when day == 28`) cho trường hợp đi ngủ từ Tối; hai bản dùng chung nội dung, `@once` chung một cờ | `t4_cao_trao_bat_dau`: ở phòng → tỉnh giấc thấy giường Minh trống, radar 4 vạch; ở nơi khác → "Bạn vừa về tới KTX thì…" → hành lang thấy Minh đi vào cầu thang → theo → `~ stair_loop start` | — | **Bắt buộc** (QĐ-7.3 = A) |
| 28 | `stair_loop_escaped` | `t4_thoat_cau_thang`: chiếu nghỉ thật, Minh ngồi ngủ gục tựa tường, tay cầm tờ rơi nhàu; khác nhau theo `canh_bao_minh` (1: Minh mơ màng "…ông nói đúng…"; 0: không tỉnh, bạn dìu về) và `hieu_vong_lap` (1 câu tự hào "giải bằng Vật lý") → về phòng → "Ngoài cửa sổ, trời bắt đầu sáng." | `~ emit to_be_continued` | Bắt buộc |

### 3.4 Nội dung hội thoại — quy tắc viết

- File: `content/dialogue/tuan1.dlg`, `tuan2.dlg`, `tuan3.dlg`, `tuan4.dlg`, `chung.dlg` (thoại mặc định của từng NPC theo trạng thái/tuần, `@trigger interact <npc>` + `@when`), `tin_nhan.dlg` (sự kiện chỉ gửi tin nhắn), `ket_thuc.dlg`. Nội dung lõi bước 6 giữ nguyên file.
- Nội dung demo của bước 3–5: đề xuất chuyển vào `content/dialogue/_demo/` và cho `DialogueLibrary` bỏ qua thư mục này — **hỏi người dùng trước khi di chuyển/xóa**.
- **Khối lượng** gợi ý: ~350–450 câu thoại tổng; tuần 1 ~100, tuần 2 ~80, tuần 3 ~80, tuần 4 ~80, kết ~40. Mỗi câu ≤ ~90 ký tự.
- **Giọng nhân vật** (gợi ý, giữ nhất quán):

  | Nhân vật | Giọng |
  |---|---|
  | Minh | quê nghèo, hiền, hay đùa tự giễu; xưng "tui", gọi "ông" |
  | 2 bạn cùng phòng | Tuấn (miền Tây, vui, hay khoe mắm nhà gửi); Khoa (Tây Nguyên, ít nói, pha cà phê nhà trồng) |
  | Anh K. | đàn anh chỉn chu, nói ngọt, hay chêm "mindset", "network"; xưng "anh – em"; không bao giờ nói thẳng "đa cấp" |
  | Cô Ba chủ quán | xởi lởi, thương sinh viên, gọi "con"; nói rõ lương, giờ |
  | Tiền bối năm n | hài, bí ẩn nhẹ, không ai biết học năm mấy; xưng "anh – em" |
  | Nữ thủ khoa | điềm tĩnh, thẳng, hơi cạnh tranh (tuyến phụ E10 để sau) |
  | Giảng viên | không tên, nghiêm mà tốt bụng |
  | Mẹ | lo lắng, giấu khó khăn trong nhà, "con – mẹ" |
- **Tông** (bắt buộc rà lại từng file):
  - Tuần 1–2 **hoàn toàn đời thường** (60–70% nội dung cả MVP là đời sinh viên); dị tượng chỉ bắt đầu từ tuần 3, tăng nhẹ ở tuần 4.
  - Không kinh dị: không jumpscare, máu, cái chết, ma quỷ đáng sợ. Bí ẩn = lệch nhỏ, câu hỏi chưa có lời đáp.
  - Đa cấp: không chế giễu người bị lôi kéo; Minh là nạn nhân; K. dùng chiêu thật (việc nhẹ lương cao, "đầu tư vào chính mình", phí thành viên, thu nhập từ rủ người, giấu gia đình) để người chơi **nhận ra được cờ đỏ** — lựa chọn tỉnh táo luôn có, không bắt buộc phải sa bẫy.
  - Kiệt sức/"lệch nhịp": không dùng nhãn bệnh tâm thần; hồi phục bằng việc đời thường.
  - Không tên người thật, mã tòa nhà thật, tên hệ thống thật của trường thật (dùng "Cổng sinh viên", "Giảng đường H1"…). "KTX Khu A/B" đã chốt trong FEATURES nên giữ.
  - Vật lý chỉ dùng phần đã kiểm tra ở bước 6; thêm nội dung Vật lý mới → **[CẦN KIỂM TRA]** + hỏi người dùng.
- Lựa chọn có hậu quả thì hậu quả phải **trả** (hứa ít, trả đúng): `da_gop_quy`, `nhan_viec_to_roi`, `canh_bao_minh`, `hieu_vong_lap` đều được nhắc lại ở cảnh kết hoặc màn "Còn tiếp…".

### 3.5 Màn "Còn tiếp…"

- `scenes/ui/to_be_continued.tscn` (bắt `to_be_continued`): fade đen → chữ "Còn tiếp…" → bảng tổng kết:
  - Đã sống 28 ngày; tiền hiện có; 4 chỉ số; GPA tạm tính (bước 4); quan hệ với Minh, K. (5 bậc).
  - Học phí: đã đóng đúng hạn / đã đóng trong gia hạn / **chưa đóng** — "Ở bản đầy đủ, quá hạn gia hạn (hết tuần 4) sẽ dẫn tới kết thúc 'Nghỉ học'." (BALANCE: MVP chỉ cảnh báo).
  - Các lựa chọn: góp quỹ phòng, nhận/nghỉ việc của K., cảnh báo Minh, giải vòng lặp bằng Vật lý.
  - Mức dính líu K.: hiện theo QĐ-5.1 (khuyến nghị: lời mô tả theo `k_involvement_band`).
  - "Cảm ơn bạn đã chơi thử!" + ghi công ngắn (font Be Vietnam Pro — SIL OFL 1.1; asset ngoài nếu có theo `CREDITS.md`).
- QĐ-7.4 = A: đặt cờ `mvp_hoan_thanh = 1`, ghi một bản lưu kết thúc (ô tự lưu hoặc ô riêng ghi rõ "Kết thúc MVP"); nút "Về menu chính". Tải bản lưu kết thúc → hiện lại màn tổng kết.

### 3.6 Danh mục cờ

Thêm vào `data/story_flags.tres` mọi cờ mới của bước này (mô tả + giá trị): `mvp_hoan_thanh`, `tut_*`, `thay_to_roi`, `gap_k`, cờ phụ cho dự phòng nếu cần. `check_project.py` phải bắt cờ chưa khai báo.

### 3.7 Chơi thử tự động (bot)

- `tests/test_playthrough_mvp.gd`: chạy **ở tầng logic** (GameState + các service thuần của bước 4–6 + `EventSelector` + `DialogueRunner` + `StairLoopState`), không cần scene. Bot có chiến lược:
  - **"Chăm học"**: đủ tiết, tự học, 1 ca/ngày, từ chối K., cảnh báo Minh.
  - **"Chăm làm"**: đủ tiết khi có thể, 2 ca/ngày, ăn tiết kiệm, từ chối K.
  - **"Theo K."**: nhận việc tờ rơi từ tuần 3, 2 ca/ngày (ưu tiên tờ rơi), không cảnh báo Minh.
  - Lựa chọn hội thoại: theo bảng ánh xạ node → chỉ số lựa chọn của từng chiến lược; node không có trong bảng → chọn lựa chọn hợp lệ đầu tiên. Câu đố cầu thang: bot đi theo luật đúng (khác → xuống, giống → lên).
- Chạy 3 chiến lược × 3 chế độ, seed cố định. Kiểm tra:
  - Không có lỗi runner/nội dung; mọi beat bắt buộc chạy trước hạn chót (bảng 3.3); kết thúc với `thoat_cau_thang = 1` và sự kiện `to_be_continued`.
  - "Chăm học" ở Dễ/Khó: Sanity không chạm 0, không ngất quá 2 lần.
  - Học phí khớp ý đồ BALANCE.md (ước tính trước khi trừ tiết học, chỉ để đối chiếu): **Dễ** "chăm làm" đóng kịp hạn chính; **Khó** "chăm làm" hụt nhẹ ở hạn chính nhưng đóng được trong gia hạn; **Cực khó** "chăm làm" không đóng nổi tới ngày 28 (chỉ cảnh báo), **Cực khó** "theo K." đóng được trong gia hạn — đúng ý "áp lực dồn vào tuần 3 khi K. mời phát tờ rơi". Lệch ý đồ → test in rõ số liệu; **không** tự chỉnh giá, báo người dùng.
- Mở rộng `tools/sim_cashflow.py` lên 28 ngày với 3 chiến lược trên, có tính TKB thật (seed) + Thể lực; ghi bảng kết quả vào `BALANCE.md` mục mới "Dòng tiền 28 ngày (MVP) — tính ở bước 7".

### 3.8 Cân bằng

- Liệt kê trong báo cáo các "núm" và chỗ đặt: lương (ActionData), giá (ItemData), tụt chỉ số (`time_decay.tres`), hồi khi ngủ, ngưỡng gợi ý (`puzzle_hints.tres`), trừ Sanity vùng tần số, phạt sai câu đố, A8 mỗi ca.
- Nếu bot/mô phỏng cho thấy lệch ý đồ: đề xuất tối đa 3 thay đổi cụ thể (núm nào, từ → thành, lý do), **chờ người dùng duyệt** rồi mới sửa `.tres` + ghi BALANCE.md.

### 3.9 Kiểm chứng nội dung — mở rộng `tools/check_project.py`

- Mọi node trong bảng 3.3 tồn tại; mọi beat bắt buộc có `@required` hoặc node dự phòng; điều kiện `@when` không mâu thuẫn hiển nhiên (ví dụ `day == 9` mà `week == 3`).
- Mọi cờ đọc ở `@when`/`[if]` đều có nơi đặt (`~ set`/hệ thống) — cảnh báo cờ "chỉ đọc mà không bao giờ được đặt".
- Không còn node demo được nạp (trừ khi người dùng muốn giữ).
- Quét cụm từ cấm (danh sách ở test bước 6) trên toàn bộ `content/dialogue/` — trong file dị tượng là **lỗi**, ở file khác là **cảnh báo** để người viết tự xem lại ngữ cảnh.
- Thống kê: số câu thoại mỗi file, câu dài > 90 ký tự.

---

## 4. Test bắt buộc

| File | Kiểm tra |
|---|---|
| `test_ktx_choice.gd` | chọn A/B → `ktx_khu` đúng; khoản KTX thu đúng giá theo khu, đúng lúc chọn (không thu 2 lần ngày 1); biến thể "B" khi `ktx_khu == 2` |
| `test_tutorial_hints.gd` | mỗi gợi ý hiện 1 lần; tắt cài đặt thì không hiện nhưng cờ vẫn ghi; lưu/tải giữ cờ |
| `test_required_beats.gd` | `@required`: quá hạn → chạy bù ở `day_start` kế; ngất/Sanity 0/ngủ không nhảy qua Đêm ngày 28 |
| `test_calendar_content.gd` | mọi beat bảng 3.3 có node; mỗi beat khớp đúng ngày/khung dự kiến khi giả lập trạng thái (dùng `EventSelector`); dự phòng kích khi beat chính bị lỡ |
| `test_ending_summary.gd` | màn tổng kết lấy đúng số liệu; 3 trạng thái học phí cho 3 câu chữ khác nhau; lựa chọn được nhắc lại đúng |
| `test_playthrough_mvp.gd` | như 3.7 |
| (giữ) mọi test nội dung bước 3–6 | 0 lỗi trên nội dung thật |

Chạy thêm `python3 tools/check_project.py` và `python3 tools/sim_cashflow.py`; dán kết quả + thống kê nội dung vào báo cáo.

---

## 5. Checklist cho người dùng khi mở Godot (chơi thử thật)

1. Chơi mới (Khó) → đặt tên → màn chữ hư cấu → vài dòng mở đầu → thẻ chọn KTX: đọc mô tả A/B, chọn → vào phòng, tường đúng màu khu, tiền trừ đúng giá KTX.
2. Gặp Minh + 2 bạn cùng phòng; bảng gợi ý nhỏ hiện đúng lúc (di chuyển, tương tác, hội thoại), mỗi cái một lần.
3. Chiều ngày 1 có tin nhắn TKB; Tối Minh rủ góp quỹ. Ngày 2: buổi học đầu + cảnh nữ thủ khoa; Tối mẹ gọi, nhận nhiệm vụ học phí. Ngày 3: xin việc ở quán.
4. Chơi tiếp tới hết tuần 2 bằng vòng lặp học – làm – ăn – ngủ: thấy tờ rơi ngày 8, gặp K. ngày 9, nghe tiền bối kể truyền thuyết (ghi nhớ luật!). Ngày 14 có tin mẹ hỏi; ngày 15 đúng thông báo đã đóng / trễ hạn.
5. Tuần 3: K. mời phát tờ rơi (thử nhận ở một ván, từ chối ở ván khác); Minh thâm quầng; điện thoại nhiễu lần đầu; đêm Thứ Năm bị đánh thức thấy Minh ra ngoài.
6. Tuần 4: Minh úp mặt vào tường lẩm bẩm; thử cảnh báo Minh. Đêm Chủ Nhật: cao trào → cầu thang vô tận → tự giải bằng luật của tiền bối (thử mở gợi ý G) → thoát → cảnh kết → "Còn tiếp…" với tổng kết đúng các lựa chọn của bạn.
7. Cảm giác tông: có lúc nào thấy **sợ** hay **giật mình** không? (Nếu có → ghi lại chỗ đó, đó là lỗi tông.)
8. Chạy test: `godot --headless --path . -s res://tests/run_tests.gd` → tất cả PASS (bao gồm bot chơi thử).
9. **Phiếu chơi thử** — gửi lại cho AI sau mỗi ván (mỗi chế độ ít nhất 1 ván):
   - Chế độ, thời gian chơi thực tế, đã đóng học phí ngày nào (hoặc chưa), tiền ngày 14 và ngày 28.
   - Số lần ngất, Sanity thấp nhất, có lúc nào hết tiền ăn không.
   - Có nhận việc của K. không, vì sao; có cảnh báo Minh không.
   - Câu đố cầu thang: số lần sai, có dùng gợi ý/gọi tiền bối không, có hiểu vì sao đúng không.
   - 3 chỗ khó hiểu/nhàm/lỗi nhất; câu thoại nào nghe không tự nhiên.

---

## 6. Cách làm việc

- Trả lời tiếng Việt. Trước khi code/viết: xác nhận QĐ-7.1 → QĐ-7.4; liệt kê kế hoạch + danh sách file; trình **dàn ý từng tuần** (các beat + lựa chọn chính) và **CHỜ NGƯỜI DÙNG DUYỆT** dàn ý trước khi viết thoại chi tiết. Đổi trạng thái bước 7 trong `docs/TASKS.md` thành "Đang code".
- Quy trình bắt buộc: **viết song song → rà chéo nhiều góc nhìn → kiểm chứng → sửa**.
  - Song song: (a) mở đầu + F3 + J11; (b) nội dung tuần 1–2; (c) nội dung tuần 3–4 + kết + "Còn tiếp…"; (d) bot chơi thử + mô phỏng + kiểm chứng nội dung.
  - Rà chéo theo các góc nhìn: **khớp STORY_MVP.md** (đủ mọi gạch đầu dòng tuần 1–4, đúng tên cờ); **khớp luật câu đố bước 6** (truyền thuyết đủ 3 ý, kể trước tuần 4); **tông** (đọc lại toàn bộ thoại theo quy tắc 3.4); **giọng nhân vật** nhất quán; **người chơi không bao giờ kẹt** (beat bắt buộc có dự phòng, khóa điều khiển mở lại); **số liệu** khớp BALANCE.md; **tiếng Việt** tự nhiên, đúng chính tả, đủ dấu.
  - Kiểm chứng: `gdparse`/`gdlint`, `check_project.py`, `sim_cashflow.py`; "chạy khô" EventSelector cho từng ngày 1–28 theo một trạng thái mẫu và dán lịch kết quả vào báo cáo.
- Không cài gói lớn, không xóa/di chuyển file khi chưa hỏi. Sửa file bước 1–6 ở mức tối thiểu, liệt kê trong báo cáo.
- Cập nhật `docs/ARCHITECTURE.md`: mục "Bước 7 — Nội dung MVP" (cấu trúc file nội dung, `@required`, tutorial, màn kết, bot chơi thử). Cập nhật `STORY_MVP.md` mục "Còn mở": đánh dấu xong mục bảng giá (đã chốt ở BALANCE.md) — chỉ khi người dùng đồng ý.
- Báo cáo: file tạo/sửa; mã đã xong; thống kê nội dung; kết quả bot + mô phỏng; đề xuất cân bằng (nếu có); cách kiểm tra. Thêm ✅ vào `FEATURES.md` cho J11, F3 (và J15 nếu làm). Xong → `docs/TASKS.md` đổi thành "Xong" và ghi "MVP sẵn sàng chơi thử".
