extends CanvasLayer
signal start_requested(minutes:int, music:bool)
signal settings_requested
signal intro_requested
signal howto_requested
signal back_requested

var root:Control
var minutes:=5
var music:=true
var panel:VBoxContainer

func _ready():
    root=Control.new(); root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(root)
    show_main()

func clear():
    for c in root.get_children(): c.queue_free()

func label(t,size=24):
    var l=Label.new(); l.text=t; l.add_theme_font_size_override("font_size",size); l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; return l

func button(t):
    var b=Button.new(); b.text=t; b.custom_minimum_size=Vector2(0,64); b.add_theme_font_size_override("font_size",24); return b

func make_center(title:String):
    clear(); var center=CenterContainer.new(); center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); root.add_child(center)
    panel=VBoxContainer.new(); panel.custom_minimum_size=Vector2(520,0); panel.add_theme_constant_override("separation",14); center.add_child(panel)
    panel.add_child(label(title,40)); return panel

func show_main():
    var p=make_center("ШКОЛЬНОЕ ВЫЖИВАНИЕ")
    var play=button("Играть"); play.pressed.connect(func(): start_requested.emit(minutes,music)); p.add_child(play)
    var settings=button("Настройки"); settings.pressed.connect(func(): settings_requested.emit()); p.add_child(settings)
    var intro=button("Познакомиться"); intro.pressed.connect(func(): intro_requested.emit()); p.add_child(intro)
    var how=button("Как играть?"); how.pressed.connect(func(): howto_requested.emit()); p.add_child(how)

func show_settings():
    var p=make_center("НАСТРОЙКИ")
    var musicb=button("Музыка: ВКЛ"); musicb.text="Музыка: "+("ВКЛ" if music else "ВЫКЛ"); musicb.pressed.connect(func(): music=!music; musicb.text="Музыка: "+("ВКЛ" if music else "ВЫКЛ")); p.add_child(musicb)
    var t=label("Время выживания: "+str(minutes)+" минут",24); p.add_child(t)
    for m in [5,10,15]:
        var b=button(str(m)+" минут"); b.pressed.connect(func(mm=m): minutes=mm; t.text="Время выживания: "+str(minutes)+" минут"); p.add_child(b)
    var back=button("Назад"); back.pressed.connect(func(): show_main()); p.add_child(back)

func show_intro():
    var p=make_center("ПОЗНАКОМИТЬСЯ")
    var entries=[
        ["Литричка","Самая опасная. Хорошо замечает игрока, преследует и почти не сдаётся. Боится Андрохака."],
        ["Тишков","Если поймал — сразу конец. Может не заметить игрока, спрятавшегося за мебелью."],
        ["Лихачева (Трудовичка)","Плохо видит, но быстро ловит. После поимки есть 30 секунд, чтобы дождаться шанса на побег."],
        ["Андрохак","Добрый робот в кабинете Аквыча. Один раз за игру спасает от Литрички и после этого исчезает."],
        ["Био-Радар","Всегда с игроком. Подаёт звуковой сигнал, когда учитель рядом или начинается погоня."]]
    for e in entries:
        var h=label(e[0],27); h.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT; p.add_child(h)
        var d=label(e[1],18); d.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; d.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT; p.add_child(d)
    var back=button("Назад"); back.pressed.connect(func(): show_main()); p.add_child(back)

func show_howto():
    var p=make_center("КАК ИГРАТЬ?")
    var l=label("Выживи до конца таймера.\n\nХоди по первому этажу, слушай Био-Радар и прячься за мебелью в кабинетах.\n\nТишков убивает сразу. Лихачеву можно пережить и сбежать. Литричка самая опасная: от неё помогает Андрохак.\n\nНа ПК: WASD + мышь + пробел.\nНа телефоне: левый джойстик + свайп по правой части экрана + кнопка прыжка.\n\nПри долгом бездействии приходит Андрохак и игра заканчивается: «Заснул». ",20)
    l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; p.add_child(l)
    var back=button("Назад"); back.pressed.connect(func(): show_main()); p.add_child(back)

func hide_menu(): root.visible=false
func show_menu(): root.visible=true
