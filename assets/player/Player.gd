extends KinematicBody2D

export var speed := 120
export var maximum_jumps := 2
export var double_jump_strength := 1200.0
export var jump_strength := 1200.0
export var gravity := 4500.0

export var maxHealth: int = 3

var _currentHealth: int = maxHealth
var _declaredDead: bool = false

const DIR_UP := Vector2.UP

signal double_jumped

var _position: Vector2
var _lastDamage: int
var _velocity := Vector2.ZERO
var _jumps_made := 0

func _ready():
	_position = position
	Engine.set_target_fps(60)
	_lastDamage = OS.get_unix_time()

func _process(delta):
	$CanvasLayer/HUD/Label.text = "HEALTH " + str(_currentHealth) + "/" + str(maxHealth)


func _physics_process(delta) -> void:
	shouldRespawn()
	
	if _declaredDead:
		$".".rotation_degrees = 90
		return
	
	walking(delta)
	jumping()


func _on_KinematicBody2D_double_jumped():
	print("I have double jumped")


func jumping() -> void:
	var is_falling := _velocity.y > 0.0 and not is_on_floor()
	var is_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	var is_double_jumping := Input.is_action_just_pressed("jump") and is_falling
	var is_jump_cancelled := Input.is_action_just_released("jump") and _velocity.y < 0.0
	var is_idling := is_on_floor() and is_zero_approx(_velocity.x)
	var is_running := is_on_floor() and not is_zero_approx(_velocity.x)
	
	if is_jumping:
		_jumps_made += 1
		_velocity.y = -jump_strength
	elif is_double_jumping:
		_jumps_made += 1
		if _jumps_made <= maximum_jumps:
			emit_signal("double_jumped")
			_velocity.y = -double_jump_strength
	elif is_jump_cancelled:
		_velocity.y = 0.0
	elif is_idling or is_running:
		_jumps_made = 0


func walking(delta) -> void:
	var horizontal_direction = (
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	)
	
	_velocity.x = horizontal_direction * speed
	_velocity.y += gravity * delta
	_velocity = move_and_slide(_velocity, DIR_UP)


func takeDamage() -> void:
	if _declaredDead:
		return
	
	# Timeout on damage so we don't instantly get killed.
	var now = OS.get_unix_time()
	var diff = now - _lastDamage
	if diff < 2:
		return
	
	_currentHealth -= 1
	_lastDamage = now
	
	if _currentHealth < 1:
		die()

func shouldRespawn() -> void:
	if Input.is_action_just_pressed("jump") and _declaredDead:
		$".".rotation_degrees = 0
		_declaredDead = false
		$Camera2D/Polygon2D.color = Color(0, 0, 0, 0.0)
		_currentHealth = maxHealth
		position = _position
		print("I have respawned!")


func die():
	$Camera2D/Polygon2D.color = Color(0, 0, 0, 0.6)
	_declaredDead = true
	print("I have died!")
