extends Node

var trans = {
	" ":"%20",
	"+":"%2B",
	"&":"%26",
	"=":"%3D",
	"<":"%3C",
	">":"%3E",
	"\"":"%22",
	"#":"%23",
	",":"%2C",
	"{":"%7B",
	"}":"%7D",
	"|":"%7C",
	"\\":"%5C",
	"^":"%5E",
	"~":"%7E",
	"[":"%5B",
	"]":"%5D",
	"`":"%60",
	";":"%3B",
	#"/":"%2F", we choose to not compute it
	"?":"%3F",
	":":"%3A",
	"@":"%40",
	"$":"%24"

#	"%":"%25" Exactly, you should judge this symbol specially
}

func encode(raw:String):
	var res = String(raw)
	res = res.replace("%","%25")
	for i in trans.keys():
		if(i=="%"):
			continue
		res = res.replace(i,trans[i])
	return res

func decode(url:String):
	var res = String(url)
	for i in trans.keys():
		res = res.replace(trans[i],i)
	res = res.replace("%25","%")
	return res

func noprefix(url:String)->String:
	var flag := false
	for i in range(0,url.length()):
		if url[i] == "/":
			if flag:
				return url.substr(i+1)
			flag = true
	return url

func withprefix(url:String)->String:
	return "https://"+url
