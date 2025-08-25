extends Area2D
var template
var tdef := []
var item
var idef := []
var ct =0
var mi := false

func _process(delta: float) -> void:
	var shake = Vector2(randf_range(-1,1),randf_range(-1,1)) * tdef[3]
	$Template/Item.position = shake + Vector2(tdef[1],tdef[2])
	ct+=1
	if ct > 200: ct=0
	var ft = sin(ct*PI/100)*10
	$Template.position.y = ft
	if mi == true:
		$Template.rotation = move_toward($Template.rotation,sin(ct*PI/50)*PI/8,delta)
	else: 
		if $Template.rotation != 0: $Template.rotation = move_toward($Template.rotation,0,delta)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#item = pickitem()
	getdefs()
	setup()
	$Template.texture=ResourceLoader.load("res://Art/Items/"+template+".png")
	setcollis()
	
func go():
		getdefs()
		setup()
		settexts()
		setcollis()


func settexts():
	if item != "":
		$Template/Item.texture = ResourceLoader.load("res://Art/Items/"+item+".png")
	else: $Template/Item.texture = null
	$Template.texture=ResourceLoader.load("res://Art/Items/"+template+".png")

func setcollis():
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha($Template.texture.get_image())
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, $Template.texture.get_size()))
	for poly in polys:
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = poly
		collision_polygon.scale = $Template.scale
		collision_polygon.show()
		$Template.add_sibling.call_deferred(collision_polygon)
		# Generated polygon will not take into account the half-width and half-height offset
		# of the image when "centered" is on. So move it backwards by this amount so it lines up.
		if $Template.centered:
			collision_polygon.position -= $Template.texture.get_size()*$Template.scale/2

func getdefs():
	if cards.has(template):
		tdef = cards[template]
	else:
		tdef = cards["default"]
	if items.has(item):
		idef = items[item]
	else:
		idef = items["default"]
		
func setup():
	$Template.scale = Vector2(tdef[0],tdef[0])
	$Template.position = Vector2(randf_range(-1,1),randf_range(-1,1)) * tdef[3]
	
	$Template/Item.scale = Vector2(idef[0],idef[0])
	$Template/Item.position = Vector2(tdef[1],tdef[2])
	
func pickitem() -> String:
	var dir := DirAccess.open("res://Art/Items")
	dir.list_dir_begin()
	var files:=[""]
	for file: String in dir.get_files():
		if file.ends_with(".png"):
			files.append(file.split(".")[0])
	return files.pick_random()

func _on_mouse_entered() -> void:
	mi=true
func _on_mouse_exited() -> void:
	mi=false

var cards = {
	#of the form
	#CardType:[scale,itemoffset.x,itemoffset.y,shake]
	#captcha uses FIFO ordering
	"Captcha":[.75,-13,5,5],
	"default":[1]
}
var items := {
	#of the form
	#ItemName:[Scale]
	"Captcha":[.5],
	"Quill":[3],
	"Book":[3],
	"Mushroom":[3.5],
	"Herb":[3],
	"Acorn":[2],
	"default":[.5]
}
