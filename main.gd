extends Node

@onready var http_request = $WordapiRequester
var words = []

func _ready():
	fetch_words()

func fetch_words():
	var url = "https://random-word-api.herokuapp.com/word?number=10"  # Adjust for more words
	http_request.request(url)

func _on_word_api_requester_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		words = json  # Assuming it returns an array of strings
		print("Fetched words: ", words)
		# now, spawn word objects in the game
		spawn_words()
	else:
		print("Failed to fetch words")

func spawn_words():
	for word in words:
		# create a word node (we'll define this next)
		var word_node = preload("res://word.tscn").instantiate()
		word_node.set_word(word)
		word_node.position = Vector2(randf_range(0, 800), randf_range(0, 600))  # random position
		add_child(word_node)


func fetch_cat():
	var url = "https://api.thecatapi.com/v1/images/search"
	$CatRequester.request(url)

func _on_cat_requester_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var image_url = json[0]["url"]
	# load texture (use a separate httprequest for image)
	var image_request = HTTPRequest.new()
	add_child(image_request)
	image_request.request(image_url)
	# then set to sprite
