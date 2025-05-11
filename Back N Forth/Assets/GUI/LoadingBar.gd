extends TextureProgress

onready var text = $Text
func _process(delta):
	text.bbcode_text = "[nervous][sparkle c1=blue c2=black] loading... [" + str(round(value)) + "][/sparkle][/nervous]"
