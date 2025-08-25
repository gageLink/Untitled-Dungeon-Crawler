extends Node
#map stuff
var map = [];var facing;var curr;var prev;var NodeCt = 3;var tilesize = 15;


func readmap(node):#gets position of node
	
	var pos = Vector2.ZERO
	pos = Vector2((node.position.x-5)/10,(node.position.y-5)/10)
	return pos
