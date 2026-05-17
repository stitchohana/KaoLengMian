extends Node

enum GameState { TITLE, DAY_PREP, DAY_ACTIVE, DAY_END, GAME_OVER }

var game_state: GameState = GameState.TITLE

# 进度
var current_day: int = 0
var total_money: int = 0
var total_score: int = 0

# 当日累计
var daily_money: int = 0
var daily_tips: int = 0
var daily_served: int = 0
var daily_left: int = 0
var daily_mismatch: int = 0

# 升级: upgrade_id -> level
var upgrades: Dictionary = {}

# 当前制作的烤冷面
var current_dish: NoodleDish = null

func _ready() -> void:
    current_dish = NoodleDish.new()

func reset_game() -> void:
    current_day = 0
    total_money = 0
    total_score = 0
    upgrades.clear()
    current_dish.reset()
    game_state = GameState.TITLE

func start_new_day() -> void:
    current_day += 1
    daily_money = 0
    daily_tips = 0
    daily_served = 0
    daily_left = 0
    daily_mismatch = 0
    current_dish.reset()
    game_state = GameState.DAY_ACTIVE

func add_money(amount: int) -> void:
    total_money += amount
    daily_money += amount

func add_tip(amount: int) -> void:
    total_money += amount
    daily_tips += amount

func get_upgrade_level(upgrade_id: String) -> int:
    return upgrades.get(upgrade_id, 0)

func set_upgrade_level(upgrade_id: String, level: int) -> void:
    upgrades[upgrade_id] = level
