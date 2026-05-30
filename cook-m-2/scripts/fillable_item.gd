extends "res://scripts/clickable_item.gd"

var charges: int = 0

func _get_dish() -> NoodleDish:
	return Session.current_dish as NoodleDish

func _can_use() -> bool:
	if charges <= 0:
		return false
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

func _on_arrived() -> void:
	super._on_arrived()
	_consume_charge()

func _fly_to_target() -> void:
	super._fly_to_target()
	# For no-target items (fill items), _fly_to_target handles everything
	# without calling _on_arrived, so handle charges here too.
	if not _target:
		_consume_charge()

func _consume_charge() -> void:
	charges -= 1
	if charges <= 0:
		hide()
		_can_click = false
