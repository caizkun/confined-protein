#!/bin/bash
# @Zhikun Cai, 01/2016
#
# Use this script to merge two gro files into one
# usage:
#       chmod +x merge_two_gros.sh
#       ./merge_two_gros.sh input_system1.gro input_system2.gro output.gro [optional: x y z]


# ------ configure parameters ------
# 
# ----------------------------------

input_file_system1="$1"
input_file_system2="$2"
output_file="$3"

# use the box dimensions of systems by default, unless explicitly provided
if [ "$#" -eq 6 ]; then
	box_x=`echo "$4" | bc -l`
	box_y=`echo "$5" | bc -l`
	box_z=`echo "$6" | bc -l`
fi

# fetch system names
{
 read system1
 read num_of_atoms_system1
} < $input_file_system1

{
 read -u 3 system2
 read -u 3 num_of_atoms_system2
} 3< $input_file_system2

merged_system="Merged \"$system1\" AND \"$system2\""

# copy system1
cp $input_file_system1 $output_file

# adjust file beginning and file end
sed -i.bak "1s/$system1/$merged_system/g" $output_file
sed -i.bak '$d' $output_file

# copy system2 starting from 3rd line
sed -n '3,$p' $input_file_system2 >> $output_file

# update num of total atoms
num_of_atoms_merged_system=$(($num_of_atoms_system1 + $num_of_atoms_system2))
sed -i.bak "2s/$num_of_atoms_system1/$num_of_atoms_merged_system/g" $output_file

# use the box dimensions of systems by default, unless explicitly provided
if [ "$#" -eq 6 ]; then
	sed -i.bak '$d' $output_file
	echo "   $box_x   $box_y   $box_z" >> $output_file
fi
