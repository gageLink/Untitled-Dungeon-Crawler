extends Node2D
#scons platform=linuxbsd tools=no profile=custom.py lto=full target=template_release bits=64
#scons platform=linuxbsd tools=no profile=custom.py lto=full target=template_debug bits=64
#scons platform=windows tools=no profile=custom.py bits=64


func _input(event: InputEvent):
	if event.is_action_pressed("Spacebar"):
		glb.curr.shop = glb.facing

func _on_hallway_halls(a) -> void:#tells buttons what to display
	$Map/Buttons.walking(a)

func _on_map_review() -> void:#tells hallway to change look
	$Hallway.findhall();$Hallway.resize()

func _on_map_move(dir) -> void:
	if not await $Hallway.move(Vector2(dir[0],dir[1])):
		$Hallway.findhall()
	$Map/Buttons.BI = false


func _on_hallway_down() -> void:
	$Map.down()
	pass # Replace with function body.
