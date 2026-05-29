extends Node2D

signal dish_cut()
signal sausage_ready(pos: Vector2)

var _press_pos: Vector2 = Vector2.ZERO
var _drag_delta: Vector2 = Vector2.ZERO
var _is_dragging: bool = false
var _cut_clicks: int = 0
var _cut_click_timer: float = 0.0
var _sausage_cooking: bool = false
var _sausage_available: bool = false
var _sausage_flying: bool = false

@onready var bg: ColorRect = $Bg
@onready var labels: Node2D = $Labels
@onready var cut_counter: Label = $CutCounter
@onready var egg_timer: Timer = $EggSpreadTimer
@onready var sausage_timer: Timer = $SausageCookTimer
@onready var drop_zone: Area2D = $SausageDropZone
@onready var cook_pos: Node2D = $CookPos
@onready var sausage_pos: Node2D = $SausagePos
@onready var sausage_sprite: ColorRect = $SausagePos/SausageSprite

func _ready() -> void:
	egg_timer.timeout.connect(_on_egg_spread_done)
	sausage_timer.timeout.connect(_on_sausage_cooked)
	drop_zone.add_to_group("drop_zone_grill")

func _get_dish() -> NoodleDish:
	return Session.current_dish

func _process(delta: float) -> void:
	_update_visuals()
	if _cut_clicks > 0:
		_cut_click_timer += delta
		if _cut_click_timer > 2.0:
			_cut_clicks = 0
			_cut_click_timer = 0.0
			_update_cut_label()

func _on_sausage_dropped() -> void:
	if not _sausage_cooking and not _sausage_available:
		_sausage_cooking = true
		sausage_timer.start(Config.data.sausage_cook_time)

func _on_sausage_cooked() -> void:
	_sausage_cooking = false
	_sausage_available = true
	sausage_sprite.color = Color(0.9, 0.5, 0.2, 1)
	sausage_ready.emit(global_position)

func try_use_sausage() -> bool:
	if _sausage_available and _get_dish().can_add_sausage():
		_get_dish().sausage_added = true
		_sausage_available = false
		sausage_sprite.hide()
		return true
	return false

func _input(event: InputEvent) -> void:
	var dish = _get_dish()

	if not _is_mouse_on_grill():
		return

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_press_pos = get_global_mouse_position()
			_drag_delta = Vector2.ZERO
			_is_dragging = true
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not _is_dragging:
				return
			_is_dragging = false

			if _drag_delta.length() < Config.data.click_vs_swipe_threshold_px:
				_handle_tap(dish)
			else:
				_handle_swipe(dish)

	if event is InputEventMouseMotion and _is_dragging:
		_drag_delta += event.relative

func _is_mouse_on_sausage(event: InputEvent) -> bool:
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		var mouse = get_global_mouse_position()
		var half = Vector2(60, 30)
		var r = Rect2(sausage_pos.global_position - half, Vector2(120, 60))
		return r.has_point(mouse)
	return false

func _is_over_cookpos() -> bool:
	var mouse = get_global_mouse_position()
	var half = Vector2(35, 25)
	var r = Rect2(cook_pos.global_position - half, Vector2(70, 50))
	return r.has_point(mouse)

func _handle_tap(dish: NoodleDish) -> void:
	if _sausage_available and not _sausage_flying:
		var mouse = get_global_mouse_position()
		var half = Vector2(60, 30)
		var r = Rect2(sausage_pos.global_position - half, Vector2(120, 60))
		if r.has_point(mouse):
			_sausage_flying = true
			var target = cook_pos.global_position - sausage_pos.global_position
			var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(sausage_sprite, "position", target, 0.35)
			tween.tween_callback(func():
				_sausage_flying = false
				if try_use_sausage():
					sausage_sprite.hide()
				else:
					var bt = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
					bt.tween_property(sausage_sprite, "position", Vector2.ZERO, 0.3)
			)
			return

	if dish.can_cut():
		_cut_clicks += 1
		_cut_click_timer = 0.0
		_update_cut_label()
		if _cut_clicks >= Config.data.cut_clicks_required:
			dish.cut = true
			_cut_clicks = 0
			_update_cut_label()
			_cut_click_timer = 0.0
			dish_cut.emit()

func _handle_swipe(dish: NoodleDish) -> void:
	var abs_x = abs(_drag_delta.x)
	var abs_y = abs(_drag_delta.y)

	if abs_x < Config.data.swipe_threshold_px and abs_y < Config.data.swipe_threshold_px:
		return

	if abs_x > abs_y:
		pass
	else:
		if _drag_delta.y < 0 and dish.can_flip():
			dish.flipped = true
		elif _drag_delta.y > 0 and dish.can_roll():
			dish.rolled = true

func _is_mouse_on_grill() -> bool:
	if not bg:
		return false
	var mouse = get_global_mouse_position()
	var rect = Rect2(bg.global_position, bg.size)
	return rect.has_point(mouse)

func _is_mouse_on_sausage_label(_event: InputEvent) -> bool:
	if not $Labels/sausage.visible:
		return false
	return true

func _update_visuals() -> void:
	var dish = _get_dish()
	_set_layer_visible("noodles", dish.has_noodles)
	_set_layer_visible("egg", dish.egg_cracked and not dish.egg_spread)
	_set_layer_visible("egg_spread", dish.egg_spread and not dish.flipped)
	_set_layer_visible("flipped", dish.flipped and not dish.rolled)

	_set_layer_visible("sausage", false)

	_set_layer_visible("onion", dish.onion_fill > 0)
	_set_layer_visible("sauce", dish.sauce_fill > 0)
	_set_layer_visible("rolled", dish.rolled and not dish.cut)
	_set_layer_visible("cut", dish.cut)
	_set_layer_visible("boxed", dish.boxed)

	if dish.can_spread_egg() and egg_timer.is_stopped():
		print("EGG_TIMER: starting, egg_cracked=", dish.egg_cracked, " egg_spread=", dish.egg_spread)
		egg_timer.start(Config.data.egg_spread_time)

func _set_layer_visible(name: String, visible: bool) -> void:
	var node = labels.get_node_or_null(name)
	if node:
		node.visible = visible

func _on_egg_spread_done() -> void:
	var dish = _get_dish()
	if dish.can_spread_egg():
		dish.egg_spread = true

func _update_cut_label() -> void:
	if _cut_clicks > 0:
		cut_counter.text = "切段: %d/%d" % [_cut_clicks, Config.data.cut_clicks_required]
		cut_counter.show()
	else:
		cut_counter.hide()

func reset() -> void:
	_cut_clicks = 0
	_cut_click_timer = 0.0
	_is_dragging = false
	_sausage_cooking = false
	_sausage_available = false
	_sausage_flying = false
	sausage_sprite.hide()
	sausage_sprite.position = Vector2.ZERO
	sausage_sprite.color = Color(0.80, 0.36, 0.36, 1)
	_update_cut_label()
	egg_timer.stop()
	sausage_timer.stop()
	for child in cook_pos.get_children():
		if child is ColorRect:
			child.hide()
			if child.name == "NoodleSprite":
				child.color = Color(0.91, 0.84, 0.72, 1)
