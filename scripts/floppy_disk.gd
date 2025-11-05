extends Area2D


func _on_body_entered(_body: Node2D) -> void:
	print("Coletou 1 disquete")
	queue_free()
