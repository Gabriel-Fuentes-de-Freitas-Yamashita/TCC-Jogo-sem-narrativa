extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	dead
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var reload_timer: Timer = $ReloadTimer

const JUMP_VELOCITY = -300.0

var jump_count = 0
@export var max_jump_count = 2
@export var max_speed = 120.0
@export var acceleration = 400
@export var deceleration = 400
var direction = 0
var status: PlayerState

func _ready() -> void:
	go_to_idle_state()

# verificar estado do player
func _physics_process(delta: float) -> void:
	
	if not is_on_floor() && status != PlayerState.dead:
		velocity += get_gravity() * delta
	
	match status:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.dead:
			dead_state(delta)
	move_and_slide()
	
# transição de estados
func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")
	
func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")

func go_to_dead_state():
	status = PlayerState.dead
	anim.play("dead")
	velocity.y = 50
	velocity.x = 0
	reload_timer.start()
	
# estados do player
func idle_state(delta):
	move(delta)
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if velocity.x != 0:
		go_to_walk_state()
		return
		
func walk_state(delta):
	move(delta)
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if velocity.x == 0:
		go_to_idle_state()
		return
	
	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return
		
func jump_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	
	if velocity.y > 0:
		go_to_fall_state()

func fall_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func dead_state(_delta):
	pass

func move(delta):
	update_direction()
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
		velocity.x = direction * max_speed
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func update_direction():
	direction = Input.get_axis("left", "right")
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

func can_jump() -> bool:
	return jump_count < max_jump_count
	
func _on_hitbox_area_entered(area: Area2D) -> void:
	if status == PlayerState.dead:
		return
		
	if area.is_in_group("LethalArea"):
		hit_lethal_area()

func hit_lethal_area():
	go_to_dead_state()
	
func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()
