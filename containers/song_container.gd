extends VBoxContainer

#var name : String = ""
#var sourceUrl : String = ""
#var lyricUrl : String = ""
#var mvUrl : String = "null"
#var mvCoverUrl : String = "null"
#var artists : Array[String] = ["塞壬唱片-MSR"]

@onready var Cover : TextureRect = $HBoxContainer/SongCover
@onready var Name: Button = $HBoxContainer/Name
@onready var Author : Label = $Author
@onready var Playercom : Dictionary[String,MusicController] = {
	"Root" : $PlayerCom,
}

## Cover Size px
const CoverSize : Vector2i = Vector2i(128,128)
## Name Font Size px
const NameSize : int = 32
## Author Font Size px
const AuthorSize : int = 16


signal choose_this_song

var coverurl = ""
var lyricurl = ""
var sourceurl = ""

var lyric : LyricResource = null
var source : AudioStream = null

func set_data(asong:StandardMSRSong,simple:bool = false):
	Cover = $HBoxContainer/SongCover
	Name = $HBoxContainer/Name
	Author = $Author
	Playercom = {
		"Root" : $PlayerCom
	}
	
	Cover.custom_minimum_size = CoverSize
	Name.add_theme_font_size_override("font_size",NameSize)
	Author.label_settings.font_size = AuthorSize
	
	Name.text = asong.name
	Author.text = TranslationServer.translate("song_container.author").format([str(asong.artists)])
	
	Name.disabled = not simple
	
	if not simple:
		$HBoxContainer.alignment = ALIGNMENT_CENTER
		Cover.custom_minimum_size *= 2
		if (asong.mvCoverUrl == null) or (asong.mvCoverUrl == "<null>"):
			var from = (await MsrApi.get_album(asong.albumCid))
			coverurl = from.coverUrl
		else:
			coverurl = asong.mvCoverUrl
		lyricurl = asong.lyricUrl
		sourceurl = asong.sourceUrl
		load_picture()
		load_lyric()
		load_source()
	else:
		Cover.hide()
		Playercom.Root.hide()

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

func load_lyric():
	var retry_flag = false
	var lyric_data : PackedByteArray = await CacheSystem.load_cache(lyricurl)
	#print(texture_data)
	
	var lyric_string : String = lyric_data.get_string_from_utf8()
	
	retry_flag = lyric_string.is_empty()
	
	lyric = LyricResource.from_string(lyric_string)
	Playercom.Root.lyric = lyric
	
	if retry_flag:
		print("Warning:Cannot load lyric resource!str:",lyric_string)
		await CacheSystem.update_cache(lyricurl)
		load_lyric()

func load_source(update:bool=false):
	var retry_flag = false
	var source_data : PackedByteArray = await CacheSystem.load_cache(sourceurl)
	#print(texture_data)
	var stream : AudioStream = null
	
	retry_flag = source_data.is_empty() or update
	
	var ex = sourceurl.get_extension()
	var err = OK
	match ex:
		"wav": 
			stream = AudioStreamWAV.load_from_buffer(source_data,{"compress/mode":0})
		"ogg":
			stream = AudioStreamOggVorbis.load_from_buffer(source_data)
		"mp3":
			stream = AudioStreamMP3.load_from_buffer(source_data)
	
	retry_flag = (stream == null) or update
	
	if err != OK:
		print("Warning: Cannot load source from buffer (",err,")")
		retry_flag = true
	
	source = stream
	
	if retry_flag:
		await CacheSystem.update_cache(sourceurl)
		load_source()
	else:
		Playercom.Root.stream = source

func _on_name_pressed() -> void:
	choose_this_song.emit()

func _process(_delta: float) -> void:
	Playercom["Root"].custom_minimum_size = Vector2(self.size.x,100)
