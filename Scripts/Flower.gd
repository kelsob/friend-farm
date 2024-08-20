extends Node2D


export (int) var flower_type = 0
export (int) var flower_color = 0

var rng = RandomNumberGenerator.new()

onready var sprite = $Sprite

func _ready():
	sprite.texture = load("res://Assets/Flowers/flower" + String(flower_type) + String(flower_color) + ".png")

func advance_day():
	pass
