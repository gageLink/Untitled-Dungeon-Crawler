extends Node2D
var ct=0.0;signal halls; var dt;var cnt = 0
func _process(delta: float) -> void:
	ct+=delta
	if ct>1: ct=0
	$A.offset.y = sin(ct *2*PI)*3
	$B.offset.y = sin(ct *2*PI + PI/3)*3
	$C.offset.y = sin(ct *2*PI + 2*PI/3)*3
	$B/LBump.offset.y = lerp($B/LBump.offset.y,($A.offset.y+$B.offset.y)/2,delta)
	$B/RBump.offset.y = lerp($B/RBump.offset.y,($C.offset.y+$B.offset.y)/2,delta)
	#move stuff
	if dt != 0:
		match dt:
			1:
				$A.move_to_front()
				if scale.x < 1.5: #move forward
					cnt +=1
					var amt = Vector2.ONE*delta
					amt *= sin(((scale.x-.9)/3)*PI/2)*3*(sin(cnt/3) +1)/2
					position += Vector2(amt.x*-1150,amt.y*-640+sin(cnt/3)*7*scale.x/7)
					scale +=2*amt
					modulate.a-=amt.x
				elif  scale.x < 3:#start heading left
					cnt +=1
					var amt = Vector2.ONE*delta
					amt *= sin(((scale.x-.9)/3)*PI/2)*3*(sin(cnt/3) +1)/2
					position += Vector2(amt.x*-0,amt.y*-640+sin(cnt/3)*7*scale.x/7)
					scale +=2*amt
					modulate.a-=amt.x
					pass
				else: dt = 0
			2:
				$B.move_to_front()
				if scale.x < 3:
					cnt +=1
					var amt = Vector2.ONE*delta
					amt *= sin(((scale.x-.9)/3)*PI/2)*3*(sin(cnt/3) +1)/2
					position += Vector2(amt.x*-1150,amt.y*-640+sin(cnt/3)*7*scale.x/7)
					scale +=2*amt
					modulate.a-=amt.x
				else: dt = 0
			3:
				$C.move_to_front()
				if scale.x < 1.5: #move forward
					cnt +=1
					var amt = Vector2.ONE*delta
					amt *= sin(((scale.x-.9)/3)*PI/2)*3*(sin(cnt/3) +1)/2
					position += Vector2(amt.x*-1150,amt.y*-640+sin(cnt/3)*7*scale.x/7)
					scale +=2*amt
					modulate.a-=amt.x
				elif  scale.x < 3:#start heading right
					cnt +=1
					var amt = Vector2.ONE*delta
					amt *= sin(((scale.x-.9)/3)*PI/2)*3*(sin(cnt/3) +1)/2
					position += Vector2(amt.x*-2300,amt.y*-640+sin(cnt/3)*7*scale.x/7)
					scale +=2*amt
					modulate.a-=amt.x
					pass
				else: dt = 0
			4:
				if modulate.a > .2:
					modulate.a -= delta/1.5
					var d = 1
					for j in [$A,$B,$C]:
						d*=-1
						j.rotation+=delta*10*randf()*d
				else: dt = 0
				pass
	

func move(dir):
	var od = dir
	if glb.facing != null:#rotate for facing
		if glb.facing.y == 1.0:
			dir *= -1.0
		if glb.facing.x == 1.0:#swap em, flip x
			var t = dir.x;dir.x = dir.y*-1; dir.y =t
		if glb.facing.x == -1.0:#swap em, flip y
			var t = dir.x;dir.x = dir.y; dir.y =t*-1
	
	var rp = glb.readmap(glb.curr);var nx = rp.x + dir.x;var ny = rp.y+dir.y
	if nx == -1 or nx == glb.tilesize or ny == -1 or ny == glb.tilesize:#check bound issues
		await walk(Vector2.ZERO)
		return false
	var n = glb.map[nx][ny]
	if n != null:
		n.occ = true
		glb.curr.occ = false
		glb.prev = glb.curr
		glb.curr = n
		var r = glb.prev.get_child(2);r.color = Color(r.color.r,r.color.g,r.color.b,1)
		glb.facing = dir
		await walk(od)
		findhall()
		#curr.visible = true
		return true
	await walk(Vector2.ZERO)
	return false

func findhall():#halls are stored in a left/straight/right truth table, and referred to as such in filename
	var pos = glb.readmap(glb.curr);var a = [];var ang;var A = $A;var B= $B; var C = $C
	if glb.facing.y != 0.0:#grabs current facing direction
		ang = asin(glb.facing.y*-1)
	else:
		ang = acos(glb.facing.x)
	ang += PI/2#turns to the left
	for i in [A,B,C]:
		var off = Vector2(cos(ang),sin(ang)*-1)
		var np = pos + off
		if np.x > -1 and np.x < glb.tilesize and np.y > -1 and np.y < glb.tilesize:
			if glb.map[np.x][np.y] != null:
				glb.map[np.x][np.y].visible = true
				a.append("1")
			else:a.append("0")
		else:a.append("0")
		i.texture = ResourceLoader.load("res://Art/Hallways/Wall3/" + i.name + a.back() + ".png")
		ang -= PI/2#turns to the right
	resize()
	if ["111","000","100","011"].find(a[0]+a[1]+a[2]) != -1:
		$B/RBump.visible = true
	else:$B/RBump.visible = false
	if ["111","000","001","110"].find(a[0]+a[1]+a[2]) != -1:
		$B/LBump.visible = true
	else:$B/LBump.visible = false
	halls.emit(a+["1"])

func resize():
	dt = 0;cnt = 0
	var a = [$A,$B,$C];var x = 192.0
	modulate.a = 1
	scale = Vector2.ONE
	position = Vector2.ZERO
	skew = 0
	for i in a:
		i.position = Vector2(x,324.0)
		x+=384.0
		i.scale = Vector2.ONE*2.401/2
		i.rotation = 0
		i.z_index = 0

func walk(dir):
	var cnt = 0
	if dir == Vector2(1,0):#right
		dt = 3
		while dt!=0:
			await get_tree().create_timer(.1).timeout
		return
	if dir == Vector2(-1,0):#left
		dt = 1
		while dt!=0:
			await get_tree().create_timer(.1).timeout
		return
		
	if dir == Vector2(0,1):#back
		dt = 4
		while dt !=0:
			await get_tree().create_timer(.1).timeout
		return
	if dir == Vector2(0,-1):#forward
		dt=2
		while dt != 0:
			await get_tree().create_timer(0.1).timeout
		return
