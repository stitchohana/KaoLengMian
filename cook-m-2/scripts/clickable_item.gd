extends Area2D

signal item_used(item_id: String)
signal arrival_at_target(item_id: String)

@export var item_id: String = ""
@export var target_node_path: NodePath = NodePath()
@export var item_color: Color = Color.WHITE
@export var display_name: String = ""

var _can_click: bool = true
var _target: Node2D = null

@onready var rect: ColorRect = $ColorRect
@onready var label: Label = $Label
@onready var col_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if rect:
		rect.color = item_color
	if label and display_name:
		label.text = display_name
	if target_node_path:
		_target = get_node(target_node_path)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _is_mouse_over():
			get_viewport().set_input_as_handled()
			try_use()

func _is_mouse_over() -> bool:
	if not col_shape or not col_shape.shape:
		return false
	var shape := col_shape.shape as RectangleShape2D
	if not shape:
		return false
	var mouse := get_global_mouse_position()
	var half := shape.size * 0.5
	var r := Rect2(global_position - half, shape.size)
	return r.has_point(mouse)

func try_use() -> void:
	if not _can_click:
		return
	if not _can_use():
		_shake()
		return
	_can_click = false
	_fly_to_target()

func _can_use() -> bool:
	return true

func _apply_effect() -> void:
	pass

func _fly_to_target() -> void:
	if not _target:
		_apply_effect()
		item_used.emit(item_id)
		arrival_at_target.emit(item_id)
		_can_click = true
		return

	print("FLY: ", name, " from ", global_position, " to ", _target.global_position)
	if _target:
		var fly_time = 0.8
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "position", _target.position - get_parent().position, fly_time)
		tween.tween_callback(_on_arrived)
	else:
		_apply_effect()
		item_used.emit(item_id)
		arrival_at_target.emit(item_id)
		_can_click = true

func _move_toward(pos: Vector2) -> void:
	global_position = pos

func _on_arrived() -> void:
	_apply_effect()
	item_used.emit(item_id)
	arrival_at_target.emit(item_id)
	_can_click = true

func _shake() -> void:
	var orig = position
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y - 8, 0.05)
	tween.tween_property(self, "position:y", orig.y, 0.1)
