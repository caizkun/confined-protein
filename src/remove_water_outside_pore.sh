#!/bin/bash
# @Zhikun Cai, 01/2016
#
# Use this script to remove water molecules outside a cylinder (shell)
# usage:
#       chmod +x remove_water_outside_pore.sh
#       ./remove_water_outside_pore.sh input.gro output.gro


# ------ configure parameters ------
source configure_system_dimensions.sh

# # pore dimensions, nm
# pore_inner_radius=-0.0   # use negative to ensure cylinder
# pore_outer_radius=3.0

# # pore axis center, nm
# pore_center_x=4.0
# pore_center_y=4.0

# # filled solvent dimensions, nm
# gap_from_solvent_to_pore_surface=0.18
# solvent_filled_inner_radius=$pore_inner_radius
# solvent_filled_outer_radius=`echo "$pore_outer_radius - $gap_from_solvent_to_pore_surface" | bc -l`

# residue for removal
residue_to_remove='SOL'                 # TODO: change to array
num_of_atoms_one_removed_residue=4      # TIP4P-like: 4, SPC-like: 3
# ----------------------------------

input_file="$1"
output_file="$2"

num_of_deleted_atoms=0

{
    read system_name
    read num_of_atoms
    atom_indice=`seq 1 $num_of_atoms`

    # create output file
    echo "$system_name" > $output_file
    echo "$num_of_atoms" >> $output_file

    last_deleted_residue='ToBeDefined'

    for i_atom in $atom_indice; do
        IFS=''      # turn of word splitting to keep whitespaces
        read input_line

        current_residue=`echo ${input_line:0:10} | awk -F ' ' '{print $1}'`
        residue_id=`echo ${input_line:0:5} | awk -F ' ' '{print $1}'`
        residue_name=`echo ${input_line:5:5} | awk -F ' ' '{print $1}'`

        # echo $residue_id

        if [ "$residue_name" == "$residue_to_remove" ]; then
            # fetch x, y, z using substring;
            # don't use cut or awk because the spaces for atom_name and atom_index may merge when atom_index >= 10000
            x=${input_line:20:8}
            y=${input_line:28:8}
            z=${input_line:36:8}

            delta_x=`echo "($x - $pore_center_x)" | bc -l`
            delta_y=`echo "($y - $pore_center_y)" | bc -l`
            distance_to_center_axis=`echo "sqrt($delta_x * $delta_x + $delta_y * $delta_y)" | bc -l`

            # skip atoms located outside the desired cylinder (shell)
            # 1. exclude future writing of atoms belonging to the last deleted residue 
            if [ "$last_deleted_residue" == "$current_residue" ]; then
                continue
            fi
            # 2. skip writing new atom if outside the cylinder (shell)
            # 3. remove atoms that were already written but belong to the current skipped residue
            if (( $(echo "$distance_to_center_axis < $solvent_filled_inner_radius" | bc -l) )) || (( $(echo "$distance_to_center_axis > $solvent_filled_outer_radius" | bc -l) )); then
                last_deleted_residue="$current_residue"
                num_of_deleted_atoms=$(($num_of_deleted_atoms + $num_of_atoms_one_removed_residue))
                if [ $residue_id -lt 10000 ]; then
                    sed -i.bak "/ ${current_residue}/d" $output_file    # add one whitespace to ensure remove the exact residue
                else
                    sed -i.bak "/${current_residue}/d" $output_file
                fi

                continue
            fi
        fi

        echo "$input_line" >> $output_file
    done

    # append box dimensions
    IFS=''
    read box_dimensions
    echo "$box_dimensions" >> $output_file

} < $input_file

# update num of remaining atoms
num_of_remaining_atoms=$(($num_of_atoms - $num_of_deleted_atoms))
sed -i.bak "2s/$num_of_atoms/$num_of_remaining_atoms/g" $output_file


## ---- comment this section is GROMACS is not installed ----
## call GROMACS to renumber atom indice
#genconf_d -f "$output_file" -o "${output_file}_renum.gro" -renumber
