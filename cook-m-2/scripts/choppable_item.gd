extends "res://scripts/clickable_item.gd"

@export var clicks_required: int = 3
var _click_count: int = 0

func _can_use() -> bool:
    return _click_count < clicks_required

func try_use() -> void:
    if not _can_click:
        return
    if not _can_use():
        _shake()
        return

    _click_count += 1

    # 视觉反馈：随着点击缩小
    var scale_val = 1.0 - (float(_click_count) / float(clicks_required)) * 0.4
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2(scale_val, scale_val), 0.1)

    if _click_count >= clicks_required:
        # 切碎完成，飞入目标
        _can_click = false
        _fly_to_target()
    else:
        # 还没切完，抖动一下
        _shake()

func _apply_effect() -> void:
    # 由子类实现，或者由连接到的系统处理
    pass

func reset() -> void:
    _click_count = 0
    scale = Vector2.ONE
    _can_click = true
