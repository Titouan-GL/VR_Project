extends RigidBody3D

class_name SpaceShip

@export var movement_joystick: XRToolsInteractableJoystick
@export var rotation_joystick: XRToolsInteractableJoystick
@export var world: World
@export var crosshair: Node3D
@export var target: Node3D
@export var ik: IKModifier3D
@export var gunL: Gun
@export var gunR: Gun

var thruster_strength: float = 1000000
var rotation_speed: float = 1000
var camera: Camera3D = null
var target_enemy: Hostile = null

func _ready():
	crosshair.visible = false
	camera = get_viewport().get_camera_3d()
	
func shoot():
	gunL.target = target_enemy
	gunR.target = target_enemy
	gunL.shoot()
	gunR.shoot()

func find_target_enemy() -> Hostile:
	if target_enemy == null:
		for e in world.enemies:
			if transform.basis.z.dot(e.global_position) < 0.1:
				return e
	return null


func update_target_enemy():
	if target_enemy == null or transform.basis.z.dot(target_enemy.global_position) > 0:
		target_enemy = find_target_enemy()
		crosshair.visible = target_enemy != null
		ik.active = false
	if target_enemy != null:
		crosshair.global_position = camera.global_position+(target_enemy.global_position - camera.global_position).normalized()*1
		crosshair.look_at(target_enemy.global_position)
		target.global_position = target_enemy.global_position
		ik.active = true
	
func _process(delta: float) -> void:
	shoot()
	var movementVector: Vector3 = Vector3(movement_joystick.joystick_x_position, 0, movement_joystick.joystick_y_position)
	var rotationVector: Vector3 = Vector3(rotation_joystick.joystick_y_position, -rotation_joystick.joystick_x_position, 0)
	if(movementVector.length() > 0.1):
		apply_force(global_transform.basis*movementVector*thruster_strength*delta)
	if(rotationVector.length() > 0.1):
		apply_torque(rotationVector*rotation_speed)
	
	update_target_enemy()
