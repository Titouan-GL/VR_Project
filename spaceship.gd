extends RigidBody3D

class_name SpaceShip

@export var VR_enabled: bool = false
@export var vr_controller: VRController
@export var non_vr_camera: Camera3D
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
var mouse_input: Vector2

func _ready():
	crosshair.visible = false
	if VR_enabled:
		non_vr_camera.current = false
		vr_controller.visible = true
	else:
		non_vr_camera.current = true
		vr_controller.visible = false
	camera = get_viewport().get_camera_3d()
	
func shoot():
	gunL.target = target_enemy
	gunR.target = target_enemy
	gunL.shoot()
	gunR.shoot()

func find_target_enemy() -> Hostile:
	if target_enemy == null:
		for e in world.enemies:
			var to_target_e = (e.global_position - global_position).normalized()
			if -transform.basis.z.dot(to_target_e) > cos(deg_to_rad(30)):
				return e
	return null


func update_target_enemy():
	if target_enemy == null or -global_transform.basis.z.dot((target_enemy.global_position - global_position).normalized()) <= cos(deg_to_rad(30)):
		target_enemy = find_target_enemy()
		crosshair.visible = target_enemy != null
		ik.active = false
	if target_enemy != null:
		crosshair.global_position = camera.global_position+(target_enemy.global_position - camera.global_position).normalized()*1
		crosshair.look_at(target_enemy.global_position)
		target.global_position = target_enemy.global_position
		ik.active = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var viewport_transform: Transform2D = get_tree().root.get_final_transform()
		mouse_input += event.xformed_by(viewport_transform).relative

func _process(delta: float) -> void:
	#shoot()
	var movementVector: Vector3
	var rotationVector: Vector3
	if VR_enabled:
		movementVector = Vector3(movement_joystick.joystick_x_position, 0, movement_joystick.joystick_y_position)
		rotationVector = Vector3(rotation_joystick.joystick_y_position, -rotation_joystick.joystick_x_position, 0)
	else:
		movementVector = Vector3(int(Input.is_action_pressed("move_right"))-int(Input.is_action_pressed("move_left")), 0, int(Input.is_action_pressed("move_backward"))-int(Input.is_action_pressed("move_forward")))*45
		rotationVector = Vector3(-mouse_input.y, -mouse_input.x, 0)*10
	if(movementVector.length() > 0.1):
		apply_force(global_transform.basis*movementVector*thruster_strength*delta)
	if(rotationVector.length() > 0.1):
		apply_torque(global_transform.basis*rotationVector*rotation_speed)
	
	mouse_input = Vector2.ZERO
	update_target_enemy()
