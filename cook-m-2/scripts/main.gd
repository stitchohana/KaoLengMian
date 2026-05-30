extends Node2D

@onready var customer_queue: Node2D = $CustomerQueue
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var chicken_pos: Marker2D = $ChickenPos
@onready var noodle_zone: Node2D = $NoodleZone
@onready var onion_zone: Node2D = $OnionZone
@onready var sausage_zone: Node2D = $SausageZone
@onready var chili_zone: Node2D = $ChiliZone
@onready var box_area: Node2D = $BoxArea
@onready var hud_day: Label = $HUD/DayLabel
@onready var hud_timer: Label = $HUD/TimerLabel
@onready var hud_money: Label = $HUD/MoneyLabel
@onready var grill_area: Node2D = $GrillArea
@onready var ingredient_box: Node2D = $IngredientBox
@onready var egg_slot: Node2D = $IngredientBox/EggSlot
@onready var onion_slot: Node2D = $IngredientBox/OnionSlot
@onready var chili_slot: Node2D = $IngredientBox/ChiliSlot
@onready var order_container: VBoxContainer = $HUD/OrderContainer

var noodle_item: Area2D
var chicken_item: Area2D
var onion_block: Area2D
var chili_barrel: Area2D
var sausage_raw: Area2D
var _grill_node: Node2D
var _box_stack: Node2D

var ITEM_SCENES = {}
var FILL_ITEM_SCENES = {}

func _ready() -> void:
	_box_stack = null
	_load_scenes()
	_setup_order_header()
	_setup_box_stack()
	_setup_prep_items()
	_setup_chicken()
	_setup_ingredient_box()
	_setup_customer_manager()
	_setup_grill()
	_update_hud()
	_setup_signals()
	GameManager.start_day()

func _load_scenes() -> void:
	ITEM_SCENES = {
		noodle = load("res://scenes/prep_items/noodle_item.tscn"),
		chicken = load("res://scenes/prep_items/chicken_item.tscn"),
		onion_block = load("res://scenes/prep_items/onion_block_item.tscn"),
		chili_barrel = load("res://scenes/prep_items/chili_barrel_item.tscn"),
		sausage = load("res://scenes/prep_items/sausage_raw_item.tscn"),
	}
	FILL_ITEM_SCENES = {
		egg = load("res://scenes/prep_items/egg_fill_item.tscn"),
		onion = load("res://scenes/prep_items/onion_fill_item.tscn"),
		chili = load("res://scenes/prep_items/chili_fill_item.tscn"),
	}

func _setup_prep_items() -> void:
	var prep_config = [
		["noodle",      noodle_zone,    {"noodle":"面饼","onion_block":"洋葱","sausage":"烤肠","chili_barrel":"辣酱"}, {"noodle":Color(0.91,0.84,0.72),"onion_block":Color(0.87,0.63,0.87),"sausage":Color(0.80,0.36,0.36),"chili_barrel":Color(0.86,0.08,0.24)}],
		["onion_block", onion_zone,     {"noodle":"面饼","onion_block":"洋葱","sausage":"烤肠","chili_barrel":"辣酱"}, {"noodle":Color(0.91,0.84,0.72),"onion_block":Color(0.87,0.63,0.87),"sausage":Color(0.80,0.36,0.36),"chili_barrel":Color(0.86,0.08,0.24)}],
		["sausage",     sausage_zone,   {"noodle":"面饼","onion_block":"洋葱","sausage":"烤肠","chili_barrel":"辣酱"}, {"noodle":Color(0.91,0.84,0.72),"onion_block":Color(0.87,0.63,0.87),"sausage":Color(0.80,0.36,0.36),"chili_barrel":Color(0.86,0.08,0.24)}],
		["chili_barrel", chili_zone,    {"noodle":"面饼","onion_block":"洋葱","sausage":"烤肠","chili_barrel":"辣酱"}, {"noodle":Color(0.91,0.84,0.72),"onion_block":Color(0.87,0.63,0.87),"sausage":Color(0.80,0.36,0.36),"chili_barrel":Color(0.86,0.08,0.24)}],
	]
	for p in prep_config:
		var scene = ITEM_SCENES[p[0]].instantiate()
		scene.item_id = p[0]
		scene.item_color = p[3].get(p[0], Color.WHITE)
		scene.display_name = p[2].get(p[0], p[0])
		p[1].add_child(scene)
		scene.position = Vector2.ZERO

		match p[0]:
			"noodle":
				noodle_item = scene
				scene.arrival_at_target.connect(_on_noodle_arrived)
			"onion_block":
				onion_block = scene
				scene.arrival_at_target.connect(_on_onion_block_arrived)
			"sausage":
				sausage_raw = scene
				scene.arrival_at_target.connect(_on_sausage_arrived)
			"chili_barrel":
				chili_barrel = scene
				scene.arrival_at_target.connect(_on_chili_barrel_arrived)

func _setup_order_header() -> void:
	var header = Label.new()
	header.text = "--- 订单 ---"
	header.add_theme_color_override(&"font_color", Color(0.8, 0.8, 0.8))
	header.add_theme_font_size_override(&"font_size", 14)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	order_container.add_child(header)

func _setup_box_stack() -> void:
	var box_stack_scene = load("res://scenes/box_stack.tscn")
	_box_stack = box_stack_scene.instantiate()
	box_area.add_child(_box_stack)
	_box_stack.position = Vector2(-120, 0)

func _setup_chicken() -> void:
	var scene = ITEM_SCENES.chicken.instantiate()
	scene.item_id = "chicken"
	scene.item_color = Color(1.0, 1.0, 1.0)
	scene.display_name = "母鸡"
	add_child(scene)
	scene.position = chicken_pos.position
	chicken_item = scene
	scene.arrival_at_target.connect(_on_chicken_arrived)

func _setup_ingredient_box() -> void:
	var slot_config = [
		["egg",   egg_slot,   Color(1.0, 0.97, 0.86), "鸡蛋"],
		["onion", onion_slot, Color(0.87, 0.63, 0.87), "洋葱碎"],
		["chili", chili_slot, Color(0.86, 0.08, 0.24), "辣酱"],
	]
	for s in slot_config:
		var scene = FILL_ITEM_SCENES[s[0]].instantiate()
		scene.item_id = s[0]
		scene.item_color = s[2]
		scene.display_name = s[3]
		s[1].add_child(scene)
		scene.position = Vector2.ZERO
		scene.hide()
		scene.arrival_at_target.connect(_on_fill_item_used)

func _setup_customer_manager() -> void:
	var positions: Array[Marker2D] = []
	for child in customer_queue.get_children():
		if child is Marker2D:
			positions.append(child)
	CustomerManager.register_queue_positions(positions)
	CustomerManager.register_spawn_position(spawn_point)

func _setup_grill() -> void:
	var grill_scene = load("res://scenes/grill.tscn")
	_grill_node = grill_scene.instantiate()
	grill_area.add_child(_grill_node)
	_grill_node.dish_cut.connect(_on_dish_cut)
	_grill_node.sausage_used.connect(_on_grill_sausage_used)

func _setup_signals() -> void:
	GameManager.day_started.connect(_on_day_started)
	GameManager.day_ended.connect(_on_day_ended)
	GameManager.game_over.connect(_on_game_over)
	OrderManager.order_created.connect(_on_order_created)
	OrderManager.order_completed.connect(_on_order_completed)
	GameManager.timeout.connect(_on_day_timeout)
	CustomerManager.customer_left.connect(_on_customer_left)
	CustomerManager.all_customers_done.connect(_on_all_customers_done)

func _process(_delta: float) -> void:
	_update_hud()

func _update_hud() -> void:
	hud_day.text = "Day " + str(Session.current_day)
	hud_money.text = "$" + str(Session.total_money)
	if Session.game_state == Session.GameState.DAY_ACTIVE:
		var remaining = int(Config.data.day_duration_seconds - GameManager._elapsed_time)
		if remaining < 0:
			remaining = 0
		var m = remaining / 60
		var s = remaining % 60
		hud_timer.text = "%02d:%02d" % [m, s]

func _on_noodle_arrived(_id: String) -> void:
	if not noodle_item or not is_instance_valid(noodle_item):
		return

	var flying = ITEM_SCENES.noodle.instantiate()
	flying.item_color = Color(0.91, 0.84, 0.72)
	flying.display_name = ""
	flying._can_click = false
	add_child(flying)
	flying.global_position = noodle_zone.global_position

	noodle_item.call_deferred("set", "_can_click", false)
	var cook_pos = _grill_node.get_node("CookPos")
	var target = cook_pos.global_position
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(flying, "global_position", target, 0.5)
	tween.tween_callback(func():
		flying.queue_free()
		Session.current_dish.has_noodles = true
		var ns = cook_pos.get_node("NoodleSprite")
		if ns:
			ns.show()
		print("面饼已放入铁板")
	)

func _on_chicken_arrived(_id: String) -> void:
	var slot_egg = _find_fill_item("egg")
	if not slot_egg or slot_egg.visible:
		return

	slot_egg.charges = 4
	slot_egg.show()
	slot_egg._can_click = false
	slot_egg.position = chicken_item.position - ingredient_box.position - egg_slot.position

	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(slot_egg, "position", Vector2.ZERO, 0.35)
	tween.tween_callback(func():
		if is_instance_valid(slot_egg):
			slot_egg._can_click = true
	)
	print("鸡蛋已放入食材盒")

func _on_onion_block_arrived(_id: String) -> void:
	onion_block.reset()
	var slot = _find_fill_item("onion")
	if not slot or slot.visible:
		return
	slot.charges = 4
	slot.show()
	slot._can_click = false
	slot.position = onion_zone.position - ingredient_box.position - onion_slot.position
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(slot, "position", Vector2.ZERO, 0.35)
	tween.tween_callback(func():
		if is_instance_valid(slot):
			slot._can_click = true
	)
	print("洋葱已切碎放入食材盒")

func _on_chili_barrel_arrived(_id: String) -> void:
	var slot = _find_fill_item("chili")
	if not slot or slot.visible:
		return
	slot.charges = 4
	slot.show()
	slot._can_click = false
	slot.position = chili_zone.position - ingredient_box.position - chili_slot.position
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(slot, "position", Vector2.ZERO, 0.35)
	tween.tween_callback(func():
		if is_instance_valid(slot):
			slot._can_click = true
	)
	print("辣酱已放入食材盒")

func _on_sausage_arrived(_id: String) -> void:
	sausage_raw.call_deferred("set", "_can_click", false)
	var flying = ITEM_SCENES.sausage.instantiate()
	flying.item_color = Color(0.80, 0.36, 0.36)
	flying.display_name = ""
	flying._can_click = false
	add_child(flying)
	flying.global_position = sausage_zone.global_position

	if not _grill_node or not _grill_node.has_node("SausagePos"):
		flying.queue_free()
		return
	var spos = _grill_node.get_node("SausagePos")
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(flying, "global_position", spos.global_position, 0.5)
	tween.tween_callback(func():
		flying.queue_free()
		var ss = spos.get_node_or_null("SausageSprite")
		if ss:
			ss.show()
		if _grill_node and _grill_node.has_method("_on_sausage_dropped"):
			_grill_node._on_sausage_dropped()
	)
func _on_grill_sausage_used() -> void:
	if sausage_raw and is_instance_valid(sausage_raw):
		sausage_raw._can_click = true

func _on_dish_cut() -> void:
	if _grill_node and _grill_node.has_node("CookPos"):
		var cook_pos = _grill_node.get_node("CookPos")
		for child in cook_pos.get_children():
			if child is ColorRect:
				child.hide()
	var drag = load("res://scenes/noodle_drag_item.tscn").instantiate()
	if _grill_node and _grill_node.has_node("CookPos"):
		drag.global_position = _grill_node.get_node("CookPos").global_position
	else:
		drag.global_position = grill_area.global_position
	add_child(drag)

func _on_dish_boxed() -> void:
	Session.current_dish.reset()
	for slot in [egg_slot, onion_slot, chili_slot]:
		for child in slot.get_children():
			if child is Area2D:
				if not ("charges" in child) or child.charges <= 0:
					child.hide()
	_reset_prep_items()
	if _grill_node and _grill_node.has_method("reset"):
		_grill_node.reset(false)

func _on_sausage_dropped(_zone: Node) -> void:
	# 隐藏生烤肠，通知铁板开始烤制
	sausage_raw._can_click = false
	if _grill_node and _grill_node.has_method("_on_sausage_dropped"):
		_grill_node._on_sausage_dropped()

func _on_fill_item_used(_item_id: String) -> void:

	var slot_node = {"egg": egg_slot, "onion": onion_slot, "chili": chili_slot}.get(_item_id)
	if not slot_node or not _grill_node or not _grill_node.has_node("CookPos"):
		return

	var cook_pos = _grill_node.get_node("CookPos")
	var flying = FILL_ITEM_SCENES[_item_id].instantiate()
	flying.item_color = {"egg": Color(1,0.97,0.86), "onion": Color(0.87,0.63,0.87), "chili": Color(0.86,0.08,0.24)}.get(_item_id, Color.WHITE)
	flying.display_name = ""
	flying._can_click = false
	add_child(flying)
	flying.global_position = slot_node.global_position

	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(flying, "global_position", cook_pos.global_position, 0.5)
	tween.tween_callback(func():
		flying.queue_free()
		if _item_id == "egg":
			var es = cook_pos.get_node_or_null("EggSprite")
			if es:
				es.show()
	)

func _on_day_started(day: int) -> void:
	print("Day %d 开始！" % day)
	# 开始顾客生成
	var count = Config.data.customers_per_day_base + (day - 1) * Config.data.customers_per_day_increment
	CustomerManager.start_day(count, Config.data.base_spawn_interval)

func _on_day_ended(_day: int, _stats: Dictionary) -> void:
	for slot in [egg_slot, onion_slot, chili_slot]:
		for child in slot.get_children():
			if child is Area2D:
				child.hide()
	_reset_prep_items()
	if _box_stack and _box_stack.has_method("clear_all"):
		_box_stack.clear_all()
	if _grill_node and _grill_node.has_method("reset"):
		_grill_node.reset()

func _on_game_over(stats: Dictionary) -> void:
	print("游戏结束！天数: %d, 收入: $%d" % [stats.days_survived, stats.total_money])

func _on_order_created(order_data: Dictionary) -> void:
	var recipe = order_data.recipe
	var label = Label.new()
	label.name = "Order_" + recipe.id
	label.text = "▸ " + recipe.display_name + "  $" + str(order_data.base_price)
	label.add_theme_color_override(&"font_color", Color(1, 1, 0.6))
	label.add_theme_font_size_override(&"font_size", 14)
	order_container.add_child(label)

func _on_order_completed(order_data: Dictionary) -> void:
	var label = order_container.get_node_or_null("Order_" + order_data.recipe.id)
	if label:
		label.queue_free()

func _on_day_timeout() -> void:
	_clear_day()

func _on_customer_left(_customer: Node, reason: String) -> void:
	if reason == "timeout":
		Session.current_dish.reset()
		for slot in [egg_slot, onion_slot, chili_slot]:
			for child in slot.get_children():
				if child is Area2D:
					child.hide()
		if noodle_item and is_instance_valid(noodle_item):
			noodle_item._can_click = true
		if chicken_item and is_instance_valid(chicken_item):
			chicken_item._can_click = true
		if onion_block and is_instance_valid(onion_block):
			onion_block.reset()
		if chili_barrel and is_instance_valid(chili_barrel):
			chili_barrel._can_click = true
		if sausage_raw and is_instance_valid(sausage_raw):
			sausage_raw.show()
			sausage_raw._can_click = true
		if _grill_node and _grill_node.has_method("reset"):
			_grill_node.reset()

func _on_all_customers_done() -> void:
	if Session.game_state == Session.GameState.DAY_ACTIVE:
		GameManager.end_day()

func _clear_day() -> void:
	Session.current_dish.reset()
	for slot in [egg_slot, onion_slot, chili_slot]:
		for child in slot.get_children():
			if child is Area2D:
				child.hide()
	_reset_prep_items()
	if _box_stack and _box_stack.has_method("clear_all"):
		_box_stack.clear_all()
	if _grill_node and _grill_node.has_method("reset"):
		_grill_node.reset()
	if sausage_raw:
		sausage_raw.show()
		sausage_raw.set_draggable(true)

func _reset_prep_items() -> void:
	if noodle_item and is_instance_valid(noodle_item):
		noodle_item._can_click = true
		noodle_item.position = Vector2.ZERO
	if chicken_item and is_instance_valid(chicken_item):
		chicken_item.position = chicken_pos.position
	if onion_block and is_instance_valid(onion_block):
		onion_block.reset()
		onion_block.position = Vector2.ZERO
	if chili_barrel and is_instance_valid(chili_barrel):
		chili_barrel.position = Vector2.ZERO
	if sausage_raw and is_instance_valid(sausage_raw):
		sausage_raw.show()
		sausage_raw._can_click = true
		sausage_raw.position = Vector2.ZERO

func _find_fill_item(item_id: String) -> Area2D:
	for slot in [egg_slot, onion_slot, chili_slot]:
		for child in slot.get_children():
			if child is Area2D and child.get("item_id") == item_id:
				return child
	return null
