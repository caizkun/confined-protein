# @Zhikun Cai, UIUC, 01/2016

# Use this script to configure system dimensions
# Usage:
#	import configure_system_dimensions


# ---- configure system parameters ----
# initial box dimensions (one box vertex is in the origin)
old_box_x = 7.96480
old_box_y = 7.96480
old_box_z = 5.55840

# desired dimensions (after cropping), nm
x_min = 0.0
x_max = old_box_x
y_min = 0.0
y_max = old_box_y
z_min = 0.0
z_max = old_box_z
box_x = x_max - x_min
box_y = y_max - y_min
box_z = z_max - z_min

# pore axis center, nm
pore_center_x = 0.5 * box_x
pore_center_y = 0.5 * box_y

# pore dimensions, nm
pore_inner_radius = -0.0   # use negative to ensure cylinder
pore_outer_radius = 3.0
pore_surface_layer1_inner_radius = pore_outer_radius - 0.2
pore_surface_layer1_outer_radius = pore_outer_radius + 0.25
pore_surface_layer2_inner_radius = pore_outer_radius - 0.2
pore_surface_layer2_outer_radius = pore_outer_radius + 0.85

# filled solvent dimensions, nm
gap_from_solvent_to_pore_surface = -0.1
solvent_filled_inner_radius = pore_inner_radius
solvent_filled_outer_radius = pore_outer_radius - gap_from_solvent_to_pore_surface	
# -------------------------------------
