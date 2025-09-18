extends Node

const cena_carros = preload("res://Cenas/carros.tscn")
var pistas_rapidas_y = [104, 272, 488]
var pistas_lentas_y  = [160, 216, 324, 384, 438, 544, 600]
var score = 0

var screen_w: float
var direcao_por_pista := {}

@onready var game_timer := $GameTimer
@onready var timer_label := $HUD/TimerLabel   
var player_speed_inicial: float

func _ready():
	$HUD/Placar.text = str(score)
	$HUD/Mensagem.text = ""
	$HUD/Button.hide()
	$AudioTema.play()
	randomize()

	screen_w = get_viewport().get_visible_rect().size.x
	player_speed_inicial = $Player.speed

	
	_update_timer_text()                  

	var todas_pistas := pistas_rapidas_y.duplicate()
	todas_pistas.append_array(pistas_lentas_y)
	todas_pistas.sort()

	for i in range(todas_pistas.size()):
		var y := float(todas_pistas[i])
		var going_left := (i % 2 == 1)
		direcao_por_pista[y] = going_left

func _process(delta: float) -> void:
	_update_timer_text()                   

func _on_timer_carros_rapidos_timeout():
	var idx = randi_range(0, pistas_rapidas_y.size() - 1)
	var pista_y = float(pistas_rapidas_y[idx])
	var going_left = direcao_por_pista[pista_y]
	_spawn_car(pista_y, going_left, 700, 710)

func _on_timer_carros_lentos_timeout():
	var idx = randi_range(0, pistas_lentas_y.size() - 1)
	var pista_y = float(pistas_lentas_y[idx])
	var going_left = direcao_por_pista[pista_y]
	_spawn_car(pista_y, going_left, 300, 310)

func _spawn_car(pista_y: float, going_left: bool, vel_min: int, vel_max: int) -> void:
	var carro = cena_carros.instantiate()
	carro.move_left = going_left
	carro.speed = float(randi_range(vel_min, vel_max))

	if going_left:
		carro.position = Vector2(screen_w + 10.0, pista_y)
	else:
		carro.position = Vector2(-10.0, pista_y)

	add_child(carro)

func _on_player_pontua():
	if score <= 1:
		score += 1
		$HUD/Placar.text = str(score)
		$AudioPonto.play()
		$Player.position = $Player.posicao_inicial

	if score == 1:
		$HUD/Mensagem.text = "Você venceu!"
		$HUD/Mensagem.show()
		$HUD/Button.show()
		$TimerCarrosRapidos.stop()
		$TimerCarrosLentos.stop()
		$AudioTema.stop()
		$AudioVitoria.play()
		$Player.speed = 0
		game_timer.stop()
		_update_timer_text()                

func _on_hud_reinicia():
	score = 0
	$HUD/Mensagem.hide()
	$HUD/Placar.text = str(score)
	$HUD/Button.hide()
	$TimerCarrosRapidos.start()
	$TimerCarrosLentos.start()
	$AudioTema.play()
	$Player.speed = player_speed_inicial
	game_timer.start(15.0)
	_update_timer_text()                   

func _on_game_timer_timeout():
	$TimerCarrosRapidos.stop()
	$TimerCarrosLentos.stop()
	$AudioTema.stop()
	$Player.speed = 0
	$HUD/Mensagem.text = "Tempo esgotado!"
	$HUD/Mensagem.show()
	$HUD/Button.show()
	_update_timer_text()                     

func _update_timer_text() -> void:
	var t := 0.0
	if not game_timer.is_stopped():
		t = max(game_timer.time_left, 0.0)
	timer_label.text = _format_mm_ss(t)

func _format_mm_ss(t: float) -> String:
	var total := int(round(t))
	var m := total / 60
	var s := total % 60
	return str(m).pad_zeros(2) + ":" + str(s).pad_zeros(2)
