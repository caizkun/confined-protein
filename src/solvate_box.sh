#!/bin/bash
# @Zhikun Cai, 01/2016
#
# Use this script to solvate box
# usage:
#       ./solvate_box.sh input.gro output.gro water_model.gro


input_file="$1"
output_file="$2"
water_model_file="$3"

# call GROMACS to add water molecules into box
genbox_d -cp "$input_file" -o "$output_file" -cs "$water_model_file"