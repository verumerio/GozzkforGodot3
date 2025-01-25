extends Node

#ChannelID를 원하는 방송에 맞춰서 변형해 주세요. 방송인의 주소 제일 뒤에있는 문자열이 고유 Channel ID 입니다.
export var ChannelID = ''
export var ChannelIDDirect = ''
export var NID_AUT = ''
export var NID_SES = ''
#성인전용을 걸어놨을 경우 ChatChannelID가 검색 안되는 문제가 있습니다. 커스텀으로 Chat Channel ID를 기입해서 우회할 수 있도록 할 예정입니다.
var ChatChannelID:String = ''
var AccessToken = null
var socket = WebSocketClient.new()
#var socket = WebSocketPeer.new()
var reconnect_time = 0.0
var reconnectTimer:Timer 
var connected:bool
var firstTime = true
var ready = false
var peerID
var stats
const REQTICK = 1.0
signal chatReceived(Nickname,Msg)
# Called when the node enters the scene tree for the first time.
func _ready():
	#Channel ID를 통해서 Chat Channel ID를 찾습니다.
	var cookie = []
	var NID1 = '"NID_AUT": "%s"'%[NID_AUT]
	var NID2 = '"NID_SES": "%s"'%[NID_SES]
	cookie.push_back(NID1)
	cookie.push_back(NID2)
	var HTTPSREQ = 'https://api.chzzk.naver.com/polling/v2/channels/%s/live-status'%ChannelID
	var HTTP = HTTPRequest.new()
	add_child(HTTP)
	HTTP.connect("request_completed",self,"_on_request_completed")
#	HTTP.request_completed.connect(_on_cid_request_completed)
	#HTTP.request(HTTPSREQ)
	if ChannelIDDirect == '':
		HTTP.request(HTTPSREQ,cookie)
	else :
		ChatChannelID = ChannelIDDirect
#	await HTTP.request_completed
	yield(get_tree().create_timer(1),"timeout")
	print_debug(ChatChannelID)
	#Channel 에 접근 할 수 있게 해주는 Token을 받습니다.
	var TokenURL = 'https://comm-api.game.naver.com/nng_main/v1/chats/access-token?channelId=%s&chatType=STREAMING'%ChatChannelID
	var TOKENHTTP = HTTPRequest.new()
	add_child(TOKENHTTP)
#	TOKENHTTP.request_completed.connect(_on_token_request_completed)
	TOKENHTTP.connect("request_completed",self,"_on_token_request_completed")
	TOKENHTTP.request(TokenURL,cookie)
	yield(get_tree().create_timer(1),"timeout")
	print_debug(AccessToken)
	#yield(TOKENHTTP.request_completed,"finished")
	socket.connect("connection_closed", self, "_closed")
	socket.connect("connection_error", self, "_closed")
	socket.connect("connection_established", self, "_on_connected")
	socket.connect("data_received", self, "_on_data")
	
	var err = socket.connect_to_url('wss://kr-ss3.chat.naver.com/chat')
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		print("connected to chat server")
	yield(get_tree().create_timer(1),"timeout")
	print_debug(socket.get_connection_status())
	#socket.connect_to_url('wss://kr-ss3.chat.naver.com/chat')
	ready=true
	

	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ready:
		socket.poll()
		if socket == null:
			return
		stats = socket.get_connection_status()
		if(stats == 2):
			if ChatChannelID == '':return
			reconnect_time -= delta
			if reconnect_time<0 && !firstTime:
				_on_send('{"ver": "3","cmd": 10000}')
				reconnect_time = REQTICK

	if Input.is_key_pressed(90):
		print(stats)
		
		pass
func _on_request_completed(result, response_code, headers, body):
	if response_code==404:
		print("ERROR:404 BAD REQUEST | Check Channel ID")
		#ChatReceived.emit("에러","Channel ID를 확인해주세요")
		emit_signal("Chat_Received","Error","Channel ID 재확인 요청")
		return
	var dic = parse_json(body.get_string_from_utf8())
	var dic2 = dic["content"]
	ChatChannelID = dic2["chatChannelId"]
	

func _on_token_request_completed(result, response_code, headers, body):
	#AccessToken = parse_json(body.get_string_from_utf8())['content']['accessToken']
	var dic = parse_json(body.get_string_from_utf8())
	var dic2 = dic['content']
	AccessToken = dic2["accessToken"]
	
func _on_data():
	var payload = parse_json(socket.get_peer(1).get_packet().get_string_from_utf8())
	var bdy = payload['bdy']
	if bdy is Array:
		for eachBody in bdy:
			if eachBody.profile == null:continue
			var Profile = parse_json(eachBody['profile'])
			if Profile.has('nickname'):
				#print_debug(str(Profile['nickname'])+"/"+str(eachBody['msg']))
				emit_signal("chatReceived",Profile['nickname'],eachBody['msg'])

	
func _on_send(var sended):
	var msg = ['text',sended,{}]
	var msg_str = JSON.print(msg)
	socket.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	socket.get_peer(1).put_packet(sended.to_utf8())
	
func _on_connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	var INPUT = '{"ver":"3","cmd":100,"svcid":"game","cid":"%s","bdy":{"uid":null,"devType":2001,"accTkn":"%s","auth":"READ","libVer":"4.9.3","osVer":"Windows/10","devName":"Google Chrome/131.0.0.0","locale":"ko","timezone":"Asia/Seoul"},"tid":1}'%[ChatChannelID,AccessToken]
	_on_send(INPUT)
	reconnect_time = REQTICK
	firstTime=false


func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Connection closed, clean: ", was_clean)
	set_process(false)

