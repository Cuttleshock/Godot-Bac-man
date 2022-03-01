extends Node2D


export var player_start = Vector2(0,0)
export var enemy_start = Vector2(0,0)

onready var cell_offset = 0.5 * $Maze.cell_size * Vector2.ONE
onready var astar = AStar2D.new()
onready var map_rect = $Maze.get_used_rect()
onready var space_state = get_world_2d().direct_space_state
onready var pellet_count = get_tree().get_nodes_in_group("pellets").size()


func _ready():
	restart()
	get_tree().call_group("enemies", "set", "player", $Player)

	for x in range(map_rect.position.x, map_rect.end.x):
		for y in range(map_rect.position.y, map_rect.end.y):
			astar.add_point(map_to_id(x, y), map_loc(Vector2(x, y)) + cell_offset)

	for x in range(map_rect.position.x, map_rect.end.x):
		for y in range(map_rect.position.y, map_rect.end.y):
			var world_vec = map_loc(Vector2(x, y)) + cell_offset
			if x < map_rect.end.x - 1:
				var ray_result = space_state.intersect_ray(world_vec, world_vec + $Maze.cell_size * Vector2.RIGHT, [], 1)
				if !ray_result:
					astar.connect_points(map_to_id(x, y), map_to_id(x + 1, y))
			if y < map_rect.end.y - 1:
				var ray_result = space_state.intersect_ray(world_vec, world_vec + $Maze.cell_size * Vector2.DOWN, [], 1)
				if !ray_result:
					astar.connect_points(map_to_id(x, y), map_to_id(x, y + 1))


func restart():
	$Player.position = map_loc(player_start) + cell_offset
	$Player.reset()
	$Enemy.position = map_loc(enemy_start) + cell_offset
	$Enemy.reset()


func map_loc(v : Vector2):
	return $Maze.to_global($Maze.map_to_world(v))


func map_to_id(x, y):
	return x + map_rect.end.x * y


func _on_Enemy_request_path(enemy: Enemy, target: Vector2):
	var from_id = astar.get_closest_point(enemy.position)
	var to_id = astar.get_closest_point(target)
	var path = astar.get_point_path(from_id, to_id)
	enemy.set("nav_path", path)


func _on_Player_life_lost():
	Global.lose_life()
	restart()


func decrement_pellet_count():
	pellet_count -= 1
	if pellet_count <= 0:
		Global.load_next_scene()
