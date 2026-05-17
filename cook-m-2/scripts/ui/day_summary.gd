extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var stats_label: Label = $Panel/VBoxContainer/StatsLabel
@onready var next_day_btn: Button = $Panel/VBoxContainer/NextDayButton

func _ready() -> void:
	hide()
	next_day_btn.pressed.connect(_on_next_day)
	GameManager.day_ended.connect(_on_day_ended)
	GameManager.game_over.connect(_on_game_over)

func _on_day_ended(_day: int, stats: Dictionary) -> void:
	show()
	stats_label.text = "Day %d 完成!\n\n服务: %d 位\n离开: %d 位\n收入: $%d\n总计: $%d" % [
		stats.day, stats.served, stats.left, stats.money, stats.total
	]
	next_day_btn.show()
	next_day_btn.text = "下一天"

func _on_game_over(stats: Dictionary) -> void:
	show()
	stats_label.text = "游戏结束!\n\n存活: %d 天\n总收入: $%d" % [
		stats.days_survived, stats.total_money
	]
	next_day_btn.show()
	next_day_btn.text = "重新开始"

func _on_next_day() -> void:
	hide()
	var ses = Session
	if ses.game_state == ses.GameState.GAME_OVER:
		ses.reset_game()
		GameManager.start_day()
	else:
		GameManager.start_day()
