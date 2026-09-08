extends Node3D
var elapsed=0.0
var duration=300.0
var running=false
var music_on=true
var player
var enemies=[]
var chase_enemy
var andro_used=false
var capture_active=false
var capture_time=0.0
var capture_type=""
var circles_left=0
var hud
var timer_label
var radar_label
var message_label
var prompt_label
var patrol_points=[Vector3(-12,0,-1),Vector3(0,0,-1),Vector3(10,0,-1),Vector3(10,0,8),Vector3(0,0,8),Vector3(-12,0,8),Vector3(-12,0,-8),Vector3(8,0,-8)]
var world
var audio_players={}
var capture_timer
var rng=RandomNumberGenerator.new()

func _ready():
    rng.randomize()
    world=preload("res://scripts/world.gd").new(); add_child(world); world.build(self)
    build_environment()
    build_hud()

func build_environment():
    var env=WorldEnvironment.new(); var e=Environment.new(); e.background_mode=Environment.BG_COLOR; e.background_color=Color(0.04,0.04,0.05); e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR; e.ambient_light_color=Color(0.65,0.65,0.65); e.ambient_light_energy=1.0; env.environment=e; add_child(env)
    var light=DirectionalLight3D.new(); light.rotation_degrees=Vector3(-55,-25,0); light.light_energy=1.0; add_child(light)

func build_hud():
    hud=CanvasLayer.new(); hud.name="HUD"; add_child(hud)
    timer_label=Label.new(); timer_label.position=Vector2(20,18); timer_label.add_theme_font_size_override("font_size",30); hud.add_child(timer_label)
    radar_label=Label.new(); radar_label.position=Vector2(20,58); radar_label.add_theme_font_size_override("font_size",20); hud.add_child(radar_label)
    message_label=Label.new(); message_label.set_anchors_preset(Control.PRESET_CENTER); message_label.position=Vector2(-350,-70); message_label.size=Vector2(700,140); message_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; message_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; message_label.add_theme_font_size_override("font_size",44); hud.add_child(message_label)
    prompt_label=Label.new(); prompt_label.set_anchors_preset(Control.PRESET_CENTER); prompt_label.position=Vector2(-360,100); prompt_label.size=Vector2(720,100); prompt_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; prompt_label.add_theme_font_size_override("font_size",28); hud.add_child(prompt_label)
    message_label.hide(); prompt_label.hide(); hud.hide()

func hide_game(): hud.hide()

func start_game(minutes:int,music:bool):
    duration=float(minutes*60); music_on=music; elapsed=0; running=true; andro_used=false; capture_active=false; chase_enemy=null
    hud.show(); spawn_player(); spawn_enemies();
    if music_on: play_sound("res://assets/звуки/фоновая_музыка_геймплея.mp3",true)
    Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

func spawn_player():
    if is_instance_valid(player): player.queue_free()
    player=preload("res://scripts/player.gd").new(); player.name="Player"; add_child(player); player.global_position=Vector3(-17,0.2,-1); player.setup(self)

func spawn_enemies():
    for e in enemies: if is_instance_valid(e): e.queue_free()
    enemies=[]
    make_enemy("Литричка","res://assets/модельки/учителя/литричка.png",Vector3(15,0.2,7))
    make_enemy("Тишков","res://assets/модельки/учителя/тишков.png",Vector3(-15,0.2,-7))
    make_enemy("Лихачева","res://assets/модельки/учителя/лихачева.png",Vector3(13,0.2,2))

func make_enemy(k,t,p):
    var e=preload("res://scripts/enemy.gd").new(); e.name=k; add_child(e); e.target=player; e.setup(self,k,t,p); enemies.append(e)

func _process(delta):
    if not running: return
    elapsed+=delta
    timer_label.text="Осталось: "+format_time(max(0,duration-elapsed))
    update_radar()
    if capture_active: process_capture(delta)
    if elapsed>=duration and not capture_active: win()

func format_time(s):
    var m=int(s)/60; var sec=int(s)%60; return "%02d:%02d" % [m,sec]

func update_radar():
    if not is_instance_valid(player): return
    var nearest=999.0
    for e in enemies:
        if is_instance_valid(e) and e.state!="disabled": nearest=min(nearest,player.global_position.distance_to(e.global_position))
    radar_label.text="Био-Радар: "+("ОПАСНО" if nearest<7 else "тихо")
    if nearest<4 and int(elapsed*2)%8==0: play_sound("res://assets/звуки/биорадар_найдены_учителя.ogg")

func begin_chase(e):
    if capture_active: return
    if chase_enemy==e: return
    chase_enemy=e; e.state="chase"
    for other in enemies:
        if other!=e: other.state="disabled"; other.hide()
    play_sound("res://assets/звуки/биорадар_тебя_услышали.ogg")
    if is_instance_valid(player): player.speed=5.0

func enemy_lost(e):
    if e==chase_enemy:
        if e.kind=="Литричка":
            e.state="patrol"; e.global_position=Vector3(rng.randf_range(-12,12),0.2,rng.randf_range(-8,10)); e.show(); chase_enemy=null
        else:
            e.state="patrol"; chase_enemy=null; for o in enemies: if o!=e: o.show(); o.state="patrol"

func enemy_caught(e):
    if capture_active: return
    if e.kind=="Тишков": lose("Тишков поймал тебя.")
    elif e.kind=="Лихачева": start_likhacheva_capture()
    elif e.kind=="Литричка": start_litrichka_capture()

func start_likhacheva_capture():
    capture_active=true; capture_type="Лихачева"; capture_time=30; prompt_label.text="Может она отвлечётся?"; prompt_label.show(); player.freeze_controls(true)
    play_sound("res://assets/звуки/30_секунд_отчет_у_трудовички.mp3",false)
    var t=Timer.new(); t.wait_time=rng.randf_range(6,26); t.one_shot=true; add_child(t); t.timeout.connect(func(): if capture_active and capture_type=="Лихачева": show_escape()); t.start()

func show_escape():
    message_label.text="БЕГИ!!!"; message_label.show(); await get_tree().create_timer(2.0).timeout; message_label.hide()
    if capture_active:
        capture_active=false; prompt_label.hide(); player.freeze_controls(false); chase_enemy=null
        for e in enemies: if is_instance_valid(e): e.show(); e.state="patrol"

func start_litrichka_capture():
    capture_active=true; capture_type="Литричка"; capture_time=30; circles_left=10; prompt_label.text="Нажми 10 красных кругов!"; prompt_label.show(); player.freeze_controls(true); spawn_circle()

func spawn_circle():
    if not capture_active or capture_type!="Литричка": return
    var b=Button.new(); b.text=""; b.custom_minimum_size=Vector2(75,75); b.position=Vector2(rng.randi_range(120,1100),rng.randi_range(100,570)); b.modulate=Color(1,0.15,0.15,0.9); hud.add_child(b); b.pressed.connect(func(): b.queue_free(); circles_left-=1; if circles_left>0: spawn_circle(); else: escape_litrichka())

func escape_litrichka():
    capture_active=false; prompt_label.hide(); player.freeze_controls(false); chase_enemy=null; andro_used=true
    # if robot not used, this is the player's successful struggle; next capture is shorter
    for e in enemies: if is_instance_valid(e): e.show(); e.state="patrol"

func process_capture(delta):
    capture_time-=delta
    timer_label.text="Ситуация: "+format_time(max(0,capture_time))
    if capture_time<=0:
        if capture_type=="Лихачева": lose("Пришёл Тишков.")
        else: lose("Литричка не отпустила тебя.")

func fell_asleep():
    if running and not capture_active: lose("Заснул.")

func lose(reason):
    running=false; capture_active=false; if is_instance_valid(player): player.freeze_controls(true)
    message_label.text="ТЫ ПРОИГРАЛ\n"+reason; message_label.show(); play_sound("res://assets/звуки/проигрыш.mp3")
    await get_tree().create_timer(3.0).timeout; return_to_menu()

func win():
    running=false; if is_instance_valid(player): player.freeze_controls(true)
    message_label.text="ТЫ ПОБЕДИЛ!"; message_label.show(); play_sound("res://assets/звуки/выигрыш.mp3")
    await get_tree().create_timer(4.0).timeout; return_to_menu()

func return_to_menu():
    if is_instance_valid(player): player.queue_free(); player=null
    for e in enemies: if is_instance_valid(e): e.queue_free()
    enemies=[]; message_label.hide(); prompt_label.hide(); hud.hide(); get_parent().menu.show_menu(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

func play_sound(path:String,loop=false):
    if not music_on: return
    var a=AudioStreamPlayer.new(); a.stream=load(path); a.autoplay=true; a.volume_db=-5; add_child(a); audio_players[path]=a
    if loop: a.finished.connect(func(): if running: a.play())
