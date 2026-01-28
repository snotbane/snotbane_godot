
class_name CliAutoload extends Node

const AUTOLOAD_NAME := "cli_autoload"
const AUTOLOAD_PATH := "modules/cli/CliAutoload.gd"

static var DEFAULT_SCENE : PackedScene :
	get: return load("uid://c1nlgw0r4lj06")


func _init() -> void:
	add_child.call_deferred(DEFAULT_SCENE.instantiate())
