extends Control
var chatobj = preload("res://scene/chat.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_Receiver_chatReceived(Nickname, Msg):
	var NewChat:Chat = chatobj.instance()
	$ChatContainer.add_child(NewChat)
	NewChat.ReceiveMessage(Nickname,Msg)
	pass # Replace with function body.


func _on_Receiver_emmojiReceived(Nickname, Msg, Emojis):
	var NewChat:Chat = chatobj.instance()
	$ChatContainer.add_child(NewChat)
	NewChat.RececiveEmojis(Nickname,Msg,Emojis)
	pass # Replace with function body.
