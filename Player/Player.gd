extends KinematicBody2D

const ACCELERATION = 10
const FRICTION = 10
const MAX_SPEED = 100


var velocity = Vector2.ZERO


func _physics_process(_delta):
	
	var inputVector = Vector2.ZERO
	
	inputVector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	inputVector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	inputVector = inputVector.normalized()
		
	# This if/else handles setting our player move speed. 
	# If a direction is being pressed we will move our player toward it.
	# Else we will start to reduce our player speed towards zero.
	if (inputVector != Vector2.ZERO):
		velocity = velocity.move_toward(inputVector * MAX_SPEED, ACCELERATION)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		
	# Use the velocity = ... part in order to make it
	# so that the player character doesn't wiggle when
	# walking into a corner.
	velocity = move_and_slide(velocity)
