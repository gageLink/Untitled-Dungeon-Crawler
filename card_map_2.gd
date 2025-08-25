extends Area2D
#to replace the existing cardmap system to use the new card and item system
@export var card: PackedScene
var mi: bool #whether the mouse is in the map
signal popitem()
var cardish = false
var popstop = false

func _ready() -> void:
	$Area.shape.set_size(Global.sz)
	$Area.position = Global.sz/2
	for i in Global.startcards:
		addcard([])
		await get_tree().create_timer(.5).timeout

func _input(event):
	if event.is_action_pressed("newclick"):
		cardish = false
		#for c in Global.cards:
			#if (c.sh == true) and (Global.cards[0].sh == true):
				#return
		if mi:
			if Global.holding == null:
				Global.holding = pullcard()
				Global.HSCYP[2] = 0
	if event.is_action_released("newclick"):
		if Global.holding!=null:
			var n = pullcard(true)
			if mi:
				if Global.holding.name.contains("Item"):
					Global.items -=1
					if n != null:
						storehelditem(n)
					else:
						n = pullcard()
						takeitem(n)
						swapall()
						n = pullcard(true)
						storehelditem(n)
				elif Global.holding.name.ends_with("Card"):
					if cardish == true:
						if Global.cards.size() == 1:
							Global.HSCYP[1] = Global.holding
							Global.HSCYP[2] = 0
							Global.holding = null
							return
						if n != null:
							var ci = Global.cards.find(Global.holding)
							storehelditem(n)
							Global.cards.pop_at(ci)
							RePlace()
							#kidswap(n,n)
						else:
							n = pullcard()
							takeitem(n)
							swapall()
							n = pullcard(true)
							var ci = Global.cards.find(Global.holding)
							storehelditem(n)
							Global.cards.pop_at(ci)
							RePlace()
					else:
						Global.HSCYP[1] = Global.holding
						Global.HSCYP[2] = 0
						Global.holding.sp = get_local_mouse_position()
						Global.holding = null
			else:
				if Global.holding.name.ends_with("Card"):
					popcheck(true)
					Global.HSCYP[1] = Global.holding
					Global.HSCYP[2] = 0
					Global.holding = null
				elif Global.holding.name.contains("Item"):
					if cardish: #make that shit a card. pop its contents and blow it up
						if Global.cards.size() == Global.maxcards:
							Global.holding = null
							return
						else:
							popcheck(false)
							addcard(Global.holding,true)
							#drop contents
						Global.holding = null
						pass
					else:
						Global.holding = null


func addcard(item,aac = false):
	$Pop.pitch_scale = randf_range(.5,2)
	$Pop.play()
	if Global.cards.size() == Global.maxcards:
		return
	var new_card = card.instantiate();var Stack = [Global.DeckType]
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
	new_card.name = str(Global.counter)+"Card"
	Global.cards+=[new_card]
	Global.counter += 1

func shift():
	#moves all existing cards. Do this before spawning in the next. assumes everything was placed correctly previously
	match Global.DeckType:
		"Captcha":
			var ct = 0
			var lev = floor((float(Global.cards.size())/5.0)) + 1
			for c in Global.cards:
				if Global.cards.size()%5 == 0:
					#move em up
					c.sp.y -= 2*Global.sz.y/15
				else:
					#move everything in this level leftward
					ct += 1
					if ct > lev*5-5:
						c.sp.x -= .1*Global.sz.x
		_:
			pass

func RePlace():
	match Global.DeckType:
		"Captcha":
			var i = 0
			for c in Global.cards:
				i +=1
				c.sh = true
				if i == 1:
					$Replace.play()
				if (Global.cards.size()+1)%5 == 1:
					c.sp.y += 2*Global.sz.y/15
				if floor(float(i)/5.0) == floor(float(Global.cards.size())/5.0):
					c.sp.x -= .1*Global.sz.x
				else:
					c.sp.x -= .2*Global.sz.x
				if i%5 == 0:
					c.sp.y -= 4*Global.sz.y/15
					c.sp.x = 0.9*Global.sz.x
				await get_tree().create_timer(.2).timeout
		"Branch":
			var i =0
			for c in Global.cards:
				i+=1
				var lev = floor(log(i)/log(2))
				c.sp.x = (lev+1)*Global.sz.x/6
				c.sp.y = (i-2**lev+1)*Global.sz.y/((2**lev)+1)
		_:
			pass

func place(node):
	match Global.DeckType:
		"Captcha":
			var lev = floor(float(Global.cards.size())/5.0) +1
			node.sp.y = Global.sz.y/2 + (Global.sz.y/6)*(lev-1)
			node.sp.x = Global.sz.x/2 + (Global.sz.x*.1)*(Global.cards.size()%5)
		"Branch":
			var lev = floor(log(Global.cards.size()+1)/log(2))
			node.sp.x = (lev+1)*Global.sz.x/6
			node.sp.y = (Global.cards.size()+1-2**lev+1)*Global.sz.y/((2**lev)+1)
		_:
			node.sp.y = Global.sz.y/2
			node.sp.x = Global.sz.x/2


func kidswap(carda,cardb):#Assumes both cards have stuff
	var piv = cardb.ft.duplicate(true)
	if carda.ft.size() > 1:
		var size = carda.ft[1].texture.get_size()
		carda.ft[1].scale = Vector2(128.0/size.x,128.0/size.y)*2.0/(2.0**.8) / cardb.ft[0].scale
		carda.ft[1].position = Global.offset(cardb)
		carda.ft[1].reparent(cardb.ft[0],0)
	if cardb.ft.size() > 1:
		var size = cardb.ft[1].texture.get_size()
		cardb.ft[1].scale = Vector2(128.0/size.x,128.0/size.y)*2.0/(2.0**.8) / carda.ft[0].scale
		cardb.ft[1].position = Global.offset(carda)
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
	match Global.DeckType:
		"Captcha":
			if carda.ft.size() > 1:
				var tft = carda.ft[0]
				popitem.emit(carda.ft[1],carda.ft)
				$Snap.play()
				carda.ft = [tft].duplicate()
		"Branch":
			var i = Global.cards.find(carda); var t = .1*10.0/8.0
			if i == -1:
				if carda.ft.size() > 1:
					var tft = carda.ft[0]
					popitem.emit(carda.ft[1],carda.ft)
					$Snap.play()
					carda.ft = [tft].duplicate()
				return
			for c in Global.cards:
				if c.leaves[Global.cards.find(c)].begins_with(c.leaves[i]):
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
	match Global.DeckType:
		"Captcha":
			var a;var b;var ct = 0
			for c in Global.cards:
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
	match Global.DeckType:
		"Captcha":
			if Global.holding == null: #if youre not holding anything and youre just picking up
				return Global.cards[0] #grabs the first card
			for c in Global.cards: #if you are holding, and want to drop off
				if c != Global.holding:
					if free: #if youre looking for an "empty" card to deposit in
						if c.ft.size() < 2:
							return c #first empty nonheld card
					else: #when theres no empty cards
						return c #first nonheld card
			return null
		_:
			if Global.holding == null:
				for c in Global.cards:
					if c.mi == true:
						return c
			else:
				for c in Global.cards:
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
	if Global.holding !=null:
		cardish = true

func popcheck(swap):
	if get_local_mouse_position().clamp(Vector2.ZERO,Global.sz) != get_local_mouse_position():
		takeitem(Global.holding)
		if swap:
			swapall()

func storehelditem(n):
	$Store.pitch_scale = randf_range(.2,6)
	$Store.play()
	var p = null
	for f in Global.holding.ft:
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
	n.ft[1].position = Global.offset(n)
	Global.holding.queue_free()
	Global.holding = null
	popstop = true
	kidswap(n,n)
	popstop = false

func dropcheck():
	pass

func cardstore():
	match Global.DeckType:
		"Branch":
			pass
		_:
			pass
