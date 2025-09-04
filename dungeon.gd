extends Node2D
#scons platform=linuxbsd tools=no profile=custom.py lto=full target=template_release bits=64
#scons platform=linuxbsd tools=no profile=custom.py lto=full target=template_debug bits=64
#scons platform=windows tools=no profile=custom.py bits=64
var spawnables = [];@export var Battle : PackedScene;var battle



func _input(event: InputEvent):
	if event.is_action_pressed("Spacebar"):
		glb.curr.shop = glb.facing

func _on_hallway_halls(a) -> void:#tells buttons what to display
	if $Map.buttons != null:
		$Map.buttons.walking(a)

func _on_map_review() -> void:#tells hallway to change look
	$Hallway.findhall();$Hallway.resize()

func _on_map_move(dir) -> void:
	await $Hallway.move(Vector2(dir[0],dir[1]))
	$Map/Buttons.BI = false
	spawncheck()
	assignspawn(glb.curr.spawned)
	$Hallway.findhall()


func _on_hallway_down() -> void:
	$Map.down()


func _on_map_nf() -> void:#new floor
	#generate spawnables array
	makespawnables()

func makespawnables():
	spawnables.clear()
	spawnables.append(0)#shop
	for i in $Map.roads.size()/3:#enemies
		spawnables.append(1)

func spawncheck():
	if glb.curr.spawned == 0:
		if randf() > 0.67:#1 in 3 chance
			#get a random spawnable
			var s = spawnables.pick_random()
			assignspawn(s)
		glb.curr.spawned = 1
		if $Hallway.code == "000"and randf()>0.25:
			if [$Map.nodes[0],$Map.nodes[1]].find(glb.curr)==-1:
				glb.curr.spawned = 2
				glb.curr.modulate = Color(1,1,0)

func assignspawn(s):
	var latch = false
	if glb.prev.spawned == 2:#ambush!
		glb.prev.spawned = 1
		glb.curr.modulate = Color(1,0,0)
		spawnables.erase(1)
		return
	if glb.curr.spawned == 1:#leave
		return
	match s:
		0:#shop
			if $Hallway.code == "010":
				glb.curr.shop = glb.facing
				glb.curr.modulate = Color(1,0,1)
				latch = true
		1:#enemy
			initbattle()
			glb.curr.modulate = Color(1,0,0)
			latch = true
			pass
	if latch: spawnables.erase(s)

func initbattle():
	$Map.buttout()
	battle = Battle.instantiate()
	add_child(battle)
	battle.victory.connect(endbattle)

func endbattle():
	$Map.buttin()
	remove_child(battle)
	battle.queue_free()
