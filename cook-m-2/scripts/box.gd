extends Node2D

signal served(customer: Node, matched: bool)

enum BoxState { EMPTY, FILLED, DRAGGING }

var box_index: int = 0
var state: BoxState = BoxState.EMPTY
var _is_dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _original_pos: Vector2 = Vector2.ZERO
var _saved_dish_state: Dictionary = {}  # 保存装盒时的dish状态

@onready var rect: ColorRect = $ColorRect
@onready var label: Label = $Label
@onready var drop_area: Area2D = $DropArea
@onready var col_shape: CollisionShape2D = $DropArea/CollisionShape2D

func _ready() -> void:
	_update_visual()
	drop_area.add_to_group("box_drop_area")

func _input(event: InputEvent) -> void:
	if state == BoxState.EMPTY:
		return

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if _is_mouse_over():
				state = BoxState.DRAGGING
				_is_dragging = true
				_drag_offset = global_position - get_global_mouse_position()
				_original_pos = global_position
				rect.color = Color(0.9, 0.7, 0.4)
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if _is_dragging:
				_is_dragging = false
				state = BoxState.FILLED
				_check_customer_drop()

	if event is InputEventMouseMotion and _is_dragging:
		global_position = get_global_mouse_position() + _drag_offset

func _is_mouse_over() -> bool:
	if not col_shape or not col_shape.shape:
		return false
	var shape = col_shape.shape as RectangleShape2D
	if not shape:
		return false
	var mouse = get_global_mouse_position()
	var half = shape.size * 0.5
	var r = Rect2(global_position - half, shape.size)
	return r.has_point(mouse)

# 由 noodle_drag_item 掉落时调用
func fill_from_dish() -> void:
	if state == BoxState.EMPTY and _get_dish().cut and not _get_dish().boxed:
		_get_dish().boxed = true
		# 保存当前dish的快照用于订单匹配
		_saved_dish_state = {
			"has_noodles": _get_dish().has_noodles,
			"flipped": _get_dish().flipped,
			"rolled": _get_dish().rolled,
			"cut": _get_dish().cut,
			"boxed": true,
			"sausage_added": _get_dish().sausage_added,
			"onion_fill": _get_dish().onion_fill,
			"sauce_fill": _get_dish().sauce_fill,
		}
		state = BoxState.FILLED
		_update_visual()
		var main = get_node("/root/Main")
		if main and main.has_method("_on_dish_boxed"):
			main._on_dish_boxed()

func _check_customer_drop() -> void:
		var customers = get_tree().get_nodes_in_group("customer_drop_zone")
		for zone_area in customers:
			if not is_instance_valid(zone_area):
				continue
			if zone_area.overlaps_area(drop_area):
				_serve_to_customer(zone_area)
				return
		_return_to_origin()

func _serve_to_customer(zone_area: Area2D) -> void:
	var temp_dish = NoodleDish.new()
	temp_dish.has_noodles = _saved_dish_state.get("has_noodles", false)
	temp_dish.flipped = _saved_dish_state.get("flipped", false)
	temp_dish.rolled = _saved_dish_state.get("rolled", false)
	temp_dish.cut = _saved_dish_state.get("cut", false)
	temp_dish.sausage_added = _saved_dish_state.get("sausage_added", false)
	temp_dish.onion_fill = _saved_dish_state.get("onion_fill", 0)
	temp_dish.sauce_fill = _saved_dish_state.get("sauce_fill", 0)

	var matched = OrderManager.match_order(temp_dish)
	var base_price = matched.get("base_price", 10) if matched.size() > 0 else 10
	var value = temp_dish.calculate_value(base_price)

	if matched.size() > 0:
		GameManager.add_income(value)
	else:
		GameManager.add_income(max(1, int(value * Config.data.mismatch_penalty)))
		Session.daily_mismatch += 1

	Session.daily_served += 1

	var customer_node = zone_area.get_parent()
	if customer_node is CharacterBody2D:
		CustomerManager.on_customer_served(customer_node)

	queue_free()

func _get_dish() -> NoodleDish:
	return Session.current_dish

func _return_to_origin() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", _original_pos, 0.3)
	_update_visual()

func _update_visual() -> void:
	match state:
		BoxState.EMPTY:
			rect.color = Color(0.87, 0.72, 0.53)
			label.text = "空纸盒"
		BoxState.FILLED:
			rect.color = Color(0.9, 0.7, 0.4)
			label.text = "有面纸盒"
		BoxState.DRAGGING:
			rect.color = Color(0.9, 0.8, 0.5)
			label.text = "有面纸盒"
