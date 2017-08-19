#!/bin/bash
# @Zhikun Cai, 01/2016
#
# Use this script to sort residues
# usage:
#       chmod +x sort_residues.sh
#       ./sort_residues.sh input.gro output.gro


# ------ configure parameters ------
# sort residues; write residues of the same type together
# Unprovided residues would be written to the end of output file
residue_to_sort=('RSIX' 'ROBX' 'RONBX' 'RHAX' 'RSIOH' 'SOL')
# ----------------------------------

input_file="$1"
output_file="$2"

tmp_file='other_residues'
cp $input_file $tmp_file

head -n 2 $tmp_file > $output_file
sed -i.bak '1,2d' $tmp_file

for residue in ${residue_to_sort[@]}; do
    cat $tmp_file | grep "$residue" >> $output_file
    sed -i.bak "/$residue/d" $tmp_file
done

cat $tmp_file >> $output_file
rm $tmp_file
rm "${tmp_file}.bak"


## ---- comment this section is GROMACS is not installed ----
## call GROMACS to renumber residue indices
# genconf_d -f "$output_file" -o "${output_file}_renum.gro" -renumber
