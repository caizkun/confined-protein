# @Zhikun Cai, UIUC, 02/2016

# Use this script to find surface residues within a shell on the pore surface 
# Usage:
#   python find_surface_residues.py input.gro output.gro pore_surface_inner_radius pore_surface_outer_raidus

import sys
import numpy as np

from gropy import GroSystem


# ------ configure parameters ------
from configure_system_dimensions import pore_center_x
from configure_system_dimensions import pore_center_y

# # pore axis center, nm
# pore_center_x = 4.0
# pore_center_y = 4.0

seeking_surface_residues = ['RSIX', 'ROBX']
# ----------------------------------

if len(sys.argv) == 5:
    input_file  = str(sys.argv[1])     
    output_file = str(sys.argv[2]) 
    pore_surface_inner_radius = float(sys.argv[3])
    pore_surface_outer_radius = float(sys.argv[4])
else:
    print "Error! Not enough input arguments!"

# read input systems
input_system = GroSystem()
input_system.read_gro_file(input_file)

# pre-define output systems
system_of_surface_residues = GroSystem()
system_of_surface_residues.system_name = 'Surface residues in shell ' +  str(pore_surface_inner_radius) + '~' + str(pore_surface_outer_radius) + 'nm of "' + input_system.system_name + '"'
system_of_surface_residues.box = input_system.box

# pre-define last found residue to avoid duplicated copy of atoms
last_found_residue_id = 0
last_found_residue_name = 'ToBeDefined'

for i_atom in xrange(input_system.num_of_atoms):
    # loop over seeking surface residues
    for trial_residue in seeking_surface_residues:
        if trial_residue == input_system.residue_name[i_atom]:  
            # compute distance to center axis
            delta_x = input_system.x[i_atom] - pore_center_x
            delta_y = input_system.y[i_atom] - pore_center_y
            distance_to_center_axis = np.sqrt(delta_x**2 + delta_y**2)

            if distance_to_center_axis > pore_surface_inner_radius and distance_to_center_axis < pore_surface_outer_radius:
                # check if current residue is newly found
                if input_system.residue_id[i_atom] != last_found_residue_id or input_system.residue_name[i_atom] != last_found_residue_name:
                    system_of_surface_residues.copy_residue_entries(input_system, input_system.residue_id[i_atom], input_system.residue_name[i_atom])
                    last_found_residue_id = input_system.residue_id[i_atom]
                    last_found_residue_name = input_system.residue_name[i_atom]
            break

# write output files
system_of_surface_residues.write_gro_file(output_file)



