extends RigidBody2D
# Called when the node enters the scene tree for the first time.
@export var randy: bool
@export var item: String
var defs:= []

func _process(delta: float) -> void:
	if (position.x < 0) or(position.x > get_viewport_rect().size.x) or (position.y > get_viewport_rect().size.y):
		queue_free()


func go(newitem):
	item = pickitem(newitem)
	setitem()
	setcollis()

func setitem():
	if not item.ends_with(".png"):
		item+=".png"
	$Sprite.texture = ResourceLoader.load("res://Art/Items/"+item)
	$Sprite.scale = Vector2(defs[0],defs[0])

func setcollis():
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha($Sprite.texture.get_image())
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, $Sprite.texture.get_size()))
	for poly in polys:
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = poly
		collision_polygon.scale = $Sprite.scale
		collision_polygon.show()
		$Sprite.add_sibling.call_deferred(collision_polygon)
		# Generated polygon will not take into account the half-width and half-height offset
		# of the image when "centered" is on. So move it backwards by this amount so it lines up.
		if $Sprite.centered:
			collision_polygon.position -= $Sprite.texture.get_size()*$Sprite.scale/2

func pickitem(newitem) -> String:
	if randy:
		var dir := DirAccess.open("res://Art/Items")
		dir.list_dir_begin()
		var files:=[]
		for file: String in dir.get_files():
			if file.ends_with(".png"):
				files.append(file.split(".")[0])
		newitem = files.pick_random()
	if Dic.has(newitem):
		defs = Dic[newitem]
	else:
		defs = Dic["default"]
	return str(newitem)

#Dictionary
var Dic := {
	#of the form
	#ItemName:[Scale]
	"Captcha":[.5],
	"Quill":[3],
	"Book":[3],
	"Mushroom":[3.5],
	"Herb":[3],
	"Acorn":[1.5],
	"default":[.5]
}
