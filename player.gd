extends CharacterBody2D

signal hit

@export var JUMP_FORCE 				= -130
@export var JUMP_RELEASE_FORCE 		= -70
@export var MAX_SPEED  				= 40
@export var ACCELERATION			= 10
@export var FRICTION				= 10
@export var GRAVITY 				= 4
@export var ADDITIONAL_FALL_GRAVITY = 4
@export var FLOOR_FRICTION_FACTOR   = 0.5
@export var shot_scene : PackedScene

var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	motion_mode = MOTION_MODE_GROUNDED
	#hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	apply_gravity()
	
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")

	if input.x == 0:
		apply_friction()
	else:
		apply_acceleration(input.x)

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_FORCE
	else:
		if Input.is_action_just_released("jump") and velocity.y < JUMP_RELEASE_FORCE:
			velocity.y = JUMP_RELEASE_FORCE
			
		if velocity.y > 0:
			velocity.y += ADDITIONAL_FALL_GRAVITY

	var was_in_air = !is_on_floor()
	move_and_slide()
	var just_landed = was_in_air and is_on_floor()

	handle_anim(input.x, just_landed)
	handle_shooting()


func _on_body_entered(body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)


func start(pos):
	position = pos
	show()
	$AnimatedSprite2D.play()
	$CollisionShape2D.disabled = false

func apply_gravity():
	velocity.y += GRAVITY

func apply_friction():
	var friction = FRICTION * (1.0 if is_on_floor() else FLOOR_FRICTION_FACTOR)
	velocity.x = move_toward(velocity.x, 0, friction)

func apply_acceleration(x_input):
	var acc = ACCELERATION * (1.0 if is_on_floor() else FLOOR_FRICTION_FACTOR)
	velocity.x = move_toward(velocity.x, MAX_SPEED*x_input, acc)

func handle_anim(x_input, just_landed):
	if !is_on_floor():
		$AnimatedSprite2D.animation = "air"
	else:
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.speed_scale = clamp(abs(velocity.x) / MAX_SPEED, 0.2, 1)
			$AnimatedSprite2D.play()
		else:
			$AnimatedSprite2D.animation = "still"
	
	$AnimatedSprite2D.flip_h = x_input < 0
	
	if just_landed:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.frame = 0
	

func handle_shooting():
	if Input.get_action_strength("shoot_right") > 0:
		var shot = shot_scene.instantiate()
		shot.global_position = global_position
		get_parent().add_child(shot)
		
