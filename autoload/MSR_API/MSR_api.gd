extends Node

var debug := true

const API_BASE : String = "https://monster-siren.hypergryph.com/api/"
var global_user_content : Dictionary[String,String] = {}

func old_init_client() -> HTTPClient:
	var client := HTTPClient.new()
	var err := client.connect_to_host(API_BASE,443)
	if err != OK:
		print_debug("Error: Cannot make connect to MSRApi!(Error code:",err,")")
	
	# Wait for the response
	while client.get_status() == HTTPClient.STATUS_CONNECTING or client.get_status() == HTTPClient.STATUS_RESOLVING:
		client.poll()
		await get_tree().process_frame
	if client.get_status() != HTTPClient.STATUS_CONNECTED:
		print_debug("Error: Cannot connect to MSRApi!(Error code:",client.get_status(),")")
	
	return client

## This function will call MSR Api and get the response [br]
## It will request the url "https://monster-siren.hypergryph.com/api/" inside.
func old_call_api(api_extends:String,args:Dictionary[String,String],user_content:Dictionary[String,String]={}):
	var api_url := "api/" + api_extends
	
	var client := await old_init_client()
	
	var query_dic := args.merged(user_content)
	for i in query_dic.keys():
		query_dic[i] = (query_dic[i] as String).uri_encode()
	var query_string := client.query_string_from_dict(query_dic)
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(query_string.length())]
	var err = client.request(HTTPClient.METHOD_GET,api_url+query_string,headers,query_string)
	
	if err != OK:
		print_debug("Error: Cannot make request to MSRApi!(Error code:",err,")")
	
	# Wait for the response
	while client.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		client.poll()
		await get_tree().process_frame
	if not (client.get_status() == HTTPClient.STATUS_BODY or client.get_status() == HTTPClient.STATUS_CONNECTED):
		print_debug("Error: Cannot request MSRApi!(Error code:",client.get_status(),")")
	
	if not client.has_response():
		print_debug("Error: No response!")
	
	# If there is a response...
	headers = client.get_response_headers_as_dictionary() # Get response headers.
	if debug:
		print("code: ", client.get_response_code()) # Show response code.
		print("**headers:\\n", headers) # Show headers.
	
	# Getting the HTTP Body
	if client.is_response_chunked():
		# Does it use chunks?
		# print("Response is Chunked!")
		pass
	else:
		# Or just plain Content-Length
		var _bl = client.get_response_body_length()
		# print("Response Length: ", bl)
	# This method works for both anyway

	var rb = PackedByteArray() # Array that will hold the data.

	while client.get_status() == HTTPClient.STATUS_BODY:
		# While there is body left to be read
		client.poll()
		# Get a chunk.
		var chunk = client.read_response_body_chunk()
		if chunk.size() == 0:
			await get_tree().process_frame
		else:
			rb = rb + chunk # Append to read buffer.
	# Done!
	var json = rb.get_string_from_ascii()
	
	var res = JSON.parse_string(json)

	return res

## This function will call MSR Api and get the response [br]
## It will request the url "https://monster-siren.hypergryph.com/api/" inside.[br]
## @param [code]frommsr[/code] this will control whether the base url is appended to the url.[br]
## @param [code]trans2json[/code] this will control whether to convert the bytes data to json obj.
func call_api(api_extends:String,args:Dictionary[String,String],frommsr:bool=true,trans2json:bool=true,user_content:Dictionary[String,String]={}):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var res : Array = [{}]
	
	var _http_request_completed := func(_result:int, _response_code:int, _headers:PackedStringArray, body:PackedByteArray,res_a:Array,itrans2json:bool):
		if not itrans2json:
			res_a[0] = body
			return
		var json_parser := JSON.new()
		var err = json_parser.parse(body.get_string_from_utf8(),true)
		if err != OK:
			push_error("在JSON解析中发生了一个错误。\n",json_parser.get_error_message()," \nat line ",json_parser.get_error_line())
		res_a[0] = json_parser.data
		#res[0] = res_a[0]
		#print(str(res_a))
		#print(str(res))
	
	http_request.request_completed.connect(_http_request_completed.bind(res,trans2json))
	
	var api_url = (API_BASE + api_extends)if frommsr else api_extends
	
	# create query string from args
	var query_dic := args.merged(user_content)
	if not query_dic.is_empty():
		for i in query_dic.keys():
			query_dic[i] = (query_dic[i] as String).uri_encode()
		var query_string := http_request.query_string_from_dict(query_dic)
		api_url = api_url + "?" + query_string
	
	var error = http_request.request(api_url)
	if error != OK:
		push_error("在HTTP请求中发生了一个错误。(",error,")url:",api_url)
	
	await http_request.request_completed
	http_request.queue_free()
	return res[0]

## {"list";[S-MSR-S],"autoplay":%id%}
func get_all_songs()->Dictionary:
	var res = {} 
	var data = await call_api("songs",{})
	res = data["data"]
	var nlist : Array[StandardMSRSong] = []
	for i in res["list"]:
		nlist.append(StandardMSRSong.new().set_data(i))
	res["list"] = nlist
	return res
func get_all_albums()->Array[StandardMSRAlbum]:
	var res = {} 
	var data = await call_api("albums",{})
	res = data["data"]
	var nres : Array[StandardMSRAlbum] = []
	for i in res:
		nres.append(StandardMSRAlbum.new().set_data(i).tag_album())
	return nres
func get_song(id:String)->StandardMSRSong:
	var res
	var data = await call_api("song/"+str(id),{})
	res = StandardMSRSong.new().set_data(data["data"])
	return res
func get_album(id:String)->StandardMSRAlbum:
	var res
	var data = await call_api("album/"+str(id)+"/detail",{})
	res = StandardMSRAlbum.new().set_data(data["data"]).tag_album()
	return res
## {"list":[S-MSR-A],"end":true}
func search(keyword:String)->Dictionary:
	var res = {}
	var data = await call_api("search",{"keyword"=keyword})
	res = data["data"]["albums"]
	var nlist : Array[StandardMSRAlbum] = []
	for i in res["list"]:
		nlist.append(StandardMSRAlbum.new().set_data(i).tag_album())
	res["list"]=nlist
	return res

func _enter_tree() -> void:
	pass
