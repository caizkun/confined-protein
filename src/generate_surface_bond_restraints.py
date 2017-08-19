# @Zhikun Cai, UIUC, 02/2016

# Use this script to find the desired neighbor chain of atoms read from file
# Usage:
#   python generate_surface_restraints.py surface_molecule_input_file.gro surface_molecule_no_duplicates_output_file.gro bond_restraints_output_file.itp

import sys
import numpy as np

from gropy import GroSystem


# ------ configure parameters ------
#  [ molecule type ]
molecule_name = "RSIOH"
nrexcl        = 3

# [ atoms ]
atom_type_list    = ["HAX", "ONBX", "SIX"]
residue_nr_list   = [1, 1, 1]
residue_name_list = ["RSIOH", "RSIOH", "RSIOH"]
atom_name_list    = ["HAX", "ONBX", "SIX"]
# charge_group_list = [1, 2, 3]			# 
atom_charge_list  = [0.425, -0.95, 2.1]

# [ bonds ]
bond_length_OH      	 = 1.0e-1		# nm
bond_stretching_const_OH = 2.31850e5 * 10 	# kJ/(mol*nm^2)

# [ angles ]
bond_angle_SIOH 		 = 109.47		# degree
bond_bending_const_SIOH	 = 1.2552e2	* 10	# kJ/(mol*rad^2)
# ----------------------------------

if len(sys.argv) == 4:
    surface_molecule_input_file     				= str(sys.argv[1])
    surface_molecule_no_duplicates_output_file    	= str(sys.argv[2])
    bond_restraints_output_file                   	= str(sys.argv[3])
else:
    print "Error! Not enough input arguments!"

# read input systems
surface_molecule = GroSystem()
surface_molecule.read_gro_file(surface_molecule_input_file)

surface_SIX = GroSystem()
surface_SIX.copy_atoms_by_name(surface_molecule, "SIX")

# identify duplicated SIX's and reassign indices
indices_of_duplicated_SIX = []
for i_atom in xrange(surface_SIX.num_of_atoms):
	for j_atom in xrange(i_atom):
		if surface_SIX.atom_id[i_atom] == surface_SIX.atom_id[j_atom]:
			indices_of_duplicated_SIX.append(i_atom)
			break

print "\n Number of duplicated atoms: ", len(indices_of_duplicated_SIX)
print indices_of_duplicated_SIX

# remove duplicated SIX
surface_SIX_removed_duplicates = GroSystem()
surface_SIX_removed_duplicates.copy_atoms_by_name(surface_SIX, "SIX")
for i_atom in xrange(len(indices_of_duplicated_SIX)):
	surface_SIX_removed_duplicates.remove_atom_entry(indices_of_duplicated_SIX[i_atom] - i_atom)

indices_SIX = []
for i_atom in xrange(surface_SIX.num_of_atoms):
	for j_atom in xrange(surface_SIX_removed_duplicates.num_of_atoms):
		if surface_SIX.atom_id[i_atom] == surface_SIX_removed_duplicates.atom_id[j_atom]:
			indices_SIX.append(j_atom)
			break

print "\n Atoms indices after removing duplicates"
print indices_SIX

# generate the surface molecule without duplicated atoms
surface_molecule_removed_duplicates = GroSystem()
surface_molecule_removed_duplicates.system_name = surface_molecule.system_name
surface_molecule_removed_duplicates.box = surface_molecule.box

surface_molecule_removed_duplicates.copy_atoms_by_name(surface_molecule, "HAX")
surface_molecule_removed_duplicates.copy_atoms_by_name(surface_molecule, "ONBX")
surface_molecule_removed_duplicates.copy_atoms_by_name(surface_SIX_removed_duplicates, "SIX")

# rename residues and renumber to one single residue
for i_atom in xrange(surface_molecule_removed_duplicates.num_of_atoms):
    surface_molecule_removed_duplicates.residue_id[i_atom] = 1
    surface_molecule_removed_duplicates.residue_name[i_atom] = "RSIOH"
    surface_molecule_removed_duplicates.atom_id[i_atom] = i_atom + 1    # atom_id in gro file starts from 1

# generate H-O bond pairs within the surface molecule
indices_HAX = range(1, surface_SIX.num_of_atoms + 1)
indices_ONBX = range(surface_SIX.num_of_atoms + 1, 2*surface_SIX.num_of_atoms + 1)
indices_SIX = [(index + 2*surface_SIX.num_of_atoms + 1) for index in indices_SIX]

bond_pairs_OH = []
for i_atom in xrange(surface_SIX.num_of_atoms):
	bond_pairs_OH.append([indices_HAX[i_atom], indices_ONBX[i_atom]])		# atom index at itp file starts from 1 

# generate H-O-SI bond angle triples within the surface molecule
angle_triples_SIOH = []
for i_atom in xrange(surface_SIX.num_of_atoms):
	angle_triples_SIOH.append([indices_HAX[i_atom], indices_ONBX[i_atom], indices_SIX[i_atom]])

# write output files
surface_molecule_removed_duplicates.write_gro_file(surface_molecule_no_duplicates_output_file)

with open(bond_restraints_output_file, 'w') as file_id:
	file_id.write("[ moleculetype ]\n")
	file_id.write("; molename 	nrexcl\n")
	file_id.write("%s \t %d\n\n" % (molecule_name, nrexcl))
	file_id.write("[ atoms ]\n")
	file_id.write("; id	at_type	res_nr	res_name     at_name  cg_nr   charge\n")
	for i_atom in xrange(surface_molecule_removed_duplicates.num_of_atoms):
		for j_name in xrange(len(atom_name_list)):
			if surface_molecule_removed_duplicates.atom_name[i_atom] == atom_name_list[j_name]:
				file_id.write("%d\t%s\t%d\t%s\t%s\t%d\t%f\n" % 
					(i_atom + 1, atom_type_list[j_name], residue_nr_list[j_name], residue_name_list[j_name],
						atom_name_list[j_name], i_atom + 1, atom_charge_list[j_name]))

	file_id.write("\n[ bonds ]\n")
	file_id.write("; ai aj	funct	b0 [nm]			kb [kJ/(mol*nm^2)]\n")
	for bond_pair in bond_pairs_OH:
		file_id.write("%d\t%d\t\t%d\t%e\t%e\n" % (bond_pair[0], bond_pair[1], 1, bond_length_OH, bond_stretching_const_OH))

	file_id.write("\n[ angles ]\n")
	file_id.write("; ai aj ak	funct	theta0 [deg.]		force.const. [kJ/(mol*rad^2)]\n")
	for angle_triple in angle_triples_SIOH:
		file_id.write("%d\t%d\t%d\t\t%d\t%e\t%e\n" % (angle_triple[0], angle_triple[1], angle_triple[2], 1, bond_angle_SIOH, bond_bending_const_SIOH))	

file_id.close()













