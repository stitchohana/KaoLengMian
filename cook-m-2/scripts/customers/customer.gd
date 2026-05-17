extends CharacterBody2D

enum State { WALKING, WAITING, LEAVING_HAPPY, LEAVING_ANGRY }

var customer_state: State = State.WALKING
var order_data: Dictionary = {}
var patience_total: float = 45.0
var target_position: Vector2 = Vector2.ZERO

@onready var sprite: ColorRect = $Sprite
@onready var patience_bar: ProgressBar = $PatienceBar
@onready var patience_timer: Timer = $PatienceTimer
@onready var name_label: Label = $Label

signal patience_depleted(customer)
signal served(customer)

func _ready() -> void:
	z_index = 10
	$DropZone.add_to_group("customer_drop_zone")
	patience_timer.timeout.connect(_on_patience_timer_timeout)
	patience_depleted.connect(CustomerManager.on_customer_timeout)

func initialize(data: Dictionary) -> void:
	order_data = data
	patience_total = Config.data.base_patience_time
	patience_bar.max_value = patience_total
	patience_bar.value = patience_total
	var recipe_name = data.recipe.display_name if data.has("recipe") else "?"
	name_label.text = "要: " + recipe_name

func _process(delta: float) -> void:
	match customer_state:
		State.WALKING:
			var dir = (target_position - global_position).normalized()
			velocity = dir * 120.0
			if global_position.distance_squared_to(target_position) < 400:
				velocity = Vector2.ZERO
				customer_state = State.WAITING
				patience_timer.start(patience_total)
			move_and_slide()
		State.WAITING:
			patience_bar.value = patience_timer.time_left
			if patience_timer.time_left < patience_total * 0.2:
				sprite.color = Color.RED
			elif patience_timer.time_left < patience_total * 0.5:
				sprite.color = Color.YELLOW
		State.LEAVING_HAPPY, State.LEAVING_ANGRY:
			var exit_pos = Vector2(1200, global_position.y)
			var dir = (exit_pos - global_position).normalized()
			velocity = dir * 150.0
			move_and_slide()
			if global_position.x > 1100:
				queue_free()

func move_to_position(pos: Vector2) -> void:
	target_position = pos
	if customer_state == State.WAITING:
		customer_state = State.WALKING

func _on_patience_timer_timeout() -> void:
	customer_state = State.LEAVING_ANGRY
	patience_depleted.emit(self)

func serve() -> void:
	customer_state = State.LEAVING_HAPPY
	patience_timer.stop()
	served.emit(self)
