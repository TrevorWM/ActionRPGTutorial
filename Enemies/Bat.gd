extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export(int) var ACCELERATION = 300
export(int) var MAX_SPEED = 50
export(int) var FRICTION = 200

enum State {
	IDLE,
	WANDER,
	CHASE,
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var ai_state = State.CHASE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var player_detection_zone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match ai_state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		State.WANDER:
			pass
		State.CHASE:
			var player = player_detection_zone.player
			if player != null:
				var direction_vector = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction_vector * MAX_SPEED, ACCELERATION * delta)
			else:
				ai_state = State.IDLE
			sprite.flip_h = velocity.x < 0
				
	
	velocity = move_and_slide(velocity)

func seek_player():
	if player_detection_zone.can_see_player():
		ai_state = State.CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.create_hit_effect()
	knockback = area.knockback_vector * 120

# Example of call down signal up. Created a signal in the stats node to
# let the bat know when it runs out of health. Then we let the bat node
# decided what to do with this information.
func _on_Stats_no_health():
	queue_free()
	var enemy_death_effect = EnemyDeathEffect.instance()
	get_parent().add_child(enemy_death_effect)
	enemy_death_effect.global_position = global_position
