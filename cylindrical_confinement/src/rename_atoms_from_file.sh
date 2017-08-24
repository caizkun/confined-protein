#!/bin/bash
# @Zhikun Cai, 01/2016
#
# Use this script to rename some specified residues/atoms, which are listed in one gro file, in another gro file
# usage:
#       chmod +x rename_atoms_from_file.sh
#       ./rename_atoms_from_file.sh input_specified_atoms.gro input_system_to_modify.gro output.gro


# ------ configure parameters ------
# residue/atom names for replacement; sequence order should match
# all these four arrays should have the same lengths
old_atom_names=('OBX' 'HAX')
new_atom_names=('ONBX' 'HAX')

old_residue_names=('ROBX' 'ONSIO')
new_residue_names=('RONBX' 'RHAX')
# ----------------------------------

num_of_atom_names=${#old_atom_names[@]}

input_file_specified_atoms="$1"
input_file_to_modify="$2"
output_file="$3"

cp $input_file_to_modify $output_file

{
    read specified_system_name
    read num_of_specified_atoms
    specified_atom_indice=`seq 1 $num_of_specified_atoms`

    for i_atom in $specified_atom_indice; do
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

        for (( i_name=0; i_name<$num_of_atom_names; i_name++ )); do
            if [ "$atom_name" == "${old_atom_names[$i_name]}" ]; then
                # replacement of atom/residue name
                atom_name=${new_atom_names[$i_name]}
                residue_name=${new_residue_names[$i_name]}
                modified_input_line=`printf "%5d%-5s%5s%5d%8.3f%8.3f%8.3f%8.4f%8.4f%8.4f\n" $residue_id $residue_name $atom_name $atom_id $x $y $z $v_x $v_y $v_z`
                sed -i.bak "s/$input_line/$modified_input_line/g" $output_file
                # if removal instead of replacement, uncomment below line and block for updating num of atoms
                # sed -i.bak "/$modified_input_line/d" $output_file
                break
            fi
        done 
    done

} < $input_file_specified_atoms

# # update num of aotms in output file
# num_of_system_atoms=`sed -n '2p' < $output_file | awk '{print $1}'`
# num_of_remaining_atoms=$(($num_of_system_atoms - $num_of_specified_atoms))
# sed -i.bak "2s/$num_of_system_atoms/$num_of_remaining_atoms/g" $output_file
