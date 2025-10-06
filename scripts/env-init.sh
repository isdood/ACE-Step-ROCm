#!/bin/bash
# Script to initialize ACE-Step environment with ROCm support
# This script automates the environment setup process for new systems

set -e  # Exit on any error

echo "==========================================="
echo "ACE-Step Environment Initialization Script"
echo "==========================================="
echo

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo "❌ Error: conda is not installed or not in PATH"
    echo "Please install Miniconda or Anaconda and try again."
    exit 1
fi

echo "✅ Conda found at: $(which conda)"

# Check if acestep environment already exists
if conda env list | grep -q "acestep"; then
    echo "⚠️  Warning: 'acestep' environment already exists."
    read -p "Do you want to recreate it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing 'acestep' environment."
        source "$(conda info --base)/etc/profile.d/conda.sh"
        conda activate acestep
        activate_existing=true
    else
        echo "Removing existing 'acestep' environment..."
        conda env remove -n acestep -y
        create_env=true
    fi
else
    create_env=true
fi

# Create conda environment if needed
if [[ $create_env == true ]]; then
    echo "Creating conda environment 'acestep' with Python 3.10..."
    conda create -n acestep python=3.10 -y

    echo "✅ Conda environment 'acestep' created successfully"

    # Activate the environment
    echo "Activating conda environment 'acestep'..."
    source "$(conda info --base)/etc/profile.d/conda.sh"
    conda activate acestep

    echo "✅ Environment activated"

    # Install ACE-Step
    echo "Installing ACE-Step..."
    pip install -e . --break-system-packages

    echo "✅ ACE-Step installed successfully"
    activate_existing=false
fi

# Ensure we're in the correct environment
if [[ $activate_existing != true ]]; then
    source "$(conda info --base)/etc/profile.d/conda.sh"
    conda activate acestep
fi

echo "Current environment: $(python --version) at $(which python)"

# Set up ROCm environment variables
export LD_LIBRARY_PATH=/opt/rocm/lib:/opt/rocm/lib/llvm/lib:$LD_LIBRARY_PATH
export ROCM_PATH=/opt/rocm
export HIP_VISIBLE_DEVICES=0

echo "✅ ROCm environment variables set"

echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "ROCM_PATH: $ROCM_PATH"
echo "HIP_VISIBLE_DEVICES: $HIP_VISIBLE_DEVICES"

# Uninstall existing PyTorch packages
echo "Uninstalling existing PyTorch packages (if any)..."
pip uninstall torch torchvision torchaudio -y --break-system-packages || true

echo "✅ Existing PyTorch packages uninstalled"

# Install PyTorch with ROCm support
echo "Installing PyTorch with ROCm support..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.4 --break-system-packages

echo "✅ PyTorch with ROCm support installed successfully"

echo "==========================================="
echo "✅ Environment initialization completed!"
echo "==========================================="
echo
echo "To use ACE-Step:"
echo "1. Activate the environment: conda activate acestep"
echo "2. Start ACE-Step: ./scripts/start-acestep.sh --port 7865 --device_id 0"
echo
echo "For more information about ROCm setup, see ROCm-support.md"
