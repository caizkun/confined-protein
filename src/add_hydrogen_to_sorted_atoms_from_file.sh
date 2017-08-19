#!/bin/bash
# @Zhikun Cai, 01/2016
#
# Use this script to add hyrogen to constructed residues by grouping sequential sorted atoms read from file
# usage:
#       chmod +x add_hydrogen_to_sorted_atoms_from_file.sh
#       ./add_hydrogen_to_sorted_atoms_from_file.sh input.gro output.gro 


# ------ configure parameters ------
# sequence order should match
old_residue_sequence=('RONBX' 'RSIX' 'ROBX')    # sequence unit in file to form a new residue
old_atom_name_sequence=('ONBX' 'SIX' 'OBX')

new_constructed_residue='ONSIO'                 # one string, not array
new_atom_name_sequence=('ONBX' 'SIX' 'OBX')
# ----------------------------------

input_file="$1"                                 # file of atoms sorted according to the desired residue                      
output_file="$2"                                # save coordinates of added hydrogens

# temporary file
residue_unit_file="residue_${new_constructed_residue}_unit.gro"
residue_unit_addedH_file="residue_${new_constructed_residue}_unit_addedH.gro"

# additonal parameters for calling GROMACS pdb2gmx, usually no need to change
# require the used force field in the path or in current directory
force_field="oplsaa_clayff_spce"
added_hydrogen_name="HAX"
water_model="tip4p"
position_restraint_file="residue_${new_constructed_residue}_unit_posre.itp"
topology_file="residue_${new_constructed_residue}_unit_topol.top"
export GMX_MAXBACKUP=-1         # temporarily disenable GROMACS file backup

num_of_atoms_in_constructed_residue=${#new_atom_name_sequence[@]}

{
    read system_name
    read num_of_atoms
    atom_indice=`seq 1 $num_of_atoms`

    echo "Hyrodgens added to $system_name" > $output_file
    echo "$num_of_atoms" >> $output_file

    last_constructed_residue_id=0
    num_of_atoms_processed=0
    num_of_hydrogen_added=0

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

        if [ $num_of_atoms_processed -eq 0 ]; then
            last_constructed_residue_id=$residue_id
            echo "Residue unit of \"$new_constructed_residue\"" > $residue_unit_file
            echo "$num_of_atoms_in_constructed_residue" >> $residue_unit_file
        else
            residue_id=$last_constructed_residue_id
        fi

        residue_name="$new_constructed_residue"
        atom_name="${new_atom_name_sequence[$num_of_atoms_processed]}"

        printf "%5d%-5s%5s%5d%8.3f%8.3f%8.3f%8.4f%8.4f%8.4f\n" $residue_id $residue_name $atom_name $atom_id $x $y $z $v_x $v_y $v_z >> $residue_unit_file

        (( num_of_atoms_processed++ ))
        if [ $num_of_atoms_processed -eq $num_of_atoms_in_constructed_residue ]; then
            # append box dimensions to make the residue_unit_file a formatted gro file
            tail -n 1 $input_file >> $residue_unit_file

            # call GROMACS pdb2gmx_d to attach hydroxyl hydrogen
            # A desired residue form has already been added to force field files; require the used force field in the path or in current directory
            pdb2gmx_d -f "$residue_unit_file" -o "$residue_unit_addedH_file" -ff "$force_field" -water "$water_model" -p "$topology_file" -i "$position_restraint_file"

            # save the added hydrogen
            cat $residue_unit_addedH_file | grep "$added_hydrogen_name" >> $output_file
            (( num_of_hydrogen_added++ ))

            # reset processing flag, continue to construct next residue
            num_of_atoms_processed=0
        fi
    done

    # append box dimensions
    IFS=''
    read box_dimensions
    echo "$box_dimensions" >> $output_file

} < $input_file

# udpate num of hydrogens added
sed -i.bak "2s/$num_of_atoms/$num_of_hydrogen_added/g" $output_file
export GMX_MAXBACKUP=99     # re-enable GROMACS file backup