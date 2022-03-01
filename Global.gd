extends Node


const scene_order = [
	"TitleScreen",
	"levels/level_test",
	"GameOver",
]

var player_lives = 3 setget set_player_lives
var score = 0 setget set_score
var current_scene_index = 0

onready var root = get_tree().get_root()


func load_next_scene():
	current_scene_index += 1
	assert(
			current_scene_index < scene_order.size(),
			"Fell off the end of scene_order"
	)
	# warning-ignore: RETURN_VALUE_DISCARDED
	get_tree().change_scene("res://%s.tscn" % scene_order[current_scene_index])


func end_game():
	# warning-ignore: RETURN_VALUE_DISCARDED
	get_tree().change_scene("res://GameOver.tscn")


func reset_game():
	current_scene_index = -1
	load_next_scene()


func lose_life():
	if player_lives <= 0:
		end_game()
	else:
		self.player_lives -= 1


func update_hud():
	get_tree().call_group("HUD", "update_label_text")


func set_score(score_):
	score = score_
	update_hud()


func set_player_lives(lives_):
	player_lives = lives_
	update_hud()