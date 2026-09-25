extends CharacterBody2D

@export var speed: float = 245.0
@export var vertical_perspective: float = 0.72
@export var acceleration: float = 1500.0
@export var deceleration: float = 1900.0
@export var input_smoothing: float = 9.0
@export var attack_duration: float = 0.45
@export var skill_1_duration: float = 0.75
@export var skill_2_duration: float = 0.85
@export var skill_3_duration: float = 0.8
@export var hit_duration: float = 0.35

var touch_id: int = -1
var touch_origin := Vector2.ZERO
var touch_direction := Vector2.ZERO
var smoothed_direction := Vector2.ZERO
var motion_time := 0.0
var action_time_left := 0.0
var current_state: StringName = &"idle"
var facing: StringName = &"front"
var is_dead := false

@onready var visual: Node2D = $Visual

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and touch_id == -1 and event.position.x < get_viewport_rect().size.x * 0.65:
            touch_id = event.index
            touch_origin = event.position
            touch_direction = Vector2.ZERO
        elif not event.pressed and event.index == touch_id:
            touch_id = -1
            touch_direction = Vector2.ZERO
    elif event is InputEventScreenDrag and event.index == touch_id:
        var drag_delta: Vector2 = event.position - touch_origin
        var drag_length := drag_delta.length()
        if drag_length > 18.0:
            var strength := clamp((drag_length - 18.0) / 72.0, 0.0, 1.0)
            touch_direction = drag_delta.normalized() * strength
        else:
            touch_direction = Vector2.ZERO

func _physics_process(delta: float) -> void:
    _handle_action_input()

    if action_time_left > 0.0:
        action_time_left = max(action_time_left - delta, 0.0)

    var keyboard_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var raw_direction: Vector2 = keyboard_direction

    if raw_direction == Vector2.ZERO:
        raw_direction = touch_direction

    if raw_direction.length() > 1.0:
        raw_direction = raw_direction.normalized()

    if not is_dead and action_time_left <= 0.0:
        smoothed_direction = smoothed_direction.lerp(raw_direction, 1.0 - exp(-input_smoothing * delta))
    else:
        smoothed_direction = smoothed_direction.lerp(Vector2.ZERO, 1.0 - exp(-input_smoothing * delta))

    if raw_direction == Vector2.ZERO and smoothed_direction.length() < 0.01:
        smoothed_direction = Vector2.ZERO

    var target_velocity := Vector2(
        smoothed_direction.x * speed,
        smoothed_direction.y * speed * vertical_perspective
    )

    var rate := acceleration if raw_direction != Vector2.ZERO else deceleration
    velocity = velocity.move_toward(target_velocity, rate * delta)
    move_and_slide()

    if not is_dead and action_time_left <= 0.0:
        _update_facing(raw_direction)
        current_state = &"walk" if velocity.length() > 12.0 else &"idle"

    _update_placeholder_visual(delta)

    global_position.x = clamp(global_position.x, -2080.0, 1420.0)
    global_position.y = clamp(global_position.y, -1280.0, 1280.0)

func _handle_action_input() -> void:
    if is_dead:
        return

    if Input.is_action_just_pressed("test_death"):
        is_dead = true
        current_state = &"death"
        action_time_left = 0.0
        velocity = Vector2.ZERO
        return

    if action_time_left > 0.0:
        return

    if Input.is_action_just_pressed("attack"):
        _start_action(&"attack", attack_duration)
    elif Input.is_action_just_pressed("skill_1"):
        _start_action(&"skill_1", skill_1_duration)
    elif Input.is_action_just_pressed("skill_2"):
        _start_action(&"skill_2", skill_2_duration)
    elif Input.is_action_just_pressed("skill_3"):
        _start_action(&"skill_3", skill_3_duration)
    elif Input.is_action_just_pressed("test_hit"):
        _start_action(&"hit", hit_duration)

func _start_action(state: StringName, duration: float) -> void:
    current_state = state
    action_time_left = duration
    velocity = Vector2.ZERO

func _update_facing(direction: Vector2) -> void:
    if direction.length() < 0.1:
        return

    if abs(direction.x) > abs(direction.y) * 1.35:
        facing = &"right" if direction.x > 0.0 else &"left"
    elif abs(direction.y) > abs(direction.x) * 1.35:
        facing = &"front" if direction.y > 0.0 else &"back"
    elif direction.x > 0.0:
        facing = &"diag_right"
    else:
        facing = &"diag_left"

func _update_placeholder_visual(delta: float) -> void:
    var movement_ratio := clamp(velocity.length() / speed, 0.0, 1.0)

    if current_state == &"walk":
        motion_time += delta * (7.0 + movement_ratio * 2.0)
        visual.position.y = sin(motion_time) * 1.2 * movement_ratio
    elif current_state == &"idle":
        motion_time += delta * 2.0
        visual.position.y = sin(motion_time) * 0.45
    else:
        visual.position.y = lerp(visual.position.y, 0.0, min(delta * 12.0, 1.0))

    if facing == &"right" or facing == &"diag_right":
        visual.scale.x = 1.0
    elif facing == &"left" or facing == &"diag_left":
        visual.scale.x = -1.0

    visual.rotation = 0.0
