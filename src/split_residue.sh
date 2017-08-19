#!/bin/bash
# @Zhikun Cai, 01/2016
#
# Use this script to split provided residue into individual monatomic residues
# usage:
#       chmod +x split_residue.sh
#       ./split_residue.sh input.gro output.gro residue_to_split


# ------ configure parameters ------
# residue name would be replaced by individual atom names  
# ----------------------------------

input_file="$1"
output_file="$2"
residue_to_split="$3"

{
    read system_name
    read num_of_atoms
    atom_indice=`seq 1 $num_of_atoms`

    # create output file
    echo "$system_name" > $output_file
    echo "$num_of_atoms" >> $output_file

    last_read_residue='ToBeDefined'
    last_residue_id=0

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

        current_read_residue=${residue_id}${residue_name}

        if [ "$residue_name" == "$residue_to_split" ]; then              # rebin target residues
            residue_id=$(($last_residue_id + 1))
            residue_name=$atom_name                    
        elif [ "$current_read_residue" != "$last_read_residue" ]; then    # meanwhile adjust residue_id of irrelevant residues
            residue_id=$(($last_residue_id + 1))
        else
            residue_id=$last_residue_id
        fi

        printf "%5d%-5s%5s%5d%8.3f%8.3f%8.3f%8.4f%8.4f%8.4f\n" $residue_id $residue_name $atom_name $atom_id $x $y $z $v_x $v_y $v_z >> $output_file
    
        last_residue_id=$residue_id 
        last_read_residue=$current_read_residue
    done

    # append box dimensions
    IFS=''
    read box_dimensions
    echo "$box_dimensions" >> $output_file

} < $input_file
