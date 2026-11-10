extends RigidBody3D

# Movement configuration variables
const BASE_MOVEMENT_FORCE = 1200.0
const SPRINT_MULTIPLIER = 1.8 
const JUMP_VELOCITY = 6.0
const MAX_JUMPS = 2            

# FAST FALL CONFIGURATION
const EXTRA_FALL_SPEED = 20.0 

# Track current jump count
var jump_count = 0

# Get a reference to your floor detection raycast
@onready var ground_cast: RayCast3D = $GroundCast

func _ready() -> void:
	# Keep the character standing upright
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	
	# SMOOTH LANDING FIX: 
	# Reduces the physics body's friction so it doesn't stick to the floor when landing
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
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backward")
	apply_central_force(input * current_force * delta)
	
	# 3. Handle Jump Input (Preserving your specific input map string)
	if Input.is_action_just_pressed("jump "):
		if jump_count < MAX_JUMPS:
			linear_velocity.y = JUMP_VELOCITY
			jump_count += 1

	# 4. Instant Fast Fall Force
	if linear_velocity.y < 0:
		linear_velocity.y -= EXTRA_FALL_SPEED * delta
