extends Node2D

@export var grill_path: NodePath = NodePath()
var _grill: Node2D = null

# 食材盒中显示的物品引用
var _egg_item: Area2D = null
var _onion_item: Area2D = null
var _chili_item: Area2D = null

func _ready() -> void:
    if grill_path:
        _grill = get_node(grill_path)

func add_item(item_id: String) -> void:
    match item_id:
        "egg":
            if _egg_item:
                _egg_item.show()
        "onion":
            if _onion_item:
                _onion_item.show()
        "chili":
            if _chili_item:
                _chili_item.show()

func remove_item(item_id: String) -> void:
    match item_id:
        "egg":
            if _egg_item:
                _egg_item.hide()
        "onion":
            if _onion_item:
                _onion_item.hide()
        "chili":
            if _chili_item:
                _chili_item.hide()

func has_item(item_id: String) -> bool:
    match item_id:
        "egg": return _egg_item and _egg_item.visible
        "onion": return _onion_item and _onion_item.visible
        "chili": return _chili_item and _chili_item.visible
    return false

func clear_all() -> void:
    for id in ["egg", "onion", "chili"]:
        remove_item(id)

func register_item(item_id: String, node: Area2D) -> void:
    match item_id:
        "egg": _egg_item = node
        "onion": _onion_item = node
        "chili": _chili_item = node
    if node:
        node.hide()
