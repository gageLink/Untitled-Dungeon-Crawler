extends Area2D
#to replace the existing cardmap system to use the new card and item system
@export var card: PackedScene
var mi: bool #whether the mouse is in the map
signal popitem()
var cardish = false
var popstop = false

func _ready() -> void:
	$Area.shape.set_size(glb.sz)
	$Area.position = glb.sz/2
	for i in glb.startcards:
		addcard([])
		await get_tree().create_timer(.5).timeout

func _input(event):
	if event.is_action_pressed("newclick"):
		cardish = false
		#for c in glb.cards:
			#if (c.sh == true) and (glb.cards[0].sh == true):
				#return
		if mi:
			if glb.holding == null:
				glb.holding = pullcard()
				glb.HSCYP[2] = 0
	if event.is_action_released("newclick"):
		if glb.holding!=null:
			var n = pullcard(true)
			if mi:
				if glb.holding.name.contains("Item"):
					glb.items -=1
					if n != null:
						storehelditem(n)
					else:
						n = pullcard()
						takeitem(n)
						swapall()
						n = pullcard(true)
						storehelditem(n)
				elif glb.holding.name.ends_with("Card"):
					if cardish == true:
						if glb.cards.size() == 1:
							glb.HSCYP[1] = glb.holding
							glb.HSCYP[2] = 0
							glb.holding = null
							return
						if n != null:
							var ci = glb.cards.find(glb.holding)
							storehelditem(n)
							glb.cards.pop_at(ci)
							RePlace()
							#kidswap(n,n)
						else:
							n = pullcard()
							takeitem(n)
							swapall()
							n = pullcard(true)
							var ci = glb.cards.find(glb.holding)
							storehelditem(n)
							glb.cards.pop_at(ci)
							RePlace()
					else:
						glb.HSCYP[1] = glb.holding
						glb.HSCYP[2] = 0
						glb.holding.sp = get_local_mouse_position()
						glb.holding = null
			else:
				if glb.holding.name.ends_with("Card"):
					popcheck(true)
					glb.HSCYP[1] = glb.holding
					glb.HSCYP[2] = 0
					glb.holding = null
				elif glb.holding.name.contains("Item"):
					if cardish: #make that shit a card. pop its contents and blow it up
						if glb.cards.size() == glb.maxcards:
							glb.holding = null
							return
						else:
							popcheck(false)
							addcard(glb.holding,true)
							#drop contents
						glb.holding = null
						pass
					else:
						glb.holding = null


func addcard(item,aac = false):
	$Pop.pitch_scale = randf_range(.5,2)
	$Pop.play()
	if glb.cards.size() == glb.maxcards:
		return
	var new_card = card.instantiate();var Stack = [glb.DeckType]
	add_child(new_card)
	place(new_card)
	if not aac:
		if item.size() > 0:
			Stack += item
		new_card.go(Stack)
	else:
		new_card.ft = item.ft.duplicate(true)
		new_card.go(item.ft[0])
		#shift()
		new_card.sh = true
		var size = new_card.ft[0].texture.get_size()
		new_card.ft[0].scale = Vector2(128.0/size.x,128.0/size.y)/.65
		new_card.global_position = item.position
		item.queue_free()
	shift()
	new_card.name = str(glb.counter)+"Card"
	glb.cards+=[new_card]
	glb.counter += 1

func shift():
	#moves all existing cards. Do this before spawning in the next. assumes everything was placed correctly previously
	match glb.DeckType:
		"Captcha":
			var ct = 0
			var lev = floor((float(glb.cards.size())/5.0)) + 1
			for c in glb.cards:
				if glb.cards.size()%5 == 0:
					#move em up
					c.sp.y -= 2*glb.sz.y/15
				else:
					#move everything in this level leftward
					ct += 1
					if ct > lev*5-5:
						c.sp.x -= .1*glb.sz.x
		_:
			pass

func RePlace():
	match glb.DeckType:
		"Captcha":
			var i = 0
			for c in glb.cards:
				i +=1
				c.sh = true
				if i == 1:
					$Replace.play()
				if (glb.cards.size()+1)%5 == 1:
					c.sp.y += 2*glb.sz.y/15
				if floor(float(i)/5.0) == floor(float(glb.cards.size())/5.0):
					c.sp.x -= .1*glb.sz.x
				else:
					c.sp.x -= .2*glb.sz.x
				if i%5 == 0:
					c.sp.y -= 4*glb.sz.y/15
					c.sp.x = 0.9*glb.sz.x
				await get_tree().create_timer(.2).timeout
		"Branch":
			var i =0
			for c in glb.cards:
				i+=1
				var lev = floor(log(i)/log(2))
				c.sp.x = (lev+1)*glb.sz.x/6
				c.sp.y = (i-2**lev+1)*glb.sz.y/((2**lev)+1)
		_:
			pass

func place(node):
	match glb.DeckType:
		"Captcha":
			var lev = floor(float(glb.cards.size())/5.0) +1
			node.sp.y = glb.sz.y/2 + (glb.sz.y/6)*(lev-1)
			node.sp.x = glb.sz.x/2 + (glb.sz.x*.1)*(glb.cards.size()%5)
		"Branch":
			var lev = floor(log(glb.cards.size()+1)/log(2))
			node.sp.x = (lev+1)*glb.sz.x/6
			node.sp.y = (glb.cards.size()+1-2**lev+1)*glb.sz.y/((2**lev)+1)
		_:
			node.sp.y = glb.sz.y/2
			node.sp.x = glb.sz.x/2


func kidswap(carda,cardb):#Assumes both cards have stuff
	var piv = cardb.ft.duplicate(true)
	if carda.ft.size() > 1:
		var size = carda.ft[1].texture.get_size()
		carda.ft[1].scale = Vector2(128.0/size.x,128.0/size.y)*2.0/(2.0**.8) / cardb.ft[0].scale
		carda.ft[1].position = glb.offset(cardb)
		carda.ft[1].reparent(cardb.ft[0],0)
	if cardb.ft.size() > 1:
		var size = cardb.ft[1].texture.get_size()
		cardb.ft[1].scale = Vector2(128.0/size.x,128.0/size.y)*2.0/(2.0**.8) / carda.ft[0].scale
		cardb.ft[1].position = glb.offset(carda)
		cardb.ft[1].reparent(carda.ft[0],0)
	if not popstop:
		$Pop.play()
	for i in carda.ft.size():
		if i == 0:
			cardb.ft = [cardb.ft[0]]
		else:
			if i <= carda.ft.size() - 1:
				cardb.ft.append(carda.ft[i])
	for i in piv.size():
		if i == 0:
			carda.ft = [carda.ft[0]]
		else:
			carda.ft.append(piv[i])

func takeitem(carda):
	match glb.DeckType:
		"Captcha":
			if carda.ft.size() > 1:
				var tft = carda.ft[0]
				popitem.emit(carda.ft[1],carda.ft)
				$Snap.play()
				carda.ft = [tft].duplicate()
		"Branch":
			var i = glb.cards.find(carda); var t = .1*10.0/8.0
			if i == -1:
				if carda.ft.size() > 1:
					var tft = carda.ft[0]
					popitem.emit(carda.ft[1],carda.ft)
					$Snap.play()
					carda.ft = [tft].duplicate()
				return
			for c in glb.cards:
				if c.leaves[glb.cards.find(c)].begins_with(c.leaves[i]):
					if c.ft.size() > 1:
						var tft = c.ft[0]
						popitem.emit(c.ft[1],c.ft)
						$Snap.play()
						c.ft = [tft].duplicate()
						t *=8.0/10.0
						await get_tree().create_timer(t).timeout
		_:
			if carda.ft.size() > 1:
				var tft = carda.ft[0]
				popitem.emit(carda.ft[1],carda.ft)
				$Snap.play()
				carda.ft = [tft].duplicate()

func swapall():
	match glb.DeckType:
		"Captcha":
			var a;var b;var ct = 0
			for c in glb.cards:
				if ct == 0:
					ct+=1
					a = c
					$Pop.pitch_scale = 1
					await get_tree().create_timer(.75).timeout
				else:
					if c.ft.size()>1:
						if a == null:
							a = c
						else:
							b = c
							kidswap(a,b)
							a = c
							ct+=1
							$Pop.pitch_scale *= 1.2
							await get_tree().create_timer(.2).timeout
					else:
						$Pop.pitch_scale = 1
						return
		_:
			pass

func pullcard(free = false):
	match glb.DeckType:
		"Captcha":
			if glb.holding == null: #if youre not holding anything and youre just picking up
				return glb.cards[0] #grabs the first card
			for c in glb.cards: #if you are holding, and want to drop off
				if c != glb.holding:
					if free: #if youre looking for an "empty" card to deposit in
						if c.ft.size() < 2:
							return c #first empty nonheld card
					else: #when theres no empty cards
						return c #first nonheld card
			return null
		_:
			if glb.holding == null:
				for c in glb.cards:
					if c.mi == true:
						return c
			else:
				for c in glb.cards:
					if free:
						if c.ft.size() < 2:
							return c #first empty nonheld card
					else:
						return c
			return null

func _on_mouse_entered() -> void:
	mi = true


func _on_mouse_exited() -> void:
	mi = false
	if glb.holding !=null:
		cardish = true

func popcheck(swap):
	if get_local_mouse_position().clamp(Vector2.ZERO,glb.sz) != get_local_mouse_position():
		takeitem(glb.holding)
		if swap:
			swapall()

func storehelditem(n):
	$Store.pitch_scale = randf_range(.2,6)
	$Store.play()
	var p = null
	for f in glb.holding.ft:
		if p == null:
			f.reparent(n,0)
			n.ft+=[f].duplicate(true)
			p = f
		else:
			f.reparent(p,0)
			n.ft+=[f].duplicate(true)
			p = f
	n.ft[1].scale = n.ft[1].scale
	var size = n.ft[1].texture.get_size()
	n.ft[1].scale = Vector2(128.0/size.x,128.0/size.y)*2.0/(2.0**.8) / n.ft[0].scale
	if n.ft[1].name.ends_with("Card"):
		n.ft[1].name +="Item"
	n.ft[1].position = glb.offset(n)
	glb.holding.queue_free()
	glb.holding = null
	popstop = true
	kidswap(n,n)
	popstop = false

func dropcheck():
	pass

func cardstore():
	match glb.DeckType:
		"Branch":
			pass
		_:
			pass
