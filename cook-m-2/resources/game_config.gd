extends Resource
class_name GameConfig

# 每日时间
@export var day_duration_seconds: float = 180.0  # 每天的总时长（秒）

# 烹饪计时
@export var egg_spread_time: float = 2.0  # 鸡蛋摊开所需时间（秒）
@export var sausage_cook_time: float = 3.0  # 烤肠烤熟所需时间（秒）

# 填充系统
@export var onion_max_fill: int = 3  # 最多可添加洋葱碎次数
@export var sauce_max_fill: int = 3  # 最多可添加辣酱次数
@export var fill_item_charges: int = 4  # 食材盒每种食材的初始份数

# 价值计算
@export var min_value_ratio: float = 0.3  # 冷面最低价值占比（无配料时）
@export var fill_weight_onion: float = 0.5  # 洋葱碎对价值的贡献权重
@export var fill_weight_sauce: float = 0.5  # 辣酱对价值的贡献权重
@export var mismatch_penalty: float = 0.5  # 订单不匹配时的价格惩罚系数

# 纸盒
@export var max_boxes: int = 3  # 同时最多可存在的纸盒数量

# 顾客
@export var customers_per_day_base: int = 5  # 每天基础顾客数
@export var customers_per_day_increment: int = 1  # 每天增加的顾客数
@export var base_patience_time: float = 45.0  # 顾客基础耐心时间（秒）
@export var patience_decrease_per_day: float = 1.5  # 每天减少的耐心时间（秒）
@export var first_spawn_delay: float = 6.0  # 第一位顾客的延迟进场时间（秒）
@export var base_spawn_interval: float = 12.0  # 顾客生成间隔（秒）
@export var spawn_interval_decrease: float = 0.5  # 每天减少的生成间隔（秒）
@export var angry_customer_threshold: int = 3  # 顾客愤怒离开的临界天数
@export var recipe_count: int = 3  # 可用食谱数量
@export var walk_speed: float = 120.0  # 顾客走路速度（像素/秒）
@export var leave_speed: float = 150.0  # 顾客离开速度（像素/秒）
@export var arrival_distance: float = 20.0  # 顾客到达位置的判定距离（像素）
@export var exit_position_x: float = 1200.0  # 顾客离开时的目标X坐标
@export var exit_threshold_x: float = 1100.0  # 顾客离开的X阈值，超过即消失

# 交互阈值
@export var cut_clicks_required: int = 5  # 切段所需点击次数
@export var cut_click_timeout: float = 2.0  # 切段点击超时重置时间（秒）
@export var onion_chopp_clicks: int = 3  # 洋葱切碎所需点击次数
@export var swipe_threshold_px: float = 50.0  # 滑动判定最小距离（像素）
@export var click_vs_swipe_threshold_px: float = 30.0  # 点击与滑动的区分阈值（像素）
@export var fly_animation_duration: float = 0.3  # 飞行动画持续时间（秒）
@export var prep_fly_duration: float = 0.8  # 备料飞入食材盒的动画时间（秒）

# 价格
@export var base_price_min: int = 8  # 订单基础价格最小值
@export var base_price_max: int = 15  # 订单基础价格最大值
