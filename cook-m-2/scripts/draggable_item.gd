extends Area2D

signal drag_dropped_on(drop_zone: Node)

@export var item_id: String = ""
@export var item_color: Color = Color.WHITE
@export var display_name: String = ""

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO
var _can_drag: bool = true

@onready var rect: ColorRect = $ColorRect
@onready var label: Label = $Label

func _ready() -> void:
	if rect:
		rect.color = item_color
	if label and display_name:
		label.text = display_name

func _input(event: InputEvent) -> void:
	if not _can_drag:
		return

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if _is_over_self(event.position):
				is_dragging = true
				drag_offset = global_position - get_global_mouse_position()
				original_position = global_position
				_on_drag_start()
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_dragging:
				is_dragging = false
				_on_drag_end()

	if event is InputEventMouseMotion and is_dragging:
		global_position = get_global_mouse_position() + drag_offset

func _is_over_self(pos: Vector2) -> bool:
	if rect:
		var half = rect.size * 0.5
		var r = Rect2(global_position - half, rect.size)
		return r.has_point(pos)
	return false

func _on_drag_start() -> void:
	pass

func _on_drag_end() -> void:
	# 检测drop zone
	var spaces = get_tree().get_nodes_in_group("drop_zone_grill")
	for zone in spaces:
		if zone is Area2D and zone.overlaps_area(self):
			drag_dropped_on.emit(zone)
			return
	# 没丢到目标，弹回
	_return_to_origin()

func _return_to_origin() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", original_position, 0.3)

func set_draggable(val: bool) -> void:
	_can_drag = val
	if not val and is_dragging:
		is_dragging = false
		_return_to_origin()
