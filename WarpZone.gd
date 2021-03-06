extends Node2D


signal Actor_entered_warp (actor, destination)


# not working yet - does absolute position in the original scene
onready var left_zone_target : Vector2 = $RightZone.get_global_position()
onready var right_zone_target : Vector2 = $LeftZone.get_global_position()


func get_zone_locations() -> PoolVector2Array:
	return PoolVector2Array([
		$LeftZone/CollisionShape2D.get_global_position(),
		$RightZone/CollisionShape2D.get_global_position(),
	])


func _on_LeftZone_area_entered(area : Area2D):
	emit_signal("Actor_entered_warp", area.owner, left_zone_target)


func _on_RightZone_area_entered(area : Area2D):
	emit_signal("Actor_entered_warp", area.owner, right_zone_target)
