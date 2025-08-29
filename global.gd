extends Node

var DeckType = "Captcha"
var maxcards = 15 #yeah
var cards:=[]#mycards
var counter = 0
var items: int = 0#yuuuup how many items i got
var startcards: int = 2
var holding
var HSCYP = [null,null,null]#position, previous held card, frame counter
var sz = Vector2(1152,648)
#map stuff
var map = [];var facing;var curr;var prev;var NodeCt = 3;var tilesize = 15;

func addsprite(node, item, ft):
	if item is String:
		var Sprite = Sprite2D.new()
		Sprite.texture = ResourceLoader.load("res://Art/Items/"+item+".png")
		Sprite.texture.resource_name = item
		#set size. ideal sprite size is 128
		
		var size = Sprite.texture.get_size()
		Sprite.scale = Vector2(128.0/size.x,128.0/size.y)
		if ft.size() > 0:
			Sprite.position = offset(ft[0].name.split(str(0))[0])
		
		node.add_child(Sprite)
		ft.append(Sprite)
	if item is Array:
		var sc = Vector2(1.0,1.0)
		if node is Area2D: sc *=.65
		for i in item.size():
			var Sprite = Sprite2D.new()
			Sprite.texture = ResourceLoader.load("res://Art/Items/"+item[i]+".png")
			Sprite.texture.resource_name = item[i]
			#set size. ideal sprite size is 128. adjust with level
			var size = Sprite.texture.get_size()
			#var scale= Vector2(128.0/((1.0+float(i))**(0.2)*size.x),128.0/(((1.0+float(i))**.2)*size.y))
			var scale= Vector2((128.0/(size.x))/sc.x,(128.0/(size.y))/sc.y)
			scale /= (1+i)**.8
			Sprite.scale = scale
			sc *=scale
			Sprite.name = item[i]
			if i == 0:
				node.add_child(Sprite)
				ft.append(Sprite)
			else:
				var n = ft[i-1]
				Sprite.position = offset(n)
				n.add_child(Sprite)
				ft.append(Sprite)
	if item is Node:
		item.reparent(node,0)
	return ft
	
func offset(item)->Vector2:
	match item.ft[0].texture.resource_name:
		"Captcha": 
			return Vector2(-15,5)
		_:
			return Vector2.ZERO

func addcollis(ft):#collision will be added to the highest order item.
	var n = ft[0]
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(n.texture.get_image())
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, n.texture.get_size()))
	for poly in polys:
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = poly
		collision_polygon.scale = n.scale
		collision_polygon.show()
		n.add_sibling.call_deferred(collision_polygon)
		# Generated polygon will not take into account the half-width and half-height offset
		# of the image when "centered" is on. So move it backwards by this amount so it lines up.
		if n.centered:
			collision_polygon.position -= n.texture.get_size()*n.scale/2

func pickitem() -> String:
	var dir := ResourceLoader.list_directory("res://Art/Items")
	var files:=[]
	for file: String in dir:
		if file.ends_with(".png"):
			files.append(file.split(".")[0])
	return files.pick_random()

func readmap(node):#gets position of node
	
	var pos = Vector2.ZERO
	pos = Vector2((node.position.x-5)/10,(node.position.y-5)/10)
	return pos
