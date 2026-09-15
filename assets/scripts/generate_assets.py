"""
Mining Tycoon 3D - High-Quality Asset Generator
Blender Python script for procedural 3D asset creation
Generates optimized, validated GLB assets with LODs and collision meshes
"""

import bpy
import bmesh
import math
import random
from mathutils import Vector, Matrix
import json
import os
import sys

# Configuration
ASSET_VERSION = "1.0.0"
TRIANGLE_BUDGETS = {
    "tiny": (500, 2000),
    "normal": (2000, 8000),
    "important": (5000, 15000),
    "hero": (8000, 25000)
}

LOD_LEVELS = {
    "LOD0": 1.0,
    "LOD1": 0.5,
    "LOD2": 0.25
}


def clean_scene():
    """Remove all default objects from scene"""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    
    # Clear orphaned data
    for block in bpy.data.meshes:
        if block.users == 0:
            bpy.data.meshes.remove(block)
    for block in bpy.data.materials:
        if block.users == 0:
            bpy.data.materials.remove(block)
    for block in bpy.data.textures:
        if block.users == 0:
            bpy.data.textures.remove(block)
    for block in bpy.data.images:
        if block.users == 0:
            bpy.data.images.remove(block)


def create_material(name, base_color, metallic=0.0, roughness=0.5, normal_strength=0.0):
    """Create a PBR material with proper settings"""
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    
    # Clear default nodes
    nodes.clear()
    
    # Create principled BSDF
    bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
    bsdf.location = (0, 0)
    bsdf.inputs['Base Color'].default_value = (*base_color, 1.0)
    bsdf.inputs['Metallic'].default_value = metallic
    bsdf.inputs['Roughness'].default_value = roughness
    
    # Output
    output = nodes.new(type='ShaderNodeOutputMaterial')
    output.location = (400, 0)
    
    links.new(bsdf.outputs['BSDF'], output.inputs['Surface'])
    
    return mat


def create_rock_material(variation="stone"):
    """Create realistic rock materials"""
    if variation == "stone":
        return create_material("M_Stone", base_color=(0.45, 0.42, 0.38), metallic=0.0, roughness=0.9)
    elif variation == "coal":
        return create_material("M_Coal", base_color=(0.15, 0.15, 0.15), metallic=0.3, roughness=0.7)
    elif variation == "copper":
        return create_material("M_Copper", base_color=(0.72, 0.45, 0.20), metallic=0.8, roughness=0.4)
    elif variation == "iron":
        return create_material("M_Iron", base_color=(0.55, 0.50, 0.45), metallic=0.7, roughness=0.5)
    elif variation == "gold":
        return create_material("M_Gold", base_color=(1.0, 0.85, 0.20), metallic=0.95, roughness=0.3)
    elif variation == "crystal":
        return create_material("M_Crystal", base_color=(0.3, 0.8, 0.9), metallic=0.1, roughness=0.1)
    else:
        return create_material("M_Rock", base_color=(0.5, 0.48, 0.45), metallic=0.0, roughness=0.85)


def create_metal_material(painted=False):
    """Create industrial metal materials"""
    if painted:
        return create_material("M_Metal_Painted", base_color=(0.6, 0.65, 0.7), metallic=0.6, roughness=0.4)
    else:
        return create_material("M_Metal_Raw", base_color=(0.55, 0.55, 0.55), metallic=0.8, roughness=0.3)


def create_wood_material():
    """Create wood material for supports"""
    return create_material("M_Wood", base_color=(0.55, 0.40, 0.25), metallic=0.0, roughness=0.8)


def add_bevel(obj, width=0.02, segments=3):
    """Add bevel modifier for realistic edges"""
    bevel = obj.modifiers.new(name="Bevel", type='BEVEL')
    bevel.width = width
    bevel.segments = segments
    bevel.limit_method = 'ANGLE'
    bevel.angle_limit = math.radians(30)
    return bevel


def add_subdivision(obj, levels=2):
    """Add subdivision surface modifier"""
    subsurf = obj.modifiers.new(name="Subdivision", type='SUBSURF')
    subsurf.levels = levels
    subsurf.render_levels = levels
    return subsurf


def create_collision_mesh(obj, name_suffix="_COL"):
    """Create simplified collision mesh"""
    col_obj = obj.copy()
    col_obj.data = obj.data.copy()
    col_obj.name = f"{obj.name}{name_suffix}"
    
    # Add decimate for simpler collision
    decimate = col_obj.modifiers.new(name="Decimate", type='DECIMATE')
    decimate.ratio = 0.3  # Reduce to 30% for collision
    decimate.use_collapse_triangulate = True
    
    # Apply modifiers
    bpy.context.collection.objects.link(col_obj)
    bpy.context.view_layer.objects.active = col_obj
    
    for mod in col_obj.modifiers:
        try:
            bpy.ops.object.modifier_apply(modifier=mod.name)
        except:
            pass
    
    # Set collision physics
    col_obj.display_type = 'WIRE'
    
    return col_obj


def create_lod_mesh(obj, lod_name, ratio):
    """Create LOD version of mesh"""
    lod_obj = obj.copy()
    lod_obj.data = obj.data.copy()
    lod_obj.name = f"{obj.name}_{lod_name}"
    
    # Add decimate for LOD
    if ratio < 1.0:
        decimate = lod_obj.modifiers.new(name="Decimate", type='DECIMATE')
        decimate.ratio = ratio
        decimate.use_collapse_triangulate = True
    
    bpy.context.collection.objects.link(lod_obj)
    bpy.context.view_layer.objects.active = lod_obj
    
    for mod in lod_obj.modifiers:
        try:
            bpy.ops.object.modifier_apply(modifier=mod.name)
        except:
            pass
    
    return lod_obj


def apply_all_modifiers(obj):
    """Apply all modifiers to object"""
    for mod in obj.modifiers[:]:
        try:
            bpy.ops.object.modifier_apply(modifier=mod.name)
        except RuntimeError:
            obj.modifiers.remove(mod)


def triangulate_mesh(obj):
    """Convert mesh to triangles for game export"""
    tri = obj.modifiers.new(name="Triangulate", type='TRIANGULATE')
    tri.ngon_method = 'BEAUTY'
    tri.quad_method = 'BEAUTY'
    apply_all_modifiers(obj)


def count_triangles(obj):
    """Count triangles in mesh"""
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    faces = len([f for f in bm.faces])
    bm.free()
    return faces


def uv_unwrap_smart(obj):
    """Smart UV unwrap for texture mapping"""
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')


# ============================================================================
# ASSET GENERATORS
# ============================================================================

def generate_drill_extractor(scale=1.0):
    """Generate industrial drill extractor machine"""
    clean_scene()
    
    # Base platform
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    base = bpy.context.active_object
    base.scale = (2.5 * scale, 2.5 * scale, 0.3 * scale)
    base.name = "Machine_Base"
    base.data.materials.append(create_metal_material(painted=True))
    
    # Support columns
    for x in [-1, 1]:
        for y in [-1, 1]:
            bpy.ops.mesh.primitive_cylinder_add(radius=0.15 * scale, depth=1.5 * scale, 
                                                 location=(x * 1.2 * scale, y * 1.2 * scale, 0.9 * scale))
            column = bpy.context.active_object
            column.name = f"Machine_Column_{x}_{y}"
            column.data.materials.append(create_metal_material())
    
    # Top frame
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 2.0 * scale))
    top_frame = bpy.context.active_object
    top_frame.scale = (2.5 * scale, 2.5 * scale, 0.2 * scale)
    top_frame.name = "Machine_TopFrame"
    top_frame.data.materials.append(create_metal_material(painted=True))
    
    # Drill arm
    bpy.ops.mesh.primitive_cylinder_add(radius=0.3 * scale, depth=1.2 * scale, 
                                         location=(0, 0, 1.5 * scale))
    drill_arm = bpy.context.active_object
    drill_arm.name = "Machine_DrillArm"
    drill_arm.data.materials.append(create_metal_material())
    
    # Drill bit
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.25 * scale, radius2=0.05 * scale,
                                     depth=0.8 * scale, location=(0, 0, 0.8 * scale))
    drill_bit = bpy.context.active_object
    drill_bit.name = "Machine_DrillBit"
    drill_bit.data.materials.append(create_metal_material())
    
    # Motor housing
    bpy.ops.mesh.primitive_cylinder_add(radius=0.5 * scale, depth=0.4 * scale,
                                         location=(0, 0, 2.2 * scale))
    motor = bpy.context.active_object
    motor.name = "Machine_Motor"
    motor.data.materials.append(create_metal_material(painted=True))
    
    # Add bevels for realism
    for obj in [base, top_frame, motor]:
        add_bevel(obj, width=0.03 * scale, segments=4)
    
    # Apply modifiers and triangulate
    parent = base
    for obj in bpy.data.objects:
        if obj.type == 'MESH' and obj != parent:
            obj.parent = parent
    
    for obj in bpy.data.objects:
        if obj.type == 'MESH':
            apply_all_modifiers(obj)
            uv_unwrap_smart(obj)
    
    # Create LODs
    lods = []
    for lod_name, ratio in LOD_LEVELS.items():
        if lod_name == "LOD0":
            lods.append(base)
        else:
            lod = create_lod_mesh(base, lod_name, ratio)
            lods.append(lod)
    
    # Create collision mesh
    collision = create_collision_mesh(base)
    
    # Validate triangle count
    total_tris = sum(count_triangles(obj) for obj in lods)
    print(f"Drill Extractor - Total triangles: {total_tris}")
    
    # Export
    export_path = "/workspace/assets/models/SM_DrillExtractor.glb"
    os.makedirs(os.path.dirname(export_path), exist_ok=True)
    
    # Select all LODs for export
    bpy.ops.object.select_all(action='DESELECT')
    for lod in lods:
        lod.select_set(True)
    collision.select_set(True)
    
    bpy.ops.export_scene.gltf(
        filepath=export_path,
        export_format='GLB',
        export_selected=True,
        export_cameras=False,
        export_lights=False,
        export_animations=False,
        export_materials='EXPORT',
        export_yup=True
    )
    
    print(f"Exported: {export_path}")
    return {"path": export_path, "triangles": total_tris, "lods": len(lods)}


def generate_ore_node(resource_type="stone", scale=1.0):
    """Generate ore node/rock formation"""
    clean_scene()
    
    # Create irregular rock shape using icosphere
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=scale, location=(0, 0, 0))
    rock = bpy.context.active_object
    rock.name = f"Ore_{resource_type.capitalize()}"
    
    # Displace vertices for natural look
    mesh = rock.data
    for vertex in mesh.vertices:
        noise = random.uniform(-0.15, 0.15) * scale
        vertex.co *= (1.0 + noise)
    
    # Apply material based on resource type
    mat = create_rock_material(resource_type)
    rock.data.materials.append(mat)
    
    # Add subtle bevel
    add_bevel(rock, width=0.02 * scale, segments=2)
    apply_all_modifiers(rock)
    uv_unwrap_smart(rock)
    
    # Create LODs
    lods = []
    for lod_name, ratio in LOD_LEVELS.items():
        if lod_name == "LOD0":
            lods.append(rock)
        else:
            lod = create_lod_mesh(rock, lod_name, ratio)
            lods.append(lod)
    
    # Collision mesh
    collision = create_collision_mesh(rock)
    
    total_tris = sum(count_triangles(obj) for obj in lods)
    print(f"Ore Node ({resource_type}) - Total triangles: {total_tris}")
    
    # Export
    export_path = f"/workspace/assets/models/Ore_{resource_type.capitalize()}.glb"
    
    bpy.ops.object.select_all(action='DESELECT')
    for lod in lods:
        lod.select_set(True)
    collision.select_set(True)
    
    bpy.ops.export_scene.gltf(
        filepath=export_path,
        export_format='GLB',
        export_selected=True,
        export_yup=True
    )
    
    print(f"Exported: {export_path}")
    return {"path": export_path, "triangles": total_tris, "resource": resource_type}


def generate_conveyor_belt(length=4.0, scale=1.0):
    """Generate conveyor belt segment"""
    clean_scene()
    
    # Frame
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    frame = bpy.context.active_object
    frame.name = "Conveyor_Frame"
    frame.scale = (length * scale, 1.2 * scale, 0.15 * scale)
    frame.data.materials.append(create_metal_material(painted=True))
    
    # Rollers
    roller_count = int(length * 2)
    for i in range(roller_count):
        x_pos = -length/2 + 0.3 + (i * length/(roller_count-1)) if roller_count > 1 else 0
        bpy.ops.mesh.primitive_cylinder_add(radius=0.1 * scale, depth=1.3 * scale,
                                             location=(x_pos, 0, 0.2 * scale),
                                             rotation=(math.pi/2, 0, 0))
        roller = bpy.context.active_object
        roller.name = f"Conveyor_Roller_{i}"
        roller.data.materials.append(create_metal_material())
        roller.parent = frame
    
    # Belt surface
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, 0, 0.25 * scale))
    belt = bpy.context.active_object
    belt.name = "Conveyor_Belt"
    belt.scale = (length * scale, 1.1 * scale, 0.05 * scale)
    belt.data.materials.append(create_material("M_ConveyorBelt", 
                                                base_color=(0.2, 0.2, 0.2), 
                                                metallic=0.3, roughness=0.7))
    belt.parent = frame
    
    # Supports
    for x in [-0.4, 0.4]:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(x * length/2 * scale, 0, -0.3 * scale))
        support = bpy.context.active_object
        support.name = f"Conveyor_Support_{x}"
        support.scale = (0.2 * scale, 0.8 * scale, 0.6 * scale)
        support.data.materials.append(create_metal_material())
        support.parent = frame
    
    # Bevels
    add_bevel(frame, width=0.02 * scale, segments=3)
    
    for obj in bpy.data.objects:
        if obj.type == 'MESH':
            apply_all_modifiers(obj)
            uv_unwrap_smart(obj)
    
    # LODs
    lods = []
    for lod_name, ratio in LOD_LEVELS.items():
        if lod_name == "LOD0":
            lods.append(frame)
        else:
            lod = create_lod_mesh(frame, lod_name, ratio)
            lods.append(lod)
    
    collision = create_collision_mesh(frame)
    
    total_tris = sum(count_triangles(obj) for obj in lods)
    print(f"Conveyor Belt - Total triangles: {total_tris}")
    
    export_path = "/workspace/assets/models/SM_ConveyorBelt.glb"
    
    bpy.ops.object.select_all(action='DESELECT')
    for lod in lods:
        lod.select_set(True)
    collision.select_set(True)
    
    bpy.ops.export_scene.gltf(
        filepath=export_path,
        export_format='GLB',
        export_selected=True,
        export_yup=True
    )
    
    print(f"Exported: {export_path}")
    return {"path": export_path, "triangles": total_tris}


def generate_mine_cart(scale=1.0):
    """Generate mine cart for ore transport"""
    clean_scene()
    
    # Cart body
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.5 * scale))
    cart = bpy.context.active_object
    cart.name = "MineCart_Body"
    cart.scale = (1.5 * scale, 1.0 * scale, 0.8 * scale)
    cart.data.materials.append(create_metal_material(painted=True))
    
    # Remove top face for open cart
    bpy.context.view_layer.objects.active = cart
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.select_mode(type='FACE')
    bpy.ops.mesh.select_face_by_sides(sides=4, extend=False)
    bpy.ops.mesh.delete(type='FACE')
    bpy.ops.object.mode_set(mode='OBJECT')
    
    # Wheels
    wheel_positions = [
        (-0.6, -0.6, 0.15),
        (0.6, -0.6, 0.15),
        (-0.6, 0.6, 0.15),
        (0.6, 0.6, 0.15)
    ]
    
    for i, pos in enumerate(wheel_positions):
        bpy.ops.mesh.primitive_cylinder_add(radius=0.25 * scale, depth=0.15 * scale,
                                             location=(pos[0] * scale, pos[1] * scale, pos[2] * scale),
                                             rotation=(math.pi/2, 0, 0))
        wheel = bpy.context.active_object
        wheel.name = f"MineCart_Wheel_{i}"
        wheel.data.materials.append(create_metal_material())
        wheel.parent = cart
    
    # Axles
    for y in [-0.5, 0.5]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.08 * scale, depth=1.4 * scale,
                                             location=(0, y * scale, 0.15 * scale),
                                             rotation=(math.pi/2, 0, 0))
        axle = bpy.context.active_object
        axle.name = f"MineCart_Axle_{y}"
        axle.data.materials.append(create_metal_material())
        axle.parent = cart
    
    # Reinforcement bands
    for x in [-0.5, 0, 0.5]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.78 * scale, depth=0.1 * scale,
                                             location=(x * scale, 0, 0.5 * scale))
        band = bpy.context.active_object
        band.name = f"MineCart_Band_{x}"
        band.data.materials.append(create_metal_material())
        band.parent = cart
    
    # Bevels
    add_bevel(cart, width=0.03 * scale, segments=4)
    
    for obj in bpy.data.objects:
        if obj.type == 'MESH':
            apply_all_modifiers(obj)
            uv_unwrap_smart(obj)
    
    # LODs
    lods = []
    for lod_name, ratio in LOD_LEVELS.items():
        if lod_name == "LOD0":
            lods.append(cart)
        else:
            lod = create_lod_mesh(cart, lod_name, ratio)
            lods.append(lod)
    
    collision = create_collision_mesh(cart)
    
    total_tris = sum(count_triangles(obj) for obj in lods)
    print(f"Mine Cart - Total triangles: {total_tris}")
    
    export_path = "/workspace/assets/models/SM_MineCart.glb"
    
    bpy.ops.object.select_all(action='DESELECT')
    for lod in lods:
        lod.select_set(True)
    collision.select_set(True)
    
    bpy.ops.export_scene.gltf(
        filepath=export_path,
        export_format='GLB',
        export_selected=True,
        export_yup=True
    )
    
    print(f"Exported: {export_path}")
    return {"path": export_path, "triangles": total_tris}


def generate_tunnel_segment(length=4.0, scale=1.0):
    """Generate underground tunnel segment module"""
    clean_scene()
    
    # Tunnel arch (semi-circular)
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=2.0 * scale, 
                                          depth=length * scale, location=(0, 0, 0))
    tunnel = bpy.context.active_object
    tunnel.name = "Tunnel_Segment"
    tunnel.rotation_euler = (math.pi/2, 0, 0)
    
    # Make hollow
    bpy.context.view_layer.objects.active = tunnel
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.object.mode_set(mode='OBJECT')
    
    # Add solidify modifier for wall thickness
    solidify = tunnel.modifiers.new(name="Solidify", type='SOLIDIFY')
    solidify.thickness = 0.15 * scale
    solidify.offset = 0
    
    # Floor
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, 0, -2.0 * scale))
    floor = bpy.context.active_object
    floor.name = "Tunnel_Floor"
    floor.scale = (4.0 * scale, length * scale, 1.0 * scale)
    floor.data.materials.append(create_rock_material("stone"))
    floor.parent = tunnel
    
    # Support beams
    beam_spacing = length / 4
    for i in range(5):
        z_pos = -2.0 * scale + 0.1 * scale
        bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -length/2 + i * beam_spacing, z_pos))
        beam = bpy.context.active_object
        beam.name = f"Tunnel_Beam_{i}"
        beam.scale = (4.2 * scale, 0.15 * scale, 0.1 * scale)
        beam.data.materials.append(create_wood_material())
        beam.parent = tunnel
    
    # Side walls
    for x in [-2.0, 2.0]:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(x * scale, 0, -1.0 * scale))
        wall = bpy.context.active_object
        wall.name = f"Tunnel_Wall_{x}"
        wall.scale = (0.15 * scale, length * scale, 2.0 * scale)
        wall.data.materials.append(create_rock_material("stone"))
        wall.parent = tunnel
    
    # Material for tunnel
    tunnel.data.materials.append(create_rock_material("stone"))
    
    apply_all_modifiers(tunnel)
    
    for obj in bpy.data.objects:
        if obj.type == 'MESH':
            uv_unwrap_smart(obj)
    
    # LODs
    lods = []
    for lod_name, ratio in LOD_LEVELS.items():
        if lod_name == "LOD0":
            lods.append(tunnel)
        else:
            lod = create_lod_mesh(tunnel, lod_name, ratio)
            lods.append(lod)
    
    collision = create_collision_mesh(tunnel)
    
    total_tris = sum(count_triangles(obj) for obj in lods)
    print(f"Tunnel Segment - Total triangles: {total_tris}")
    
    export_path = "/workspace/assets/models/SM_TunnelSegment.glb"
    
    bpy.ops.object.select_all(action='DESELECT')
    for lod in lods:
        lod.select_set(True)
    collision.select_set(True)
    
    bpy.ops.export_scene.gltf(
        filepath=export_path,
        export_format='GLB',
        export_selected=True,
        export_yup=True
    )
    
    print(f"Exported: {export_path}")
    return {"path": export_path, "triangles": total_tris}


def generate_worker_mannequin():
    """Generate simple worker placeholder with proper proportions"""
    clean_scene()
    
    # Root empty for rig
    bpy.ops.object.empty_add(location=(0, 0, 0))
    root = bpy.context.active_object
    root.name = "Worker_Root"
    
    scale = 1.0
    
    # Body (capsule-like)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.25 * scale, depth=0.7 * scale, 
                                         location=(0, 0, 1.1 * scale))
    body = bpy.context.active_object
    body.name = "Worker_Body"
    body.data.materials.append(create_material("M_Uniform", base_color=(0.8, 0.75, 0.6)))
    body.parent = root
    
    # Head
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=0.2 * scale,
                                          location=(0, 0, 1.7 * scale))
    head = bpy.context.active_object
    head.name = "Worker_Head"
    head.data.materials.append(create_material("M_Skin", base_color=(0.85, 0.65, 0.55)))
    head.parent = root
    
    # Helmet
    bpy.ops.mesh.primitive_sphere_add(segments=12, ring_count=8, radius=0.22 * scale,
                                       location=(0, 0, 1.75 * scale))
    helmet = bpy.context.active_object
    helmet.name = "Worker_Helmet"
    helmet.data.materials.append(create_material("M_Helmet", base_color=(0.9, 0.85, 0.2)))
    helmet.scale = (1, 1, 0.7)
    helmet.parent = root
    
    # Arms
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.08 * scale, depth=0.5 * scale,
                                             location=(side * 0.45 * scale, 0, 1.3 * scale),
                                             rotation=(0, side * 0.3, 0))
        arm = bpy.context.active_object
        arm.name = f"Worker_Arm_{side}"
        arm.data.materials.append(create_material("M_Uniform", base_color=(0.8, 0.75, 0.6)))
        arm.parent = root
        
        # Hands
        bpy.ops.mesh.primitive_sphere_add(segments=8, ring_count=6, radius=0.09 * scale,
                                           location=(side * 0.65 * scale, 0, 1.05 * scale))
        hand = bpy.context.active_object
        hand.name = f"Worker_Hand_{side}"
        hand.data.materials.append(create_material("M_Gloves", base_color=(0.4, 0.35, 0.3)))
        hand.parent = root
    
    # Legs
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.1 * scale, depth=0.6 * scale,
                                             location=(side * 0.2 * scale, 0, 0.5 * scale))
        leg = bpy.context.active_object
        leg.name = f"Worker_Leg_{side}"
        leg.data.materials.append(create_material("M_Pants", base_color=(0.3, 0.35, 0.45)))
        leg.parent = root
        
        # Boots
        bpy.ops.mesh.primitive_box_add(size=1, location=(side * 0.2 * scale, 0, 0.05 * scale))
        boot = bpy.context.active_object
        boot.name = f"Worker_Boot_{side}"
        boot.scale = (0.12 * scale, 0.25 * scale, 0.15 * scale)
        boot.data.materials.append(create_material("M_Boots", base_color=(0.25, 0.2, 0.15)))
        boot.parent = root
    
    # Apply transforms
    for obj in bpy.data.objects:
        if obj.type == 'MESH':
            apply_all_modifiers(obj)
            uv_unwrap_smart(obj)
    
    # LODs
    lods = []
    for lod_name, ratio in LOD_LEVELS.items():
        if lod_name == "LOD0":
            lods.append(root)
        else:
            # For LODs, we need to duplicate the whole hierarchy
            bpy.ops.object.select_all(action='DESELECT')
            root.select_set(True)
            bpy.ops.object.duplicate()
            lod_root = bpy.context.active_object
            lod_root.name = f"Worker_Root_{lod_name}"
            
            # Decimate all meshes in hierarchy
            for obj in lod_root.children_recursive:
                if obj.type == 'MESH':
                    decimate = obj.modifiers.new(name="Decimate", type='DECIMATE')
                    decimate.ratio = ratio
            
            # Apply modifiers
            bpy.context.view_layer.objects.active = lod_root
            bpy.ops.object.select_all(action='DESELECT')
            lod_root.select_set(True)
            bpy.ops.object.select_hierarchy(direction='CHILD', extend=True)
            
            for obj in bpy.context.selected_objects:
                if obj.type == 'MESH':
                    for mod in obj.modifiers[:]:
                        try:
                            bpy.ops.object.modifier_apply(modifier=mod.name)
                        except:
                            pass
            
            lods.append(lod_root)
    
    total_tris = 0
    for lod in lods:
        for obj in lod.children_recursive:
            if obj.type == 'MESH':
                total_tris += count_triangles(obj)
    
    print(f"Worker Mannequin - Total triangles: {total_tris}")
    
    export_path = "/workspace/assets/models/CHAR_Worker.glb"
    
    bpy.ops.object.select_all(action='DESELECT')
    for lod in lods:
        lod.select_set(True)
    
    bpy.ops.export_scene.gltf(
        filepath=export_path,
        export_format='GLB',
        export_selected=True,
        export_yup=True
    )
    
    print(f"Exported: {export_path}")
    return {"path": export_path, "triangles": total_tris}


def generate_asset_manifest(assets_data):
    """Generate JSON manifest for all generated assets"""
    manifest = {
        "version": ASSET_VERSION,
        "generated_at": __import__('datetime').datetime.utcnow().isoformat(),
        "assets": assets_data,
        "summary": {
            "total_assets": len(assets_data),
            "total_triangles": sum(a.get('triangles', 0) for a in assets_data)
        }
    }
    
    manifest_path = "/workspace/assets/manifests/asset_manifest.json"
    os.makedirs(os.path.dirname(manifest_path), exist_ok=True)
    
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)
    
    print(f"Generated manifest: {manifest_path}")
    return manifest


def main():
    """Main asset generation pipeline"""
    print("=" * 60)
    print("MINING TYCOON 3D - ASSET GENERATION PIPELINE")
    print("=" * 60)
    
    # Ensure output directories exist
    os.makedirs("/workspace/assets/models", exist_ok=True)
    os.makedirs("/workspace/assets/manifests", exist_ok=True)
    os.makedirs("/workspace/assets/collisions", exist_ok=True)
    
    assets_data = []
    
    # Generate all assets
    print("\n--- Generating Drill Extractor ---")
    assets_data.append(generate_drill_extractor(scale=1.0))
    
    print("\n--- Generating Ore Nodes ---")
    for resource in ["stone", "coal", "copper", "iron", "gold", "crystal"]:
        assets_data.append(generate_ore_node(resource_type=resource, scale=random.uniform(0.8, 1.2)))
    
    print("\n--- Generating Conveyor Belt ---")
    assets_data.append(generate_conveyor_belt(length=4.0, scale=1.0))
    
    print("\n--- Generating Mine Cart ---")
    assets_data.append(generate_mine_cart(scale=1.0))
    
    print("\n--- Generating Tunnel Segment ---")
    assets_data.append(generate_tunnel_segment(length=4.0, scale=1.0))
    
    print("\n--- Generating Worker Character ---")
    assets_data.append(generate_worker_mannequin())
    
    # Generate manifest
    print("\n--- Generating Asset Manifest ---")
    manifest = generate_asset_manifest(assets_data)
    
    print("\n" + "=" * 60)
    print("ASSET GENERATION COMPLETE")
    print(f"Total assets generated: {manifest['summary']['total_assets']}")
    print(f"Total triangles: {manifest['summary']['total_triangles']}")
    print("=" * 60)
    
    return manifest


if __name__ == "__main__":
    main()
