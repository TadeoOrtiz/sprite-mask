@icon("res://addons/sprite-mask/icon.png")
@tool
class_name SpriteMask
extends Sprite2D


## Sprite Reinvented. Based in Aarhificial Idea
##
## A Sprite2D node but with the addition 
## of color search across two images
##

## Emitted when the [member skin_texture] applied.
signal skin_applied
## Emitted when the [member map_texture] changed.
signal map_changed
## Emitted when the [member base_texture] changed.
signal base_changed

## Base texture where [member map_texture] and [member skin_texture]
@export var base_texture: Texture2D:
	set(new_texture):
		base_texture = new_texture
		emit_signal("base_changed")
		if base_texture and base_texture.changed.get_connections().size() == 0:
			base_texture.changed.connect(_apply_skin)
		_apply_skin()

## Texture to scan
@export var map_texture: Texture2D:
	set(new_texture):
		map_texture = new_texture
		emit_signal("map_changed")
		if map_texture and map_texture.changed.get_connections().size() == 0:
			map_texture.changed.connect(_apply_skin)
		_apply_skin()

## Texture to apply by [member map_texture] colors
@export var skin_texture: Texture2D:
	set(new_texture):
		skin_texture = new_texture
		if skin_texture and skin_texture.changed.get_connections().size() == 0:
			skin_texture.changed.connect(_apply_skin)
		_apply_skin()

## This dictionary contain all pixels (color and position)
## of [member map_texture]
## [codeblock]
## var texture : Texture2D
## var texture_pixels = get_pixels(texture) 
## print(texture_pixels)
## 
## #Console
## {
## (0.1664, 0, 0.3031, 1): (0, 0),
## (0.1520, 0, 0.2451, 1): (0, 1),
## (0.1514, 0, 0.2444, 1): (1, 0),
## (0.1294, 0, 0.2589, 1): (1, 1),
## }
## [/codeblock]
var pixels_map: Dictionary

## This function return [Dictionary] with pixel color and position
func get_pixels(_texture: Texture2D) -> Dictionary:
	var dir: Dictionary
	if _texture:
		# Get image
		var image: Image = _texture.get_image()
		
		var heigth := _texture.get_height()
		var width := _texture.get_width()
		var pixel_pos: Vector2i
		
		# Travel image
		for x in width:
			for y in heigth:
				pixel_pos = Vector2i(x, y)
				var pixel_color = image.get_pixelv(pixel_pos)
				
				# Add only pixels non-transparent
				if pixel_color.a != 0:
					dir[pixel_color] = pixel_pos
	
	return dir

## Apply skin_texture to base_texture with
## information of map_pixels and create a new texture
## to apply on the sprite texture
func _apply_skin():
	if not base_texture:
		texture = null
		queue_redraw()
		return
	else:
		texture = base_texture
		queue_redraw()
	
	if map_texture and skin_texture:
		if map_texture.get_size() != skin_texture.get_size():
			texture = base_texture
			printerr("Incompatible Skin")
			queue_redraw()
			return
		
		pixels_map = get_pixels(map_texture)
		var new_image: Image = base_texture.get_image().duplicate() as Image
		new_image.convert(Image.FORMAT_RGBA8)
		var skin_image: Image = skin_texture.get_image() as Image
		
		for x in base_texture.get_width():
			for y in base_texture.get_height():
				var pixel_pos: Vector2i = Vector2i(x, y)
				var pixel_color: Color = new_image.get_pixelv(pixel_pos)
				if pixel_color.a == 0 or not pixels_map.has(pixel_color):
					continue
				
				var new_pixel_color: Color = skin_image.get_pixelv(pixels_map[pixel_color])
				new_image.set_pixelv(pixel_pos, new_pixel_color)
				
		
		texture = ImageTexture.create_from_image(new_image)
		emit_signal("skin_applied")
		queue_redraw()

