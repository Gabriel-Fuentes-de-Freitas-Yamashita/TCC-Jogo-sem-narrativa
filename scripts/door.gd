extends Area2D

enum DoorState {
	closed,
	opened,
	opening
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var door_id: String = ""
@export var next_level = ""

var status: DoorState
var can_interact = false

func _ready():
	if GameState.is_door_open(door_id):
		status = DoorState.opened
		anim.play("opened")
	else:
		status = DoorState.closed
		anim.play("closed")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && can_interact == true:
		match status:
			DoorState.closed:
				status = DoorState.opening
				anim.play("opening")
				anim.connect("animation_finished", Callable(self, "on_door_open_finished"), CONNECT_ONE_SHOT)
			DoorState.opened:
				GameState.open_door(door_id)
				call_deferred("load_next_scene")
			_:
				pass


func on_door_open_finished():
	if anim.animation == "opening":
		status = DoorState.opened

func load_next_scene():
	get_tree().change_scene_to_file("res://scenes/" + next_level + ".tscn")


func _on_body_entered(_body: Node2D) -> void:
	print("Entrou")
	can_interact = true

func _on_body_exited(_body: Node2D) -> void:
	can_interact = false


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "opening":
		status = DoorState.opened
		anim.disconnect("animation_finished", _on_animated_sprite_2d_animation_finished)
