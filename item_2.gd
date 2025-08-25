extends RigidBody2D
#this is to serve as a redo of the item system
#rather than use an existing sprite, i will use the idea of a sprite
#such that i can have items embedded in other items
var ft = []#family twee
var mi = false
var held = false
var ct = 0.0

func _input(event):
	if mi:
		if event.is_action_pressed("newclick"):
			if glb.holding == null:
				glb.holding = self
				held = true
	if event.is_action_released("newclick"):
		if glb.holding == self:
			var spd = Input.get_last_mouse_velocity()
			linear_velocity = Vector2(clamp(spd.x,-1000,1000),clamp(spd.y,-1000,1000))
			
		held = false



func _process(delta: float) -> void:
	var sz = ft[0].texture.get_size() * scale * ft[0].scale
	var mp = get_local_mouse_position()
	if (abs(mp.x) < abs(sz.x/2))and(abs(mp.y) < abs(sz.y/2)):
		mi = true
	else:
		mi = false
		#follow mouse
	if held:
		self.global_position = lerp(self.global_position,get_global_mouse_position(),delta*15)
		self.global_position.y += sin(ct*PI/50.0)*10.0
		self.global_rotation =  sin(ct*PI/50.0+PI/6)*2
		ct+=1.0
		if ct > 200.0:
			ct = 0.0
		self.linear_velocity = Vector2.ZERO
	#position = Vector2.ZERO
	var i = 0
	for f in ft:
		if i != 0:
			#f.position.lerp(Vector2(randi_range(-10*i**.2,10*i**.2),randi_range(-10*i**.2,10*i**.2)),3)
			f.position = Vector2(randi_range(-2*i**.2,2*i**.2),randi_range(-2*i**.2,2*i**.2))
		i+=1
	pass
	

func go(item):
	ft = glb.addsprite(self,item,ft)
	glb.addcollis(ft)
