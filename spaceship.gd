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
@export var gunL: Gun
@export var gunR: Gun
#engine
@export var engines: Array[BoneAttachment3D]


var camera: Camera3D = null
var target_enemy: Hostile = null
var mouse_input: Vector2
var engine: Spaceship_Engine = null
var joystick_max_angle: float = 45

var movementVector: Vector3
var rotationVector: Vector3

func _ready():
	engine = Spaceship_Engine.new()
	engine.create(self, engines)
	crosshair.visible = false
	if VR_enabled:
		non_vr_camera.current = false
		vr_controller.visible = true
	else:
		non_vr_camera.current = true
		vr_controller.visible = false
	camera = get_viewport().get_camera_3d()
	

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
	if target_enemy != null:
		crosshair.global_position = camera.global_position+(target_enemy.global_position - camera.global_position).normalized()*1
		crosshair.look_at(target_enemy.global_position)
		target.global_position = target_enemy.global_position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var viewport_transform: Transform2D = get_tree().root.get_final_transform()
		mouse_input += event.xformed_by(viewport_transform).relative

func _physics_process(delta: float) -> void:
	engine.physics_process(movementVector, rotationVector, delta)

func _process(_delta: float) -> void:
	if VR_enabled:
		movementVector = Vector3(movement_joystick.joystick_x_position, 0, movement_joystick.joystick_y_position)/joystick_max_angle
		rotationVector = Vector3(rotation_joystick.joystick_y_position, -rotation_joystick.joystick_x_position, 0)/joystick_max_angle
	else:
		movementVector = Vector3(int(Input.is_action_pressed("move_right"))-int(Input.is_action_pressed("move_left")), 0, int(Input.is_action_pressed("move_backward"))-int(Input.is_action_pressed("move_forward")))
		rotationVector = Vector3(-mouse_input.y, -mouse_input.x, 0)/5
		if Input.is_action_pressed("mouse_left"): gunL.shoot(target_enemy)
		if Input.is_action_pressed("mouse_right"): gunR.shoot(target_enemy)

	
	mouse_input = Vector2.ZERO
	engine.process(_delta)
	update_target_enemy()
