extends Area2D
var EnemyName
var attributes
var MI := false; var ct = 0;var state = 0;signal expire
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("newclick") and MI:
		damage([Vector2(1,0),Vector2(0,0)])
		state = 1

#func _ready() -> void:
	#EnemyName = "Bad Man"
	#loadattributes()

func _process(delta: float) -> void:
	if (MI):
		ct += 1;if ct > 360:ct = 0
		var ang = (ct*2*PI)/360
		modulate = Color(sin(ang)/2.0 + .5,cos(ang)/2.0 + .5,sin(ang+PI)/2.0 + .5)
	if state != 0:#where they take damage
		state -= delta
		scale = Vector2.ONE*state
		if state < 4*delta:
			state = 0
	else:
		scale = Vector2.ONE
		pass

func _on_mouse_entered() -> void:
	MI = true
	modulate = Color(1,0,1,1)
func _on_mouse_exited() -> void:
	MI = false
	modulate = Color(1,1,1,1)


func loadattributes():
	attributes = dic.attributes.enemies[EnemyName].duplicate(true)
	var t= Sprite2D.new()
	t.texture = ResourceLoader.load("res://Art/Enemies/"+EnemyName+".png")
	add_child(t)
	glb.addcollis([t])

func attack():
	pass

func damage(inc):
	var dmg  = inc.duplicate(true)
	var nm = dic.attributes.example.duplicate(true)
	for att in attributes.size():
		attributes[att].x -= dmg.front().x + attributes[att].x*dmg.front().y
		dmg.pop_front()
		if attributes[att].x <= attributes[att].y and attributes[att].y != -1:
			#var t = Label.new()
			#t.text = nm.front()
			#add_child(t)
			expire.emit(self,nm.front())
		nm.pop_front()
			
