extends Control
var center=Vector2.ZERO
var knob=Vector2.ZERO
var active=false
func _ready():
    mouse_filter=Control.MOUSE_FILTER_STOP
func _draw():
    draw_circle(size/2,90,Color(1,1,1,0.12)); draw_circle(size/2+knob,42,Color(1,1,1,0.35))
func _gui_input(e):
    if e is InputEventScreenTouch:
        active=e.pressed
        if active: knob=clamp_vec(e.position-size/2,70)
        else: knob=Vector2.ZERO
        queue_redraw()
    elif e is InputEventScreenDrag and active:
        knob=clamp_vec(e.position-size/2,70); queue_redraw()
func clamp_vec(v,m): return v.limit_length(m)
func get_vector(): return knob/70.0
