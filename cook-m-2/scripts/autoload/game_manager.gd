extends Node

signal day_started(day_number: int)
signal day_ended(day_number: int, stats: Dictionary)
signal game_over(final_stats: Dictionary)
signal customer_left_angry(count: int)
signal timeout()

var _elapsed_time: float = 0.0
var _day_active: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if not _day_active:
		return
	_elapsed_time += delta
	if _elapsed_time >= Config.data.day_duration_seconds:
		_day_active = false
		timeout.emit()
		end_day()

func start_day() -> void:
	Session.start_new_day()
	_elapsed_time = 0.0
	_day_active = true
	day_started.emit(Session.current_day)

func add_income(value: int, is_tip: bool = false) -> void:
	if is_tip:
		Session.add_tip(value)
	else:
		Session.add_money(value)

func on_customer_left_angry() -> void:
	Session.daily_left += 1
	customer_left_angry.emit(Session.daily_left)
	if Session.daily_left >= Config.data.angry_customer_threshold:
		end_game()

func end_day() -> void:
	_day_active = false
	Session.game_state = Session.GameState.DAY_END
	var stats = {
		"served": Session.daily_served,
		"left": Session.daily_left,
		"mismatch": Session.daily_mismatch,
		"money": Session.daily_money,
		"tips": Session.daily_tips,
		"total": Session.total_money,
		"day": Session.current_day,
	}
	day_ended.emit(Session.current_day, stats)

func end_game() -> void:
	_day_active = false
	Session.game_state = Session.GameState.GAME_OVER
	var stats = {
		"total_money": Session.total_money,
		"total_score": Session.total_score,
		"days_survived": Session.current_day,
	}
	game_over.emit(stats)
