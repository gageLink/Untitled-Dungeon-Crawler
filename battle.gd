extends Node2D
@export var enemy: PackedScene
var enemies = [];var NewsTO = 3.0;var timer

func _ready() -> void:
	initbattle()

func initbattle():
	for i in randi_range(1,5):
		var e = enemy.instantiate()
		e.EnemyName = dic.EBF[glb.floor].pick_random()
		e.expire.connect(expire)
		add_child(e)
		e.loadattributes()
		e.position = Vector2(randi_range(100,glb.sz.x-100),randi_range(100,glb.sz.y-100))
		enemies.append(e)
	pass

func expire(enny,COD):
	var q = dic.expirationquotes.pick_random()
	$Label.text = enny.EnemyName + q[0] + COD + q[1]
	$NewsTimer.start(NewsTO)
	remove_child(enny)
	enemies.erase(enny)
	enny.queue_free()
	pass

func remlab():
	$Label.text = ""
	remove_child(timer)
