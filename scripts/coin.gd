extends Area2D

func _on_coin_body_enter( body ):
	get_node("anim").play("get")
	get_node("shape").queue_free()
	yield(get_node("anim"), "finished")
	queue_free()
