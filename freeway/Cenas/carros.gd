extends RigidBody2D

@export var speed: float = 450.0
@export var move_left: bool = false

func _ready():
	var tipos_carros = $Animacao.sprite_frames.get_animation_names()
	var carro = tipos_carros[randi_range(0, tipos_carros.size() - 1)]
	$Animacao.animation = carro

	# define direção
	var dir = -1.0 if move_left else 1.0
	linear_velocity = Vector2(speed * dir, 0)

	$Animacao.flip_h = false
	$Animacao.flip_v = move_left

func _on_notificador_screen_exited():
	queue_free()
