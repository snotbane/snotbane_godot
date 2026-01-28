
class_name TerminalCommandHost extends Node

static var RX_ARG_PARSE := RegEx.create_from_string(r"(?:([\"'`]).*\1)|(?:\b\w+\b)")

class TerminalCommand extends Object:
	var method : Callable
	var default_args : Array[Variant]
	var name : StringName :
		get: return TerminalCommandHost.registry.find_key(self)

	func _init(__method__: Callable, __name__: StringName, __default_args__: Array[Variant]) -> void:
		method = __method__
		default_args = __default_args__

		assert(not TerminalCommandHost.registry.has(__name__), "The TerminalCommand with the name \"%s\" already exists. This will replace the original one." % __name__)
		TerminalCommandHost.registry[__name__] = self

	func invoke(args: Array) -> void:
		# if args.size() != method.get_argument_count() > args.size() + default_args.size():
		# 	printerr("Invalid arguments: not enough arguments/defaults present.")
		# 	return
		# # args.resize()
		# while args.size() < method.get_argument_count():
		# 	args.push_back()
		# # while args.size() < registry[command_name].default_args.size():
		method.callv(args)


static var registry : Dictionary[StringName, TerminalCommand]


func receive_invocation(text: String) -> void:
	var arg_parse_matches : Array[RegExMatch] = RX_ARG_PARSE.search_all(text)
	if arg_parse_matches.is_empty(): return

	var command_name : StringName = arg_parse_matches[0].get_string()
	if command_name not in registry:
		printerr("No such command '%s' exists." % command_name)
		return

	arg_parse_matches.remove_at(0)
	var args : PackedStringArray
	for arg in arg_parse_matches:
		args.push_back(arg.get_string())

	registry[command_name].invoke(args)
