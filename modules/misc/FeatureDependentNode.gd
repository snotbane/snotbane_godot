## This node will only exist (or be visible) if certain feature tags are present.
class_name FeatureDependentNode extends Node

## If enabled, this node will not be destroyed but it will be kept and made invisible. Only works for nodes that have the [member visible] property. Also, this script will always be removed at runtime even if the node is kept.
@export var keep_invisible : bool = false

## Determines if this node should be kept, if the feature tags match this rule.
@export_enum("Any present", "All present", "None present") var keep_when : int = ANY
enum { ANY, ALL, NONE }

## List of features to check for. See [url https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html]
@export var features : PackedStringArray

func _init() -> void:
	var should_keep : bool = keep_when != ANY or features.is_empty()
	for feature in features:
		if OS.has_feature(feature):
			match keep_when:
				ANY: should_keep = true; break
				ALL: continue
				NONE: should_keep = false; break
		else:
			match keep_when:
				ALL: should_keep = false; break

	if keep_invisible:
		if get(&"visible") != null:
			self.visible = should_keep
		self.set_script(null)
	elif not should_keep:
		queue_free()
