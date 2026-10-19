class_name MoneyFormat
extends RefCounted
## Định dạng tiền VND: 1500000 → "1.500.000 đ", -250000 → "-250.000 đ".

const THOUSANDS_SEPARATOR: String = "."
const CURRENCY_SUFFIX: String = " đ"


static func format_vnd(amount: int) -> String:
	var digits: String = str(absi(amount))
	var grouped: String = ""
	var count: int = 0
	# Duyệt từ phải sang trái, chèn dấu chấm sau mỗi 3 chữ số.
	for i in range(digits.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			grouped = THOUSANDS_SEPARATOR + grouped
		grouped = digits[i] + grouped
		count += 1
	if amount < 0:
		grouped = "-" + grouped
	return grouped + CURRENCY_SUFFIX
