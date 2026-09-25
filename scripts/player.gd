extends CharacterBody2D

@export var speed: float = 245.0
@export var vertical_perspective: float = 0.72
@export var acceleration: float = 1500.0
@export var deceleration: float = 1900.0
@export var input_smoothing: float = 9.0

var touch_id: int = -1
var touch_origin := Vector2.ZERO
var touch_direction := Vector2.ZERO
var smoothed_direction := Vector2.ZERO
var motion_time := 0.0

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
    var keyboard_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var raw_direction: Vector2 = keyboard_direction

    if raw_direction == Vector2.ZERO:
        raw_direction = touch_direction

    if raw_direction.length() > 1.0:
        raw_direction = raw_direction.normalized()

    smoothed_direction = smoothed_direction.lerp(raw_direction, 1.0 - exp(-input_smoothing * delta))

    if raw_direction == Vector2.ZERO and smoothed_direction.length() < 0.01:
        smoothed_direction = Vector2.ZERO

    var target_velocity := Vector2(
        smoothed_direction.x * speed,
        smoothed_direction.y * speed * vertical_perspective
    )

    var rate := acceleration if raw_direction != Vector2.ZERO else deceleration
    velocity = velocity.move_toward(target_velocity, rate * delta)

    move_and_slide()

    # Animação visual leve, sem sacudir o corpo durante a caminhada.
    var movement_ratio := clamp(velocity.length() / speed, 0.0, 1.0)
    if movement_ratio > 0.05:
        motion_time += delta * (7.0 + movement_ratio * 2.0)
        visual.position.y = sin(motion_time) * 1.2 * movement_ratio
        if abs(velocity.x) > 10.0:
            visual.scale.x = 1.0 if velocity.x > 0.0 else -1.0
    else:
        motion_time += delta * 2.0
        visual.position.y = sin(motion_time) * 0.45

    visual.rotation = 0.0

    # Mantém o jogador dentro da área jogável desta primeira versão.
    global_position.x = clamp(global_position.x, -2080.0, 1420.0)
    global_position.y = clamp(global_position.y, -1280.0, 1280.0)
