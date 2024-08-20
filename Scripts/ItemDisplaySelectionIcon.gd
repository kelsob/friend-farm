extends Node2D

onready var arrow_left = $Icon/ArrowLeft
onready var arrow_right = $Icon/ArrowRight
onready var arrow_up = $Icon/ArrowUp
onready var arrow_down = $Icon/ArrowDown
onready var anim = $Icon/AnimationPlayer


func show_all_arrows():
	arrow_left.show()
	arrow_right.show()
	arrow_up.show()
	arrow_down.show()

func hide_all_arrows():
	arrow_left.hide()
	arrow_right.hide()
	arrow_up.hide()
	arrow_down.hide()

func show_horizontal_arrows():
	arrow_left.show()
	arrow_right.show()

func hide_horizontal_arrows():
	arrow_left.hide()
	arrow_right.hide()

func show_vertical_arrows():
	arrow_up.show()
	arrow_down.show()

func hide_vertical_arrows():
	arrow_up.hide()
	arrow_down.hide()

func show_left():
	arrow_left.show()

func hide_left():
	arrow_left.hide()

func show_right():
	arrow_right.show()

func hide_right():
	arrow_right.hide()

func show_up():
	arrow_up.show()

func hide_up():
	arrow_up.hide()

func show_down():
	arrow_down.show()

func hide_down():
	arrow_down.hide()
