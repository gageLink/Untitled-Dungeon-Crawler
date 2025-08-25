extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.play("picker")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	scale = Vector2.ONE*.5
	if $Sprite2D.animation=="Holding":
		scale *=1.5
		global_position.y+=40


func _on_timer_timeout() -> void:
	if visible:
		if glb.holding != null:
			var fs =$Sprite2D.sprite_frames.get_frame_count($Sprite2D.animation)
			var nf = $Sprite2D.frame
			while nf == $Sprite2D.frame:
				nf = randi_range(0,fs)
			$Sprite2D.frame = nf
