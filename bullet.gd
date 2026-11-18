extends RigidBody3D

class_name Bullet

var gun: Gun
var dir: Vector3

func fire(origin: Gun, target: Node3D) -> void:
	gun = origin
	global_position = gun.global_position
	global_rotation = gun.global_rotation
	if target:
		dir = (target.global_position-global_position).normalized()
	else:
		dir = global_basis.y
	add_constant_force(dir*1000)
	
