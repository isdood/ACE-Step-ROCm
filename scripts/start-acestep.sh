#!/bin/bash
# Script to run ACE-Step with proper ROCm environment

export LD_LIBRARY_PATH=/opt/rocm/lib:/opt/rocm/lib/llvm/lib:$LD_LIBRARY_PATH
export ROCM_PATH=/opt/rocm
export HIP_VISIBLE_DEVICES=0

# Use conda python if available, otherwise use system python
if command -v conda &> /dev/null && conda env list | grep -q "acestep"; then
    source "$(conda info --base)/etc/profile.d/conda.sh"
    conda activate acestep
fi

echo "ROCm Environment Set:"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "ROCM_PATH: $ROCM_PATH"
echo "HIP_VISIBLE_DEVICES: $HIP_VISIBLE_DEVICES"

# Test ROCm detection
echo "Testing ROCm detection..."
python -c "
import torch
print('PyTorch version:', torch.__version__)
print('HIP available:', hasattr(torch, 'hip') and torch.hip.is_available())
if hasattr(torch, 'hip') and torch.hip.is_available():
    print('HIP devices:', torch.hip.device_count())
    for i in range(torch.hip.device_count()):
        print(f'  Device {i}: {torch.hip.get_device_name(i)}')
"

echo "Starting ACE-Step web app..."
python -m acestep.gui "$@"
