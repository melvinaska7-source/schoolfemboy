extends Node3D

var game
var menu

func _ready():
    game = preload("res://scripts/game.gd").new()
    game.name = "Game"
    add_child(game)
    menu = preload("res://scripts/menu.gd").new()
    menu.name = "Menu"
    add_child(menu)
    menu.start_requested.connect(_on_start)
    menu.settings_requested.connect(_on_settings)
    menu.intro_requested.connect(_on_intro)
    menu.howto_requested.connect(_on_howto)
    menu.back_requested.connect(_on_back)
    game.hide_game()

func _on_start(minutes:int, music:bool):
    menu.hide_menu()
    game.start_game(minutes, music)

func _on_settings(): menu.show_settings()
func _on_intro(): menu.show_intro()
func _on_howto(): menu.show_howto()
func _on_back(): menu.show_main()
