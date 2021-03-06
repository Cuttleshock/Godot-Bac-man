class_name Actor
extends KinematicBody2D


enum Facing { UP, RIGHT, LEFT, DOWN, NONE }

const unit_vectors = {
	Facing.UP: Vector2.UP,
	Facing.RIGHT: Vector2.RIGHT,
	Facing.LEFT: Vector2.LEFT,
	Facing.DOWN: Vector2.DOWN,
	Facing.NONE: Vector2.ZERO,
}


export var speed = 60

var facing = Facing.NONE setget set_facing
var queued_facing = Facing.NONE setget queue_facing
var movement_epsilon = 1
var hurts_player = false
var eats_ghosts = false

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var space_state = get_world_2d().direct_space_state


func _physics_process(delta):
	var frame_speed = speed * delta
	var velocity = frame_speed * unit_vectors[queued_facing]

	if facing != queued_facing:
		if not can_move_in(queued_facing):
			velocity = frame_speed * unit_vectors[facing]
			# We're flush against a wall; check if we can turn soon
			# TODO: un-hardcode the 8s
			var corner = position + 8 * unit_vectors[facing] + 8 * unit_vectors[queued_facing]
			var off_corner = corner + 2 * unit_vectors[queued_facing]
			# collision_layer: walls only
			var ray_result = space_state.intersect_ray(corner, off_corner, [], 1)
			if ray_result:
				# We're nowhere near a turn - flush the queued turn
				queue_facing(facing)
			else:
				# We may have to brake to make it into the turn.
				var ray_2 = space_state.intersect_ray(off_corner, off_corner + velocity, [], 1)
				if ray_2:
					var max_move = off_corner.distance_to(ray_2.position)
					# Seemingly inconsistent ray collision can cause max_move == 0,
					# leading the actor to get stuck far away from a turn
					if max_move > 0:
						velocity = velocity.clamped(max_move)
		else:
			# We can turn to the queued_facing
			set_facing(queued_facing)

	# warning-ignore: RETURN_VALUE_DISCARDED
	move_and_collide(velocity)

	# Modulus is a little awkward because floats, and also less flexible
	if position.x >= screen_width:
		position.x -= screen_width
	elif position.x < 0:
		position.x += screen_width

	if position.y >= screen_height:
		position.y -= screen_height
	elif position.y < 0:
		position.y += screen_height


func reset():
	set_facing(Facing.NONE)
	queue_facing(Facing.NONE)


func set_facing(facing_):
	match facing_:
		Facing.UP:
			$AnimatedSprite.play()
			turn_up()
		Facing.RIGHT:
			$AnimatedSprite.play()
			turn_right()
		Facing.DOWN:
			$AnimatedSprite.play()
			turn_down()
		Facing.LEFT:
			$AnimatedSprite.play()
			turn_left()
		Facing.NONE:
			$AnimatedSprite.stop()
			turn_right()

	facing = facing_


func queue_facing(facing_):
	queued_facing = facing_


func turn_left():
	$AnimatedSprite.rotation = 0
	$AnimatedSprite.flip_h = true


func turn_right():
	$AnimatedSprite.rotation = 0
	$AnimatedSprite.flip_h = false


func turn_up():
	$AnimatedSprite.rotation = -PI/2
	$AnimatedSprite.flip_h = false


func turn_down():
	$AnimatedSprite.rotation = PI/2
	$AnimatedSprite.flip_h = false


func can_move_in(direction : int) -> bool:
	if direction == Facing.NONE:
		return false # true?
	else:
		var velocity = unit_vectors[direction] * movement_epsilon
		var collision = move_and_collide(velocity, true, true, true) # test_only true
		return not collision


func nearest_facing(vec: Vector2):
	if abs(vec.x) >= abs(vec.y):
		if vec.x >= 0:
			return Facing.RIGHT
		else:
			return Facing.LEFT
	else:
		if vec.y >= 0:
			return Facing.DOWN
		else:
			return Facing.UP


func is_opposite_facing(f1, f2):
	return (
		(f1 == Facing.DOWN and f2 == Facing.UP)
		or (f1 == Facing.UP and f2 == Facing.DOWN)
		or (f1 == Facing.LEFT and f2 == Facing.RIGHT)
		or (f1 == Facing.RIGHT and f2 == Facing.LEFT)
	)


func get_left_facing(facing_ : int) -> int:
	match facing_:
		Facing.UP:
			return Facing.LEFT
		Facing.LEFT:
			return Facing.DOWN
		Facing.DOWN:
			return Facing.RIGHT
		Facing.RIGHT:
			return Facing.UP
		_:
			return Facing.LEFT


func get_right_facing(facing_ : int) -> int:
	return get_left_facing(get_left_facing(get_left_facing(facing_)))
