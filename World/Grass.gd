extends Node2D

func create_grass_effect():
	
#	This loads the grass destroy animation in the same position as
#	the grass object that was destroyed. It loads the animation scene
#	then creates an instance of the animation at the global position
#	of the current grass object.
	var GrassEffect = load("res://Effects/GrassEffect.tscn")
	var grass_effect = GrassEffect.instance()
	var world = get_tree().current_scene
	
	world.add_child(grass_effect)
	grass_effect.global_position = global_position
	
	queue_free()


func _on_Hurtbox_area_entered(area):
	create_grass_effect()
	queue_free()
