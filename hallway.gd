extends Node2D
var ct=0.0;signal halls
func _process(delta: float) -> void:
	ct+=delta
	if ct>1: ct=0
	$A.offset.y = sin(ct *2*PI)*3
	$B.offset.y = sin(ct *2*PI + PI/3)*3
	$C.offset.y = sin(ct *2*PI + 2*PI/3)*3
	$B/LBump.offset.y = lerp($B/LBump.offset.y,($A.offset.y+$B.offset.y)/2,delta)
	$B/RBump.offset.y = lerp($B/RBump.offset.y,($C.offset.y+$B.offset.y)/2,delta)
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
	if ["111","000","100","011"].find(a[0]+a[1]+a[2]) != -1:
		$B/RBump.visible = true
	else:$B/RBump.visible = false
	if ["111","000","001","110"].find(a[0]+a[1]+a[2]) != -1:
		$B/LBump.visible = true
	else:$B/LBump.visible = false
	halls.emit(a+["1"])

func resize():
	var a = [$A,$B,$C];var x = 192.0
	modulate.a = 1
	for i in a:
		i.position = Vector2(x,324.0)
		x+=384.0
		i.scale = Vector2.ONE*2.401/2
		i.rotation = 0
		i.z_index = 0

func walk(dir):
	if dir == Vector2(1,0):#right
		var p = [$A.position,$C.scale,$B.position,$C.position,Vector2.ZERO]
		$C.z_index = 1
		var m = 0
		for i in 21:
			modulate.a -= 0.05
			for j in [$A,$B,$C]:
				if j.scale.x > 3.5/2:
					m = 1
					j.scale.x += (7.2/2-p[4].x)/20
					if j == $A:
						$A.position.x += 4*(p[2]-p[3]).x/20
					if j == $B:
						$B.position.x += 2.5*(p[2]-p[3]).x/20
					if j == $C:
						$C.position.x += (p[2]-p[3]).x/20
				else:
					j.scale += (Vector2.ONE*5-p[1])/20
					p[4] = j.scale
					if j == $A:
						$A.position.x += (-1014-p[0].x)/20
					if j == $C:
						$C.position.x += (2176-p[3].x)/20
			if m == 0:
				await get_tree().create_timer(.2).timeout
			else:
				await get_tree().create_timer(.05).timeout
					
	if dir == Vector2(-1,0):#left
		var p = [$A.position,$A.scale,$B.position,$C.position,Vector2.ZERO]
		$A.z_index = 1
		var m = 0
		for i in 21:
			modulate.a -= 0.05
			for j in [$A,$B,$C]:
				if j.scale.x > 3.5/2:
					m = 1
					j.scale.x += (7.2/2-p[4].x)/20
					if j == $A:
						$A.position.x += (p[2]-p[0]).x/20
					if j == $B:
						$B.position.x += 2.5*(p[2]-p[0]).x/20
					if j == $C:
						$C.position.x += 4*(p[2]-p[0]).x/20
				else:
					j.scale += (Vector2.ONE*10/2-p[1])/20
					p[4] = j.scale
					if j == $A:
						$A.position.x += (-1014-p[0].x)/20
					if j == $C:
						$C.position.x += (2176-p[3].x)/20
			if m == 0:
				await get_tree().create_timer(.2).timeout
			else:
				await get_tree().create_timer(.05).timeout
					
		pass
	if dir == Vector2(0,1):#back
		var a = [1+randf()*2,1+randf()*2,1+randf()*2]
		for i in 21:
			modulate.a -= 0.05
			await get_tree().create_timer(.02).timeout
			$A.rotation += a[0]*2*PI/20
			$B.rotation -= a[1]*2*PI/20
			$C.rotation += a[2]*2*PI/20
			
		pass
	if dir == Vector2(0,-1):#forward
		var s = [$B.scale,$A.position,$C.position]
		$B.z_index=1
		for i in 41:
			modulate.a -= 0.025
			await get_tree().create_timer(.025).timeout
			for j in [$A,$B,$C]:
				j.scale += (Vector2.ONE*10/2-s[0])/40
				if j == $A:
					$A.position.x += (-1014-s[1].x)/40
				if j == $C:
					$C.position.x += (2176-s[2].x)/40
	pass
	resize()
