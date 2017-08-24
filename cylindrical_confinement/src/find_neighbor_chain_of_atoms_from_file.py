# @Zhikun Cai, UIUC, 02/2016

# Use this script to find the desired neighbor chain of atoms read from file
# Usage:
#   python find_neighbor_chain_of_atoms_from_file.py surface_input_file.gro bulk_input_file.gro output_neighbor_chain.gro

import sys
import numpy as np

from gropy import GroSystem


# ------ configure parameters ------
# 1st is the starting atom (read from input file)
# 2nd is the first neighbor of the 1st
# 3rd is the first neighbor of the 2nd (excluding the 1st)
# etc ...
atom_neighbor_chain = ['ONBX', 'SIX', 'OBX']

# one element fewer than above
neighbor_searching_cutoffs=[0.2, 0.2]        # SI-O ~ 0.16 nm; SI-SI ~ 0.32 nm; O-O ~ 0.26 nm
# ----------------------------------

if len(sys.argv) == 4:
    surface_input_file = str(sys.argv[1])     
    bulk_input_file    = str(sys.argv[2]) 
    output_file        = str(sys.argv[3])
else:
    print "Error! Not enough input arguments!"

# read input systems
surface_system = GroSystem()
surface_system.read_gro_file(surface_input_file)
bulk_system    = GroSystem()
bulk_system.read_gro_file(bulk_input_file)

# pre-define output system
system_of_neighbor_chain = GroSystem()

output_system_name_tmp = 'Atom neighbor chain ( '
for neighbor in atom_neighbor_chain:
    output_system_name_tmp += neighbor + ' '
output_system_name_tmp += ') in "' + bulk_system.system_name + '"'

system_of_neighbor_chain.system_name = output_system_name_tmp
system_of_neighbor_chain.box = surface_system.box

# determine length of neighbor chain
length_of_neighbor_chain = len(atom_neighbor_chain);

for i_surface_atom in xrange(surface_system.num_of_atoms):
    # match the starting atom
    if surface_system.atom_name[i_surface_atom] == atom_neighbor_chain[0]:
        system_of_neighbor_chain.copy_atom_entry(surface_system, i_surface_atom)
        
        # loop over the rest neighbor chain
        for i_neighbor in xrange(1, length_of_neighbor_chain):

            # neighbor searching
            for j_bulk_atom in xrange(bulk_system.num_of_atoms):
                
                # exclude self
                if bulk_system.atom_id[j_bulk_atom] == system_of_neighbor_chain.atom_id[-1] and \
                    bulk_system.atom_name[j_bulk_atom] == system_of_neighbor_chain.atom_name[-1]:
                    continue
                
                # exclude previous atom in the neighbor chain
                if i_neighbor > 1:
                    if bulk_system.atom_id[j_bulk_atom] == system_of_neighbor_chain.atom_id[-2] and \
                        bulk_system.atom_name[j_bulk_atom] == system_of_neighbor_chain.atom_name[-2]:
                            continue

                if bulk_system.atom_name[j_bulk_atom] == atom_neighbor_chain[i_neighbor]:
                    # compute distance between two atoms
                    delta_x = bulk_system.x[j_bulk_atom] - system_of_neighbor_chain.x[-1]
                    delta_y = bulk_system.y[j_bulk_atom] - system_of_neighbor_chain.y[-1]
                    delta_z = bulk_system.z[j_bulk_atom] - system_of_neighbor_chain.z[-1]
                    delta_x -= bulk_system.box[0] * round(delta_x / bulk_system.box[0])     # pbc
                    delta_y -= bulk_system.box[1] * round(delta_y / bulk_system.box[1])
                    delta_z -= bulk_system.box[2] * round(delta_z / bulk_system.box[2])
                    distance_bewteen_two_atoms = np.sqrt(delta_x**2 + delta_y**2 + delta_z**2)

                    if distance_bewteen_two_atoms < neighbor_searching_cutoffs[i_neighbor - 1]:
                        system_of_neighbor_chain.copy_atom_entry(bulk_system, j_bulk_atom)
                        break

# write output file
system_of_neighbor_chain.write_gro_file(output_file)

