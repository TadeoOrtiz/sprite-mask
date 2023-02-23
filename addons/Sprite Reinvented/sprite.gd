@icon("res://addons/Sprite Reinvented/icon.png")
@tool
extends Sprite2D
class_name SpriteReinvented

## Sprite Reinvented. Origin Idea By aarhificial
##
## A Sprite2D node but with the addition 
## of color search across two images
##

##Emitted when the [member skin_texture] changes.
signal skin_changed

##Texture to scan
@export var map_texture : Texture2D = null:
	set(new_texture):
		map_texture = new_texture
		map_pixels = get_pixels(map_texture)
		apply_skin()

##Texture to apply by [member map_texture] colors
@export var skin_texture : Texture2D = null:
	set(new_texture):
		skin_texture = new_texture
		apply_skin()
		emit_signal("skin_changed")

##Base texture where [member map_texture] and [member skin_texture]
@export var base_texture : Texture2D = null:
	set(new_texture):
		base_texture = new_texture
		apply_skin()

##This dictionary contain all pixels (color and position) 
##to [member map_texture] [br]
## [codeblock]
## var texture : Texture2D
## var texture_pixels = get_pixels(texture) 
## print(texture_pixels)
##
## #Console
## {(1, 1): (0.1294, 0, 0.2431, 1), (1, 2): (0.1804, 0.0353, 0.3098, 1)}
## [/codeblock]
var map_pixels : Dictionary = {}

##This function return [Dictionary] with pixel position and color
func get_pixels(_texture : Texture2D):
	var dir := {}
	if _texture:
		##Create image
		var image : Image = _texture.get_image()
		
		var heigth := _texture.get_height()
		var width := _texture.get_width()
		
		var pixel_pos : Vector2i
		
		for x in width:
			for y in heigth:
				pixel_pos = Vector2i(x,y)
				var pixel_color = image.get_pixelv(pixel_pos)
				if pixel_color.a != 0:
					dir[pixel_pos] = pixel_color
	return dir

##Apply [member skin_texture] to [member base_texture] with
##information of [member map_pixels] and create a new texture
##to apply on the sprite texture
func apply_skin():
	if base_texture and skin_texture and map_texture:
		var new_image : Image = base_texture.get_image().duplicate()
		var skin_image : Image = skin_texture.get_image().duplicate()
		
		var width = new_image.get_width()
		var heigth = new_image.get_height()
		
		for cell_x in width:
			for cell_y in heigth:
				
				var pixel_pos = Vector2i(cell_x, cell_y)
				var pixel_color = new_image.get_pixelv(pixel_pos)
				
				if pixel_color.a != 0:
					var map_pos = map_pixels.find_key(pixel_color)
					
					if map_pos:
						var skin_color = skin_image.get_pixelv(map_pos)
						new_image.set_pixelv(pixel_pos, skin_color)
		
		var image_texture = ImageTexture.create_from_image(new_image)
		texture = image_texture
