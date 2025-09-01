extends Area2D

var MI := false; var ct = 0;

func _process(_delta: float) -> void:
	
	if (MI):
		ct += 1;if ct > 360:ct = 0
		var ang = (ct*2*PI)/360
		modulate = Color(sin(ang)/2.0 + .5,cos(ang)/2.0 + .5,sin(ang+PI)/2.0 + .5)

func _on_mouse_entered() -> void:
	MI = true
func _on_mouse_exited() -> void:
	MI = false
	modulate = Color(1,1,1,1)
