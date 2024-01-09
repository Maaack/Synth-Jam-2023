extends PanelContainer

@export var animation_player : AnimationPlayer

func fade_in():
	if not animation_player.is_playing():
		animation_player.play(&"FadeIn")
	else:
		animation_player.play(&"RESET")

func _on_mouse_entered():
	fade_in()

func _on_mouse_exited():
	animation_player.play(&"FadeOut")

func _ready():
	connect(&"mouse_entered", _on_mouse_entered)
	connect(&"mouse_exited", _on_mouse_exited)
