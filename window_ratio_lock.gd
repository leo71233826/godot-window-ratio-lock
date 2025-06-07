```gdscript
extends Node

# Indicates if the window is currently being resized
var is_resizing = false
# Stores the previous window size to calculate changes
var previous_size = Vector2i.ZERO
# Aspect ratio locked during corner dragging, -1.0 means no lock
var locked_aspect: float = -1.0
# Mode of dragging lock: "none", "horizontal", "vertical", or "corner"
var locked_drag_mode: String = "none"
# Counts idle frames with no size change to detect end of dragging
var idle_frame_counter := 0

# Allowed aspect ratio range (min, max), e.g., 4:3 to 16:9
@export var ratio_range: Vector2 = Vector2(4.0 / 3, 16.0 / 9)
# Number of idle frames to unlock the drag mode
const IDLE_FRAMES_TO_UNLOCK := 6

func _ready() -> void:
	"""
	Called when the node is added to the scene.
	Connects to the window's 'size_changed' signal and records the initial window size.
	"""
	get_window().connect("size_changed", Callable(self, "_on_window_size_changed"))
	previous_size = get_window().size

func _process(_delta):
	"""
	Called every frame.
	Tracks idle frames after resizing to reset drag lock mode once resizing stops.
	"""
	if locked_drag_mode != "none":
		idle_frame_counter += 1
		if idle_frame_counter > IDLE_FRAMES_TO_UNLOCK:
			locked_drag_mode = "none"
			locked_aspect = -1.0
			idle_frame_counter = 0

func _on_window_size_changed():
	"""
	Handles window resize events.
	Determines the drag mode (horizontal, vertical, corner),
	calculates and constrains the new window size based on aspect ratio limits,
	and applies the constrained size if needed.
	"""
	if is_resizing:
		return
	is_resizing = true
	await get_tree().process_frame

	var current_size = get_window().size
	var delta = current_size - previous_size
	var new_size: Vector2i = current_size

	# Detect drag mode based on dominant resize direction
	if locked_drag_mode == "none":
		if abs(delta.x) > abs(delta.y) * 1.5:
			locked_drag_mode = "horizontal"
		elif abs(delta.y) > abs(delta.x) * 1.5:
			locked_drag_mode = "vertical"
		else:
			locked_drag_mode = "corner"
			locked_aspect = float(current_size.x) / current_size.y

	idle_frame_counter = 0  # Reset idle counter on size change

	match locked_drag_mode:
		"horizontal":
			new_size = constrain_width(current_size)
		"vertical":
			new_size = constrain_height(current_size)
		"corner":
			# Adjust size to maintain locked aspect ratio within ratio_range
			var desired_width = int(current_size.y * locked_aspect)
			var desired_height = int(current_size.x / locked_aspect)

			if abs(current_size.x - desired_width) < abs(current_size.y - desired_height):
				new_size.y = desired_height
			else:
				new_size.x = desired_width

			var ratio = float(new_size.x) / new_size.y
			ratio = clamp(ratio, ratio_range.x, ratio_range.y)
			new_size.x = int(new_size.y * ratio)

	# Apply new size if it differs from current
	if new_size != current_size:
		get_window().disconnect("size_changed", Callable(self, "_on_window_size_changed"))
		get_window().size = new_size
		previous_size = new_size
		get_window().connect("size_changed", Callable(self, "_on_window_size_changed"))
	else:
		previous_size = new_size

	is_resizing = false

func constrain_width(size: Vector2i) -> Vector2i:
	"""
	Constrains the window height based on the width and allowed aspect ratio range.

	@param size: The current window size.
	@return: Size with constrained height to maintain aspect ratio limits.
	"""
	size.y = int(clamp(size.y, size.x / ratio_range.y, size.x / ratio_range.x))
	return size

func constrain_height(size: Vector2i) -> Vector2i:
	"""
	Constrains the window width based on the height and allowed aspect ratio range.

	@param size: The current window size.
	@return: Size with constrained width to maintain aspect ratio limits.
	"""
	size.x = int(clamp(size.x, size.y * ratio_range.x, size.y * ratio_range.y))
	return size
```

这样写，注释符合Godot官方GDScript风格，清晰专业，方便维护和理解。需要我帮你加中文注释吗？
