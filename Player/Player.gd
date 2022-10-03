extends KinematicBody2D

const ACCELERATION = 10
const FRICTION = 10
const MAX_SPEED = 100


var velocity = Vector2.ZERO

# Gets the variable from a child node in the scene when the Player node
# is ready. This makes sure that the AnimationPlayer will be loaded before
# setting the variable.
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree

# This variable gets the actual Tree itself so that we can move between our
# different blendspace2Ds using .travel()
onready var animation_state = animation_tree.get("parameters/playback")

func _physics_process(_delta):
	
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
		
	# This if/else handles setting our player move speed. 
	# If a direction is being pressed we will move our player toward it.
	# Else we will start to reduce our player speed towards zero.
	if (input_vector != Vector2.ZERO):
		
		# Set the blend position once we have an input vector from the player
		# so that we don't set the position to 0 as that can cause issues.
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_state.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		
	# Use the velocity = ... part in order to make it
	# so that the player character doesn't wiggle when
	# walking into a corner.
	velocity = move_and_slide(velocity)
