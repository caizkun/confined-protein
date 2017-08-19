#!/bin/bash
# @Zhikun Cai, 01/2016
#
# Use this script to rename silica residues
# usage:
#       chmod +x rename_silica_residues.sh
#       ./rename_silica_residues.sh input.gro output.gro


# ------ configure parameters ------
# residue names for replacement; sequence order should match
old_residue_names=('SIX' 'ONBX' 'OBX' 'HAX')
new_residue_names=('RSIX' 'RONBX' 'ROBX' 'RHAX')
# ----------------------------------

num_of_residue_names=${#old_residue_names[@]}

input_file="$1"
output_file="$2"

{
    read system_name
    read num_of_atoms
    atom_indice=`seq 1 $num_of_atoms`

    # create output file
    echo "$system_name" > $output_file
    echo "$num_of_atoms" >> $output_file

    for i_atom in $atom_indice; do
        IFS=''      # turn of word splitting to keep whitespaces
        read input_line

        # spaces for the first four variables in gro file may merge, don't simply use cut or awk    
        residue_id=`echo ${input_line:0:5} | awk -F ' ' '{print $1}'`
        residue_name=`echo ${input_line:5:5} | awk -F ' ' '{print $1}'`
        atom_name=`echo ${input_line:10:5} | awk -F ' ' '{print $1}'`
        atom_id=`echo ${input_line:15:5} | awk -F ' ' '{print $1}'`
        x=${input_line:20:8}
        y=${input_line:28:8}
        z=${input_line:36:8}
        v_x=${input_line:44:8}
        v_y=${input_line:52:8}
        v_z=${input_line:60:8}

        for (( i_name=0; i_name<$num_of_residue_names; i_name++ )); do
            if [ $residue_name == ${old_residue_names[$i_name]} ]; then
                residue_name=${new_residue_names[$i_name]}
                break
            fi
        done

        printf "%5d%-5s%5s%5d%8.3f%8.3f%8.3f%8.4f%8.4f%8.4f\n" $residue_id $residue_name $atom_name $atom_id $x $y $z $v_x $v_y $v_z >> $output_file
    done

    # append box dimensions
    IFS=''
    read box_dimensions
    echo "$box_dimensions" >> $output_file

} < $input_file

