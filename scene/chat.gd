extends Control
class_name Chat
onready var NicknameLabel:Label = $HBoxContainer/Name
onready var MessageLabel:Label = $HBoxContainer/Dialog

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
	MessageLabel.text = Message
	pass
