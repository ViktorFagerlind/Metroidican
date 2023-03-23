extends Area2D

@export var SPEED = 100

var direciton = Vector2.ZERO

func set_direction(new_direction):
	direciton = new_direction.normalised()
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
