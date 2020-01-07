extends KinematicBody2D

signal animate
signal player_hurt

const UP = Vector2(0, -1)
const GRAVITY = 35
const WORLD_LIMIT = 1900

export var lives = 3
export var horizontal_speed = 250
export var jump_force = 250 # will be negative when called
export var boost = 400

onready var audio_player : AudioStreamPlayer = get_node("AudioStreamPlayer")

var velocity = Vector2(0, 0)
var grounded = false
var snap_vector = Vector2(0, 32)
var is_hurt = false

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	horizontal_movement()
	jump()
	apply_gravity()
	
	snap_vector = Vector2(0, 32) if grounded else Vector2(0, 0)
	velocity = move_and_slide_with_snap(velocity, snap_vector, UP, true, 2)
	if is_on_floor() and (Input.is_action_just_released("move_left") || Input.is_action_just_released("move_right")):
		velocity.y = 0
	
	check_is_on_floor()
	
	if !is_hurt:
		animate()
	pass

func horizontal_movement():
	if Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
		velocity.x = -horizontal_speed
	elif Input.is_action_pressed("move_right") and !Input.is_action_pressed("move_left"):
		velocity.x = horizontal_speed
	else:
		velocity.x = 0
	pass

func jump():
	if Input.is_action_just_pressed("jump") and grounded:
		audio_player.stream = load("res://SFX/SFX_Jump10.ogg")
		audio_player.play()
		velocity.y = -jump_force
		grounded = false
	pass

func apply_gravity():
	velocity.y += GRAVITY
	
	if position.y > WORLD_LIMIT:
		# do game over
		end_game()
	pass

func end_game():
	get_tree().change_scene("res://Levels/GameOver.tscn")
	pass

func check_is_on_floor():
	if is_on_floor():
		grounded = true
		if is_hurt:
			is_hurt = false
	else:
		grounded = false
	pass

func animate():
	var has_input = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
	emit_signal("animate", velocity, grounded, has_input)
	pass

func hurt():
	is_hurt = true
	position.y -= 1
	audio_player.stream = load("res://SFX/SFX_Hit10.ogg")
	audio_player.play()
#	yield(get_tree(), "idle_frame")
	grounded = false
	velocity.y = -jump_force
	lives -= 1
	emit_signal("player_hurt")
	
	if lives < 1:
		end_game()
	pass

func boost():
	position.y -= 1
	grounded = false
	velocity.y = 0
	velocity.y -= boost
	pass