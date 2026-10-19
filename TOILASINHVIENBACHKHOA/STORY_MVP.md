# Cốt truyện MVP — Chapter 1, tuần 1–4

Phạm vi: Chapter 1 giai đoạn 1–2, kết thúc bằng dị tượng cầu thang vô tận.
Mã tính năng (A1, G3…) tham chiếu `FEATURES.md`.

## Diễn biến theo tuần

### Tuần 1 — Nhập học
- Đặt tên nhân vật (J10), chọn KTX Khu A/B (F3), nhận thời khóa biểu ngẫu nhiên (B2).
- Gặp Minh (bạn cùng phòng). Minh đề nghị cả phòng góp quỹ chung (D4) → cờ `da_gop_quy`.
- Gọi điện về quê: đặt động lực, biết hạn học phí là cuối tuần 2 (B3).
- Tìm việc làm thêm: phụ quán cơm / bưng cà phê (D1).
- Cảnh ngắn ở giảng đường giới thiệu nữ thủ khoa.
- Tutorial lồng vào các sự kiện trên (J11).

### Tuần 2 — Áp lực cơm áo
- Vòng lặp chính: đi học, làm thêm, ăn, ngủ.
- Thấy tờ rơi CLB "Tương Lai Vàng". Đàn anh K. xuất hiện lần đầu, nói chuyện làm giàu.
- Gặp tiền bối "sinh viên năm n" — kể truyền thuyết cầu thang KTX (gài gợi ý cho câu đố tuần 4).
- Cuối tuần: hạn học phí. Thiếu tiền → cảnh báo; đủ → cờ `da_dong_hoc_phi`.

### Tuần 3 — Cám dỗ
- K. mời phát tờ rơi, hoa hồng cao (D3) → tăng Mức dính líu (A8), cờ `nhan_viec_to_roi`.
- Minh có quầng thâm (E3, `minh_trang_thai = 2`).
- Điện thoại nhiễu lần đầu (G1).
- Sự kiện đêm: thấy Minh lén ra ngoài (G4).

### Tuần 4 — Dị tượng đầu tiên
- Minh đứng úp mặt vào tường, lẩm bẩm công thức trộn khẩu hiệu đa cấp (`minh_trang_thai = 3`).
- Người chơi có thể cảnh báo Minh → cờ `canh_bao_minh`.
- Cao trào: cầu thang vô tận (G3). Lời giải dựa trên truyền thuyết tiền bối kể ở tuần 2.
- Thoát được → cờ `thoat_cau_thang` → màn hình "Còn tiếp…".

## NPC
| NPC | Vai trò trong MVP |
|---|---|
| Minh | Bạn cùng phòng, nghèo, dần sa vào đường dây của K. |
| Đàn anh K. | Phản diện, chủ CLB "Tương Lai Vàng" |
| Chủ quán | Nơi làm thêm |
| Giảng viên | Không tên, dạy trên lớp |
| Nữ thủ khoa | Một cảnh giới thiệu |
| Tiền bối năm n | Kể truyền thuyết cầu thang |

## Địa điểm
Phòng KTX · hành lang/cầu thang KTX · giảng đường · thư viện · quán làm thêm.

## Cờ cốt truyện
`ktx_khu` · `da_gop_quy` · `da_dong_hoc_phi` · `nhan_viec_to_roi` · `canh_bao_minh` · `minh_trang_thai` (1–3) · `thoat_cau_thang`

## Còn mở
- [ ] Bảng giá: học phí, lương mỗi ca, giá các món ăn, tiền góp quỹ. [CẦN QUYẾT ĐỊNH]
- [x] Câu đố cầu thang: "Chiếu nghỉ lạ" — khác thì đi xuống, giống thì đi lên, đúng 4 lần liền là thoát; đo tiếng ù 25,0 Hz (ống kín một đầu, tầng 3,43 m). Chốt theo QĐ-6.1.
