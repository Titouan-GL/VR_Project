extends BoneAttachment3D

class_name Gun

var bullet_instance: PackedScene = preload("res://bullet.tscn")
var fire_timer: float = 0.3
var cur_timer: float = 0
var target: Node3D = null

func instanciate_bullet():
	var instance: Bullet = bullet_instance.instantiate()
	get_tree().get_current_scene().add_child(instance)
	instance.fire(self)
		

func shoot():
	while cur_timer <= 0:
		instanciate_bullet()
		cur_timer += fire_timer

func _process(delta: float) -> void:
	if cur_timer > 0:
		cur_timer -= delta
	
