extends KinematicBody2D

const ACCELERATION = 500
const FRICTION = ACCELERATION * 10
const MAX_SPEED = 100

enum State {
	MOVE,
	ROLL,
	ATTACK,
}

var current_state = State.MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

# Gets the variable from a child node in the scene when the Player node
# is ready. This makes sure that the AnimationPlayer will be loaded before
# setting the variable.
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree

# This variable gets the actual Tree itself so that we can move between our
# different blendspace2Ds using .travel()
onready var animation_state = animation_tree.get("parameters/playback")

func _ready():
	animation_tree.active = true

func _physics_process(delta):
	
	match current_state:
		State.MOVE:
			move_state(delta)
		State.ROLL:
			roll_state()
		State.ATTACK:
			attack_state()


func move_state(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	
	# This if/else handles setting our player move speed. 
	# If a direction is being pressed we will move our player toward it.
	# Else we will start to reduce our player speed towards zero.
	if (input_vector != Vector2.ZERO):
		
		roll_vector = input_vector
		
		# Set the blend position once we have an input vector from the player
		# so that we don't set the position to 0 as that can cause issues.
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_state.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	# Use the velocity = ... part in order to make it
	# so that the player character doesn't wiggle when
	# walking into a corner.
	move()
	
	if Input.is_action_just_pressed("Roll"):
		current_state = State.ROLL
	
	if Input.is_action_just_pressed("attack"):
		current_state = State.ATTACK
		velocity = Vector2.ZERO
	
func move():
	velocity = move_and_slide(velocity)

func attack_state():
	animation_state.travel("Attack")
	
func attack_animation_finished():
	current_state = State.MOVE
	
func roll_state():
	velocity = roll_vector * MAX_SPEED * 1.5
	move()
	animation_state.travel("Roll")
	
func roll_animation_finished():
	current_state = State.MOVE
	# Prevents microstutter of player movement at the end of a roll
	velocity = velocity * 0.70
