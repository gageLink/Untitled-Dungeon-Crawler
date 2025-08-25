extends Area2D
var bloom = 0
var occ = false
var ct = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	modulate.a = .6
	pass # Replace with function body.


 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if occ:
		ct += 1
		visible = true
		#var r = get_child(2)empla
		#r.color = Color(r.color.r,r.color.g,r.color.b,(sin(ct*PI/50)+1)/2)
	#else:
		#var r = get_child(2)
		#r.color = Color(r.color.r,r.color.g,r.color.b,1)
		
	#if bloom == 0:
		#get_child(2).color = Color(1,1,1,1)
	#if bloom == 1:
		#get_child(2).color = Color(0,0,1,1)
	#if bloom == 2:
		#get_child(2).color = Color(1,0,1,1)
	##
	pass
