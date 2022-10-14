extends KinematicBody2D

export var gravity := 4500.0
export var walkingSpeed = 55.0

const DIR_UP := Vector2.UP

var _direction := Vector2.RIGHT
var _velocity := Vector2.ZERO

func _ready():
	pass

func _physics_process(delta):
	
	if _direction == Vector2.RIGHT:
		$Sprite.scale.x = 1
	else:
		$Sprite.scale.x = -1
	
	if is_on_wall():
		_direction = -_direction
	
	
	_velocity = _direction * walkingSpeed
	_velocity.y += gravity * delta
	_velocity = move_and_slide(_velocity, DIR_UP)
	
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision and collision.collider.name == "PlayerBody":
			if collision.collider.has_method("takeDamage"):
				collision.collider.takeDamage()
