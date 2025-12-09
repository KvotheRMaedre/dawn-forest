extends Sprite2D
class_name PlayerTexture

@export var player: CharacterBody2D
@export var animation : AnimationPlayer

@onready var wall_ray: RayCast2D = $"../WallRay"
@onready var attack_collision: CollisionShape2D = $"../AttackArea/Collision"

var normal_attack : bool = false
var suffix : String = "_right"
var is_shield_off : bool = false
var is_crouch_off : bool = false

func animate(direction : Vector2) -> void:
	verify_position(direction)
	if player.dead || player.on_hit:
		hit_behavior()
	elif player.is_attacking || player.is_defending || player.is_crouching || player.is_sliding:
		action_behavior()
	elif direction.y != 0:
		vertical_behavior(direction)
	elif player.landing == true and !player.is_on_ceiling():
		animation.play("landing")
		if player.jump_count > 1:
			player.set_physics_process(false)
	else:
		horizontal_behavior(direction)

func verify_position(direction : Vector2) -> void:
	if direction.x > 0:
		flip_h = false
		suffix = "_right"
		wall_ray.rotation_degrees = 0
		player.direction = -1
	elif direction.x < 0:
		wall_ray.rotation_degrees = 180
		flip_h = true
		suffix = "_left"
		player.direction = 1

func hit_behavior() -> void:
	player.set_physics_process(false)
	attack_collision.set_deferred("disabled", true)
	if player.dead:
		animation.play("death")
	elif player.on_hit:
		animation.play("hit")

func action_behavior() -> void:
	if player.next_to_wall():
		animation.play("wall_slide")
	elif player.is_attacking && normal_attack:
		animation.play("attack" + suffix)
	elif player.is_defending and is_shield_off:
		animation.play("shield")
		is_shield_off = false
	elif player.is_crouching and is_crouch_off:
		animation.play("crouch")
		is_crouch_off = false
	

func horizontal_behavior(direction : Vector2) -> void:
	if direction.x != 0:
		animation.play("run")
	else:
		animation.play("idle")

func vertical_behavior(direction : Vector2) -> void:
	if direction.y > 0:
		player.landing = true
		animation.play("fall")
	elif direction.y < 0:
		animation.play("jump")

func _on_animation_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"landing":
			player.landing = false
			player.set_physics_process(true)
		"attack_left":
			normal_attack = false
			player.is_attacking = false
		"attack_right":
			normal_attack = false
			player.is_attacking = false
		"hit":
			player.on_hit = false
			player.set_physics_process(true)
			
			if player.is_defending:
				animation.play("shield")
				
			if player.is_crouching:
				animation.play("crouch")
