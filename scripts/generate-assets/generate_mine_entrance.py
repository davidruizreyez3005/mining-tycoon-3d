"""
Blender Python script to generate a low-poly mine entrance asset.
Outputs: assets/models/mine_entrance.glb
"""

import bpy
import os

# Clear existing objects
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

# Set up scene
bpy.context.scene.unit_settings.system = 'METRIC'
bpy.context.scene.unit_settings.scale_length = 1.0

# Create materials
def create_material(name, color, roughness=0.8):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Roughness"].default_value = roughness
    return mat

wood_mat = create_material("Wood", (0.4, 0.25, 0.1, 1), 0.9)
stone_mat = create_material("Stone", (0.35, 0.35, 0.35, 1), 0.95)
dark_mat = create_material("DarkInterior", (0.1, 0.1, 0.1, 1), 0.9)
metal_mat = create_material("Metal", (0.5, 0.5, 0.5, 1), 0.6)

# Create mine entrance group
entrance_group = bpy.data.objects.new("MineEntrance", None)
bpy.context.collection.objects.link(entrance_group)

# Main tunnel cylinder (dark interior)
bpy.ops.mesh.primitive_cylinder_add(
    radius=1.5,
    depth=4,
    vertices=16,
    location=(0, 2, 0)
)
tunnel = bpy.context.active_object
tunnel.name = "Tunnel_Interior"
tunnel.data.materials.append(dark_mat)
tunnel.rotation_euler = (1.5708, 0, 0)  # Rotate to face Z
bpy.ops.object.shade_smooth()
entrance_group.children.link(tunnel)

# Wooden frame - top beam
bpy.ops.mesh.primitive_box_add(size=(3.5, 0.4, 0.3), location=(0, 0, 2.3))
top_beam = bpy.context.active_object
top_beam.name = "Frame_TopBeam"
top_beam.data.materials.append(wood_mat)
entrance_group.children.link(top_beam)

# Wooden frame - left post
bpy.ops.mesh.primitive_box_add(size=(0.3, 0.3, 2.5), location=(-1.6, 0, 1.25))
left_post = bpy.context.active_object
left_post.name = "Frame_LeftPost"
left_post.data.materials.append(wood_mat)
entrance_group.children.link(left_post)

# Wooden frame - right post
bpy.ops.mesh.primitive_box_add(size=(0.3, 0.3, 2.5), location=(1.6, 0, 1.25))
right_post = bpy.context.active_object
right_post.name = "Frame_RightPost"
right_post.data.materials.append(wood_mat)
entrance_group.children.link(right_post)

# Support beams on top
for i in range(3):
    x_offset = -1.0 + i * 1.0
    bpy.ops.mesh.primitive_box_add(size=(0.2, 0.5, 0.1), location=(x_offset, -0.3, 2.5))
    support = bpy.context.active_object
    support.name = f"Support_Beam_{i}"
    support.data.materials.append(wood_mat)
    entrance_group.children.link(support)

# Warning sign post
bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=2, location=(-2.5, 0, 1))
sign_post = bpy.context.active_object
sign_post.name = "Sign_Post"
sign_post.data.materials.append(wood_mat)
entrance_group.children.link(sign_post)

# Sign board
bpy.ops.mesh.primitive_box_add(size=(0.8, 0.1, 0.5), location=(-2.5, 0, 2.2))
sign_board = bpy.context.active_object
sign_board.name = "Sign_Board"
sign_board.data.materials.append(wood_mat)
entrance_group.children.link(sign_board)

# Lantern hanging from frame
bpy.ops.mesh.primitive_cylinder_add(radius=0.15, depth=0.3, vertices=8, location=(0, 0.3, 2.1))
lantern = bpy.context.active_object
lantern.name = "Lantern"
lantern.data.materials.append(metal_mat)
entrance_group.children.link(lantern)

# Chain for lantern
bpy.ops.mesh.primitive_curve_bezier_add(location=(0, 0.3, 2.3))
chain = bpy.context.active_object
chain.name = "Lantern_Chain"
chain.data.bezier_curves[0].points[0].co = (0, 0.3, 2.3)
chain.data.bezier_curves[0].points[1].co = (0, 0.3, 2.1)
entrance_group.children.link(chain)

# Apply transforms
bpy.context.view_layer.update()
for obj in entrance_group.children:
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

# Export as GLB
output_path = "//assets/models/mine_entrance.glb"
bpy.ops.export_scene.gltf(
    filepath=output_path,
    export_format='GLB',
    export_selected=True,
    use_selection=True,
    export_yup=True,
    export_apply=True,
    export_animations=False,
    export_morph=False,
    export_cameras=False,
    export_lights=False
)

print(f"Exported mine entrance to {output_path}")
