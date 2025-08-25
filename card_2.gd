extends Area2D
#as with item2, serves to replace the existing card system
#in order to facilitate nesting, i will be using instances of sprites as well as collisions
#to start out with? honestly i think i can just. use the same code.
var ft = [];var ct = 0;var mi;var sp = Vector2.ZERO; var sh := false;var lp = ""
#family tree;count(for movement);mouse in;supposed position;shifting;leaf position

func _process(delta: float) -> void:
	move(delta)

func go(item):
	ft = Global.addsprite(self,item,ft).duplicate(true)
	Global.addcollis(ft)

func setitem(item):
	if ft.size() > 1:
		return
	var n = get_child(0)
	Global.addsprite(n,item,ft)


func _on_mouse_entered():
	mi = true

func _on_mouse_exited():
	mi = false

func move(delta):
	self.position = lerp(self.position,sp,delta * 2)
	var i = 0
	match Global.DeckType:
		"Branch":
			if Global.holding == self:
				var where = lerp(global_position,get_global_mouse_position(),delta*15)
				global_position = Vector2(clamp(where.x,0,Global.sz.x), clamp(where.y,0,Global.sz.y))
				for c in Global.cards:
					var offset = position - sp
					if c != self:
						if leaves[Global.cards.find(c)].begins_with(leaves[Global.cards.find(self)])and c.ft.size()>1:
							c.position = c.sp+offset
			elif ft.size() < 2:
				position.x = 5*Global.sz.x/6
			return
	sp.x = clamp(sp.x,0.0,Global.sz.x)
	sp.y = clamp(sp.y,0.0,Global.sz.y)
	if sh:
		position = lerp(position,sp,delta*2)
		if (position-sp).length() < 1:
			position = sp
			sh = false
	#follow mouse
	if Global.holding == self:
		var where = lerp(global_position,get_global_mouse_position(),delta*15)
		global_position = Vector2(clamp(where.x,0,Global.sz.x), clamp(where.y,0,Global.sz.y))
		self.global_position.y += sin(ct*PI/50.0)*10.0
		self.global_rotation =  sin(ct*PI/50.0+PI/6)*2
		
	else:
		self.position = lerp(self.position,sp,delta * 2)
		for c in Global.cards:
			if c != self:
				if abs(sp - c.sp).length() < 100.0:
					sp += Vector2(randf()-.5,randf()-.5)*10
					c.sp += Vector2(randf()-.5,randf()-.5)*10
	#be silly
	for f in ft:
		if i == 0:
			var it = sin(ct*PI/100)*10
			f.position.y = it
		else:
			var shake = Vector2(randf_range(-1,1),randf_range(-1,1))*3
			if f != null:
				f.offset = shake
		if mi == true:
			rotation = move_toward(rotation,sin(ct*PI/50)*PI/8,delta)
		else: 
			if rotation != 0: rotation = move_toward(rotation,0,delta)
		i += 1
	ct+=1
	if ct > 200: ct=0

var leaves = {0:"0",1:"00",2:"01",3:"000",4:"001",5:"010",6:"011",7:"0000",8:"0001",9:"0010",10:"0011",11:"0100",12:"0101",13:"0110",14:"0111"}
