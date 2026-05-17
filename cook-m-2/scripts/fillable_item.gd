extends "res://scripts/clickable_item.gd"

func _get_dish() -> NoodleDish:
	return Session.current_dish as NoodleDish

func _can_use() -> bool:
	var dish = _get_dish()
	match item_id:
		"egg":
			return dish.can_crack_egg()
		"onion":
			return dish.can_fill_onion()
		"chili":
			return dish.can_fill_sauce()
	return false

func _apply_effect() -> void:
	var dish = _get_dish()
	match item_id:
		"egg":
			dish.egg_cracked = true
		"onion":
			dish.onion_fill += 1
		"chili":
			dish.sauce_fill += 1
