#!/bin/bash
# @Zhikun Cai, 01/2016
#
# Use this script to remove some specified residues/atoms, which are listed in one gro file, in another gro file
# usage:
#       chmod +x remove_atoms_from_file.sh
#       ./remove_atoms_from_file.sh input_specified_atoms.gro input_system_to_modify.gro output.gro


# ------ configure parameters ------
# 
# ----------------------------------

input_file_specified_atoms="$1"
input_file_to_modify="$2"
output_file="$3"

cp $input_file_to_modify $output_file

{
    read specified_system_name
    read num_of_specified_atoms

    if [ $num_of_specified_atoms -ne 0 ]; then

        specified_atom_indice=`seq 1 $num_of_specified_atoms`

        for i_atom in $specified_atom_indice; do
            IFS=''      # turn of word splitting to keep whitespaces
            read input_line

            sed -i.bak "/$input_line/d" $output_file
        done
    fi

} < $input_file_specified_atoms

# update num of aotms in output file
num_of_system_atoms=`sed -n '2p' < $output_file | awk '{print $1}'`
num_of_output_lines=`cat $output_file | wc -l`
num_of_remaining_atoms=$(($num_of_output_lines - 3))
sed -i.bak "2s/$num_of_system_atoms/$num_of_remaining_atoms/g" $output_file
