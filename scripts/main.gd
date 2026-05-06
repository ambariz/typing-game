extends Node2D

var words = []
var fallback_words = ["cat", "jump", "code", "run", "fast", "play", "rise", "win", "goal", "climb"]

var current_index = 0
var current_word = ""
var typed = ""

var step_positions = []
var current_step = 0

var game_ready = false

@onready var player = $player
@onready var label = $CanvasLayer/WordLabel
@onready var http = $WordAPI

func _ready():
	label.text = "LOADING..."
	http.request_completed.connect(_on_request_completed)
	fetch_words()

func fetch_words():
	var url = "https://random-words-api.kushcreates.com/api?language=en&type=lowercase&words=10"
	http.request(url)

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())

		if typeof(json) == TYPE_ARRAY:
			words = []

			for item in json:
				if typeof(item) == TYPE_DICTIONARY and item.has("word"):
					var w = item["word"].to_lower()
					if w.length() >= 3 and w.length() <= 10:
						words.append(w)

			if words.size() < 3:
				use_fallback()
		else:
			use_fallback()
	else:
		use_fallback()

	start_game_after_words()

func use_fallback():
	words = fallback_words

func start_game_after_words():
	current_index = 0
	current_step = 0
	setup_steps()
	start_next_word()
	game_ready = true

func setup_steps():
	step_positions.clear()

	var start_pos = player.position
	var height_step = 120
	var side_offset = 120

	for i in range(words.size()):
		var x = start_pos.x + (side_offset if i % 2 == 0 else -side_offset)
		var y = start_pos.y - (height_step * (i + 1))
		step_positions.append(Vector2(x, y))

func start_next_word():
	if current_index >= words.size():
		win_game()
		return

	current_word = words[current_index]
	typed = ""
	update_display()

func _input(event):
	if not game_ready:
		return

	if event is InputEventKey and event.pressed:
		var char = OS.get_keycode_string(event.keycode).to_lower()

		if char.length() == 1 and char.is_valid_identifier():
			typed += char
			update_display()

			if typed == current_word:
				word_completed()
			elif not current_word.begins_with(typed):
				game_over()

		if event.keycode == KEY_BACKSPACE:
			if typed.length() > 0:
				typed = typed.substr(0, typed.length() - 1)
				update_display()

func update_display():
	var remaining = current_word.substr(typed.length())
	label.text = "|" + remaining

func word_completed():
	move_player_to_next_step()
	current_index += 1
	await get_tree().create_timer(0.4).timeout
	start_next_word()

func move_player_to_next_step():
	if current_step >= step_positions.size():
		win_game()
		return

	var target = step_positions[current_step]
	var dir = 1 if target.x > player.position.x else -1
	player.jump_with_side(dir)
	current_step += 1

func game_over():
	label.text = "FAILED"
	set_process_input(false)
	fail_fall()

func fail_fall():
	if step_positions.size() > 0:
		player.position.x = step_positions[0].x
	player.velocity.y = -player.jump_force * 0.5

func win_game():
	label.text = "YOU WIN!"
	set_process_input(false)
