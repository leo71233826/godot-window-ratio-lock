extends Node

# Whether the window is currently being resized.
var is_resizing = false

# The previous size of the window before the last resize event.
var previous_size = Vector2i.ZERO

# The allowed aspect ratio range for the window. 
# x: minimum ratio (width / height), y: maximum ratio.
@export var ratio_range: Vector2 = Vector2(4.0/3, 16.0/9)

# Called when the node is added to the scene tree.
func _ready() -> void:
	# Connect to the window's size_changed signal to handle resizing.
	get_window().connect("size_changed", Callable(self, "_on_window_size_changed"))
	previous_size = get_window().size

# Callback function triggered when the window size changes.
func _on_window_size_changed():
	if is_resizing:
		return
	is_resizing = true

	# Wait one frame to avoid rapid triggering.
	await get_tree().process_frame

	var current_size = get_window().size
	var delta = current_size - previous_size
	var new_size: Vector2i

	if abs(delta.x) > abs(delta.y) * 1.5:
		# Width-driven resize
		new_size = constrain_width(current_size)
	elif abs(delta.y) > abs(delta.x) * 1.5:
		# Height-driven resize
		new_size = constrain_height(current_size)
	else:
		# Corner drag, enforce exact aspect ratio
		new_size = enforce_aspect_ratio(current_size)

	if new_size != current_size:
		# Temporarily disconnect signal to prevent recursion
		get_window().disconnect("size_changed", Callable(self, "_on_window_size_changed"))
		get_window().size = new_size
		previous_size = new_size
		get_window().connect("size_changed", Callable(self, "_on_window_size_changed"))
	else:
		previous_size = new_size

	is_resizing = false

# Constrains the height based on the given width to maintain the aspect ratio range.
# @param size Current window size
# @return New constrained size
func constrain_width(size: Vector2i) -> Vector2i:
	size.y = int(clamp(size.y, size.x / ratio_range.y, size.x / ratio_range.x))
	return size

# Constrains the width based on the given height to maintain the aspect ratio range.
# @param size Current window size
# @return New constrained size
func constrain_height(size: Vector2i) -> Vector2i:
	size.x = int(clamp(size.x, size.y * ratio_range.x, size.y * ratio_range.y))
	return size

# Enforces a single aspect ratio within the allowed range by adjusting width or height.
# @param size Current window size
# @return New size with enforced aspect ratio
func enforce_aspect_ratio(size: Vector2i) -> Vector2i:
	var aspect = size.x / size.y
	var clamped = clamp(aspect, ratio_range.x, ratio_range.y)

	if abs(aspect - clamped) < 0.01:
		return size

	var desired_width = int(size.y * clamped)
	var desired_height = int(size.x / clamped)

	if abs(size.x - desired_width) < abs(size.y - desired_height):
		size.y = desired_height
	else:
		size.x = desired_width

	return size
