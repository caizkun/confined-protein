# @Zhikun Cai, UIUC, 02/2016

# Use this script to construct a surface molecule layer
# Usage:
#   python construct_surface_molecule.py surface_residues_input_file.gro surface_hydrogens_input_file.gro surface_molecule_output_file.gro

import sys
import numpy as np

from gropy import GroSystem


# ------ configure parameters ------

unnecessary_atom_list = ['OBX']

# ----------------------------------

if len(sys.argv) == 4:
    surface_residues_input_file     = str(sys.argv[1])
    surface_hydrogens_input_file    = str(sys.argv[2])
    output_file                     = str(sys.argv[3])
else:
    print "Error! Not enough input arguments!"


# read input systems
surface_residues = GroSystem()
surface_residues.read_gro_file(surface_residues_input_file)
surface_hydrogens = GroSystem()
surface_hydrogens.read_gro_file(surface_hydrogens_input_file)

# remove unnecessary atoms from surface residues
for atom_name in unnecessary_atom_list:
    surface_residues.remove_atoms_by_name(atom_name)

# construct the surface molecule
surface_molecule = GroSystem()
surface_molecule.system_name = "Constructed surface molecule"
surface_molecule.box = surface_residues.box

for i_atom in xrange(surface_hydrogens.num_of_atoms):
    surface_molecule.copy_atom_entry(surface_hydrogens, i_atom)
    surface_molecule.copy_atom_entry(surface_residues, 2 * i_atom)
    surface_molecule.copy_atom_entry(surface_residues, 2 * i_atom + 1)

# write output file
surface_molecule.write_gro_file(output_file)
