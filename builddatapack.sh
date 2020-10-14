#!/bin/bash

# builddatapack.sh
# Build Data Pack v.1.0.1

# Copyright (C) 2017-2020 Michael McMahon
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# This script only works with GNU/Linux.  To run this on Mac and GNU/Linux distros
# without gpicview, remove all lines that reference gpicview.

# builddatapack works with dicemechanicsim to run tests, display the output, and
# package the contents.

# To run, open a terminal and enter:
#   bash builddatapack.sh


# Variables
N_SIM=40  # Default value

# Optional command line arguments via getopts
while getopts "s:" opt;
do
  case ${opt} in
    s )
      N_SIM=$OPTARG
      re_isanum='^[0-9]+$'
      if ! [[ $N_SIM =~ $re_isanum ]] ; then
        echo "Error: The number of simulations must be a positive whole number!"
        exit 1
      elif [ $N_SIM -eq "0" ]; then
        echo "Error: The number of simulations must be greater than 0!"
        exit 1
      fi
      ;;
    ? )
      echo "Usage: bash builddatapack.sh [-s N_SIM]"
      exit 1
      ;;
  esac
done

# Generate timestamp variable
pack=$(date +%Y%m%d-%H%M)

# Run N_SIM simulations and display contents
for i in $(seq 1 $N_SIM);
do
  # Run dms
  python3 dicemechanicsim.py 2>/dev/null
  # Display the latest png file
  ls -tr | tail -n 1 | xargs gpicview 2>/dev/null &
  # From bmb at https://stackoverflow.com/questions/1587059
  # Wait 3 second
  sleep 3
  # Stop gpicview
  pkill gpicview
done

# Create a temp directory and copy work files
mkdir -p $pack
cd $pack
mv ../*.csv .
mv ../*.png .
cp ../dicemechanicsim.py .
cp ../plotdicemechanic.py .
cp ../builddatapack.sh .

# Archive in zip format
zip -r data$pack.zip ./*

# Remove temp directory and work files
mv data$pack.zip ../data/
cd ..
rm -fr $pack
