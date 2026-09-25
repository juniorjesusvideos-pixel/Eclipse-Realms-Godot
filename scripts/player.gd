extends CharacterBody2D

@export var speed: float = 260.0

var touch_id: int = -1
var touch_origin := Vector2.ZERO
var touch_direction := Vector2.ZERO

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

func _physics_process(_delta: float) -> void:
    var keyboard_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var direction: Vector2 = keyboard_direction
    if direction == Vector2.ZERO:
        direction = touch_direction
    velocity = direction * speed
    move_and_slide()
