extends RigidBody3D

# Settings for how the player moves
const BASE_MOVEMENT_FORCE = 45.0  
const SPRINT_MULTIPLIER = 1.8 
const JUMP_VELOCITY = 12.0        
const MAX_JUMPS = 2            
const HORIZONTAL_DAMPING = 8.0    

# Fast fall stuff
const EXTRA_FALL_SPEED = 30.0 

# Double jump tracker
var jump_count = 0

# Link to the raycast under the player
@onready var ground_cast: RayCast3D = $GroundCast

func _ready() -> void:
	# Lock rotation so the player doesn't tip over
	axis_lock_angular_x = true
	axis_lock_angular_y = true 
	axis_lock_angular_z = true
	
	# Make a new material with no friction so we don't stick to walls
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = 0.0

func _physics_process(delta: float) -> void:
	# Reset jumps if we are touching the ground
	if ground_cast.is_colliding():
		jump_count = 0 

	# Check if we are sprinting
	var current_force = BASE_MOVEMENT_FORCE
	if Input.is_action_pressed("sprint"):
		current_force *= SPRINT_MULTIPLIER

	# Get WASD inputs
	var input_dir := Vector3.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.z = Input.get_axis("move_forward", "move_backward")
	
	# If moving, push the player
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		apply_central_force(input_dir * current_force)
	else:
		# If not pushing buttons, slow down manually so we don't slide forever
		var vel = linear_velocity
		vel.x = move_toward(vel.x, 0, HORIZONTAL_DAMPING * delta * 10)
		vel.z = move_toward(vel.z, 0, HORIZONTAL_DAMPING * delta * 10)
		linear_velocity = vel

	# Jumping logic
	if Input.is_action_just_pressed("jump"):
		if jump_count < MAX_JUMPS:
			linear_velocity.y = JUMP_VELOCITY
			jump_count += 1

	# Make falling faster when moving downwards
	if linear_velocity.y < 0:
		linear_velocity.y -= EXTRA_FALL_SPEED * delta
