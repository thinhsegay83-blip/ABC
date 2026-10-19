# Font tiếng Việt — Be Vietnam Pro (J7)

Game dùng **Be Vietnam Pro** làm font mặc định (đủ dấu tiếng Việt). Font phát hành theo
**SIL Open Font License 1.1 (OFL)**: được dùng miễn phí, kể cả trong game thương mại, được
đóng gói kèm game; chỉ cần giữ file giấy phép `OFL.txt` đi kèm và không bán riêng file font.

File font **không có sẵn trong repo**. Khi chưa có font, game vẫn chạy bình thường bằng font
mặc định của Godot (`Game._apply_font()` tự bỏ qua).

## Cần những file nào

Đặt đúng tên, đúng chỗ (phân biệt hoa/thường):

```
fonts/
  BeVietnamPro-Regular.ttf   ← bắt buộc để đổi font (Game.FONT_REGULAR_PATH)
  BeVietnamPro-Bold.ttf      ← chữ đậm (dùng cho bold_font của RichTextLabel)
  OFL.txt                    ← giấy phép, bắt buộc giữ kèm khi phát hành
  README.md                  ← file này
```

## Cách 1 — Tải từ trang Google Fonts (khuyên dùng)

1. Mở <https://fonts.google.com/specimen/Be+Vietnam+Pro>.
2. Bấm **Get font** → **Download all** để tải file `.zip`.
3. Giải nén. Trong thư mục giải nén, tìm và chép 3 file sau vào thư mục `fonts/` của dự án:
   - `BeVietnamPro-Regular.ttf`
   - `BeVietnamPro-Bold.ttf`
   - `OFL.txt`
   (Các kiểu khác như Light, SemiBold, Italic… không cần, đừng chép vào để bản build nhẹ hơn.)

## Cách 2 — Tải bằng dòng lệnh (từ kho google/fonts trên GitHub)

Chạy ở thư mục gốc dự án:

```bash
cd fonts
curl -L -o BeVietnamPro-Regular.ttf https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-Regular.ttf
curl -L -o BeVietnamPro-Bold.ttf    https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-Bold.ttf
curl -L -o OFL.txt                  https://github.com/google/fonts/raw/main/ofl/bevietnampro/OFL.txt
```

Trên Windows PowerShell thay `curl -L -o <tên> <url>` bằng
`Invoke-WebRequest <url> -OutFile <tên>`.

Kiểm tra nhanh: mỗi file `.ttf` phải nặng khoảng vài trăm KB. Nếu chỉ vài KB thì có thể đã tải
nhầm trang HTML — mở bằng trình soạn thảo, thấy `<html>` thì tải lại theo Cách 1.

## Sau khi chép font

1. Mở dự án bằng Godot Editor một lần (hoặc chạy `godot --headless --path . --import`) để Godot
   import file `.ttf` (sinh file `.import`).
2. (Tùy chọn) Chọn file `.ttf` trong FileSystem → tab **Import**: giữ *Antialiasing = Grayscale*,
   tắt *Generate Mipmaps*, *Hinting = Light*, rồi bấm **Reimport**.
3. Chạy game: chữ trong menu ("Chơi mới", "Tải game", "Cài đặt"…) hiển thị bằng Be Vietnam Pro,
   dấu tiếng Việt (ă, â, ê, ô, ơ, ư, đ và 5 dấu thanh) hiện đầy đủ, không bị ô vuông.

## Cách font được áp dụng

`scripts/autoload/game.gd` → `_apply_font()` khi game khởi động:

- Nếu `res://fonts/BeVietnamPro-Regular.ttf` tồn tại: đặt làm `ThemeDB.fallback_font` và
  `default_font` của theme mặc định → mọi Control dùng font này (không cần sửa từng scene).
- Nếu có `BeVietnamPro-Bold.ttf`: dùng làm chữ đậm (`bold_font`) cho RichTextLabel.
- Nếu không có file: giữ nguyên font của engine, không báo lỗi.

## Ghi công (credits)

Khi phát hành, thêm vào màn hình credits / file giấy phép của game:

> Be Vietnam Pro — © The Be Vietnam Pro Project Authors (chép đúng dòng Copyright trong `OFL.txt`), phát hành theo SIL Open Font License 1.1.
