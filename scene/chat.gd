extends Control
class_name Chat
onready var NicknameLabel:Label = $HBoxContainer/Name
var GReader = GifReader.new()
var emojiDic : Dictionary
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rect_global_position.y<-20 :
		queue_free()
	pass

func ReceiveMessage(Nickname,Message):
	NicknameLabel.text = Nickname
	var newcharlabel = NicknameLabel.duplicate()
	newcharlabel.text = Message
	$HBoxContainer.add_child(newcharlabel)
	pass
	
func RececiveEmojis(Nickname, Message, Emojis:Dictionary):
	NicknameLabel.text = Nickname
	print(Message)
	
	for keys in Emojis.keys():
		print(Emojis[keys]+"+"+keys)
		imgload(Emojis[keys],keys)
		yield(get_tree().create_timer(0.5),"timeout")
	writetxt(Message)
	pass
	
func imgload(imgurl,imgnum):
	var imgreq = HTTPRequest.new()
	add_child(imgreq)
	imgreq.connect("request_completed",self,"_img_request")
	if imgurl.substr(imgurl.length()-3) == "gif" :
		imgreq.download_file = "user://"+imgnum+".gif"
	else:
		imgreq.download_file = "user://"+imgnum+".png"
	imgreq.request(imgurl)
	yield(imgreq,"request_completed")
	if imgurl.substr(imgurl.length()-3) == "gif" :
		emojiDic[str(imgnum)] = convgif("user://"+imgnum+".gif")
		print("dictionary added (gif)")
	else:
		var imt = ImageTexture.new()
		var img = Image.new()
		img.load("user://"+imgnum+".png")
		imt.create_from_image(img)
		emojiDic[str(imgnum)] = imt
		print("dictionary added (png)")
	
	pass

func _img_request(result, response_code, headers, body):
	if response_code==200:
		print("img loaded")
	pass
	
func convgif(var source_file):
	var img = ImageTexture.new()
	var tex = GReader.read(source_file)
	if tex == null:
		return FAILED
	var sf = SpriteFrames.new()
	var minLength = 1000
	var maxLength = 0
	#sf.add_frame("default", tex.get_frame_texture(0))
	img = tex
	return img

func writetxt(Message):
	print(emojiDic)
	var temp = ""
	var checksum = false
	while Message != "":
		checksum = false
		for keyz in emojiDic.keys():
			var tempchar = "{:"+keyz+":}"
			if Message.find(tempchar) == 0 :
				checksum = true
				var newcharlabel = NicknameLabel.duplicate()
				newcharlabel.text = temp
				$HBoxContainer.add_child(newcharlabel)
				temp = ""
				var stamp = TextureRect.new()
				stamp.texture = emojiDic[str(keyz)]
				stamp.expand=true
				stamp.rect_min_size.x=30
				stamp.rect_min_size.y=30
				$HBoxContainer.add_child(stamp)
				Message.erase(0,tempchar.length())
		if !checksum :
			temp+=Message.substr(0,1)
			Message.erase(0,1)
	pass
