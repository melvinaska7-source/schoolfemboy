extends CharacterBody3D

var speed=4.4
var gravity=14.0
var jump_speed=5.0
var yaw=0.0
var pitch=0.0
var look_sensitivity=0.003
var camera:Camera3D
var game
var joystick:Control
var touch_look:Control
var jump_button:Button
var last_input_time=0.0
var alive=true

func setup(g):
    game=g
    camera=Camera3D.new(); camera.position=Vector3(0,1.55,0); camera.current=true; add_child(camera)
    var shape=CollisionShape3D.new(); var cap=CapsuleShape3D.new(); cap.radius=.32; cap.height=1.7; shape.shape=cap; shape.position.y=.85; add_child(shape)
    build_mobile_ui()

func build_mobile_ui():
    var layer=CanvasLayer.new(); layer.name="MobileControls"; add_child(layer)
    joystick=preload("res://scripts/joystick.gd").new(); joystick.position=Vector2(35,520); joystick.size=Vector2(190,190); layer.add_child(joystick)
    jump_button=Button.new(); jump_button.text="ПРЫЖОК"; jump_button.position=Vector2(1110,585); jump_button.size=Vector2(130,70); jump_button.add_theme_font_size_override("font_size",18); layer.add_child(jump_button)
    jump_button.pressed.connect(func(): if is_on_floor(): velocity.y=jump_speed)
    touch_look=Control.new(); touch_look.set_anchors_preset(Control.PRESET_FULL_RECT); touch_look.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(touch_look)

func _unhandled_input(e):
    if not alive: return
    if e is InputEventMouseMotion and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
        yaw -= e.relative.x*look_sensitivity; pitch=clamp(pitch-e.relative.y*look_sensitivity,-1.25,1.25); rotation.y=yaw; camera.rotation.x=pitch; last_input_time=game.elapsed
    elif e is InputEventScreenDrag and e.position.x>300:
        yaw -= e.relative.x*0.004; pitch=clamp(pitch-e.relative.y*0.004,-1.25,1.25); rotation.y=yaw; camera.rotation.x=pitch; last_input_time=game.elapsed
    elif e is InputEventMouseButton and e.button_index==MOUSE_BUTTON_LEFT and e.pressed:
        Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
    if not alive: return
    var inp=Input.get_vector("move_left","move_right","move_forward","move_back")
    if joystick and joystick.visible:
        var j=joystick.get_vector(); if j.length()>0.05: inp=j
    var dir=(transform.basis * Vector3(inp.x,0,inp.y)).normalized()
    velocity.x=dir.x*speed; velocity.z=dir.z*speed
    if not is_on_floor(): velocity.y-=gravity*delta
    if Input.is_action_just_pressed("jump") and is_on_floor(): velocity.y=jump_speed
    move_and_slide()
    last_input_time=game.elapsed if inp.length()>0.05 else last_input_time
    if game.elapsed-last_input_time>22.0: game.fell_asleep()

func freeze_controls(v:bool):
    alive=!v
    if joystick: joystick.visible=!v
    if jump_button: jump_button.visible=!v
    if v: velocity=Vector3.ZERO
