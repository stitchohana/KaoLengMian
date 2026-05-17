extends Node2D

var boxes: Array[Node] = []
var _can_click: bool = true

var box_scene: PackedScene = null

func _load_box_scene() -> void:
	box_scene = load("res://scenes/box.tscn")

func _ready() -> void:
	_load_box_scene()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _is_mouse_over():
			get_viewport().set_input_as_handled()
			_spawn_box()

func _is_mouse_over() -> bool:
	var col = $Area2D/CollisionShape2D
	if not col or not col.shape:
		return false
	var shape = col.shape as RectangleShape2D
	if not shape:
		return false
	var mouse = get_global_mouse_position()
	var half = shape.size * 0.5
	var r = Rect2(global_position - half, shape.size)
	return r.has_point(mouse)

func _spawn_box() -> void:
	if not _can_click:
		return
	if not box_scene:
		return
	if boxes.size() >= Config.data.max_boxes:
		_shake()
		return

	var slot_idx = boxes.size()
	var slot_marker = get_node("../BoxSlot" + str(slot_idx)) as Marker2D
	if not slot_marker:
		return
	var target_pos = slot_marker.global_position

	var box = box_scene.instantiate()
	box.global_position = global_position
	box.box_index = slot_idx
	add_child(box)
	boxes.append(box)
	box.tree_exited.connect(_on_box_removed.bind(box))

	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(box, "global_position", target_pos, 0.35)

func _on_box_removed(box: Node) -> void:
	boxes.erase(box)

func _reposition_boxes() -> void:
	pass

func _shake() -> void:
	var orig = position
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Area2D, "position:y", 4, 0.05)
	tween.tween_property($Area2D, "position:y", 0, 0.1)

func clear_all() -> void:
	for box in boxes:
		if is_instance_valid(box):
			box.queue_free()
	boxes.clear()
