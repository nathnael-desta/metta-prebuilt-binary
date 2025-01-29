#!/bin/bash

# Function to print error messages
error() {
    echo "$1" >&2
    exit 1
}

# Check for prerequisites
command -v git >/dev/null 2>&1 || error "git is required but not installed. Aborting."
command -v python3 >/dev/null 2>&1 || error "python3 is required but not installed. Aborting."
command -v pip3 >/dev/null 2>&1 || error "pip3 is required but not installed. Aborting."


# Variables
REPO_URL="https://github.com/nathnael-desta/metta-prebuilt-binary.git"
INSTALL_DIR="$HOME/metta-bin"
VENV_DIR="$INSTALL_DIR/venv"
BINARY_PATH="$INSTALL_DIR/v0.1.11/metta"
DESTINATION_PATH="/usr/local/bin/metta"
WRAPPER_BINARY_PATH="$HOME/metta-bin/metta-run/release/metta-run"
WRAPPER_PATH="/usr/local/bin/metta-run"

# Step 1: Clone the repository
# If the repository already exists, ignore this step
if [ -d "$INSTALL_DIR" ]; then
		echo "The repository already exists. Skipping cloning."
else
		echo "Cloning the repository..."
		git clone $REPO_URL $INSTALL_DIR || error "Failed to clone repository."
fi
cd $INSTALL_DIR || error "Failed to enter the repository directory."


# Step 2: Set up Python virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv $VENV_DIR || error "Failed to create Python virtual environment."
source $VENV_DIR/bin/activate || error "Failed to activate Python virtual environment."


# Step 3: Install Python dependencies
if [ -f "./requirements.txt" ]; then
    echo "Installing Python dependencies..."
    pip install -r requirements.txt || error "Failed to install Python dependencies."
else
    echo "No requirements.txt found"
		error "Failed to install Python dependencies."
fi


# Step 4: Move the binary to /usr/local/bin
if [ -f "$BINARY_PATH" ]; then
    echo "Moving the binary to $DESTINATION_PATH..."
    sudo cp $BINARY_PATH $DESTINATION_PATH || error "Failed to move the binary to /usr/local/bin."

    # Make sure the binary is executable
    sudo chmod +x $DESTINATION_PATH || error "Failed to make the binary executable."

    echo "Installation complete! You can now run 'metta' from any path."
else
    error "Build failed or the binary was not found."
fi

# Step 5: Create a wrapper script to run metta with the virtual environment activated automatically
# Step 5: Move the wrapper binary to /usr/local/bin
if [ -f "$WRAPPER_BINARY_PATH" ]; then
    echo "Moving the wrapper binary to $WRAPPER_PATH..."
    sudo cp $WRAPPER_BINARY_PATH $WRAPPER_PATH || error "Failed to move the wrapper binary to /usr/local/bin."

    # Make sure the wrapper binary is executable
    sudo chmod +x $WRAPPER_PATH || error "Failed to make the wrapper binary executable."

    echo "Installation complete! You can now run 'metta-run' from any path."
else
    error "Wrapper build failed or the binary was not found."
fi

echo "To use the metta with python environment automatically activated, run 'metta-run' instead of 'metta'."
echo "To activate the virtual environment manually, run 'source $VENV_DIR/bin/activate' then use 'metta' as usual."
echo "To deactivate it, simply run 'deactivate'."
