extends Resource
class_name GameConfig

# 每日时间
@export var day_duration_seconds: float = 180.0

# 烹饪计时
@export var egg_spread_time: float = 2.0
@export var sausage_cook_time: float = 3.0

# 填充系统
@export var onion_max_fill: int = 3
@export var sauce_max_fill: int = 3

# 价值计算
@export var min_value_ratio: float = 0.3
@export var fill_weight_onion: float = 0.5
@export var fill_weight_sauce: float = 0.5
@export var mismatch_penalty: float = 0.5

# 纸盒
@export var max_boxes: int = 3

# 顾客
@export var customers_per_day_base: int = 5
@export var customers_per_day_increment: int = 1
@export var base_patience_time: float = 45.0
@export var patience_decrease_per_day: float = 1.5
@export var base_spawn_interval: float = 12.0
@export var spawn_interval_decrease: float = 0.5
@export var angry_customer_threshold: int = 3

# 交互阈值
@export var cut_clicks_required: int = 5
@export var swipe_threshold_px: float = 50.0
@export var click_vs_swipe_threshold_px: float = 30.0
@export var fly_animation_duration: float = 0.3

# 价格
@export var base_price_min: int = 8
@export var base_price_max: int = 15
