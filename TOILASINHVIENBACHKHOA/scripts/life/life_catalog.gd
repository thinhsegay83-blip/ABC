class_name LifeCatalog
extends RefCounted
## Nạp toàn bộ dữ liệu đời sinh viên từ data/*.tres (J13).
## Danh sách id liệt kê ở đây (không quét thư mục) để chạy đúng cả khi xuất bản game.

const ECONOMY_PATH: String = "res://data/economy.tres"
const ACTION_IDS: Array[String] = [
	"di_hoc", "tu_hoc", "xin_viec", "lam_quan_com", "bung_ca_phe", "nghi", "ngu",
]
const ITEM_IDS: Array[String] = [
	"banh_mi", "com_tam", "pho", "ca_phe_coc", "nuoc_tang_luc", "tra_sua", "mi_goi",
	"giao_trinh_giai_tich_1", "giao_trinh_vat_ly_1", "giao_trinh_hoa_dai_cuong",
	"giao_trinh_nhap_mon_ky_thuat",
]
const SUBJECT_IDS: Array[String] = [
	"giai_tich_1", "vat_ly_1", "hoa_dai_cuong", "nhap_mon_ky_thuat",
]
const SHOP_IDS: Array[String] = ["quay_quan", "goc_ca_phe", "may_ban_nuoc", "quay_photo"]
const EFFECT_IDS: Array[String] = ["cafein"]

## Tên hiển thị các nơi chốn (khớp id khu vực ở bước 2).
const PLACE_NAMES: Dictionary = {
	"ktx_room": "Phòng KTX",
	"ktx_hallway": "Hành lang KTX",
	"lecture_hall": "Giảng đường",
	"library": "Thư viện",
	"food_shop": "Quán cơm – cà phê",
}
const PLACE_ORDER: Array[String] = [
	"ktx_room", "ktx_hallway", "lecture_hall", "library", "food_shop",
]

var economy: EconomyConfig
var actions: Array[ActionData] = []
var items: Dictionary = {}  # id -> ItemData
var subjects: Array[SubjectData] = []
var shops: Array[ShopData] = []
var effects: Dictionary = {}  # id -> StatusEffectData


static func load_default() -> LifeCatalog:
	var catalog: LifeCatalog = LifeCatalog.new()
	catalog.economy = load(ECONOMY_PATH) as EconomyConfig
	if catalog.economy == null:
		push_warning("LifeCatalog: không nạp được %s, dùng mặc định" % ECONOMY_PATH)
		catalog.economy = EconomyConfig.new()
	for id: String in ACTION_IDS:
		var action: ActionData = _load("actions", id) as ActionData
		if action != null:
			catalog.actions.append(action)
	for id: String in ITEM_IDS:
		var item: ItemData = _load("items", id) as ItemData
		if item != null:
			catalog.items[item.id] = item
	for id: String in SUBJECT_IDS:
		var subject: SubjectData = _load("subjects", id) as SubjectData
		if subject != null:
			catalog.subjects.append(subject)
	for id: String in SHOP_IDS:
		var shop: ShopData = _load("shops", id) as ShopData
		if shop != null:
			catalog.shops.append(shop)
	for id: String in EFFECT_IDS:
		var effect: StatusEffectData = _load("effects", id) as StatusEffectData
		if effect != null:
			catalog.effects[effect.id] = effect
	return catalog


func get_action(id: String) -> ActionData:
	for action: ActionData in actions:
		if action.id == id:
			return action
	return null


func get_item(id: String) -> ItemData:
	return items.get(id, null) as ItemData


func get_subject(id: String) -> SubjectData:
	for subject: SubjectData in subjects:
		if subject.id == id:
			return subject
	return null


func get_shop(id: String) -> ShopData:
	for shop: ShopData in shops:
		if shop.id == id:
			return shop
	return null


func get_effect(id: String) -> StatusEffectData:
	return effects.get(id, null) as StatusEffectData


func actions_at(place_id: String) -> Array[ActionData]:
	var result: Array[ActionData] = []
	for action: ActionData in actions:
		if action.place_id == place_id:
			result.append(action)
	return result


func shops_at(place_id: String) -> Array[ShopData]:
	var result: Array[ShopData] = []
	for shop: ShopData in shops:
		if shop.place_id == place_id:
			result.append(shop)
	return result


func subject_name(id: String) -> String:
	var subject: SubjectData = get_subject(id)
	return subject.display_name if subject != null else id


static func place_name(place_id: String) -> String:
	return str(PLACE_NAMES.get(place_id, place_id))


static func _load(folder: String, id: String) -> Resource:
	var path: String = "res://data/%s/%s.tres" % [folder, id]
	if not ResourceLoader.exists(path):
		push_warning("LifeCatalog: thiếu %s" % path)
		return null
	return load(path)
