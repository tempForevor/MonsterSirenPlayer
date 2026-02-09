extends Control

@onready var MainTabCt : TabContainer = %Main
@onready var AllAlbumsContent : VBoxContainer = $Main/all_albums/ResContainer/ResContainer
@onready var SearchText : LineEdit = %Search
@onready var SearchRes : VBoxContainer = $Main/search/Container/Container/ResContainer/ResContainer
@onready var SearchResResizerCt : ScrollContainer = $Main/search/Container/Container/ResContainer
@onready var SearchResizerCt : VBoxContainer = $Main/search/Container/Container
@onready var SearchCt : HSplitContainer = $Main/search/Container/Container/SearchContainer

func _init() -> void:
	ScenesVariables.MonsterSirenPlayer = self

func _ready() -> void:
	for i in MainTabCt.get_children():
		if not (i is Control):
			continue
		MainTabCt.set_tab_title(MainTabCt.get_tab_idx_from_control(i),TranslationServer.translate("maintabct."+i.name+".title"))
		MainTabCt.set_tab_tooltip(MainTabCt.get_tab_idx_from_control(i),TranslationServer.translate("maintabct."+i.name+".tooltip"))
	_on_main_tab_selected(0)
	SearchResizerCt.custom_minimum_size = DisplayServer.window_get_size()
	var ts = DisplayServer.window_get_size()
	ts.y -= SearchCt.size.y
	SearchResResizerCt.custom_minimum_size = ts

func _on_main_tab_selected(tab: int) -> void:
	if tab == 0:
		print("loading albums...")
		if AllAlbumsContent == null:
			return
		PlayerUtil.reset_res_container(AllAlbumsContent)
		var r := await MsrApi.get_all_albums()
		for i in r:
			AllAlbumsContent.add_child(await PlayerUtil.create_album_detail_label(i))

func _on_search() -> void:
	print("loading search results...")
	PlayerUtil.reset_res_container(SearchRes)
	var r := await MsrApi.search(str(SearchText.text))
	var rl : Array[StandardMSRAlbum] = r["list"]
	for i in rl:
		SearchRes.add_child(await PlayerUtil.create_album_detail_label(i))
	var el := Label.new()
	el.text = "main.search.isend" if str(r["end"]) == "true" else "main.search.isnotend"
	el.add_theme_color_override("font_color",Color.DARK_TURQUOISE)
	SearchRes.add_child(el)
