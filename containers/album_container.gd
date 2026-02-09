extends VBoxContainer

@onready var Cover : TextureRect = $HBoxContainer/AlbumCover
@onready var Name: Button = $HBoxContainer/Name
@onready var Author : Label = $Author
@onready var Intro : Label = $Intro
@onready var Visible : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

## Cover Size px
const CoverSize : Vector2i = Vector2i(128,128)
## Name Font Size px
const NameSize : int = 32
## Author Font Size px
const AuthorSize : int = 16
## Intro Font Size
const IntroSize : int = 24

signal choose_this_album

var coverurl = ""
var load_tex_thread : Thread


func set_data(aalbum:StandardMSRAlbum,simple:bool = false):
	Cover = $HBoxContainer/AlbumCover
	Name = $HBoxContainer/Name
	Author = $Author
	Intro = $Intro
	Visible = $VisibleOnScreenNotifier2D
	
	Cover.custom_minimum_size = CoverSize
	Visible.rect = Rect2(Vector2.ZERO,CoverSize)
	Name.add_theme_font_size_override("font_size",NameSize)
	Author.label_settings.font_size = AuthorSize
	Intro.label_settings.font_size = IntroSize
	
	Name.text = aalbum.name
	Author.text = TranslationServer.translate("album_container.author").format([aalbum.belong] if aalbum.artists.is_empty() else [str(aalbum.artists)])
	Intro.text = aalbum.intro
	Visible.screen_entered.connect(once_load_texture)
	
	Name.disabled = not simple
	
	if simple:
		coverurl = aalbum.coverUrl
	else:
		Cover.custom_minimum_size *= 2
		coverurl = aalbum.coverDeUrl
		$HBoxContainer.alignment = ALIGNMENT_CENTER
	#load_picture()

var once_load_flag = false
func once_load_texture():
	if once_load_flag:
		return
	once_load_flag = true
	load_picture()
		

func load_picture():
	var retry_flag = false
	var texture_data : PackedByteArray = await CacheSystem.load_cache(coverurl)
	#print(texture_data)
	var image  = Image.new()
	
	var ex = coverurl.get_extension()
	var err = OK
	match ex:
		"jpg":
			err = image.load_jpg_from_buffer(texture_data)
		"png":
			err = image.load_png_from_buffer(texture_data)
		"svg":
			err = image.load_svg_from_buffer(texture_data)
		"bmp":
			err = image.load_bmp_from_buffer(texture_data)
		"ktx":
			err = image.load_ktx_from_buffer(texture_data)
		"tga":
			err = image.load_tga_from_buffer(texture_data)
		"webp":
			err = image.load_webp_from_buffer(texture_data)
	if err != OK:
		print("Warning: Cannot load image from buffer (",err,")")
		retry_flag = true
	var texture = ImageTexture.create_from_image(image) 
	Cover.texture = texture
	if retry_flag:
		await CacheSystem.update_cache(coverurl)
		load_picture()

func _on_name_pressed() -> void:
	choose_this_album.emit()

func _exit_tree() -> void:
	if load_tex_thread == null:
		return
	load_tex_thread.wait_to_finish()
	load_tex_thread.free()
