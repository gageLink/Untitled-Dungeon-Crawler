extends Node2D
var nodes := []
var roads := []
var mindist = 20
@export var mapsquare: PackedScene
signal review
var BI:= false#block input

func _input(event: InputEvent) -> void:
	if not BI:
		BI = true
		if event.is_action_pressed("click"):
			var g = false
			while g == false:
				reset()
				for i in (roads.size()/1.5):
					cleardeadroad(findfurthestroad())
				g = await grow()
				trim()
		BI = false

func _ready() -> void:
	var g = false
	while g == false:
		reset()
		for i in (roads.size()/1.5):
			cleardeadroad(findfurthestroad())
		g = await grow()
		trim()


func _process(_delta: float) -> void:
	var s  = $SpotTime.time_left
	if glb.curr != null:
		var r = glb.curr.get_child(2)
		r.color = Color(r.color.r,r.color.g,r.color.b,(sin(s *2*PI)+1)/2)

func setnodes():
	for i in range(glb.NodeCt):
		var pos = randpos()
		pos = fixpos(pos)
		var s = mapsquare.instantiate()
		var c = ColorRect.new()
		c.size = Vector2(8.5,8.5)
		c.color = Color(1,1,0,1)
		c.position = Vector2.ONE*c.size.x/-2
		var b = ColorRect.new()
		b.size = Vector2(10.0,10.0)
		b.color = Color(0,0,0,1)
		b.position = Vector2.ONE*-5
		s.position = pos
		glb.map[((s.position.x+5.0)/10)-1][((s.position.y+5.)/10)-1]=s
		add_child(s)
		s.add_child(b)
		s.add_child(c)
		nodes += [s]

func setinout():
	var s = mapsquare.instantiate()
	var b = ColorRect.new()
	b.size = Vector2(10.0,10.0)
	b.color = Color(0,1,0,1)
	b.position = Vector2.ONE*-5
	var c = ColorRect.new()
	c.size = Vector2(8.5,8.5)
	c.color = Color(1,0,0,1)
	c.position = Vector2.ONE*8.5/-2
	s.position = randpos()
	glb.map[((s.position.x+5.0)/10)-1][((s.position.y+5.)/10)-1]=s
	
	add_child(s)
	s.add_child(b)
	s.add_child(c)
	nodes += [s]
	s = mapsquare.instantiate()
	
	b = ColorRect.new()
	b.size = Vector2(10.0,10.0)
	b.color = Color(1,0,0,1)
	b.position = Vector2.ONE*-5
	c = ColorRect.new()
	c.size = Vector2(8.5,8.5)
	c.color = Color(1,0,0,1)
	c.position = Vector2.ONE*8.5/-2
	s.position = randpos()
	s.position = fixpos(s.position)
	glb.map[((s.position.x+5.0)/10)-1][((s.position.y+5.)/10)-1]=s
	add_child(s)
	s.add_child(b)
	s.add_child(c)
	nodes += [s]

func addroad(pos):
	if not roadexists(pos):
		var s = mapsquare.instantiate()
		var b = ColorRect.new()
		b.size = Vector2(10.0,10.0)
		b.color = Color(0,0,0,1)
		b.position = Vector2.ONE*-5
		var c = ColorRect.new()
		c.size = Vector2(8.5,8.5)
		c.color = Color(1,1,1,0)
		c.position = Vector2.ONE*8.5/-2
		s.position = pos
		glb.map[((s.position.x+5.0)/10)-1][((s.position.y+5.)/10)-1]=s
		add_child(s)
		s.add_child(b)
		s.add_child(c)
		roads += [s]

func roadexists(pos):
	for r in roads:
		if (pos -r.position).length() < 10.0:
			return true
	return false

func randpos():
	return Vector2(randi_range(1,glb.tilesize),randi_range(1,glb.tilesize))*10 - Vector2.ONE*5

func fixpos(pos):
	var latch  = true
	while latch  == true:
		latch  = false
		for n in nodes:
			if latch  == false:
				if (abs(pos.x - n.position.x) < mindist) or (abs(pos.y - n.position.y) < mindist):
					pos = randpos()
					latch = true
	return pos

func buildroads():
	roads += nodes
	for i in nodes.size():
		if i < 2:#if in/out
			var n = nodes.pick_random()
			while nodes.find(n) < 2: #prevents the in/out from being chosen
				n = nodes.pick_random()
			if nodes[i].position.x > n.position.x:#go left
				for k in range (nodes[i].position.x-10,n.position.x-1,-10):
					addroad(Vector2(k,nodes[i].position.y))
			else:#go right
				for k in range (nodes[i].position.x+10,n.position.x+1,10):
					addroad(Vector2(k,nodes[i].position.y))
			if nodes[i].position.y > n.position.y:#go up
				for k in range (nodes[i].position.y-10,n.position.y-1,-10):
					addroad(Vector2(n.position.x,k))
			else:#go down
				for k in range (nodes[i].position.y+10,n.position.y+1,10):
					addroad(Vector2(n.position.x,k))
			#find a random node and connect to it
		else:
			for j in range(i+1,nodes.size()):
				#go hoz then vert
				if nodes[i].position.x > nodes[j].position.x:#go left
					for k in range (nodes[i].position.x-10,nodes[j].position.x-1,-10):
						addroad(Vector2(k,nodes[i].position.y))
				else:#go right
					for k in range (nodes[i].position.x+10,nodes[j].position.x+1,10):
						addroad(Vector2(k,nodes[i].position.y))
				if nodes[i].position.y > nodes[j].position.y:#go up
					for k in range (nodes[i].position.y-10,nodes[j].position.y-1,-10):
						addroad(Vector2(nodes[j].position.x,k))
				else:#go down
					for k in range (nodes[i].position.y+10,nodes[j].position.y+1,10):
						addroad(Vector2(nodes[j].position.x,k))
				
				#go vert then hoz
				if nodes[i].position.y > nodes[j].position.y:#go up
					for k in range (nodes[i].position.y-10,nodes[j].position.y-1,-10):
						addroad(Vector2(nodes[i].position.x,k))
				else:#go down
					for k in range (nodes[i].position.y+10,nodes[j].position.y+1,10):
						addroad(Vector2(nodes[i].position.x,k))
				if nodes[i].position.x > nodes[j].position.x:#go left
					for k in range (nodes[i].position.x-10,nodes[j].position.x-1,-10):
						addroad(Vector2(k,nodes[j].position.y))
				else:#go right
					for k in range (nodes[i].position.x+10,nodes[j].position.x+1,10):
						addroad(Vector2(k,nodes[j].position.y))

func breakroads():
	for i in floor(roads.size()*float(glb.NodeCt)/50.0):
		var r  = roads.pick_random()
		if nodes.find(r) == -1:
			var p = glb.readmap(r)
			glb.map[p.x][p.y] = null
			var ro = r
			roads.pop_at(roads.find(r))
			ro.queue_free()




#should redo the bloom stuff
#bloom is a state of being connected to the start node
#a road can be unbloomed, blooming, or bloomed
#the turn after a road is made blooming, it passes that on to unbloomed roads it is touching
#once it tries to pass it on to all surrounding roads, it turns bloomed
#if no roads are left blooming, all roads touching the start node have bloomed
#if this state is reached without hitting the end node, this map is a failure and must be redrawn
#on simple maps, paths connecting to the end nodes can be long and easily severed
#conversely, on complex maps, paths are more readily replaced
#so, like, they shouldnt be too off from each other in terms of loading time
#i would like to make the search for the nodes easier, so i want to store these nodes in a position matrix
#a logical map, if you will

func buildmap():
	for i in glb.tilesize:
		glb.map.append([])
		for j in glb.tilesize:
			glb.map[i].append(null)



func bloom(node):
	var p = glb.readmap(node)
	for i in 4:
		var x = int(p.x+cos(i*PI/2));
		var y = int(p.y+sin(i*PI/2));
		if x >=0 and x <= (glb.tilesize-1) and y >=0 and y <= (glb.tilesize-1):#makes sure we're in bounds
			var r = glb.map[x][y]#rotates around position
			if r != null:
				if r.bloom == 0:
					r.bloom = 1

func findbloom():
	var b =[]
	for r in roads:
		if r.bloom == 1:
			b.append(r)
	return b

func debloom():
	for r in roads:
		r.bloom = 0

func trim():
	for r in roads:
		if r.bloom == 0:
			r.visible = false
			var p = glb.readmap(r)
			glb.map[p.x][p.y] = null

func grow():
	var valid = false
	debloom()
	nodes[0].bloom = 1
	var bms = findbloom()
	while bms.size() > 0:
		for b in bms:
			#await get_tree().create_timer(.15/bms.size()).timeout
			bloom(b)
			b.bloom = 2
			if b == nodes[1]:
				valid = true
		bms.clear()
		bms = findbloom()
	return valid

func reset():
	for r in roads:
		for c in r.get_children():
			c.queue_free
		r.queue_free()
	glb.map.clear()
	roads.clear()
	nodes.clear()
	buildmap()
	setinout()
	randomize()
	setnodes()
	buildroads() 
	#facing = null
	debloom();bloom(nodes[0]);var b = findbloom()
	glb.facing = glb.readmap(nodes[0]) - glb.readmap(b[0])
	glb.curr = roads[0]
	glb.prev = null
	glb.curr.occ = true
	#findhall()
	glb.curr.visible = true
	#resize()
	review.emit()


func findfurthestroad():
	var start = nodes[0];var sp = glb.readmap(start);var end = nodes[1];var ep = glb.readmap(end)
	var fr = nodes[0];
	while fr == nodes[0] or fr == nodes[1]:
		fr = nodes.pick_random()
	var fd = Vector2((glb.readmap(fr)-sp).length(),(glb.readmap(fr)-ep).length()).length()
	for i in 32:
		var r = roads[0];
		while r == roads[0] or r == roads[1]:
			r = roads.pick_random()
		var rp = glb.readmap(r)
		if Vector2((rp-sp).length(),(rp-ep).length()).length() > fd:
			fr = r
			fd = Vector2((rp-sp).length(),(rp-ep).length()).length()
	fr.get_child(1).color = Color(0,1,0)
	fr.bloom = 4
	return fr

func cleardeadroad(r):
	r.visible = false
	var p = glb.readmap(r)
	glb.map[p.x][p.y] = null
	roads.erase(r)
