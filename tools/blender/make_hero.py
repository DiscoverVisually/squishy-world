"""Squishy World HERO V3 | original Blender 4.5 source & glTF asset.
Art target: approved Jelly Fantasy concept. Editable sculpt, 7 named shape keys,
integrated jelly limbs, recessed eyes, layered amber gaze, gradient gel.
NOT art-approved until normal-camera Godot WebGL2 review. No paid dependencies.
"""
import bpy, os, math
from math import sin, cos, pi, exp, sqrt
from mathutils import Vector

OUT=os.path.abspath(os.getenv("ASSET_OUT","production-preview"))
os.makedirs(OUT,exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
collection=bpy.data.collections.new("SQ_Hero_Runtime")
bpy.context.scene.collection.children.link(collection)

def keep(obj):
    for c in tuple(obj.users_collection): c.objects.unlink(obj)
    collection.objects.link(obj)
    if obj.type=="MESH":
        for poly in obj.data.polygons: poly.use_smooth=True
    return obj

def material(name,color,rough=.21,coat=.30,subs=.0,metal=.0):
    m=bpy.data.materials.new(name)
    m.use_nodes=True
    m.diffuse_color=(*color,1)
    bs=m.node_tree.nodes.get("Principled BSDF")
    bs.inputs["Base Color"].default_value=(*color,1)
    bs.inputs["Roughness"].default_value=rough
    bs.inputs["Coat Weight"].default_value=coat
    bs.inputs["Coat Roughness"].default_value=.14
    bs.inputs["Subsurface Weight"].default_value=subs
    bs.inputs["Metallic"].default_value=metal
    return m

gel=material("GEL_Jade_WebCompatible",(.055,.62,.20),.13,.62,.30)
tip=material("GEL_LuminousSprouts",(.13,.75,.31),.14,.50,.22)
dark=material("EYE_DeepChocolate",(.018,.016,.021),.12,.4)
whites=material("EYE_Ivory",(.97,.98,.96),.19,.28)
honey=material("EYE_AmberRing",(.56,.29,.095),.17,.4)
inner_honey=material("EYE_IrisGold",(.92,.54,.15),.21,.3)
pupil=material("EYE_GlassPupil",(.009,.014,.020),.085,.78)
glint=material("EYE_WhiteSoftbox",(1.0,1.0,1.0),.08,.25)
cheeks=material("CHEEK_CoralBlush",(.92,.43,.44),.39,.12,.14)
mouth=material("MOUTH_RaspberryShadow",(.17,.028,.060),.36,.15)
tongue=material("MOUTH_Rose",(.97,.30,.39),.32,.22)

# Blender-only studio look. Runtime uses production WebGL2 shader.
nodes=gel.node_tree.nodes
links=gel.node_tree.links
bs=nodes.get("Principled BSDF")
coord=nodes.new("ShaderNodeTexCoord")
coord.location=(-760,150)
sep=nodes.new("ShaderNodeSeparateXYZ")
sep.location=(-560,150)
links.new(coord.outputs["Generated"],sep.inputs[0])
ramp=nodes.new("ShaderNodeValToRGB")
ramp.location=(-325,165)
ramp.color_ramp.interpolation="EASE"
ramp.color_ramp.elements.remove(ramp.color_ramp.elements[1])
def ramp_color(pos,col):
    e=ramp.color_ramp.elements.new(pos)
    e.color=(*col,1)
ramp.color_ramp.elements[0].position=0.0
ramp.color_ramp.elements[0].color=(.016,.18,.10,1)
ramp_color(.27,(.035,.34,.12))
ramp_color(.61,(.055,.60,.20))
ramp_color(.86,(.21,.77,.31))
ramp_color(1.0,(.40,.89,.49))
links.new(sep.outputs["Z"],ramp.inputs[0])
links.new(ramp.outputs[0],bs.inputs["Base Color"])
noise=nodes.new("ShaderNodeTexNoise")
noise.location=(-555,-120)
noise.inputs["Scale"].default_value=5.4
noise.inputs["Detail"].default_value=2.0
noise.inputs["Roughness"].default_value=.6
links.new(coord.outputs["Generated"],noise.inputs["Vector"])
micro=nodes.new("ShaderNodeBump")
micro.location=(-50,-90)
micro.inputs["Strength"].default_value=.065
micro.inputs["Distance"].default_value=.012
links.new(noise.outputs["Fac"],micro.inputs["Height"])
links.new(micro.outputs["Normal"],bs.inputs["Normal"])

def sphere(name, pos, scale, mat, segments=64,rings=48):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments,ring_count=rings,location=pos)
    ob=bpy.context.object
    ob.name=name
    ob.scale=scale
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    ob.data.materials.append(mat)
    return keep(ob)

# Sculpted silhouette with subtle offsets: generous base, tapered dome, no toy-sphere.
body=sphere("SquishyBody",(0,0,0),(1,1,1),gel,128,84)
base=[]
def gauss(dx,dy,spread):
    return exp(-((dx/spread)**2+(dy/spread)**2))
for v in body.data.vertices:
    x,y,z=v.co
    norm=(z+1.0)*.5
    width=.99*(1.0-.095*norm)
    depth=.88*(1.0-.060*norm)
    ox=x*width
    oy=y*depth
    oz=.94+z*.84
    # Wide lower cheeks, drooping soft sides, asymmetric organic life.
    ox*=1.0+.024*sin(4.1*y+2.3*z)
    oz+=.013*sin(6*x+2.1*y)*(1.0-abs(z))
    # Recessed eyelid sockets are actual deformations in the jelly shell.
    for sx in (-1.0,1.0):
        oy+=.065*gauss((ox-sx*.345),oz-1.17,.27)*max(0.0,-y)
        # Soft hand-like protrusions are part of the SAME watertight body.
        ox+=sx*.17*gauss(ox-sx*.74,oz-.60,.28)*max(0.0,abs(x))
        # Broad gel feet grow from bottom shell; no detached shoe outlines.
        feet=gauss(ox-sx*.42,oz-.26,.31)*max(0.0,-y)
        oy-=.10*feet
        oz-=.055*feet
    if oz<.29: oz=.29+(oz-.29)*.24
    v.co=(ox,oy,oz)
    base.append(v.co.copy())

# Production silhouette is a single watertight gel volume; not separate
# toy spheres. Fuse original body, asymmetric side fins and pliable paws.
# Do this BEFORE shape keys: all body parts then share the same spring-driven skin.
fusion_parts=[body]
for side,tag in [(-1,"L"),(1,"R")]:
    fin=sphere("Temp_Fin_"+tag,(side*.83,-.12,.59),(.262,.31,.255),gel,48,32)
    fin.rotation_euler[1]=side*.19
    paw=sphere("Temp_Paw_"+tag,(side*.47,-.29,.24),(.308,.350,.180),gel,56,32)
    paw.rotation_euler[1]=side*.045
    fusion_parts.extend([fin,paw])
bpy.ops.object.select_all(action="DESELECT")
for part in fusion_parts: part.select_set(True)
bpy.context.view_layer.objects.active=body
bpy.ops.object.join()
body.name="SquishyBody"
body.data.remesh_voxel_size=.042
bpy.ops.object.voxel_remesh()
smoother=body.modifiers.new("OrganicVolumeSmooth","SMOOTH")
smoother.factor=1.08
smoother.iterations=4
bpy.ops.object.modifier_apply(modifier=smoother.name)
for polygon in body.data.polygons:polygon.use_smooth=True
base=[v.co.copy() for v in body.data.vertices]
assert len(base) >= 3500, "Merged body mesh resolution too low"
body.shape_key_add(name="Basis",from_mix=False)
def deform(name,fn):
    b=body.shape_key_add(name=name,from_mix=False)
    for i,p in enumerate(base):b.data[i].co=fn(p.copy())
deform("Squash",lambda p:Vector((p.x*1.19,p.y*1.17,.13+(p.z-.13)*.73)))
deform("StretchUp",lambda p:Vector((p.x*.83,p.y*.83,.13+(p.z-.13)*1.32)))
deform("LeanLeft",lambda p:Vector((p.x-.29*sin(pi*max(.0,min(1.0,p.z/1.85))),p.y,p.z)))
deform("LeanRight",lambda p:Vector((p.x+.29*sin(pi*max(.0,min(1.0,p.z/1.85))),p.y,p.z)))
deform("Impact",lambda p:Vector((p.x*1.18,p.y*1.15,.13+(p.z-.13)*.77)))
deform("PokeFront",lambda p:Vector((p.x,p.y+.20*gauss(p.x,p.z-1.07,.36)*max(0,-p.y),p.z)))
deform("HappyWiggle",lambda p:Vector((p.x+.10*sin(3.0*p.z),p.y,p.z+.018*sin(7.0*p.x))))

# Crown sprouts have deliberately different forms and height. Tiny gel beads.
crown=[
(-.20,-.03,1.72, (.100,.128,.135), 0.28),
(.15,.035,1.73, (.080,.103,.111),-.26),
(.01,.065,1.77, (.045,.06,.061), 0.0)
]
for i,(x,y,z,scale,turn) in enumerate(crown):
    o=sphere("CrownSoftBud_"+str(i),(x,y,z),scale,tip,48,32)
    o.rotation_euler[1]=turn

# Contoured face components: much thinner in depth than former sphere patches.
# Each part keeps a named identity for the Godot face deformation rig.
for side,tag in [(-1,"L"),(1,"R")]:
    cx=side*.345
    sphere("EyeRoot_"+tag,(cx,-.765,1.175),(.246,.028,.298),gel,60,40)
    sphere("EyeRim_"+tag,(cx,-.777,1.173),(.236,.022,.288),dark,64,44)
    sphere("EyeIvory_"+tag,(cx,-.793,1.174),(.223,.017,.270),whites,64,44)
    sphere("Iris_"+tag,(cx-side*.026,-.810,1.159),(.183,.015,.213),honey,64,44)
    sphere("IrisLight_"+tag,(cx-side*.029,-.827,1.161),(.151,.013,.180),inner_honey,60,44)
    sphere("Pupil_"+tag,(cx-side*.031,-.843,1.163),(.146,.012,.183),pupil,64,44)
    sphere("Catchlight_"+tag,(cx-side*.031-.063,-.859,1.239),(.056,.008,.063),glint,40,28)
    sphere("MicroGlint_"+tag,(cx-side*.031+.075,-.861,1.095),(.017,.006,.023),glint,28,20)
    sphere("Cheek_"+tag,(side*.67,-.685,.83),(.126,.009,.058),cheeks,64,32)

# Joyful mouth with a dark inside and a bright raised tongue.
smile=sphere("Mouth",(0,-.828,.685),(.226,.019,.143),mouth,80,48)
sphere("Tongue",(0,-.846,.616),(.116,.012,.044),tongue,52,36)
# Subtle glossy lower-lip high point, visually continuous with gel.
sphere("MouthLip",(0,-.799,.547),(.128,.007,.016),tip,48,24)

# Sculpt quality check and directly editable master.
bpy.ops.object.select_all(action="DESELECT")
for ob in collection.objects: ob.select_set(True)
bpy.context.view_layer.objects.active=body
blend=os.path.join(OUT,"hero_squishy.blend")
bpy.ops.wm.save_as_mainfile(filepath=blend)
glb=os.path.join(OUT,"hero_squishy.glb")
bpy.ops.export_scene.gltf(filepath=glb, export_format="GLB",
    use_selection=True,export_apply=False,
    export_morph=True,export_morph_normal=True,export_yup=True)

# Render multiple angles to review at character scale, not only studio glamour.
bpy.ops.object.select_all(action="DESELECT")
def look_at(o,target):
    o.rotation_euler=(Vector(target)-o.location).to_track_quat("-Z","Y").to_euler()
bpy.ops.object.camera_add(location=(1.0,-5.8,2.35))
cam=bpy.context.object
cam.name="Review_Ortho_Camera"
cam.data.type="ORTHO"
cam.data.ortho_scale=3.11
look_at(cam,(0,0,.95))
bpy.context.scene.camera=cam

for n,power,size,color,loc in [
("Key",330,4.5,(1,.93,.81),(-2.6,-3.3,4.5)),
("CoolRim",420,3.0,(.48,.88,1),(2.7,2.4,3.2)),
("Fill",160,3.0,(1,.75,.72),(3.0,-2.1,1.8))]:
    bpy.ops.object.light_add(type="AREA",location=loc)
    light=bpy.context.object
    light.name=n
    light.data.energy=power
    light.data.shape="DISK"
    light.data.size=size
    light.data.color=color
    look_at(light,(0,0,.95))
# Neutral plinth makes transparent appearance and contact shadow readable.
bpy.ops.mesh.primitive_cylinder_add(vertices=120,radius=1.82,depth=.10,location=(0,0,-.03))
plinth=bpy.context.object
plinth.name="REVIEW_ONLY_Plinth"
plinth.data.materials.append(material("REVIEW_MatteSlate",(.21,.29,.34),.65,.04))
for p in plinth.data.polygons:p.use_smooth=True
scene=bpy.context.scene
scene.render.engine="CYCLES"
scene.cycles.samples=32
bpy.context.view_layer.cycles.use_denoising=True
scene.render.resolution_x=800
scene.render.resolution_y=800
scene.render.resolution_percentage=100
scene.render.image_settings.file_format="PNG"
scene.world.color=(.16,.19,.23)
scene.view_settings.view_transform="Standard"
scene.view_settings.look="Medium High Contrast"
scene.view_settings.exposure=-0.2
scene.render.film_transparent=False
for name,pos in [
("hero_preview.png",(1.0,-5.8,2.35)),
("hero_front.png",(0,-6.2,2.0)),
("hero_side.png",(6.3,-.35,1.95)),
("hero_back.png",(0,6.2,1.95))]:
    cam.location=pos
    look_at(cam,(0,0,.96))
    scene.render.filepath=os.path.join(OUT,name)
    bpy.ops.render.render(write_still=True)
assert len(body.data.shape_keys.key_blocks)==8
assert os.path.getsize(glb)>10000
print("SUCCESS: hero preview, editable .blend and morph-enabled .glb",os.path.getsize(glb))
