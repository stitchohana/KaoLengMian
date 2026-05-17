extends Resource
class_name NoodleDish

var has_noodles: bool = false
var egg_cracked: bool = false
var egg_spread: bool = false
var flipped: bool = false
var sausage_added: bool = false
var onion_fill: int = 0
var sauce_fill: int = 0
var rolled: bool = false
var cut: bool = false
var boxed: bool = false

func reset() -> void:
	has_noodles = false
	egg_cracked = false
	egg_spread = false
	flipped = false
	sausage_added = false
	onion_fill = 0
	sauce_fill = 0
	rolled = false
	cut = false
	boxed = false

func can_add_noodles() -> bool:
	return not has_noodles

func can_crack_egg() -> bool:
	return has_noodles and not egg_cracked

func can_spread_egg() -> bool:
	return egg_cracked and not egg_spread

func can_flip() -> bool:
	return egg_spread and not flipped

func can_add_sausage() -> bool:
	return flipped and not sausage_added

func can_fill_onion() -> bool:
	return flipped and onion_fill < 3

func can_fill_sauce() -> bool:
	return flipped and sauce_fill < 3

func can_roll() -> bool:
	return flipped and not rolled

func can_cut() -> bool:
	return rolled and not cut

func can_box() -> bool:
	return cut and not boxed

func calculate_value(base_price: int) -> int:
	var fill = 0.0
	fill += float(onion_fill) / 3.0 * 0.5
	fill += float(sauce_fill) / 3.0 * 0.5
	var ratio = 0.3 + fill * 0.7
	return max(1, int(base_price * ratio))
