extends CanvasLayer
class_name DevConsole

@onready var console: RichTextLabel = %Console
@onready var text_input: LineEdit = %TextInput

var autocomplete_methods: Array = []

var history: Array[String] = []
var history_index: int = -1
enum history_direction {
	NEXT = -1,
	PREVIOUS = 1
}


func _ready() -> void:
	autocomplete_methods = get_script() \
		.get_script_method_list() \
		.map(func(method: Dictionary): return method.name)


func _run_command(command: String) -> void:
	var expression := Expression.new()
	var parse_error := expression.parse(command)
	if parse_error != OK:
		_print_error(expression.get_error_text())
		return

	var result = expression.execute([], self)
	if result != null:
		_print_result(str(result))
	else:
		_print_error(expression.get_error_text())


func _move_caret_to_end():
	text_input.caret_column = text_input.text.length()


func _set_history(direction: history_direction):
	if history.size() == 0: return
	history_index = clamp(history_index + direction, 0, history.size() - 1)
	text_input.text = history[history_index]
	_move_caret_to_end()


func _print_result(message: String) -> void:
	console.text += "%s\n" % message


func _print_error(message: String) -> void:
	console.text += "[color=#FF0000]%s[/color]\n" % message


func get_sum() -> int:
	return 5 + 5


func _on_text_input_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("console_submit"):
		history.push_front(text_input.text)
		_run_command(text_input.text)
		history_index = -1
		text_input.clear()

	elif event.is_action_released("console_previous"):
		_set_history(history_direction.PREVIOUS)

	elif event.is_action_released("console_next"):
		_set_history(history_direction.NEXT)

	elif event.is_action_released("console_autocomplete"):
		if text_input.text.is_empty(): return

		var found_methods = autocomplete_methods.filter(
			func(method_name: String):
				return method_name.begins_with(text_input.text))

		text_input.text = found_methods.front()
		_move_caret_to_end()
