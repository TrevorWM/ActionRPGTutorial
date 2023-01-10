extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export(int) var ACCELERATION = 300
export(int) var MAX_SPEED = 50
export(int) var FRICTION = 200
export(int) var WANDER_TOLERANCE = 50

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
onready var soft_collision = $SoftCollision
onready var wander_controller = $WanderController
onready var animation_player = $AnimationPlayer

func _ready():
	ai_state = randi()%State.size()

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match ai_state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			update_wander()
		
		State.WANDER:
			seek_player()
			update_wander()
				
			accelerate_towards_point(wander_controller.target_position, delta)
				
			if global_position.distance_to(wander_controller.target_position) <= WANDER_TOLERANCE:
				update_wander()
				
		State.CHASE:
			var player = player_detection_zone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				ai_state = State.IDLE
				
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * 400
		
	velocity = move_and_slide(velocity)

func accelerate_towards_point(point, delta):
	var direction_vector = global_position.direction_to(point)
	velocity = velocity.move_toward(direction_vector * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func update_wander():
	if wander_controller.get_time_left() == 0:
		ai_state = randi()%State.size()
		wander_controller.start_wander_timer(rand_range(1,3))

func seek_player():
	if player_detection_zone.can_see_player():
		ai_state = State.CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)
	knockback = area.knockback_vector * 120

# Example of call down signal up. Created a signal in the stats node to
# let the bat know when it runs out of health. Then we let the bat node
# decided what to do with this information.
func _on_Stats_no_health():
	queue_free()
	var enemy_death_effect = EnemyDeathEffect.instance()
	get_parent().add_child(enemy_death_effect)
	enemy_death_effect.global_position = global_position

func _on_Hurtbox_invincibility_started():
	animation_player.play("Start")

func _on_Hurtbox_invincibility_ended():
	animation_player.play("Stop")
