extends Node2D

const WORLD_RECT := Rect2(-2200.0, -1400.0, 4400.0, 2800.0)

func _ready() -> void:
    queue_redraw()
    print("Eclipse Realms - base 3/4 carregada")

func _draw() -> void:
    # Base do mapa
    draw_rect(WORLD_RECT, Color("18291f"), true)

    # Água / margem à direita
    var water := PackedVector2Array([
        Vector2(1450, -1400), Vector2(2200, -1400),
        Vector2(2200, 1400), Vector2(1650, 1400),
        Vector2(1500, 900), Vector2(1600, 420),
        Vector2(1480, -80), Vector2(1580, -620)
    ])
    draw_colored_polygon(water, Color("194b5d"))
    for y in range(-1300, 1301, 130):
        draw_line(Vector2(1660, y), Vector2(2080, y + 34), Color(0.25, 0.72, 0.82, 0.22), 3.0)

    # Estrada principal em perspectiva 3/4
    var road_main := PackedVector2Array([
        Vector2(-2200, -210), Vector2(-2200, 210),
        Vector2(1500, 520), Vector2(1560, 160)
    ])
    draw_colored_polygon(road_main, Color("665c4b"))

    var road_cross := PackedVector2Array([
        Vector2(-360, -1400), Vector2(60, -1400),
        Vector2(430, 1400), Vector2(10, 1400)
    ])
    draw_colored_polygon(road_cross, Color("625949"))

    # Praça central
    draw_circle(Vector2(40, 90), 280.0, Color("706758"))
    draw_circle(Vector2(40, 90), 230.0, Color("5c5549"), false, 7.0)
    draw_circle(Vector2(40, 90), 110.0, Color("756b59"), false, 5.0)

    # Pedras da estrada para quebrar o aspecto plano
    for x in range(-2000, 1401, 145):
        var y := -35.0 + sin(float(x) * 0.013) * 65.0
        draw_rect(Rect2(Vector2(x, y), Vector2(54, 22)), Color(0.43, 0.40, 0.34, 0.65), true)
    for y in range(-1250, 1251, 130):
        var x := 35.0 + sin(float(y) * 0.011) * 62.0
        draw_rect(Rect2(Vector2(x, y), Vector2(28, 46)), Color(0.42, 0.39, 0.33, 0.55), true)

    # Ruínas e estruturas
    _draw_ruin(Vector2(-1080, -560))
    _draw_ruin(Vector2(820, -720))
    _draw_ruin(Vector2(-1260, 620))
    _draw_portal(Vector2(1120, 520))

    # Árvores / vegetação nas bordas e clareiras
    var trees := [
        Vector2(-1950,-1120), Vector2(-1640,-990), Vector2(-1300,-1160),
        Vector2(-760,-1030), Vector2(520,-1120), Vector2(1020,-1050),
        Vector2(1360,-930), Vector2(-2020,980), Vector2(-1700,1110),
        Vector2(-1260,1020), Vector2(-760,1160), Vector2(720,1120),
        Vector2(1160,980), Vector2(-1840,-420), Vector2(-1740,420),
        Vector2(1180,-250), Vector2(1320,760)
    ]
    for p in trees:
        _draw_tree(p)

    # Lampiões e pequenos pontos mágicos
    for p in [Vector2(-760,-180), Vector2(540,220), Vector2(-420,610), Vector2(800,-380)]:
        _draw_lamp(p)

    for p in [Vector2(-920,310), Vector2(660,-520), Vector2(980,780), Vector2(-1480,-730)]:
        draw_circle(p, 11.0, Color("56d9ff"))
        draw_circle(p, 24.0, Color(0.25, 0.75, 1.0, 0.18))

func _draw_tree(p: Vector2) -> void:
    draw_rect(Rect2(p + Vector2(-13, 24), Vector2(26, 72)), Color("5a3825"), true)
    draw_circle(p, 76.0, Color("183b24"))
    draw_circle(p + Vector2(-42, 18), 48.0, Color("21502d"))
    draw_circle(p + Vector2(45, 10), 52.0, Color("244f2b"))
    draw_circle(p + Vector2(0, -42), 54.0, Color("2b5d32"))

func _draw_ruin(p: Vector2) -> void:
    draw_rect(Rect2(p + Vector2(-115, -34), Vector2(230, 68)), Color("484b43"), true)
    draw_rect(Rect2(p + Vector2(-104, -62), Vector2(48, 120)), Color("5a5d54"), true)
    draw_rect(Rect2(p + Vector2(58, -54), Vector2(42, 108)), Color("5a5d54"), true)
    draw_line(p + Vector2(-115, 42), p + Vector2(115, 42), Color("252822"), 8.0)

func _draw_lamp(p: Vector2) -> void:
    draw_line(p + Vector2(0, 32), p + Vector2(0, -54), Color("2b251f"), 9.0)
    draw_circle(p + Vector2(0, -64), 16.0, Color("ffb53f"))
    draw_circle(p + Vector2(0, -64), 32.0, Color(1.0, 0.55, 0.16, 0.12))

func _draw_portal(p: Vector2) -> void:
    draw_rect(Rect2(p + Vector2(-78, -10), Vector2(30, 150)), Color("55564f"), true)
    draw_rect(Rect2(p + Vector2(48, -10), Vector2(30, 150)), Color("55564f"), true)
    draw_arc(p + Vector2(0, 4), 86.0, PI, TAU, 32, Color("777971"), 28.0)
    draw_arc(p + Vector2(0, 4), 58.0, PI, TAU, 32, Color("8a4cff"), 10.0)
    draw_circle(p + Vector2(0, 18), 46.0, Color(0.42, 0.18, 0.95, 0.35))
