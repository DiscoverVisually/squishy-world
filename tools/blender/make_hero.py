"""Squishy World: Blender 4.5 LTS cloud authored hero review candidate.
Non-shipping until silhouette, shader and spring physics are approved in browser.
"""
import bpy, math, os
from mathutils import Vector
from math import sin, pi, exp
out=os.path.abspath(os.environ.get("ASSET_OUT","production-preview"))
os.makedirs(out,exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
coll=bpy.data.collections.new("Squishy_Runtime_Export")
bpy.context.scene.collection.children.link(coll)
def material(name,rgb,rough=.23,coat=.22):
    m=bpy.data.materials.new(name)
    m.diffuse_color=(*rgb,1)
    m.use_nodes=True
    node=m.node_tree.nodes.get("Principled BSDF")
    node.inputs["Base Color"].default_value=(*rgb,1)
    node.inputs["Roughness"].default_value=rough
    node.inputs["Coat Weight"].default_value=coat
    return m
jade=material("Jade_Gel_WebOpaque",(.09,.64,.29),.15,.39)
mint=material("InnerMint",(.19,.80,.40),.16,.40)
outline=material("Eye_Outline",(.045,.10,.12),.35)
white=material("Ivory_Eye",(1,.98,.92),.15)
iris=material("WarmIris",(.42,.29,.16),.15)
pupil=material("Ink_Pupil",(.025,.020,.026),.11)
shine=material("Eye_Gloss",(1,1,1),.12)
blush=material("Coral_Blush",(.67,.26,.34),.47)
lip=material("Raspberry_Mouth",(.25,.04,.095),.4)
tongue=material("Tongue",(.99,.44,.52),.45)
def runtime(obj):
    for c in tuple(obj.users_collection): c.objects.unlink(obj)
    coll.objects.link(obj)
    if obj.type=="MESH":
        for p in obj.data.polygons: p.use_smooth=True
    return obj
def sphere(name,pos,scale,mat,segments=48,rings=32):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments,ring_count=rings,location=pos)
    o=bpy.context.object
    o.name=name
    o.scale=scale
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    o.data.materials.append(mat)
    return runtime(o)

# Original non-spherical pear contour. Body includes eight animatable shape keys.
body=sphere("SquishyBody",(0,0,0),(1,1,1),jade,80,50)
raw=[]
for v in body.data.vertices:
    x,y,z=v.co
    width=.90+.10*(1-z)/2
    depth=.80+.06*(1-z)/2
    xx=x*width*(1+.024*sin(3*y+z))
    yy=y*depth
    zz=.92+.79*z+.02*sin(4*x+2*y)*(1-abs(z))
    if zz<.12: zz=.12+(zz-.12)*.15
    v.co=(xx,yy,zz)
    raw.append(v.co.copy())
body.shape_key_add(name="Basis")
def key(name,fn):
    b=body.shape_key_add(name=name)
    for i,p in enumerate(raw):
        b.data[i].co=fn(p)
key("Squash",lambda p:Vector((p.x*1.20,p.y*1.20,.12+(p.z-.12)*.74)))
key("StretchUp",lambda p:Vector((p.x*.80,p.y*.80,.12+(p.z-.12)*1.32)))
key("LeanLeft",lambda p:Vector((p.x-.28*sin(pi*max(.0,min(1.,p.z/2))),p.y,p.z)))
key("LeanRight",lambda p:Vector((p.x+.28*sin(pi*max(.0,min(1.,p.z/2))),p.y,p.z)))
key("Impact",lambda p:Vector((p.x*1.16,p.y*1.12,.12+(p.z-.12)*.78)))
key("PokeFront",lambda p:Vector((p.x,p.y+.22*exp(-(p.x/.35)**2-((p.z-1.1)/.40)**2)*max(0,-p.y),p.z)))
key("HappyWiggle",lambda p:Vector((p.x+.11*sin(p.z*3.1),p.y,p.z)))
for x,z,scale,m in [
    (-.18,1.65,(.115,.14,.155),mint),(.18,1.66,(.085,.11,.12),jade),
    (-.81,.62,(.17,.24,.20),jade),(.81,.62,(.17,.24,.20),jade),
    (-.43,.15,(.28,.32,.135),jade),(.43,.15,(.28,.32,.135),jade)]:
    sphere("Gel_Appendage", (x,0,z),scale,m)
# Face is separately animated later by FaceAnchor to preserve eye placement on body deformation.
for side in (-1,1):
    x=side*.33
    tag="L" if side<0 else "R"
    sphere("EyeRim_"+tag,(x,-.726,1.09),(.255,.066,.294),outline)
    sphere("EyeIvory_"+tag,(x,-.763,1.10),(.235,.047,.270),white)
    sphere("Iris_"+tag,(x-side*.025,-.807,1.075),(.160,.029,.184),iris)
    sphere("Pupil_"+tag,(x-side*.025,-.835,1.080),(.123,.018,.145),pupil)
    sphere("Catchlight_"+tag,(x-side*.025-.045,-.851,1.14),(.048,.013,.059),shine,24,16)
    sphere("Blush_"+tag,(side*.60,-.64,.80),(.12,.010,.050),blush)
    # Brows intentionally omitted: the hero reads more warm and toy-like without brows.
sphere("Mouth",(0,-.796,.67),(.18,.022,.182),lip)
sphere("Tongue",(0,-.823,.574),(.099,.015,.057),tongue)

bpy.ops.object.select_all(action="DESELECT")
for ob in coll.objects: ob.select_set(True)
bpy.context.view_layer.objects.active=body
blend=os.path.join(out,"hero_squishy.blend")
bpy.ops.wm.save_as_mainfile(filepath=blend)
glb=os.path.join(out,"hero_squishy.glb")
bpy.ops.export_scene.gltf(filepath=glb, export_format="GLB",
    use_selection=True,export_apply=False,export_morph=True,
    export_morph_normal=True,export_yup=True)

# Studio render for reviewing volume/face/material candidate (not proof of browser fidelity).
bpy.ops.object.select_all(action="DESELECT")
bpy.ops.object.camera_add(location=(2.55,-5.9,2.42))
camera=bpy.context.object
camera.rotation_euler=(Vector((0,0,1.04))-camera.location).to_track_quat("-Z","Y").to_euler()
camera.data.type="ORTHO"
camera.data.ortho_scale=3.15
bpy.context.scene.camera=camera
for pos,power,size,color in [
    ((0,-4.0,5.0),440,4.0,(1.0,.93,.85)),
    ((3,1.3,4.1),580,3.5,(.57,.94,1)),
    ((-3,-1.0,2.3),180,3.0,(1,.70,.69))]:
    bpy.ops.object.light_add(type="AREA",location=pos)
    o=bpy.context.object
    o.data.energy=power
    o.data.shape="DISK"
    o.data.size=size
    o.data.color=color
    o.rotation_euler=(Vector((0,0,1))-o.location).to_track_quat("-Z","Y").to_euler()
scene=bpy.context.scene
scene.render.engine="CYCLES"
scene.cycles.samples=16
scene.render.resolution_x=720
scene.render.resolution_y=720
scene.render.resolution_percentage=100
scene.world.color=(.12,.15,.19)
scene.render.image_settings.file_format="PNG"
scene.render.filepath=os.path.join(out,"hero_preview.png")
bpy.ops.render.render(write_still=True)
assert len(body.data.shape_keys.key_blocks)>=8
assert os.path.getsize(glb)>10000
print("SUCCESS: hero preview, editable .blend and morph-enabled .glb",os.path.getsize(glb))
