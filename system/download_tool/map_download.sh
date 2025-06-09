#!/bin/bash

for (( i=1; i<=12; i++)); do
  echo m-37-$i.jpg
  wget -nv --restrict-file-names=lowercase --ignore-case https://freemap.com.ua/wp-content/themes/foundation_xy/assets/images/maps/genshtab/m-37-$i.jpg
done

# american 250000
# NN-36-10
# NN-36-11
# NM-35-1 - NM-35-12
# NM-36-1 - NM-36-12
# NM-37-1 - NM-37-12
# NL-35-1 - NL-35-12
# NL-36-1 - NL-36-12
# NL-37-1 - NL-37-12
# 
#for ((j=35; j<=37; j++)); do
# for (( i=1; i<=12; i++)); do
#  echo NL-$j-$i.jpg
#  wget -nv --restrict-file-names=lowercase --ignore-case https://freemap.com.ua/wp-content/themes/foundation_xy/assets/images/maps/usa/NL-$j-$i.jpg
# done
#done
