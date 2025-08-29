extends Node2D
#scons platform=linuxbsd tools=no profile=custom.py lto=full target=template_release bits=64
#scons platform=linuxbsd tools=no profile=custom.py lto=full target=template_debug bits=64
#scons platform=windows tools=no profile=custom.py bits=64


func _on_hallway_halls(a) -> void:
	$Buttons.walking(a)



func _on_map_review() -> void:
	$Hallway.findhall();$Hallway.resize()
	pass # Replace with function body.


func _on_buttons_bind() -> void:
	_on_map_review()


func _on_buttons_move(dir) -> void:
	if not await $Hallway.move(Vector2(dir[0],dir[1])):
		$Hallway.findhall()
	$Buttons.BI = false
	
