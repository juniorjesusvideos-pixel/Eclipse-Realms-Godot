extends CharacterBody2D

@export var speed: float = 245.0
@export var vertical_perspective: float = 0.72

var touch_id: int = -1
var touch_origin := Vector2.ZERO
var touch_direction := Vector2.ZERO
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
        if drag_delta.length() > 18.0:
            touch_direction = drag_delta.normalized()
        else:
            touch_direction = Vector2.ZERO

func _physics_process(delta: float) -> void:
    var keyboard_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var input_direction: Vector2 = keyboard_direction

    if input_direction == Vector2.ZERO:
        input_direction = touch_direction

    if input_direction != Vector2.ZERO:
        input_direction = input_direction.normalized()
        velocity = Vector2(
            input_direction.x * speed,
            input_direction.y * speed * vertical_perspective
        )
        motion_time += delta * 11.0
        visual.position.y = sin(motion_time) * 2.5
        visual.rotation = sin(motion_time * 0.5) * 0.015

        if abs(input_direction.x) > 0.08:
            visual.scale.x = 1.0 if input_direction.x > 0.0 else -1.0
    else:
        velocity = velocity.move_toward(Vector2.ZERO, speed * 8.0 * delta)
        motion_time += delta * 3.0
        visual.position.y = sin(motion_time) * 1.2
        visual.rotation = 0.0

    move_and_slide()

    # Mantém o jogador dentro da área jogável desta primeira versão.
    global_position.x = clamp(global_position.x, -2080.0, 1420.0)
    global_position.y = clamp(global_position.y, -1280.0, 1280.0)
