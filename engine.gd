extends Object

class_name Spaceship_Engine

var rb: RigidBody3D
var thruster_strength: float = 1000000
var rotation_speed: float = 100000

func create(_rb: RigidBody3D):
	rb = _rb

func process(_move_input: Vector3, _rotation_input: Vector3, _delta: float):
	var basis: Transform3D = rb.global_transform.basis
	if(_move_input.length() > 0.1):
		rb.apply_force(basis*_move_input*thruster_strength*_delta)
		var local_vel: Vector3 = basis*rb.linear_velocity
		for i in range(3):
			if local_vel[i] > 0 and _move_input[i] < 0 or local_vel[i] < 0 and _move_input[i] > 0:
				var added_vel: Vector3 = Vector3(0,0,0)
				added_vel[i] += _move_input[i]*thruster_strength*_delta
				rb.apply_force(basis*added_vel)
	if(_rotation_input.length() > 0.1):
		rb.apply_torque(basis*_rotation_input*rotation_speed*_delta)
