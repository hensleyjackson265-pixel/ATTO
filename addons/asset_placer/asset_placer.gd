extends RigidBody3D

# Movement configuration variables
const BASE_MOVEMENT_FORCE = 45.0  
const SPRINT_MULTIPLIER = 1.8 
const JUMP_VELOCITY = 12.0        
const MAX_JUMPS = 2            
const HORIZONTAL_DAMPING = 8.0    

# FAST FALL CONFIGURATION
const EXTRA_FALL_SPEED = 30.0 

# Track current jump count
var jump_count = 0

# Get a reference to your floor detection raycast
@onready var ground_cast: RayCast3D = $GroundCast

func _ready() -> void:
	# Keep the character standing upright
	axis_lock_angular_x = true
	axis_lock_angular_y = true 
	axis_lock_angular_z = true
	
	# SMOOTH LANDING FIX: Ensure physics body does not stick to floors or walls
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = 0.0
	physics_material_override.rough = false

func _physics_process(delta: float) -> void:
	# --- GROUND CHECK REFRESH ---
	if ground_cast.is_colliding():
		jump_count = 0 

	# 1. Determine current movement force based on Sprint input
	var current_force = BASE_MOVEMENT_FORCE
	if Input.is_action_pressed("sprint"):
		current_force *= SPRINT_MULTIPLIER

	# 2. Handle Horizontal Movement
	var input_dir := Vector3.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.z = Input.get_axis("move_forward", "move_backward")
	
	if input_dir.length() > 0:
		# Normalize input so diagonals don't make you speed up
		input_dir = input_dir.normalized()
		
		# Apply movement force
		apply_central_force(input_dir * current_force)
		
		# Turn off horizontal damping while pushing controls
		linear_damp_mode = RigidBody3D.DAMP_MODE_COMBINE
		linear_damp = 0.0
	else:
		# Stop instantly when you let go of the keys
		linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
		var vel = linear_velocity
		vel.x = move_toward(vel.x, 0, HORIZONTAL_DAMPING * delta * 10)
		vel.z = move_toward(vel.z, 0, HORIZONTAL_DAMPING * delta * 10)
		linear_velocity = vel

	# 3. Handle Jump Input (Cleaned up trailing space check)
	if Input.is_action_just_pressed("jump"):
		if jump_count < MAX_JUMPS:
			linear_velocity.y = JUMP_VELOCITY
			jump_count += 1

	# 4. Instant Fast Fall Force
	if linear_velocity.y < 0:
		linear_velocity.y -= EXTRA_FALL_SPEED * delta
