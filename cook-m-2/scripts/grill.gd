extends Node2D

signal dish_cut()
signal sausage_ready(pos: Vector2)
signal sausage_used()

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
@onready var noodle_sprite: ColorRect = $CookPos/NoodleSprite
var flipped_sprite: ColorRect
var rolled_sprite: ColorRect
var onion_sprite: ColorRect
var sauce_sprite: ColorRect
var dish_sausage_sprite: ColorRect
@onready var sausage_pos: Node2D = $SausagePos
@onready var sausage_sprite: ColorRect = $SausagePos/SausageSprite

func _ready() -> void:
	egg_timer.timeout.connect(_on_egg_spread_done)
	sausage_timer.timeout.connect(_on_sausage_cooked)
	drop_zone.add_to_group("drop_zone_grill")

	# Create flipped noodle sprite in code (separate node for easy texture replacement later)
	flipped_sprite = ColorRect.new()
	flipped_sprite.name = "FlippedSprite"
	flipped_sprite.visible = false
	flipped_sprite.offset_left = -35.0
	flipped_sprite.offset_top = -25.0
	flipped_sprite.offset_right = 35.0
	flipped_sprite.offset_bottom = 25.0
	flipped_sprite.color = Color(0.85, 0.7, 0.5, 1)
	cook_pos.add_child(flipped_sprite)

	# Create rolled noodle sprite (visible after rolling, before cutting)
	rolled_sprite = ColorRect.new()
	rolled_sprite.name = "RolledSprite"
	rolled_sprite.visible = false
	rolled_sprite.offset_left = -35.0
	rolled_sprite.offset_top = -25.0
	rolled_sprite.offset_right = 35.0
	rolled_sprite.offset_bottom = 25.0
	rolled_sprite.color = Color(0.75, 0.55, 0.35, 1)
	cook_pos.add_child(rolled_sprite)
	# Create onion and sauce sprites at CookPos
	onion_sprite = ColorRect.new()
	onion_sprite.name = "OnionSprite"
	onion_sprite.visible = false
	onion_sprite.offset_left = -18.0
	onion_sprite.offset_top = -8.0
	onion_sprite.offset_right = 18.0
	onion_sprite.offset_bottom = 8.0
	onion_sprite.color = Color(0.87, 0.63, 0.87, 1)
	cook_pos.add_child(onion_sprite)

	sauce_sprite = ColorRect.new()
	sauce_sprite.name = "SauceSprite"
	sauce_sprite.visible = false
	sauce_sprite.offset_left = -22.0
	sauce_sprite.offset_top = -12.0
	sauce_sprite.offset_right = 22.0
	sauce_sprite.offset_bottom = 12.0
	sauce_sprite.color = Color(0.86, 0.08, 0.24, 1)
	cook_pos.add_child(sauce_sprite)

	# Create dish sausage sprite (visible at CookPos when added to dish)
	dish_sausage_sprite = ColorRect.new()
	dish_sausage_sprite.name = "DishSausageSprite"
	dish_sausage_sprite.visible = false
	dish_sausage_sprite.offset_left = -20.0
	dish_sausage_sprite.offset_top = -8.0
	dish_sausage_sprite.offset_right = 20.0
	dish_sausage_sprite.offset_bottom = 8.0
	dish_sausage_sprite.color = Color(0.9, 0.5, 0.2, 1)
	cook_pos.add_child(dish_sausage_sprite)

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
		sausage_sprite.position = Vector2.ZERO
		sausage_sprite.color = Color(0.80, 0.36, 0.36, 1)
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
		sausage_used.emit()
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
			# Create temporary flying visual (leaves sausage_sprite at SausagePos)
			var fly_sprite = ColorRect.new()
			fly_sprite.size = Vector2(40, 16)
			fly_sprite.color = Color(0.9, 0.5, 0.2, 1)
			add_child(fly_sprite)
			fly_sprite.global_position = sausage_sprite.global_position
			var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(fly_sprite, "global_position", cook_pos.global_position, 0.35)
			tween.tween_callback(func():
				_sausage_flying = false
				fly_sprite.queue_free()
				if not try_use_sausage():
					# Shake to indicate failure
					var orig = sausage_sprite.position
					var bt = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
					bt.tween_property(sausage_sprite, "position", orig + Vector2(0, -8), 0.1)
					bt.tween_property(sausage_sprite, "position", orig, 0.2)
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

	_set_layer_visible("sausage", dish.sausage_added and not dish.rolled)

	_set_layer_visible("onion", dish.onion_fill > 0)
	_set_layer_visible("sauce", dish.sauce_fill > 0)
	_set_layer_visible("rolled", dish.rolled and not dish.cut)
	_set_layer_visible("cut", dish.cut)
	_set_layer_visible("boxed", dish.boxed)

	# Sausage sprite at SausagePos visible when available
	sausage_sprite.visible = _sausage_available or _sausage_cooking

	# Dish sausage sprite at CookPos shown when added to dish (not rolled yet)
	dish_sausage_sprite.visible = dish.sausage_added and not dish.rolled and not dish.cut

	# Noodle sprites: raw noodle before flip, flipped sprite after flip
	noodle_sprite.visible = dish.has_noodles and not dish.flipped
	flipped_sprite.visible = dish.flipped and not dish.rolled and not dish.cut
	rolled_sprite.visible = dish.rolled and not dish.cut
	onion_sprite.visible = dish.onion_fill > 0 and not dish.rolled and not dish.cut
	sauce_sprite.visible = dish.sauce_fill > 0 and not dish.rolled and not dish.cut

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

func reset(reset_sausage: bool = true) -> void:
	_cut_clicks = 0
	_cut_click_timer = 0.0
	_is_dragging = false
	_sausage_flying = false
	if reset_sausage:
		_sausage_cooking = false
		_sausage_available = false
		sausage_sprite.hide()
		sausage_sprite.position = Vector2.ZERO
		sausage_sprite.color = Color(0.80, 0.36, 0.36, 1)
		sausage_timer.stop()
	_update_cut_label()
	egg_timer.stop()
	for child in cook_pos.get_children():
		if child is ColorRect:
			child.hide()
			if child.name == "NoodleSprite":
				child.color = Color(0.91, 0.84, 0.72, 1)
