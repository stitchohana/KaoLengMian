extends Node

signal order_created(order_data: Dictionary)
signal order_completed(order_data: Dictionary)
signal order_expired(order_data: Dictionary)

var recipes: Array[Recipe] = []
var active_orders: Array[Dictionary] = []

func _ready() -> void:
	_load_recipes()

func _load_recipes() -> void:
	# 优先从 resources 加载
	var list = ResourceLoader.load("res://resources/recipes.tres", "RecipeList", ResourceLoader.CACHE_MODE_REUSE)
	if list and list is RecipeList:
		recipes = list.recipes.duplicate()
		if recipes.size() > 0:
			return
	# fallback: 硬编码默认配方
	recipes = _default_recipes()

func _default_recipes() -> Array[Recipe]:
	var r: Array[Recipe] = []
	var data = [
		{"id": "classic", "name": "经典", "sauces": [], "toppings": ["onion"], "price": 10},
		{"id": "spicy", "name": "辣味", "sauces": ["spicy"], "toppings": ["onion"], "price": 12},
		{"id": "sausage", "name": "烤肠", "sauces": [], "toppings": ["sausage"], "price": 12},
		{"id": "deluxe", "name": "豪华", "sauces": ["spicy"], "toppings": ["onion", "sausage"], "price": 15},
	]
	for d in data:
		var recipe = Recipe.new()
		recipe.id = d.id
		recipe.display_name = d.name
		recipe.base_price = d.price
		for s in d.sauces:
			recipe.required_sauces.append(s)
		for t in d.toppings:
			recipe.required_toppings.append(t)
		r.append(recipe)
	return r

func generate_order(customer: Node) -> Dictionary:
	var recipe = recipes.pick_random() if recipes.size() > 0 else _default_recipes()[0]
	var order = {
		"recipe": recipe,
		"creation_time": Time.get_ticks_msec(),
		"is_completed": false,
		"is_expired": false,
		"base_price": recipe.base_price,
	}
	active_orders.append(order)
	order_created.emit(order)
	return order

func match_order(dish: NoodleDish) -> Dictionary:
	for order in active_orders:
		if order.is_completed or order.is_expired:
			continue
		if _dish_matches_order(dish, order.recipe):
			order.is_completed = true
			order_completed.emit(order)
			return order
	return {}

func _dish_matches_order(dish: NoodleDish, recipe: Recipe) -> bool:
	if not dish.has_noodles or not dish.flipped or not dish.rolled:
		return false
	for s in recipe.required_sauces:
		if s == "spicy" and dish.sauce_fill <= 0:
			return false
	for t in recipe.required_toppings:
		if t == "onion" and dish.onion_fill <= 0:
			return false
		if t == "sausage" and not dish.sausage_added:
			return false
	return true

func mark_expired(order_data: Dictionary) -> void:
	order_data.is_expired = true
	order_expired.emit(order_data)
