extends CharacterBody2D

@export var speed: float = 150
@export var accel: float = 1

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D as AnimatedSprite2D
var current_dir = Vector2.ZERO

func movement(_delta):
	var direction: Vector2 = Input.get_vector("left", "right", "foward", "backward")
	current_dir = direction.normalized()
	velocity.x = move_toward(velocity.x, speed * direction.x, accel)
	velocity.y = move_toward(velocity.y, speed * direction.y, accel)
	move_and_slide()

func _process(delta):
	movement(delta)
	play_anim()

func play_anim():
	if current_dir.y > 0:
		anim_sprite.flip_v = false
		anim_sprite.play("walk_front")
	elif current_dir.y < 0:
		anim_sprite.flip_v = false
		anim_sprite.play("walk_back")
	elif current_dir.x < 0:
		anim_sprite.flip_h = false
		anim_sprite.play("walk_side")
	elif current_dir.x > 0:
		anim_sprite.flip_h = true
		anim_sprite.play("walk_side")
	else:
		anim_sprite.stop()
