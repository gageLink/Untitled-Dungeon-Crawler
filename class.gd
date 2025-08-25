extends Node2D

@export var item: PackedScene
@export var card: PackedScene

func _ready() -> void:
	for i in range(15):
		additem(glb.pickitem())

func _process(_delta: float) -> void:
	queue_redraw()
	if glb.holding == null:
		$Arm/Sprite2D.animation = "picker"
		$Arm/Sprite2D.z_index =2
	else:
		$Arm/Sprite2D.animation = "Holding"
		$Arm/Sprite2D.z_index =0

func _draw() -> void:
	var at = $Arm/Sprite2D.sprite_frames.get_frame_texture($Arm/Sprite2D.animation,$Arm/Sprite2D.frame)
	for c in glb.cards:
		var sca = $CardMap.scale;var h=10
		for f in c.ft:
			var t = f.texture
			sca*=f.scale
			var wid = t.get_size() * sca
			var aw = at.get_size()*.6
			#draw_texture(t,Vector2(c.global_position.x,glb.sz.y))
			var ud = sin(c.ct*PI/100)*2
			var pom=30-(c.sp.y/glb.sz.y)*30.0
			if glb.holding == c:
				if glb.HSCYP[2] < 28:
					if c.ft[0]==f:
						glb.HSCYP[2]+=1
					var div = float(glb.HSCYP[2])/30.0
					pom += ((glb.sz.y-c.global_position.y)/3)*div
				else:
					pom += (glb.sz.y-c.global_position.y)/3
				if c.ft[0]==f:
					draw_set_transform(Vector2(f.global_position.x-aw.x/2.0,glb.sz.y - 15.0+ud-pom),0)
					draw_texture_rect(at,Rect2(Vector2(0.0,5.0),Vector2(aw.x,40)),false)
			elif glb.HSCYP[1] == c:
				if glb.HSCYP[2] < 28:
					if c.ft[0]==f:
						glb.HSCYP[2]+=1
					var div = 1-(float(glb.HSCYP[2])/30.0)
					pom += ((glb.sz.y-c.global_position.y)/3)*div
				else:
					glb.HSCYP[1] = null
			draw_set_transform(Vector2(f.global_position.x-wid.x/2.0,glb.sz.y - 25.0+ud-pom),c.rotation/4)
			draw_texture_rect(t,Rect2(Vector2(0.0,0.0),Vector2(wid.x,h)),false)
			h-=1.0

func additem(thing):
	var new_item = item.instantiate()
	new_item.position = Vector2( randi_range(0,get_viewport().size.x/2),randi_range(0,get_viewport().size.y/2))
	new_item.rotation = randf_range(-2,2)
	new_item.go(thing)
	glb.items += 1
	new_item.name = str(glb.items) + "Item"
	add_child(new_item)

func _on_card_map_2_popitem(thing: Node, ft: Array):
	var new_item = item.instantiate()
	if glb.holding.name.contains("Card"):
		new_item.global_position = Vector2(ft.duplicate(true)[0].global_position.x,glb.sz.y-((glb.sz.y-glb.holding.global_position.y)/3)-(30-(glb.holding.sp.y/glb.sz.y)*30.0)-50)
	else:
		if $CardMap.mi:
			new_item.global_position = Vector2(ft.duplicate(true)[0].global_position.x,glb.sz.y-85.0)
		else:
			new_item.global_position = get_global_mouse_position()
	new_item.linear_velocity = Vector2(0.0,-600.0)+Input.get_last_mouse_velocity()
	new_item.rotation = randf_range(-2,2)
	add_child(new_item)
	thing.reparent(new_item,0)
	new_item.ft = ft.duplicate(true)
	new_item.ft.pop_front()
	new_item.ft[0].position = Vector2.ZERO;new_item.ft[0].offset=Vector2.ZERO;
	var size = new_item.ft[0].texture.get_size();new_item.ft[0].scale = Vector2(128.0/size.x,128.0/size.y)
	glb.addcollis(new_item.ft)
	glb.items+=1
	new_item.name = str(glb.items)+"Item"
