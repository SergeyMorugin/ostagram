#!/bin/bash

cd /home/margo/neural-style
export PATH=$PATH:/home/margo/torch/install/bin
export LD_LIBRARY_PATH=/home/margo/torch/install/lib
echo "th neural_style.lua $parametr1 > output/output.log 2> output/error.log &"
th neural_style.lua $parametr1 > output/output.log 2> output/error.log &
