extends Node

var data: GameConfig

func _ready() -> void:
    data = ResourceLoader.load("res://resources/game_config.tres") as GameConfig
