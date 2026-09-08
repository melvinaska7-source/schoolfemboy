extends CharacterBody3D
var kind=""
var game
var target
var state="patrol"
var speed=1.8
var chase_speed=3.8
var patrol_points=[]
var patrol_index=0
var sprite:Sprite3D
var spawn_position
var hear_distance=3.0
var vision_distance=16.0
var lost_time=0.0

func setup(g,k,texture_path,pos):
    game=g; kind=k; spawn_position=pos
    position=pos
    speed={"Литричка":2.0,"Тишков":1.8,"Лихачева":2.2}.get(kind,2.0)
    chase_speed={"Литричка":4.0,"Тишков":4.2,"Лихачева":4.4}.get(kind,4.0)
    hear_distance={"Литричка":4.0,"Тишков":4.5,"Лихачева":3.0}.get(kind,4.0)
    vision_distance={"Литричка":999.0,"Тишков":999.0,"Лихачева":8.0}.get(kind,10.0)
    var sh=CollisionShape3D.new(); var cap=CapsuleShape3D.new(); cap.radius=.35; cap.height=1.7; sh.shape=cap; sh.position.y=.85; add_child(sh)
    sprite=Sprite3D.new(); sprite.texture=load(texture_path); sprite.pixel_size=0.008; sprite.position.y=1.15; sprite.billboard=BaseMaterial3D.BILLBOARD_ENABLED; sprite.no_depth_test=false; add_child(sprite)
    patrol_points=game.patrol_points

func can_see_player():
    if not is_instance_valid(target): return false
    var d=global_position.distance_to(target.global_position)
    if d>vision_distance: return false
    var from=global_position+Vector3.UP*1.2; var to=target.global_position+Vector3.UP*1.0
    var q=PhysicsRayQueryParameters3D.create(from,to); q.exclude=[self]
    var hit=get_world_3d().direct_space_state.intersect_ray(q)
    return hit.is_empty() or hit.collider==target

func _physics_process(delta):
    if state=="disabled": return
    if not is_instance_valid(target): return
    var d=global_position.distance_to(target.global_position)
    if state=="patrol":
        if d<=hear_distance or can_see_player():
            game.begin_chase(self); return
        var p=patrol_points[patrol_index]; var v=(p-global_position); v.y=0
        if v.length()<1.0: patrol_index=(patrol_index+1)%patrol_points.size()
        else: velocity=v.normalized()*speed
    elif state=="chase":
        if can_see_player() or d<=hear_distance or kind=="Литричка":
            lost_time=0; var v=(target.global_position-global_position); v.y=0
            if v.length()>0.1: velocity=v.normalized()*chase_speed
        else:
            lost_time+=delta; velocity=Vector3.ZERO
            if lost_time>4.0: game.enemy_lost(self)
    move_and_slide()
    if d<1.0: game.enemy_caught(self)
