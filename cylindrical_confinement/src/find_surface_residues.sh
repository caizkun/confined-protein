#!/bin/bash
# @Zhikun Cai, 01/2016
#
# Use this script to find surface residues within a shell on the pore surface 
# usage:
#       chmod +x find_surface_residues.sh
#       ./find_surface_residues.sh input.gro output.gro pore_surface_inner_radius pore_surface_outer_radius


# ------ configure parameters ------
source configure_system_dimensions.sh

## pore axis center, nm
#pore_center_x=4.0
#pore_center_y=4.0

# surface residue of interest
surface_residues_to_find=('RSIX' 'ROBX')
# ----------------------------------

input_file="$1"
output_file="$2" 
pore_surface_inner_radius=$3
pore_surface_outer_radius=$4

{
    read system_name
    read num_of_atoms
    atom_indice=`seq 1 $num_of_atoms`

    # create output file
    echo "Pore-surface residues in \"${system_name}\"" > $output_file
    echo "$num_of_atoms" >> $output_file

    last_found_residue='ToBeDefined'

    for i_atom in $atom_indice; do
        IFS=''      # turn of word splitting to keep whitespaces
        read input_line

        # spaces for the first four variables in gro file may merge, don't simply use cut or awk    
        residue_id=`echo ${input_line:0:5} | awk -F ' ' '{print $1}'`
        residue_name=`echo ${input_line:5:5} | awk -F ' ' '{print $1}'`
        current_residue=${residue_id}${residue_name}

        x=${input_line:20:8}
        y=${input_line:28:8}
        z=${input_line:36:8}

        for trial_residue in ${surface_residues_to_find[@]}; do
            if [ "$trial_residue" == "$residue_name" ]; then
                delta_x=`echo "($x - $pore_center_x)" | bc -l`
                delta_y=`echo "($y - $pore_center_y)" | bc -l`
                distance_to_center_axis=`echo "sqrt($delta_x * $delta_x + $delta_y * $delta_y)" | bc -l`

                if (( $(echo "$distance_to_center_axis > $pore_surface_inner_radius" | bc -l) )) && (( $(echo "$distance_to_center_axis < $pore_surface_outer_radius" | bc -l) )); then
                    if [ "$current_residue" != "$last_found_residue" ]; then
                        if [ $residue_id -lt 10000 ]; then
                            cat $input_file | grep " $current_residue" >> $output_file  # add whitespace to ensure select the exact residue
                        else
                            cat $input_file | grep "$current_residue" >> $output_file
                        fi
                        last_found_residue=$current_residue
                    fi
                fi

                break
            fi
        done
    done

    # append box dimensions
    IFS=''
    read box_dimensions
    echo "$box_dimensions" >> $output_file

} < $input_file

# update num of aotms within the surface shell
num_of_output_lines=`cat $output_file | wc -l`
num_of_surface_atoms=$(($num_of_output_lines - 3))
sed -i.bak "2s/$num_of_atoms/$num_of_surface_atoms/g" $output_file
