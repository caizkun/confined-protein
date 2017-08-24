# @Zhikun Cai, UIUC, 02/2016

# Use this scrip to classify atoms according to a desired neighbor list.
#   A atom is considered dangling if has no neighbors, and is saved in output_dangling_atoms;
#   A atom is considered unsaturated if it has fewer or unmatched neighbors than the right neighbor list, and is saved in output_unsaturated_atoms;
#   A atom is considered saturated if it has the right neighbor list, and is saved in output_saturated_atoms;
#   A atom is considered oversaturated if it has more neighbors than the right neighbor list, and is saved in output_oversaturated_atoms;
#
# Usage:
#   python classify_atom_by_neighbors.py surface_input_file.gro bulk_input_file.gro output_dangling_atoms.gro output_unsaturated_atoms.gro output_oversaturated_atoms.gro  

import sys
import numpy as np

from gropy import GroSystem


# ------ configure parameters ------
atom_to_classify = 'SIX'
seeking_neighbor_list = ['OBX', 'OBX', 'OBX', 'OBX']

neighbor_searching_cutoff = 0.2         # SI-O ~ 0.16 nm; SI-SI ~ 0.32 nm; O-O ~ 0.26 nm
# ----------------------------------

if len(sys.argv) == 7:
    surface_input_file = str(sys.argv[1])     
    bulk_input_file = str(sys.argv[2]) 
    output_file_dangling_atoms = str(sys.argv[3])
    output_file_unsaturated_atoms = str(sys.argv[4])
    output_file_saturated_atoms = str(sys.argv[5])
    output_file_oversaturated_atoms = str(sys.argv[6])
else:
    print "Error! Not enough input arguments!"

num_of_seeking_neighbors = len(seeking_neighbor_list)

# read input systems
surface_system = GroSystem()
surface_system.read_gro_file(surface_input_file)
bulk_system = GroSystem()
bulk_system.read_gro_file(bulk_input_file)

# pre-define output systems
system_of_dangling_atoms = GroSystem()
system_of_dangling_atoms.system_name = 'Dangling ' + atom_to_classify + ' in "' + surface_system.system_name + '"'
system_of_dangling_atoms.box = surface_system.box

system_of_unsaturated_atoms = GroSystem()
system_of_unsaturated_atoms.system_name = 'Unsaturated ' + atom_to_classify + ' in "' + surface_system.system_name + '"'
system_of_unsaturated_atoms.box = surface_system.box

system_of_saturated_atoms = GroSystem()
system_of_saturated_atoms.system_name = 'Saturated ' + atom_to_classify + ' in "' + surface_system.system_name + '"'
system_of_saturated_atoms.box = surface_system.box

system_of_oversaturated_atoms = GroSystem()
system_of_oversaturated_atoms.system_name = 'Oversaturated ' + atom_to_classify + ' in "' + surface_system.system_name + '"'
system_of_oversaturated_atoms.box = surface_system.box

for i_surface_atom in xrange(surface_system.num_of_atoms):
    if surface_system.atom_name[i_surface_atom] == atom_to_classify:
        found_neighbor_list = []
        
        # neighbor list searching
        for j_bulk_atom in xrange(bulk_system.num_of_atoms):
            
            # exclude self
            if bulk_system.atom_id[j_bulk_atom] == surface_system.atom_id[i_surface_atom] and \
                bulk_system.atom_name[j_bulk_atom] == surface_system.atom_name[i_surface_atom]:
                continue

            # compute distance between two atoms
            delta_x = bulk_system.x[j_bulk_atom] - surface_system.x[i_surface_atom]
            delta_y = bulk_system.y[j_bulk_atom] - surface_system.y[i_surface_atom]
            delta_z = bulk_system.z[j_bulk_atom] - surface_system.z[i_surface_atom]
            delta_x -= bulk_system.box[0] * round(delta_x / bulk_system.box[0])     # pbc
            delta_y -= bulk_system.box[1] * round(delta_y / bulk_system.box[1])
            delta_z -= bulk_system.box[2] * round(delta_z / bulk_system.box[2])
            distance_bewteen_two_atoms = np.sqrt(delta_x**2 + delta_y**2 + delta_z**2)

            if distance_bewteen_two_atoms < neighbor_searching_cutoff:
                found_neighbor_list.append(bulk_system.atom_name[j_bulk_atom])
                if len(found_neighbor_list) == len(seeking_neighbor_list) + 1:
                    break

        # compare found neighbor list with that of desire
        num_of_found_neighbors = len(found_neighbor_list)
        
        # check dangling atom
        if num_of_found_neighbors == 0: 
            print "Dangling: atom_id %d, neighbors %r" % (surface_system.atom_id[i_surface_atom], found_neighbor_list)
            system_of_dangling_atoms.copy_atom_entry(surface_system, i_surface_atom)
            continue
        
        # check oversaturated atom
        if num_of_found_neighbors > num_of_seeking_neighbors:
            print "Oversaturated: atom_id %d, neighbors %r" % (surface_system.atom_id[i_surface_atom], found_neighbor_list)
            system_of_oversaturated_atoms.copy_atom_entry(surface_system, i_surface_atom)
            continue

        # check unsaturated atom
        if num_of_found_neighbors < num_of_seeking_neighbors:
            print "Unsaturated case 1 (fewer): atom_id %d, neighbors %r" % (surface_system.atom_id[i_surface_atom], found_neighbor_list)
            system_of_unsaturated_atoms.copy_atom_entry(surface_system, i_surface_atom)
        else:
            # check if neighbor list match exactly
            num_of_matched_neighbors = 0
            for i_seeking_neighbor in xrange(num_of_seeking_neighbors):
                for j_found_neighbor in xrange(num_of_found_neighbors):
                    if found_neighbor_list[j_found_neighbor] == seeking_neighbor_list[i_seeking_neighbor]:
                        num_of_matched_neighbors += 1
                        found_neighbor_list[j_found_neighbor] = ''
                        break

            if num_of_matched_neighbors == num_of_seeking_neighbors:
                print "Saturated: atom_id %d, neighbors %r" % (surface_system.atom_id[i_surface_atom], found_neighbor_list)
                system_of_saturated_atoms.copy_atom_entry(surface_system, i_surface_atom)
            else:
                print "Unsaturated case 2 (unmatched): atom_id %d, neighbors %r" % (surface_system.atom_id[i_surface_atom], found_neighbor_list)
                system_of_unsaturated_atoms.copy_atom_entry(surface_system, i_surface_atom)

# write output files
system_of_dangling_atoms.write_gro_file(output_file_dangling_atoms)
system_of_unsaturated_atoms.write_gro_file(output_file_unsaturated_atoms)
system_of_saturated_atoms.write_gro_file(output_file_saturated_atoms)
system_of_oversaturated_atoms.write_gro_file(output_file_oversaturated_atoms)



