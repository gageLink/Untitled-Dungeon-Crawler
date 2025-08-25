extends Node2D
var butt = null
var BI = false
#scons platform=linuxbsd tools=no profile=custom.py build=no3d.build lto=full bits=64
#scons platform=windows tools=no profile=custom.py build=custom.build bits=64

func _on_up_mouse_entered() -> void:
	$Up/BG.modulate.a = 1
	butt = $Up
	pass # Replace with function body.


func _on_up_mouse_exited() -> void:
	$Up/BG.modulate.a = 0
	butt = null
	pass # Replace with function body.


func _on_down_mouse_entered() -> void:
	$Down/BG.modulate.a = 1
	butt = $Down
	pass # Replace with function body.


func _on_down_mouse_exited() -> void:
	$Down/BG.modulate.a = 0
	butt = null
	pass # Replace with function body.


func _on_left_mouse_entered() -> void:
	$Left/BG.modulate.a = 1
	butt = $Left
	pass # Replace with function body.


func _on_left_mouse_exited() -> void:
	$Left/BG.modulate.a = 0
	butt = null
	pass # Replace with function body.


func _on_right_mouse_entered() -> void:
	$Right/BG.modulate.a = 1
	butt = $Right
	pass # Replace with function body.


func _on_right_mouse_exited() -> void:
	$Right/BG.modulate.a = 0
	butt = null
	pass # Replace with function body.


func _on_hallway_halls(a) -> void:
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
	if event.is_action_pressed("click"):
		if butt != null:
			if not BI:
				_on_hallway_halls(["0","0","0","0"])
				BI = true
				if butt == $Up:
					if not await $Hallway.move(Vector2(0,-1)):
						$Hallway.findhall()
					BI = false
					return
				if butt == $Down:
					if not await $Hallway.move(Vector2(0,1)):
						$Hallway.findhall()
					BI = false
					return
				if butt == $Left:
					if not await $Hallway.move(Vector2(-1,0)):
						$Hallway.findhall()
					BI = false
					return
				if butt == $Right:
					if not await $Hallway.move(Vector2(1,0)):
						$Hallway.findhall()
					BI = false
					return


func _on_map_review() -> void:
	$Hallway.findhall();$Hallway.resize()
	pass # Replace with function body.
