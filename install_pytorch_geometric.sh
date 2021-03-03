#!/usr/bin/env bash

set -x

TORCH='1.6.0'
CUDA='cu101'

# see https://pytorch-geometric.readthedocs.io/en/latest/notes/installation.html
pip install torch-scatter -f https://pytorch-geometric.com/whl/torch-${TORCH}+${CUDA}.html
pip install torch-sparse -f https://pytorch-geometric.com/whl/torch-${TORCH}+${CUDA}.html
pip install torch-cluster -f https://pytorch-geometric.com/whl/torch-${TORCH}+${CUDA}.html
pip install torch-spline-conv -f https://pytorch-geometric.com/whl/torch-${TORCH}+${CUDA}.html
pip install torch-geometric

# pip uninstall torch-scatter
# pip uninstall torch-sparse
# pip uninstall torch-cluster
# pip uninstall torch-spline-conv
# pip uninstall torch-geometric
