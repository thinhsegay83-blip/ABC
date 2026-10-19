# Hàng đợi nhiệm vụ — MVP Chapter 1 (tuần 1–4)

> Lập bởi "AI lập nhiệm vụ" ngày 18/10/2026. Prompt chi tiết từng bước: `docs/prompts/BUOC_<n>.md` (bước 1: `/home/user/PROMPT_BUOC1.md`).
> AI code đổi cột **Trạng thái** khi bắt đầu ("Đang code") và khi đã báo cáo xong ("Xong"). Người dùng kiểm tra checklist thấy lỗi thì đổi lại "Đang code".

## Bảng hàng đợi

| Bước | Mã tính năng | Phụ thuộc | Trạng thái | Quyết định cần chốt |
|---|---|---|---|---|
| 1 — Nền tảng (`PROMPT_BUOC1.md`) | J1–J8, J12, J13, J18, A1–A6, B1 | — | Xong | — |
| 2 — Thế giới đi lại được + đồ họa placeholder (`BUOC_2.md`) | F1, F2, F4, F6 (+ chuẩn bị F3, G3); lưu `current_area` vào save | Bước 1 | Chờ | QĐ-2.1, QĐ-2.2 (QĐ-2.3 không chặn) |
| 3 — Hội thoại & cờ (`BUOC_3.md`) | E1, H1, J9, J10 | Bước 1, 2 | Xong (chưa nối Interactable — chờ bản đồ) | QĐ-3.1, QĐ-3.2 |
| 4 — Vòng lặp đời sinh viên (`BUOC_4.md`) | C1, C2, C3, D1, D6, D7, B2, B3, B4, B10 (+ hoàn thiện hậu quả A1–A3) | Bước 1–3 | Xong (logic + UI tạm; chờ bản đồ để gắn Interactable) | QĐ-4.1 → QĐ-4.7: dùng khuyến nghị |
| 5 — NPC & sự kiện (`BUOC_5.md`) | E2, E3, E6, D3, D4, A8, H2, I1, I2 | Bước 1–4 | Xong (QĐ-5.1→5.3 theo khuyến nghị; sprite/anchor chờ bản đồ) | QĐ-5.1 → QĐ-5.3 |
| 6 — Dị tượng (`BUOC_6.md`) | G1, G2, G3, G4 | Bước 1–5 | Chờ | QĐ-6.1 → QĐ-6.3 |
| 7 — Ghép nội dung tuần 1–4 (`BUOC_7.md`) | J11, F3 (+ J15), nội dung sự kiện/hội thoại tuần 1–4, màn "Còn tiếp…", chơi thử + cân bằng | Bước 1–6 | Chờ | QĐ-7.1 → QĐ-7.4 |

- Thứ tự làm: tuần tự 2 → 7, mỗi bước dùng API của bước trước. Muốn rút ngắn thời gian: phần **logic thuần** của bước 3 (parser `.dlg`, điều kiện, runner, `PlayerName`) không phụ thuộc bước 2, có thể viết song song với bước 2.
- Prompt bước 3–7 ghi tên API "dự kiến"; nếu `docs/ARCHITECTURE.md` thực tế khác thì AI code theo ARCHITECTURE.md và ghi chú chỗ lệch.

---

## Quyết định đang chờ người dùng

Chưa trả lời thì AI code dùng phương án **khuyến nghị** và ghi rõ trong báo cáo.

### Chặn bước 2
- [ ] **QĐ-2.1** Dựng bản đồ khi AI không mở được Editor: lưới ký tự trong `.tres` + dựng TileMapLayer bằng code (`@tool`) / Python sinh tile data nhị phân / người dùng tự vẽ. → **Khuyến nghị: lưới ký tự + dựng bằng code.**
- [ ] **QĐ-2.2** FEATURES D1 có 2 việc mà F4 chỉ có 1 quán: gộp "quán cơm – cà phê" / tách 2 khu / bỏ cà phê. → **Khuyến nghị: gộp 1 khu.**
- [ ] **QĐ-2.3** (không chặn) Đồ họa lâu dài: giữ placeholder tới khi chơi thử xong / thay sớm bằng CC0 / gói trả phí. → **Khuyến nghị: giữ placeholder.**

### Chặn bước 3
- [ ] **QĐ-3.1** Hệ thống hội thoại: tự viết định dạng `.dlg` / Dialogue Manager 3 / Dialogic 2 (addon phải tự cài trên máy người dùng). → **Khuyến nghị: tự viết `.dlg`.**
- [ ] **QĐ-3.2** Tên mặc định trong ô đặt tên: gợi ý sẵn 1 tên / bắt buộc nhập / nút ngẫu nhiên. → **Khuyến nghị: gợi ý sẵn (ví dụ "Phong"), sửa được.**

### Chặn bước 4
- [ ] **QĐ-4.1** Mua đồ ăn/giáo trình ở đâu (F4 không có cửa hàng): quầy trong quán + máy bán nước KTX + quầy photo thư viện / thêm khu căn tin / qua điện thoại. → **Khuyến nghị: không thêm khu (phương án đầu).**
- [ ] **QĐ-4.2** Phạt trễ học phí 500.000: cộng vào khoản phải đóng / trừ thẳng vào ví. → **Khuyến nghị: cộng vào khoản phải đóng (16.500.000).**
- [ ] **QĐ-4.3** Cà phê "Thể lực tạm thời" (A9 là C1): làm bản rút gọn chỉ hiệu ứng cafein / chỉ +Thể lực / chờ A9. → **Khuyến nghị: cafein rút gọn (+20 rồi −10 sau 2 khung).**
- [ ] **QĐ-4.4** Sanity về 0 trong MVP (Bad Ending là C1): thất bại mềm (mất 1 ngày, hồi về 30) / màn Bad Ending thử / chỉ cảnh báo. → **Khuyến nghị: thất bại mềm.**
- [ ] **QĐ-4.5** Giáo trình: photo 80.000 (tự học +5 thay vì +3) / sách gốc 150.000 / không bán. → **Khuyến nghị: photo 80.000.**
- [ ] **QĐ-4.6** "Tháng" để thu KTX/quỹ: 28 ngày / 30 ngày. → **Khuyến nghị: 28 ngày.**
- [ ] **QĐ-4.7** "Tối đa 2 ca/ngày" (giả định trong BALANCE) thành luật? có / không. → **Khuyến nghị: có.**

### Chặn bước 5
- [ ] **QĐ-5.1** Mức dính líu K. (A8): ẩn số, gợi bằng lời / hiện thanh trong điện thoại / chỉ debug. → **Khuyến nghị: ẩn số.**
- [ ] **QĐ-5.2** Bạn cùng phòng ngoài Minh: thêm 2 bạn "nền" / chỉ Minh. → **Khuyến nghị: 2 bạn nền (gợi ý Tuấn, Khoa).**
- [ ] **QĐ-5.3** Gọi điện về quê (E7 là C1): chỉ cuộc gọi kịch bản / gọi tự do 1 lần/ngày hồi Sanity. → **Khuyến nghị: chỉ cuộc gọi kịch bản.**

### Chặn bước 6
- [ ] **QĐ-6.1** Câu đố cầu thang (STORY còn mở): "Chiếu nghỉ lạ" — khác thì xuống, giống thì lên, kèm đo tiếng ù ống kín một đầu 25,0 Hz / đếm bậc 12→13 / đi theo tiếng ù nhỏ dần. → **Khuyến nghị: "Chiếu nghỉ lạ" (gộp 13 bậc làm một chỗ lệch).**
- [ ] **QĐ-6.2** Người chơi bị kẹt câu đố: gợi ý tự tăng + "Gọi tiền bối" sau 8 lần sai / không trợ giúp / thêm nút bỏ qua (trợ năng). → **Khuyến nghị: phương án đầu.**
- [ ] **QĐ-6.3** Âm báo 25 Hz (loa laptop khó phát): âm tượng trưng nghe được + số Hz trên điện thoại + phụ đề / phát đúng 25 Hz. → **Khuyến nghị: âm tượng trưng.**

### Chặn bước 7
- [ ] **QĐ-7.1** KTX Khu A/B khác nhau: chỉ trang trí / Khu B rẻ 250.000 nhưng đi xa −3 Thể lực mỗi chuyến / khác cả NPC (C1). → **Khuyến nghị: khác 1 thông số (phương án giữa).**
- [ ] **QĐ-7.2** Dòng tuyên bố hư cấu (J15 = C1 nhưng đã chốt có ở màn mở đầu): làm luôn trong MVP / để C1. → **Khuyến nghị: làm luôn.**
- [ ] **QĐ-7.3** Cao trào cầu thang: cố định Đêm ngày 28 / người chơi tự kích trong tuần 4 (hạn chót ngày 28). → **Khuyến nghị: cố định Đêm ngày 28.**
- [ ] **QĐ-7.4** Sau "Còn tiếp…": về menu chính + giữ bản lưu kết thúc / chơi tự do tiếp. → **Khuyến nghị: về menu chính.**

### Còn mở từ tài liệu gốc (không chặn MVP)
- [ ] Ngày hạn học phí HK2 (BALANCE.md ghi [CẦN QUYẾT ĐỊNH]) — thuộc Chapter 2 (B13 = SAU).
- [ ] Công thức chỉ số (FEATURES "Câu hỏi còn mở") — bước 4 đưa bộ số [ĐX] + mô phỏng; người dùng duyệt sau khi xem bảng mô phỏng.

---

## Số liệu đề xuất [ĐX] cần duyệt (không chặn)

AI code dùng các giá trị này (đặt trong `.tres`, ghi vào BALANCE.md mục "Đề xuất") nếu người dùng chưa có ý kiến. Giá đã chốt trong BALANCE.md giữ nguyên.

| Bước | Số đề xuất |
|---|---|
| 4 | TKB: 4 môn (Giải tích 1 – 4 TC – 2 buổi/tuần, Vật lý 1 – 4 – 2, Hóa đại cương – 3 – 1, Nhập môn kỹ thuật – 3 – 1), Thứ 2–6 Sáng/Chiều, ngày 1 chưa có tiết · Vào học: Thể lực −8, Trí tuệ +2 · Tự học: Thể lực −6, Sanity −2, Trí tuệ +3 · Ca làm: Thể lực −15/−12, Đói −5 · Nghỉ: Thể lực +10, Sanity +3 · Ngủ: Thể lực +60 (từ Tối +75), Sanity +10 · Món: bánh mì Đói +15, cơm/phở +25, trà sữa Sanity +10, cà phê/nước tăng lực Thể lực +20 rồi −10 sau 2 khung, mì gói 8.000 Đói +12 · Đói < 20: học ×0,5, Thể lực −3/khung · Ngất: mất 1 khung, Thể lực 30, Sanity −5 · Trễ học phí: Sanity −10, nhắc ngày 8/12/13/14 (gia hạn 22/26/27/28) · Điểm 10 = 3 × chuyên cần + 7 × nắm bài; quy đổi thang 4 theo thang tín chỉ phổ biến |
| 5 | Tờ rơi: Thể lực −10/ca, nhận việc A8 +5 · Đi chơi: 50.000, Sanity +15, quan hệ +5, Tối, 1 lần/ngày · Quan hệ 5 bậc (20/40/60/80) · A8: thấp < 30, vừa 30–59, cao ≥ 60 · Lịch NPC (bảng trong BUOC_5.md) |
| 6 | Radar: ngưỡng vạch 0,10/0,30/0,55/0,80 · Vùng tần số: Sanity −1 mỗi 5 giây, tối đa −10 mỗi lần vào · Sai câu đố: Sanity −3 · Gợi ý theo Trí tuệ: < 25 / 25–49 / ≥ 50 · "Gọi tiền bối" sau 8 lần sai, Sanity −5 |
| 7 | Khu B: 250.000/tháng, −3 Thể lực mỗi chuyến đi học/làm (nếu QĐ-7.1 = phương án giữa) · K. "tò mò" lần đầu: A8 +2 |

---

## Mâu thuẫn tài liệu đã phát hiện

| # | Mâu thuẫn | Xử lý đề xuất (ở đâu) |
|---|---|---|
| 1 | A3 (MVP) "Sanity về 0 thì Bad Ending" nhưng H11 Bad Ending và J14 màn Game Over là C1 | MVP dùng thất bại mềm (QĐ-4.4, bước 4) |
| 2 | D7 (MVP) "cà phê cóc = Thể lực tạm thời" nhưng A9 trạng thái tạm thời (cafein) là C1 | Làm hiệu ứng cafein rút gọn (QĐ-4.3, bước 4) |
| 3 | D6 (MVP) bán "vật liệu chế tạo" nhưng G10 chế tạo là C1; F4 không có khu cửa hàng | MVP chỉ bán đồ ăn + giáo trình; chỗ bán theo QĐ-4.1 (bước 4) |
| 4 | D1 có 2 việc (quán cơm, cà phê) nhưng F4 chỉ có 1 "quán làm thêm" | QĐ-2.2 (bước 2) |
| 5 | STORY tuần 1 có "gọi điện về quê", A3 ghi "hồi Sanity khi gọi về nhà", nhưng E7 gọi điện về quê là C1 | MVP chỉ cuộc gọi kịch bản (QĐ-5.3, bước 5) |
| 6 | "Quyết định đã chốt": màn mở đầu có dòng hư cấu, nhưng J15 để ưu tiên C1 | QĐ-7.2 (bước 7) |
| 7 | J3 "HUD: 6 chỉ số" nhưng ARCHITECTURE HUD chỉ có 4 thanh + tiền (A6 chuyển sang điện thoại); A8 (MVP) chưa có chỗ lưu/hiển thị trong ARCHITECTURE | A6 trong điện thoại (bước 5); A8 lưu bằng cờ `dinh_lieu_k`, hiển thị theo QĐ-5.1. Nên sửa câu chữ J3 trong FEATURES |
| 8 | BALANCE: bảng dòng tiền 14 ngày chưa trừ khung giờ đi học (đã tự ghi [CẦN KIỂM TRA]); "tối đa 2 ca/ngày" là giả định chứ chưa là luật; "cần có" tính sẵn 200.000 quỹ phòng dù STORY cho góp quỹ là lựa chọn | Bước 4 tính lại có TKB, chạy cả 2 trường hợp có/không quỹ; QĐ-4.7 |
| 9 | Hạn gia hạn học phí "cuối tuần 4" trùng ngày kết thúc MVP (cầu thang tuần 4) → thực tế hạn gia hạn không bao giờ bị vượt trong MVP | Hợp với BALANCE "MVP chỉ hiện cảnh báo": màn "Còn tiếp…" cảnh báo nếu chưa đóng (bước 7) |
| 10 | STORY tuần 2 chỉ ghi "thiếu tiền → cảnh báo", chưa nhắc luật đã chốt "gia hạn tới cuối tuần 4 + phạt 500.000" | Bước 4 làm đủ luật; nên bổ sung 1 dòng vào STORY_MVP.md |
| 11 | STORY_MVP "Còn mở: Bảng giá… [CẦN QUYẾT ĐỊNH]" nhưng BALANCE.md đã chốt giá cố định | Đánh dấu xong mục này trong STORY_MVP.md (bước 7, khi người dùng đồng ý) |
| 12 | E3 liệt kê 4 trạng thái Minh (có "mất tích") nhưng cờ `minh_trang_thai` trong STORY chỉ 1–3 | Không xung đột thật: MVP dùng 1–3, chừa 4 cho H5 (C1) — bước 5 |
| 13 | FEATURES "Godot 4 bản stable mới nhất" vs ARCHITECTURE "Godot 4.4+" | Tương thích; giữ "viết cho 4.4, chạy được bản mới hơn" |
| 14 | Code bước 1 đã có thêm `Game.FONT_BOLD_PATH`, `TestCase.after_each/assert_almost_eq/json_round_trip` nhưng ARCHITECTURE.md chưa ghi | AI code bước 1 đang cập nhật ARCHITECTURE.md — chỉ cần nhớ đồng bộ |
| 15 | Ghi chú nghiên cứu (`truyen_thuyet_di_tuong.md`) có nhiều ý mang màu kinh dị (bóng đè, "nghe gọi đủ họ tên thì đừng quay lại", hồn ma) — trái dòng "Tông truyện" | Các prompt bước 6–7 chỉ lấy ý hợp tông, có bảng "Được / Không được" và test quét từ cấm |

---

## Ghi chú chung cho AI code

**Môi trường**: không có Godot binary (chỉ `gdparse`/`gdlint`); mạng chặn github.com, godotengine.org, fonts.google.com; pypi/npm được, Pillow có sẵn. Đồ họa/âm thanh tự tạo bằng `tools/gen_art.py`, `tools/gen_audio.py`. Test do người dùng chạy: `godot --headless --path . -s res://tests/run_tests.gd`. Kiểm chứng tĩnh bằng `python3 tools/check_project.py` (tạo ở bước 2, các bước sau mở rộng).

**Quy trình mỗi bước**: chờ duyệt kế hoạch → viết song song → rà chéo nhiều góc nhìn → kiểm chứng → sửa → báo cáo (file tạo/sửa, mã đã xong, ✅ trong FEATURES.md, cập nhật ARCHITECTURE.md, cách kiểm tra). Không cài gói lớn, không xóa file khi chưa hỏi.

**Lớp giao diện (CanvasLayer) dự kiến**: InteractionPrompt 5 · Hud 10 · DialogueBox 30 · ActionMenu/Shop/TKB 40 · DaySummary 42 · TravelMenu 45 · Phone 48 · PauseMenu 50 · Toast 90 · SceneLoader 100 · DebugMenu 120.

**Phím dự kiến (tránh trùng)**: Esc tạm dừng · F1 debug · E tương tác · WASD/mũi tên di chuyển · Space/Enter/E/chuột trái tiếp hội thoại · giữ Ctrl tua · T tự chạy chữ · L lịch sử · Tab điện thoại · I túi đồ · G suy nghĩ (gợi ý câu đố).

**Autoload dự kiến (theo thứ tự)**: AudioManager, Settings, SaveSystem, Game, DialogueSystem (bước 3), StudentLife (bước 4), EventDirector (bước 5), SceneLoader, Toast, DebugMenu.

**Khóa save mới dự kiến (không tăng `SAVE_VERSION`, thiếu khóa thì dùng mặc định)**: `current_area`, `current_spawn` (bước 2) · `player_name` (bước 3) · `life` (bước 4) · `story` (bước 5).
