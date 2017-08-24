#!/bin/bash
# @Zhikun Cai, 01/2016
#
# Use this script to specify system dimensions
# usage:
#       chmod +x configure_system_dimensions.sh
#       source configure_system_dimensions.sh


# ---- configure system parameters ----
# initial box dimensions (one box vertex is in the origin)
old_box_x=7.96480
old_box_y=7.96480
old_box_z=5.55840

# desired dimensions (after cropping), nm
x_min=0.0
x_max=$old_box_x
y_min=0.0
y_max=$old_box_y
z_min=0.0
z_max=$old_box_z
box_x=`echo "$x_max - $x_min" | bc -l`
box_y=`echo "$y_max - $y_min" | bc -l`
box_z=`echo "$z_max - $z_min" | bc -l`

# pore axis center, nm
pore_center_x=`echo "0.5 * $box_x" | bc -l`
pore_center_y=`echo "0.5 * $box_y" | bc -l`

# pore dimensions, nm
pore_inner_radius=-0.0   # use negative to ensure cylinder
pore_outer_radius=3.0
pore_surface_layer1_inner_radius=`echo "$pore_outer_radius - 0.2" | bc -l`
pore_surface_layer1_outer_radius=`echo "$pore_outer_radius + 0.25" | bc -l`
pore_surface_layer2_inner_radius=`echo "$pore_outer_radius - 0.2" | bc -l`
pore_surface_layer2_outer_radius=`echo "$pore_outer_radius + 0.85" | bc -l`

# filled solvent dimensions, nm
gap_from_solvent_to_pore_surface=-0.1
solvent_filled_inner_radius=$pore_inner_radius
solvent_filled_outer_radius=`echo "$pore_outer_radius - $gap_from_solvent_to_pore_surface" | bc -l`		
# -------------------------------------
