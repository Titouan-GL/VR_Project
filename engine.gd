extends Object

class_name Spaceship_Engine

var rb: RigidBody3D
var thruster_strength: float = 300000
var rotation_speed: float = 100000
var stabilizer_on: bool = true
var engines_attach: Array[BoneAttachment3D]
var engines_lookat: Array[LookAtModifier3D]
var engines_target: Array[Marker3D]
var engine_direction: Array[Vector3]
var skeleton: Skeleton3D

var setup_finished: bool = false
var move_input: Vector3 = Vector3.ZERO

func create(_rb: RigidBody3D, _engines_look_at: Array[BoneAttachment3D]):
	rb = _rb
	engines_attach = _engines_look_at

func orient_engines():
	for i in range(engines_attach.size()):
		var current_dir: Vector3 = (engines_target[i].position - engines_attach[i].position).normalized()
		var target_dir: Vector3
		if( move_input.length() > 0.1):
			target_dir = move_input.normalized()
		else:
			target_dir = engine_direction[i]
		var new_dir: Vector3 = current_dir.slerp(target_dir, 0.1)
		engines_target[i].position = engines_attach[i].position + new_dir.normalized()*1000

func setup():
	for i in range(engines_attach.size()):
		skeleton = engines_attach[i].get_skeleton()
		var target: Marker3D = Marker3D.new()
		skeleton.add_child(target)
		engines_target.append(target)
		var lookat: LookAtModifier3D = LookAtModifier3D.new()
		engines_attach[i].get_parent().add_child(lookat)
		engines_lookat.append(lookat)
		lookat.bone = engines_attach[i].bone_idx
		lookat.forward_axis = SkeletonModifier3D.BONE_AXIS_PLUS_Y
		lookat.primary_rotation_axis = Vector3.AXIS_X
		lookat.target_node = target.get_path()
		engine_direction.append(skeleton.get_bone_global_pose(lookat.bone).basis.y)
		engines_target[i].position = engine_direction[i].normalized()*1000
	


func process(_delta: float):
	if !setup_finished:
		setup()
		setup_finished = true
	orient_engines()

func physics_process(_move_input: Vector3, _rotation_input: Vector3, _delta: float):
	move_input = _move_input
	var basis: Basis = rb.global_transform.basis 
	var global_vel: Vector3 = rb.linear_velocity
	var local_vel: Vector3 = basis * global_vel
	if(_move_input.length() > 0.1):
		rb.apply_force(basis * _move_input * thruster_strength)
		for i in range(3):
			if local_vel[i] > 0 and _move_input[i] < 0 or local_vel[i] < 0 and _move_input[i] > 0:
				var added_vel: Vector3 = Vector3(0,0,0)
				added_vel[i] += _move_input[i]*thruster_strength
				rb.apply_force(basis * added_vel)
	elif stabilizer_on and rb.linear_velocity != Vector3.ZERO:
		if (global_vel.normalized()*thruster_strength*_delta/rb.mass).length() > global_vel.length():
			rb.linear_velocity = Vector3.ZERO
		else:
			rb.apply_force(-global_vel.normalized() * thruster_strength)
			
	if(_rotation_input.length() > 0.1):
		rb.apply_torque(basis*_rotation_input*rotation_speed)
		
