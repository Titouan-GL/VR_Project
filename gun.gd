extends BoneAttachment3D

class_name Gun

var bullet_instance: PackedScene = preload("res://bullet.tscn")
var fire_timer: float = 0.3
var cur_timer: float = 0

func instanciate_bullet(target: Node3D):
	var instance: Bullet = bullet_instance.instantiate()
	get_tree().get_current_scene().add_child(instance)
	instance.fire(self, target)
		

func shoot(target: Node3D):
	while cur_timer <= 0:
		instanciate_bullet(target)
		cur_timer += fire_timer

func _process(delta: float) -> void:
	if cur_timer > 0:
		cur_timer -= delta
	
