extends Area2D

var is_dragging: bool = false
var _offset: Vector2 = Vector2.ZERO
var _original: Vector2 = Vector2.ZERO

@onready var col_shape: CollisionShape2D = $CollisionShape2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _is_mouse_over():
			is_dragging = true
			_offset = global_position - get_global_mouse_position()
			_original = global_position
			get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_dragging:
			is_dragging = false
			_check_drop()

	if event is InputEventMouseMotion and is_dragging:
		global_position = get_global_mouse_position() + _offset

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

func _check_drop() -> void:
	var boxes = get_tree().get_nodes_in_group("box_drop_area")
	for box_area in boxes:
		if box_area is Area2D and box_area.overlaps_area(self):
			var box = box_area.get_parent()
			if box and box.get("state") == 0:  # BoxState.EMPTY
				box.fill_from_dish()
				queue_free()
				return
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", _original, 0.3)
