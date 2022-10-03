extends KinematicBody2D

const ACCELERATION = 10
const FRICTION = 10
const MAX_SPEED = 100


var velocity = Vector2.ZERO

# Gets the variable from a child node in the scene when the Player node
# is ready. This makes sure that the AnimationPlayer will be loaded before
# setting the variable.
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree

# This variable gets the actual Tree itself so that we can move between our
# different blendspace2Ds using .travel()
onready var animationState = animationTree.get("parameters/playback")

func _physics_process(_delta):
	
	var inputVector = Vector2.ZERO
	
	inputVector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	inputVector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	inputVector = inputVector.normalized()
		
	# This if/else handles setting our player move speed. 
	# If a direction is being pressed we will move our player toward it.
	# Else we will start to reduce our player speed towards zero.
	if (inputVector != Vector2.ZERO):
		
		# Set the blend position once we have an input vector from the player
		# so that we don't set the position to 0 as that can cause issues.
		animationTree.set("parameters/Idle/blend_position", inputVector)
		animationTree.set("parameters/Run/blend_position", inputVector)
		animationState.travel("Run")
		velocity = velocity.move_toward(inputVector * MAX_SPEED, ACCELERATION)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		
	# Use the velocity = ... part in order to make it
	# so that the player character doesn't wiggle when
	# walking into a corner.
	velocity = move_and_slide(velocity)
