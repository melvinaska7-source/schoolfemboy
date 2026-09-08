extends Node3D

func box(parent,pos,size,mat=null):
    var body=StaticBody3D.new(); body.position=pos; parent.add_child(body)
    var mesh=MeshInstance3D.new(); var bm=BoxMesh.new(); bm.size=size; mesh.mesh=bm; body.add_child(mesh)
    var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=size; cs.shape=sh; body.add_child(cs)
    if mat: mesh.material_override=mat
    return body

func make_mat(path:String, color=Color(0.72,0.72,0.72)):
    var m=StandardMaterial3D.new(); m.albedo_color=color
    if path!="":
        var t=load(path); if t: m.albedo_texture=t
    m.uv1_scale=Vector3(2,2,2); return m

func build(parent):
    var floor_mat=make_mat("res://assets/текстуры/пол/пол_мозайка.jpg",Color(0.7,0.7,0.7))
    var wall_mat=make_mat("res://assets/текстуры/стены/белая_стена_коридор.jpg",Color(0.9,0.9,0.9))
    var yellow=make_mat("res://assets/текстуры/стены/желтая_стена_у_кабинета_директора.jpg",Color(0.9,0.8,0.5))
    box(parent,Vector3(0,-0.1,0),Vector3(42,0.2,30),floor_mat)
    # outer shell, approximate first-floor senior building from supplied evacuation plan
    box(parent,Vector3(0,1.6,-15),Vector3(42,3.2,.3),wall_mat)
    box(parent,Vector3(-21,1.6,0),Vector3(.3,3.2,30),wall_mat)
    box(parent,Vector3(21,1.6,0),Vector3(.3,3.2,30),wall_mat)
    box(parent,Vector3(0,1.6,15),Vector3(42,3.2,.3),wall_mat)
    # Main horizontal corridor
    box(parent,Vector3(-2,1.6,-2.0),Vector3(34,3.2,.25),wall_mat)
    box(parent,Vector3(-2,1.6,4.0),Vector3(34,3.2,.25),wall_mat)
    # Central vertical corridor
    box(parent,Vector3(4,1.6,8),Vector3(.25,3.2,22),wall_mat)
    box(parent,Vector3(-4,1.6,8),Vector3(.25,3.2,22),wall_mat)
    # classrooms along east side, doors left open via segmented walls
    room(parent,Vector3(12,1.6,10),Vector3(13,3.2,.25),wall_mat) # top of rooms
    room(parent,Vector3(12,1.6,5),Vector3(13,3.2,.25),wall_mat)
    room(parent,Vector3(12,1.6,0),Vector3(13,3.2,.25),wall_mat)
    room(parent,Vector3(12,1.6,-5),Vector3(13,3.2,.25),wall_mat)
    room(parent,Vector3(12,1.6,-10),Vector3(13,3.2,.25),wall_mat)
    # left classrooms / offices
    room(parent,Vector3(-12,1.6,9),Vector3(10,3.2,.25),wall_mat)
    room(parent,Vector3(-12,1.6,4),Vector3(10,3.2,.25),wall_mat)
    # director office near entrance, yellow wall
    room(parent,Vector3(-12,1.6,-7),Vector3(10,3.2,.25),yellow)
    # vertical partitions between rooms, with approximate door gaps
    for z in [-7,-2,3,8,13]:
        box(parent,Vector3(18,1.6,z),Vector3(.25,3.2,3.6),wall_mat)
        box(parent,Vector3(6,1.6,z),Vector3(.25,3.2,3.6),wall_mat)
    # stairwell blocks: intentionally closed for first version
    box(parent,Vector3(-14,1.5,13),Vector3(5,3,4),wall_mat)
    box(parent,Vector3(10,1.5,13),Vector3(5,3,4),wall_mat)
    # entrance vestibule-ish obstacles
    box(parent,Vector3(-17,1,0),Vector3(2,2,.8),wall_mat)
    # modern desks in classrooms; hide spots
    for room_x in [-12,12]:
        for z in [-10,-5,0,5,10]:
            if room_x==12 or z>=0:
                for dz in [-1.2,1.2]:
                    box(parent,Vector3(room_x,dz*0+0.65,z+dz),Vector3(1.1,1.3,.65),null)

func room(parent,pos,size,mat):
    # segment each room's far wall with a central doorway gap
    var half=size.x/2.0
    box(parent,pos+Vector3(-half/2.0,0,0),Vector3(size.x/2.0-1.0,size.y,0.25),mat)
    box(parent,pos+Vector3(half/2.0,0,0),Vector3(size.x/2.0-1.0,size.y,0.25),mat)
