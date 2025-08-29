extends Area2D
@export var card: PackedScene
@export var maxcards = 15
var mi: bool
var cards: int = 0
var sz = Vector2(1152,648)
var spread = []
var template = ["Captcha"]
var item = ["Book","Herb","Wall"]
signal popitem(thing: String)
signal clickable

func _input(event):
	if mi:
		if event.is_action_pressed("click"):
			addcard()
		if event.is_action_pressed("mclick"):
			placeitem(pickitem())
		if event.is_action_pressed("rclick"):
			takeitem()
		if event.is_action_pressed("Spacebar"):
			for n in get_children():
				if n.name.ends_with("Card"):
					takeitem()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func addcard():
	if cards == maxcards:
		return
	var new_card = card.instantiate()
	new_card.go(template + item)
	new_card.name = str(cards)+"Card"
	shift()
	place(new_card)
	add_child(new_card)
	cards+=1


func _on_mouse_entered() -> void:
	mi = true
	clickable.emit(self)
func _on_mouse_exited() -> void:
	mi=false
	clickable.emit(null)

func place(node):
	match template[0]:
		"Captcha":
			var lev = ceil(cards/5)+1
			node.position.y = sz.y/2 + (sz.y/6)*(lev-1)
			node.position.x = sz.x/2 + (sz.x*.1)*(cards%5)

func shift():
	#moves all existing cards. Do this before spawning in the next. assumes everything was placed correctly previously
	match template[0]:
		"Captcha":
			var ct = 0
			var lev = floor((cards/5)) + 1
			for n in get_children():
				if n.name.ends_with("Card"):
					if cards%5 == 0:
						#move em up
						n.position.y -= 2*sz.y/15
					else:
						#move everything in this level leftward
						ct += 1
						if ct > lev*5-5:
							n.position.x -= .1*sz.x

func placeitem(thing):
	var no = Node.new()
	glb.addsprite(no,thing,[])
	add_child(no)
	match template[0]:
		"Captcha": #places items at the last available card, or at the end of the array, forcing the first card out
			if cards == 0: return
			var kids = get_children()
			var latch = false
			for n in kids:
				if n.name.ends_with("Card"):
					if n.ft.size()<2:
						var kidos = glb.get_children()
						glb.get_children()[0].reparent(n.ft[0])
			if latch == false:#if you cant find an empty card
				#clear the first card
				takeitem()
				#place the last card
				placeitem(thing)
	remove_child(no)

func takeitem():
	match template[0]:
		"Captcha":
			var kids = get_children()
			for n in kids:
				if n.name.ends_with("Card"):
					if n.ft.size() > 2:
						var t = n.ft[0]
						popitem.emit(n.ft[1],n.ft)
						n.ft = [t]
						setitems()
						return
func setitems():
	match template[0]:
		"Captcha":
			var titem = ""
			var kids = get_children()
			var pn
			var latch = false
			for n in kids:
				if n.name.ends_with("Card"):
					if n.ft.size() < 2:#empty
						pn = n
						if latch == true:
							return
						latch = true
					else:
						glb.givekids(n,pn)
						pn = n
					
					
func pickitem() -> String:
	var dir := DirAccess.open("res://Art/Items")
	dir.list_dir_begin()
	var files:=[]
	for file: String in dir.get_files():
		if file.ends_with(".png"):
			files.append(file.split(".")[0])
	return files.pick_random()
