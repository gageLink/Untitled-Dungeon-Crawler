extends Node2D
var butt = null
var BI = false
signal bind;signal move()
func _on_up_mouse_entered() -> void:
	$Up/BG.modulate.a = 1
	butt = $Up


func _on_up_mouse_exited() -> void:
	$Up/BG.modulate.a = 0
	butt = null


func _on_down_mouse_entered() -> void:
	$Down/BG.modulate.a = 1
	butt = $Down


func _on_down_mouse_exited() -> void:
	$Down/BG.modulate.a = 0
	butt = null


func _on_left_mouse_entered() -> void:
	$Left/BG.modulate.a = 1
	butt = $Left


func _on_left_mouse_exited() -> void:
	$Left/BG.modulate.a = 0
	butt = null


func _on_right_mouse_entered() -> void:
	$Right/BG.modulate.a = 1
	butt = $Right


func _on_right_mouse_exited() -> void:
	$Right/BG.modulate.a = 0
	butt = null

func walking(a):
	if a[3] == "1":
		$Down.modulate.a=1
	else:$Down.modulate.a=.5
	if a[2] == "1":
		$Right.modulate.a=1
	else:$Right.modulate.a=.5
	if a[1] == "1":
		$Up.modulate.a=1
	else:$Up.modulate.a=.5
	if a[0] == "1":
		$Left.modulate.a=1
	else:$Left.modulate.a=.5

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("newclick"):
		if butt != null:
			if not BI:
				bind.emit()
				BI = true
				walking(["0","0","0","0"])
				if butt == $Up:
					move.emit([0,-1])
					return
				if butt == $Down:
					move.emit([0,1])
					return
				if butt == $Left:
					move.emit([-1,0])
					return
				if butt == $Right:
					move.emit([1,0])
					return
