#!/bin/bash
# @Zhikun Cai, 01/2016
#
# Use this script to run subsequent procedures to prepare silica pore
# usage:
#       chmod +x prepare_system.sh
#       ./prepare_system.sh


#-------------------------
#		configure 1 
#-------------------------
# manipulate system configuration

initial_gro_file="silica_300K.gro"
system_keywords="mBKS_silica"

# configure system dimensions
chmod +x configure_system_dimensions.sh
source configure_system_dimensions.sh

# # dig a pore through the box
# chmod +x remove_residues_inside_pore.sh
# ./remove_residues_inside_pore.sh $initial_gro_file "${system_keywords}_pore.gro"

# # renumber atoms
# genconf_d -f "${system_keywords}_pore.gro" -o "${system_keywords}_pore.gro" -renumber

# echo "config 1 done!"


#-------------------------
#		configure 2 
#-------------------------
# process namings and indice to match force field topology files

gro_file_to_rename="${system_keywords}_pore.gro"
renaming_keywords="${system_keywords}_pore"

# # rename silica residues
# chmod +x rename_silica_residues.sh
# ./rename_silica_residues.sh "$gro_file_to_rename" "${renaming_keywords}_renamed.gro"

# # # sort residues
# # chmod +x sort_residues.sh
# # ./sort_residues.sh "${renaming_keywords}_renamed_atoms_rebined_residues.gro" "${renaming_keywords}_renamed_sorted.gro"

# # # # renumber residues
# # genconf_d -f "${renaming_keywords}_renamed_sorted.gro" -o "${renaming_keywords}_renamed_sorted_renum.gro" -renumber

# echo "config 2 done!"


#-------------------------
#		configure 3 
#-------------------------
# adjust atoms on the pore surface

gro_file_to_adjust_surface="${renaming_keywords}_renamed.gro"
adjusting_surface_keywords="${renaming_keywords}"

# # find surface residues
# #chmod +x find_surface_residues.sh
# #time ./find_surface_residues.sh "$gro_file_to_adjust_surface" "${adjusting_surface_keywords}_surface_layer1.gro" 4.3 4.75
# #time ./find_surface_residues.sh "$gro_file_to_adjust_surface" "${adjusting_surface_keywords}_surface_layer2.gro" 4.3 5.35

# python find_surface_residues.py "$gro_file_to_adjust_surface" "${adjusting_surface_keywords}_surface_layer1.gro" $pore_surface_layer1_inner_radius $pore_surface_layer1_outer_radius
# python find_surface_residues.py "$gro_file_to_adjust_surface" "${adjusting_surface_keywords}_surface_layer2.gro" $pore_surface_layer2_inner_radius $pore_surface_layer2_outer_radius

# echo "finished find_surface_residue"


# # find unsaturated silicons
# python classify_silicon_by_neighbors.py "${adjusting_surface_keywords}_surface_layer1.gro" "${adjusting_surface_keywords}_surface_layer2.gro" "${adjusting_surface_keywords}_surface_dangling_silicons.gro" "${adjusting_surface_keywords}_surface_unsaturated_silicons.gro" "${adjusting_surface_keywords}_surface_saturated_silicons.gro"  "${adjusting_surface_keywords}_surface_oversaturated_silicons.gro" > classify_silicon_output

# # remove unsaturated silicons from layer2
# chmod +x remove_atoms_from_file.sh
# ./remove_atoms_from_file.sh "${adjusting_surface_keywords}_surface_dangling_silicons.gro" "${adjusting_surface_keywords}_surface_layer2.gro" "${adjusting_surface_keywords}_surface_layer2_dangling_silicons_removed.gro"
# ./remove_atoms_from_file.sh "${adjusting_surface_keywords}_surface_unsaturated_silicons.gro" "${adjusting_surface_keywords}_surface_layer2.gro" "${adjusting_surface_keywords}_surface_layer2_dangling_unsaturated_silicons_removed.gro"

# echo "finished adjusting silicons"


# # find nonbridging oxygens after removing unsaturated silicons
# python classify_oxygen_by_neighbors.py "${adjusting_surface_keywords}_surface_layer1.gro" "${adjusting_surface_keywords}_surface_layer2_dangling_unsaturated_silicons_removed.gro" "${adjusting_surface_keywords}_surface_dangling_oxygens.gro" "${adjusting_surface_keywords}_surface_nonbriding_oxygens.gro" "${adjusting_surface_keywords}_surface_briding_oxygens.gro"  "${adjusting_surface_keywords}_surface_oversaturated_oxygens.gro" > classify_oxygen_output

# # remove dangling oxygens from layer2
# ./remove_atoms_from_file.sh "${adjusting_surface_keywords}_surface_dangling_oxygens.gro" "${adjusting_surface_keywords}_surface_layer2_dangling_unsaturated_silicons_removed.gro" "${adjusting_surface_keywords}_surface_layer2_dangling_unsaturated_silicons_oxygens_removed.gro"

# # rename nonbriging oxygens in layer2
# ./rename_atoms_from_file.sh "${adjusting_surface_keywords}_surface_nonbriding_oxygens.gro" "${adjusting_surface_keywords}_surface_layer2_dangling_unsaturated_silicons_oxygens_removed.gro" "${adjusting_surface_keywords}_surface_layer2_dangling_unsaturated_silicons_oxygens_removed_nonbridging_renamed.gro"

# # rename nonbriging oxygens itself
# ./rename_atoms_from_file.sh "${adjusting_surface_keywords}_surface_nonbriding_oxygens.gro" "${adjusting_surface_keywords}_surface_nonbriding_oxygens.gro" "${adjusting_surface_keywords}_surface_nonbriding_oxygens_renamed.gro"

# echo "finished adjusting oxygens"


# # process the surface layers to add hydrogoen
# # to add hydroxyl hydrogens: sort neighbor atoms of nonbriding oxygens for forming SIOH residues later
# python find_neighbor_chain_of_atoms_from_file.py "${adjusting_surface_keywords}_surface_nonbriding_oxygens_renamed.gro" "${adjusting_surface_keywords}_surface_layer2_dangling_unsaturated_silicons_oxygens_removed_nonbridging_renamed.gro" "${adjusting_surface_keywords}_surface_sioh_residues.gro"

# # to add hydroxyl hydrogens: add hyrogen to constructed residues by grouping sequential sorted atoms read from file
# chmod +x add_hydrogen_to_sorted_atoms_from_file.sh
# time ./add_hydrogen_to_sorted_atoms_from_file.sh "${adjusting_surface_keywords}_surface_sioh_residues.gro" "${adjusting_surface_keywords}_surface_addedH.gro"

# # to add hydroxyl hydrogens: rename residue name for added hydrogens
# ./rename_atoms_from_file.sh "${adjusting_surface_keywords}_surface_addedH.gro" "${adjusting_surface_keywords}_surface_addedH.gro" "${adjusting_surface_keywords}_surface_addedH_renamed.gro"

# echo "\n finished locating hydrogens"


# # process the bulk system after locating hydrogens
# # remove dangling silicons from the whole system gro
# ./remove_atoms_from_file.sh "${adjusting_surface_keywords}_surface_dangling_silicons.gro" "$gro_file_to_adjust_surface" "${adjusting_surface_keywords}_dangling_silicons_removed.gro"

# # remove unsaturated silicons from the whole system gro
# ./remove_atoms_from_file.sh "${adjusting_surface_keywords}_surface_unsaturated_silicons.gro" "${adjusting_surface_keywords}_dangling_silicons_removed.gro" "${adjusting_surface_keywords}_dangling_unsaturated_silicons_removed.gro"

# # remove dangling oxygens from the whole system gro
# ./remove_atoms_from_file.sh "${adjusting_surface_keywords}_surface_dangling_oxygens.gro" "${adjusting_surface_keywords}_dangling_unsaturated_silicons_removed.gro" "${adjusting_surface_keywords}_dangling_unsaturated_silicons_oxygens_removed.gro"

# # rename nonbriging oxygens from the whole system gro
# ./rename_atoms_from_file.sh "${adjusting_surface_keywords}_surface_nonbriding_oxygens.gro" "${adjusting_surface_keywords}_dangling_unsaturated_silicons_oxygens_removed.gro" "${adjusting_surface_keywords}_dangling_unsaturated_silicons_oxygens_removed_nonbridging_renamed.gro"


#### -------- if not to add bond restraint to surface H -------
##
#### merge added hydroxyl hydrogens
###./merge_two_gros.sh "${adjusting_surface_keywords}_surface_addedH_renamed.gro" "${adjusting_surface_keywords}_dangling_unsaturated_silicons_oxygens_removed_nonbridging_renamed.gro" "${adjusting_surface_keywords}_dangling_unsaturated_silicons_oxygens_removed_nonbridging_renamed_addedH.gro"
##
#### -------- if to add bond restraint to surface H -----------

# python construct_surface_molecule.py "${adjusting_surface_keywords}_surface_sioh_residues.gro" "${adjusting_surface_keywords}_surface_addedH_renamed.gro" "${adjusting_surface_keywords}_surface_molecule.gro"

# python generate_surface_bond_restraints.py "${adjusting_surface_keywords}_surface_molecule.gro" "${adjusting_surface_keywords}_surface_molecule_no_duplicates.gro" "${adjusting_surface_keywords}_surface_molecule_no_duplicates.itp"

# # remove duplicated surface atoms
# ./remove_atoms_from_file.sh "${adjusting_surface_keywords}_surface_molecule.gro" "${adjusting_surface_keywords}_dangling_unsaturated_silicons_oxygens_removed_nonbridging_renamed.gro" "${adjusting_surface_keywords}_dangling_unsaturated_silicons_oxygens_removed_nonbridging_renamed_duplicates_removed.gro"

# # merge surface molecule without duplicates to the original bulk system
# ./merge_two_gros.sh "${adjusting_surface_keywords}_surface_molecule_no_duplicates.gro" "${adjusting_surface_keywords}_dangling_unsaturated_silicons_oxygens_removed_nonbridging_renamed_duplicates_removed.gro" "${adjusting_surface_keywords}_dangling_unsaturated_silicons_oxygens_removed_nonbridging_renamed_addedH.gro"

# echo "added surface restraints"

#### -----------------------------------------------------------


# # sort
# ./sort_residues.sh "${adjusting_surface_keywords}_dangling_unsaturated_silicons_oxygens_removed_nonbridging_renamed_addedH.gro" "${adjusting_surface_keywords}_dangling_unsaturated_silicons_oxygens_removed_nonbridging_renamed_addedH_sorted.gro"

# # renumber
# genconf_d -f "${adjusting_surface_keywords}_dangling_unsaturated_silicons_oxygens_removed_nonbridging_renamed_addedH_sorted.gro" -o "${adjusting_surface_keywords}_surface_adjusted.gro" -renumber

# echo "\n surface processing done!"


#-------------------------
#		configure 4
#-------------------------
# put protein in the pore and solvate with water and maybe ions

gro_file_to_solvate="${adjusting_surface_keywords}_surface_adjusted.gro"
solvation_keywords="${adjusting_surface_keywords}_surface_adjusted"

protein_gro_file="./lysozyme/1AKI_processed.gro"
protein_keywords="lysozyme"

## shift the protein coordinates to the pore center
#editconf_d -f "$protein_gro_file" -o "${protein_keywords}_shifted.gro" -box $box_x $box_y $box_z -c
#
## randomly change the orientation of protein
#genconf_d -f "${protein_keywords}_shifted.gro" -o "${protein_keywords}_shifted_rotated.gro" -rot
#
## insert the protein into the pore
#./merge_two_gros.sh "${protein_keywords}_shifted_rotated.gro" "$gro_file_to_solvate" "${solvation_keywords}_protein_inserted.gro"
#
# solvate box with water
chmod +x solvate_box.sh
./solvate_box.sh "${solvation_keywords}_protein_inserted.gro" "${solvation_keywords}_protein_inserted_oversolvated.gro" "tip4p.gro"

 # remove water located outside the pore
chmod +x remove_water_outside_pore.sh
./remove_water_outside_pore.sh "${solvation_keywords}_protein_inserted_oversolvated.gro" "${solvation_keywords}_protein_inserted_solvated.gro"

# renumber atoms
genconf_d -f "${solvation_keywords}_protein_inserted_solvated.gro" -o "${solvation_keywords}_protein_inserted_solvated.gro" -renumber



## --- fill in more water after NVT equilibration ---
#chmod +x solvate_box.sh
#./solvate_box.sh "nvt.gro" "nvt_oversolvated.gro" "spc216.gro"
#
## remove water located outside the pore
#chmod +x remove_water_outside_pore.sh
#./remove_water_outside_pore.sh "nvt_oversolvated.gro" "nvt_solvated.gro"

# sort residues
# Do this manually may be the easiest, and then renumber

# renumber residues
#genconf_d -f "nvt_solvated.gro" -o "nvt_solvated_sorted.gro" -renumber
























