extends Node

signal customer_spawned(customer: Node)
signal customer_left(customer: Node, reason: String)
signal all_customers_done()

var customer_scene: PackedScene = null
var queue_positions: Array[Marker2D] = []
var spawn_position: Marker2D = null
var active_customers: Array[Node] = []
var total_to_spawn: int = 0
var total_spawned: int = 0
var _spawn_timer: Timer
var _current_interval: float = 12.0

func _ready() -> void:
    customer_scene = load("res://scenes/customers/customer.tscn")
    _spawn_timer = Timer.new()
    _spawn_timer.one_shot = true
    add_child(_spawn_timer)
    _spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func register_queue_positions(positions: Array[Marker2D]) -> void:
    queue_positions = positions

func register_spawn_position(pos: Marker2D) -> void:
    spawn_position = pos

func start_day(customer_count: int, spawn_interval: float) -> void:
    total_to_spawn = customer_count
    total_spawned = 0
    _current_interval = spawn_interval
    active_customers.clear()
    _spawn_customer()
    if total_spawned < total_to_spawn:
        _spawn_timer.start(_current_interval)

func _on_spawn_timer_timeout() -> void:
    _spawn_customer()
    if total_spawned < total_to_spawn:
        _spawn_timer.start(_current_interval)

func _spawn_customer() -> void:
    if total_spawned >= total_to_spawn:
        return
    total_spawned += 1
    if not customer_scene or not spawn_position:
        return
    var customer = customer_scene.instantiate()
    customer.global_position = spawn_position.global_position
    add_child(customer)
    active_customers.append(customer)
    var order_data = OrderManager.generate_order(customer)
    customer.initialize(order_data)
    _update_queue_positions()
    customer_spawned.emit(customer)

func _update_queue_positions() -> void:
    for i in active_customers.size():
        if i < queue_positions.size():
            active_customers[i].move_to_position(queue_positions[i].global_position)

func _check_all_done() -> void:
    if active_customers.is_empty() and total_spawned >= total_to_spawn:
        all_customers_done.emit()

func on_customer_served(customer: Node) -> void:
    active_customers.erase(customer)
    if is_instance_valid(customer):
        customer.queue_free()
    customer_left.emit(customer, "served")
    _update_queue_positions()
    _check_all_done()

func on_customer_timeout(customer: Node) -> void:
    active_customers.erase(customer)
    if is_instance_valid(customer):
        customer.queue_free()
    customer_left.emit(customer, "timeout")
    GameManager.on_customer_left_angry()
    _update_queue_positions()
    _check_all_done()

func get_active_count() -> int:
    return active_customers.size()

func get_total_spawned() -> int:
    return total_spawned
