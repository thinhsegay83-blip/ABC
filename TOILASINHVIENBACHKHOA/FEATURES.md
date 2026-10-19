# Tôi Là Sinh Viên Bách Khoa — Danh sách tính năng

Tài liệu gốc cho việc lập trình. Mọi tính năng mới phải thêm vào đây trước khi code.

## Quyết định đã chốt

| Mục | Quyết định |
|---|---|
| Engine | Godot 4 (bản stable mới nhất), GDScript |
| Nền tảng | PC trước, mobile sau |
| Bối cảnh | Thế giới giả tưởng; màn mở đầu có dòng "Mọi nhân vật, tổ chức, sự kiện đều là hư cấu" |
| Tông truyện | Bí ẩn / kỳ ảo đô thị nhẹ nhàng, KHÔNG phải game kinh dị: không jumpscare, không máu me, không chết chóc, không ma quỷ đáng sợ |
| Giọng thoại | Trung tính, câu ngắn, xưng "mình/bạn"; không dùng giọng địa phương. Tham khảo Stardew Valley, Kindergarten, Punch Club: thoại gọn, hệ quả của lựa chọn rõ ràng |
| Nhân vật chính | Cố định nam |
| Romance | Không có ở Chapter 1, để chương sau |
| Nhánh đột nhập | Stealth đơn giản (né tầm nhìn bảo vệ, bị phát hiện thì làm lại đoạn) |
| Câu đố Vật lý | Kết hợp: người chơi tự giải; Trí tuệ càng cao gợi ý càng rõ |
| Độ khó | 3 chế độ: Dễ / Khó / Cực khó (chi tiết trong BALANCE.md) |
| Trễ hạn học phí | Gia hạn tới cuối tuần 4 + phạt 500.000 |

## Câu hỏi còn mở

- [ ] Công thức cụ thể cho các chỉ số (tốc độ giảm/hồi) — làm ở BALANCE.md.

## Quy ước nhãn

**Ưu tiên**
- `MVP` — bản chơi thử đầu tiên: Chapter 1 giai đoạn 1–2 (tuần 1–4), kết thúc bằng dị tượng cầu thang vô tận.
- `C1` — cần để hoàn thành trọn Chapter 1.
- `PH` — cần trước khi phát hành trên Steam.
- `SAU` — chương sau hoặc bản cập nhật.

**Nguồn**
- `[P]` — tài liệu pitch
- `[C1]` — cốt truyện Chapter 1
- `[ĐX]` — đề xuất bổ sung
- `[Bạn]` — yêu cầu của chủ dự án

---

## A. Chỉ số nhân vật

| ID | Tính năng | Ưu tiên | Nguồn |
|---|---|---|---|
| A1 | ✅ **Thể lực** — giảm khi làm việc, thức đêm; hồi khi ngủ/nghỉ; về 0 thì ngất, mất khung giờ | MVP | [P] |
| A2 | ✅ **Đói** — giảm theo thời gian; hồi khi ăn (tốn tiền); đói quá thì Thể lực tụt nhanh, học kém hiệu quả | MVP | [Bạn] |
| A3 | ✅ **Sanity** — giảm do dị tượng, đồ của K., áp lực deadline; hồi khi ngủ, đi chơi, gọi về nhà; thấp thì ảo giác, gợi ý sai, dễ bị K. dụ; về 0 thì Bad Ending | MVP | [P][C1] |
| A4 | ✅ **Trí tuệ** — tăng khi đi học, tự học, làm bài tập; mở khóa gợi ý câu đố | MVP | [P] |
| A5 | ✅ **Tiền** — thu: lương, trợ cấp, học bổng; chi: trọ, ăn, giáo trình, học phí | MVP | [P] |
| A6 | ✅ **Quan hệ theo từng NPC** — độ thân thiết riêng với mỗi người | MVP | [P] |
| A7 | **Uy tín** — giảm khi làm việc tà đạo (dụ dỗ người khác) | C1 | [C1] |
| A8 | ✅ **Mức dính líu với K.** — tăng khi nhận việc/đi hội thảo của K.; cao thì mở Bad Ending "con rối" | MVP | [C1] |
| A9 | **Trạng thái tạm thời** — no, buồn ngủ, cafein, cảm sốt | C1 | [ĐX] |
| A10 | **Ốm** — kiệt sức hoặc dầm mưa thì nằm nhà 1–2 ngày | C1 | [ĐX] |

> Đã xử lý mâu thuẫn: pitch gộp "Social/Sanity" → tách thành A3 và A6. Pitch cho "ăn uống hồi Thể lực" → ăn hồi Đói, ngủ hồi Thể lực.

## B. Thời gian và lịch

| ID | Tính năng | Ưu tiên | Nguồn |
|---|---|---|---|
| B1 | ✅ 4 khung giờ/ngày (Sáng, Chiều, Tối, Đêm), ngày → tuần → học kỳ | MVP | [P] |
| B2 | ✅ Thời khóa biểu ngẫu nhiên đầu game | MVP | [C1] |
| B3 | ✅ Hạn đóng học phí đầu năm | MVP | [C1] |
| B4 | ✅ Tiền trọ/KTX định kỳ | MVP | [P] |
| B5 | Hạn bài tập lớn / đồ án | C1 | [P] |
| B6 | Thi giữa kỳ | C1 | [C1] |
| B7 | Tua nhanh (montage) từ tuần 6 tới lúc công bố điểm học kỳ 1 | C1 | [ĐX] |
| B8 | Thi cuối kỳ đầy đủ | SAU | [ĐX] |
| B9 | Đăng ký tín chỉ dạng minigame tranh slot | SAU | [P] |
| B10 | ✅ Màn tổng kết cuối ngày (thu, chi, thay đổi chỉ số) | MVP | [ĐX] |
| B11 | Lịch dạng tháng trên điện thoại | C1 | [ĐX] |
| B12 | Thời tiết: mưa ảnh hưởng đi lại và tâm trạng | SAU | [ĐX] |
| B13 | Học phí HK2 (16.000.000, đóng đầu HK2); 1 năm = 2 học kỳ | SAU | [Bạn] |

## C. Học tập

| ID | Tính năng | Ưu tiên | Nguồn |
|---|---|---|---|
| C1 | ✅ Hành động: đi học, tự học ở thư viện | MVP | [P] |
| C2 | ✅ Điểm danh — trốn học bị trừ điểm chuyên cần | MVP | [ĐX] |
| C3 | ✅ Điểm riêng từng môn (Giải tích, Vật lý, Đồ án…) → GPA | MVP | [P] |
| C4 | Thức trắng chạy đồ án/ôn thi: tăng nhiều tiến độ, trừ nặng Thể lực và Sanity | C1 | [P] |
| C5 | Bảng điểm cuối học kỳ | C1 | [C1] |
| C6 | Học bổng chia mức: khuyến khích từng kỳ; toàn phần cho True Ending | C1 / SAU | [P] |
| C7 | Nợ môn, cảnh báo học vụ, đình chỉ học | SAU | [P] |
| C8 | **Sổ tay bài giảng** — kiến thức học trên lớp thành gợi ý cho câu đố | C1 | [C1] |

## D. Kinh tế

| ID | Tính năng | Ưu tiên | Nguồn |
|---|---|---|---|
| D1 | ✅ Việc làm thêm: phụ quán cơm, bưng cà phê | MVP | [C1] |
| D2 | Việc làm thêm: gia sư, bồi bàn, trực lab, shipper | SAU | [P] |
| D3 | ✅ Việc tà đạo: phát tờ rơi dụ dỗ (MVP), phục vụ hộp đêm (C1) — hoa hồng cao, tăng A8, bật cờ cốt truyện | MVP / C1 | [C1] |
| D4 | ✅ Quỹ chung của phòng KTX — các thành viên góp tiền | MVP | [ĐX] |
| D5 | Gửi tiền về quê | C1 | [C1] |
| D6 | ✅ Cửa hàng: đồ ăn, giáo trình, vật liệu chế tạo | MVP | [ĐX] |
| D7 | ✅ Món ăn có hiệu ứng riêng: cơm tấm (Đói), trà sữa (Sanity), cà phê cóc (Thể lực tạm thời) | MVP | [P] |
| D8 | Việc làm có cấp bậc — làm lâu lương tăng | SAU | [ĐX] |
| D9 | Trực lab: có lương + được vào phòng lab ban đêm | SAU | [P] |

## E. NPC và tương tác

| ID | Tính năng | Ưu tiên | Nguồn |
|---|---|---|---|
| E1 | ✅ Hội thoại có chân dung, lựa chọn rẽ nhánh, mỗi lựa chọn đổi chỉ số/cờ | MVP | [P] |
| E2 | ✅ Lịch trình NPC theo khung giờ | MVP | [ĐX] |
| E3 | ✅ NPC đổi trạng thái theo cốt truyện (Minh: bình thường → thâm quầng → úp mặt vào tường → mất tích) | MVP | [C1] |
| E4 | Bạn cùng phòng mách mối làm thêm và tin đồn | C1 | [P] |
| E5 | Cảnh báo Minh sớm → ảnh hưởng kết quả giải cứu | C1 | [C1] |
| E6 | ✅ Đi chơi với bạn: hồi Sanity, tăng Quan hệ | MVP | [P] |
| E7 | Gọi điện về quê | C1 | [C1] |
| E8 | Giảng viên (hỏi bài, giới thiệu việc) | SAU | [P] |
| E9 | Câu lạc bộ | SAU | [P] |
| E10 | Nữ thủ khoa: tuyến nhiệm vụ phụ, cạnh tranh điểm | SAU | [P] |
| E11 | Đồng đội đi cùng, mỗi người một kỹ năng chuyên ngành (IT, Cơ khí, Hóa) | SAU | [P] |
| E12 | Romance | SAU | [P] |

## F. Bản đồ và khám phá

| ID | Tính năng | Ưu tiên | Nguồn |
|---|---|---|---|
| F1 | Di chuyển góc nhìn từ trên xuống, va chạm, camera bám theo | MVP | [ĐX] |
| F2 | Tương tác (đến gần, nhấn phím) | MVP | [ĐX] |
| F3 | Chọn KTX Khu A hoặc Khu B lúc đầu game | MVP | [C1] |
| F4 | Khu vực MVP: phòng KTX, hành lang/cầu thang KTX, giảng đường, thư viện, quán làm thêm | MVP | [P][C1] |
| F5 | Khu vực C1: hộp đêm, phòng hội thảo, nhà kho, đường hầm | C1 | [C1] |
| F6 | Bản đồ có phiên bản ngày và đêm | MVP | [P] |
| F7 | Xe buýt di chuyển giữa các khu | C1 | [P][C1] |
| F8 | Màn hình bản đồ | C1 | [ĐX] |
| F9 | Cơ sở 2 (giảng đường cũ, xưởng, rừng/hồ đá) và cơ sở 1 | SAU | [P] |

## G. Dị tượng và giải đố

| ID | Tính năng | Ưu tiên | Nguồn |
|---|---|---|---|
| G1 | **Khả năng đặc biệt = radar điện thoại**: điện thoại nhiễu khi dị tượng ở gần | MVP | [P][ĐX] |
| G2 | Âm thanh báo hiệu: nhạc tần số lạ = vùng đang trừ Sanity | MVP | [C1] |
| G3 | Dị tượng cầu thang vô tận + câu đố logic để thoát | MVP | [C1] |
| G4 | Sự kiện đêm trong phòng (bị đánh thức, thấy Minh) | MVP | [C1] |
| G5 | Dị tượng mạnh dần theo tuần | C1 | [C1] |
| G6 | Dị tượng xe buýt lạc vào sương mù | C1 | [C1] |
| G7 | Hành lang méo / không gian biến dạng | C1 | [C1] |
| G8 | Câu đố mạch điện | C1 | [P] |
| G9 | Câu đố Vật lý cộng hưởng (gợi ý theo 3 mức Trí tuệ) | C1 | [C1] |
| G10 | Chế tạo thiết bị cơ bản | C1 | [P] |
| G11 | Thực thể dị biến (1–2 loại), mỗi loại có điểm yếu riêng | C1 | [P] |
| G12 | Khu vực bị phong ấn, mở khi giải xong câu đố | C1 | [P] |
| G13 | Trận cao trào không bạo lực: phá loa, phá đá, đánh thức người bị thôi miên | C1 | [C1] |
| G14 | Số người được giải cứu ảnh hưởng chất lượng kết thúc | C1 | [C1] |

## H. Điều tra và cốt truyện

| ID | Tính năng | Ưu tiên | Nguồn |
|---|---|---|---|
| H1 | ✅ Cờ cốt truyện (ghi nhớ lựa chọn) | MVP | [ĐX] |
| H2 | ✅ Sổ nhiệm vụ | MVP | [ĐX] |
| H3 | Hội thảo của K. có lịch cố định | C1 | [C1] |
| H4 | Đồ uống hộp đêm có tác dụng ẩn (trừ Sanity, tăng A8) | C1 | [C1] |
| H5 | Minh mất tích cùng quỹ chung (D4) | C1 | [C1] |
| H6 | Sổ manh mối — ghép bằng chứng | C1 | [C1] |
| H7 | 2 nhánh tiếp cận: cửa sau (nhân viên hộp đêm) / đột nhập | C1 | [C1] |
| H8 | Stealth đơn giản cho nhánh đột nhập | C1 | Đã chốt |
| H9 | Đêm Hội Thức Tỉnh có giờ cố định, đến trễ thì kết quả khác | C1 | [C1] |
| H10 | Kết thúc Chapter 1: K. bị bắt, bảng điểm, học bổng, after-credit (điện thoại vỡ của K.) | C1 | [C1] |
| H11 | Bad Ending trong C1: kiệt sức, Sanity về 0, "con rối" (A8 cao) | C1 | [P][C1] |
| H12 | Codex truyền thuyết (do tiền bối kể) | SAU | [P] |
| H13 | Normal / True Ending toàn game | SAU | [P] |

## I. Vật phẩm và điện thoại

| ID | Tính năng | Ưu tiên | Nguồn |
|---|---|---|---|
| I1 | ✅ Túi đồ | MVP | [ĐX] |
| I2 | ✅ Điện thoại: tin nhắn, ví, thời khóa biểu, radar (G1) | MVP | [ĐX] |
| I3 | Điện thoại vỡ của K. (vật phẩm cốt truyện) | C1 | [C1] |
| I4 | Kỹ năng phụ: nấu ăn, sửa đồ điện, lập trình | SAU | [ĐX] |

## J. Nền kỹ thuật

| ID | Tính năng | Ưu tiên | Nguồn |
|---|---|---|---|
| J1 | ✅ Menu chính, menu tạm dừng (Esc), cài đặt (âm lượng, độ phân giải, toàn màn hình) | MVP | [ĐX] |
| J2 | ✅ Lưu/tải 3 ô + tự lưu đầu mỗi ngày | MVP | [ĐX] |
| J3 | ✅ HUD: 6 chỉ số, ngày, khung giờ, tiền | MVP | [ĐX] |
| J4 | ✅ Chuyển scene có hiệu ứng mờ dần | MVP | [ĐX] |
| J5 | ✅ Quản lý âm thanh: nhạc nền, hiệu ứng | MVP | [ĐX] |
| J6 | ✅ Input Map: bàn phím + chuột | MVP | [ĐX] |
| J7 | ✅ Font tiếng Việt đủ dấu | MVP | [ĐX] |
| J8 | ✅ Thông báo nhỏ (toast) | MVP | [ĐX] |
| J9 | ✅ Tiện ích hội thoại: xem lại lịch sử, tua đoạn đã đọc, tự chạy chữ, chỉnh tốc độ chữ | MVP | [ĐX] |
| J10 | ✅ Đặt tên nhân vật | MVP | [ĐX] |
| J11 | Hướng dẫn chơi (tutorial) | MVP | [ĐX] |
| J12 | ✅ Menu debug: chỉnh chỉ số, nhảy ngày, bật/tắt cờ | MVP | [ĐX] |
| J13 | ✅ Dữ liệu tách khỏi code (Godot Resource .tres: vật phẩm, hành động, NPC, sự kiện) | MVP | [ĐX] |
| J14 | Màn hình Game Over / kết thúc / credits | C1 | [ĐX] |
| J15 | Dòng tuyên bố hư cấu ở màn mở đầu | C1 | Đã chốt |
| J16 | Hỗ trợ tay cầm, đổi phím | PH | [ĐX] |
| J17 | Thành tựu Steam, lưu đám mây | PH | [ĐX] |
| J18 | ✅ Chọn độ khó: Dễ / Khó / Cực khó (tiền ban đầu, tốc độ tụt chỉ số, lương) | MVP | [Bạn] |
| J19 | Chọn quê (ưu thế nhỏ khi bắt đầu) | SAU | [ĐX] |
| J20 | Tiếng Anh | SAU | [ĐX] |
| J21 | Bản mobile | SAU | [P] |
