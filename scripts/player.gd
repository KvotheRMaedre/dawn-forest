extends CharacterBody2D
class_name Player

@export var player_texture : Sprite2D
@export var speed : int
@export var jump_speed : int
@export var player_gravity : int

var jump_count : int = 0
var landing : bool = false
var is_attacking : bool = false
var is_defending : bool = false
var is_crouching : bool = false

var can_track_input : bool = true

func _physics_process(delta: float) -> void:
	horizontal_movement_env()
	vertical_movement_env()
	actions_env()
	gravity(delta)
	move_and_slide()
	player_texture.animate(velocity)

func horizontal_movement_env() -> void:
	var input_direction : float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if !can_track_input || is_attacking:
		velocity.x = 0
		return
		
	velocity.x = input_direction * speed
	
func vertical_movement_env() -> void:
	if is_on_floor():
		jump_count = 0
	if Input.is_action_just_pressed("ui_select") and jump_count < 2 && can_track_input && !is_attacking:
		jump_count += 1
		velocity.y = jump_speed

func gravity(delta : float) -> void:
	velocity.y += delta * player_gravity
	if velocity.y >= player_gravity:
		velocity.y = player_gravity

func actions_env() -> void:
	attack()
	crouch()
	defend()

func attack() -> void:
	var attack_condition : bool = !is_attacking && !is_crouching && !is_defending
	if Input.is_action_just_pressed("attack") && attack_condition and is_on_floor():
		is_attacking = true
		player_texture.normal_attack = true

func crouch() -> void:
	if Input.is_action_pressed("crouch") && is_on_floor() && !is_defending:
		is_crouching = true
		can_track_input = false
	elif !is_defending:
		is_crouching = false
		can_track_input = true
		player_texture.is_crouch_off = true

func defend() -> void:
	if Input.is_action_pressed("defense") && is_on_floor() && !is_crouching:
		is_defending = true
		can_track_input = false
	elif !is_crouching:
		is_defending = false
		can_track_input = true
		player_texture.is_shield_off = true
