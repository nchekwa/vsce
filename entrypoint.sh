#!/bin/bash


# List of valid ENV parameters:
#   INSTALL_EXTENSIONS="redhat.vscode-yaml ms-python.python"
#     -> or use file: /home/coder/.config/extensions.txt
#   INSTALL_EXTENSIONS_FORCE=true
#   INSTALL_DPKG="curl git jq"
#     -> or use file: /home/coder/.config/dpkg.txt
#   INSTALL_NPM="express lodash axios"
#     -> or use file: /home/coder/.config/npm.txt
#   EXTENSIONS_UPDATE=true
#   BOOT_INSTALL_SCRIPT="/home/coder/.config/boot.sh"

## 




# Function to parse a configuration file and return valid entries
parse_config_file() {
    local file_path=$1
    local valid_entries=""
    
    if [ -f "$file_path" ]; then
        echo "Reading configuration from $file_path"
        
        # Read file line by line
        while IFS= read -r line || [ -n "$line" ]; do
            # Skip empty lines and comments
            if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
                continue
            fi
            
            # Extract content before any comment
            entry=$(echo "$line" | awk '{print $1}')
            
            if [ ! -z "$entry" ]; then
                valid_entries="$valid_entries $entry"
            fi
        done < "$file_path"
    fi
    
    echo "$valid_entries"
}

# Check if user-data-dir and extensions-dir exist
if [ ! -d "/home/coder/.code/data" ] || [ ! -d "/home/coder/.code/extensions" ]; then
    echo "Creating user-data-dir and extensions-dir"
    mkdir -p /home/coder/.code/data
    mkdir -p /home/coder/.code/extensions
fi

# Show current version as one line
version_info=$(code-server --version)
echo "Current version:" $(echo $version_info | tr '\n' ' ')


# List existing extensions
echo "Existing installed extensions:"
code-server --user-data-dir=/home/coder/.code/data --extensions-dir=/home/coder/.code/extensions --list-extensions --show-versions


# Install system packages if specified in environment variable or config file
PACKAGES_TO_INSTALL=""

# Check environment variable
if [ ! -z "${INSTALL_DPKG}" ]; then
    echo "Found packages in environment variable: ${INSTALL_DPKG}"
    
    # Remove quotes and replace commas with spaces
    CLEANED_PACKAGES="${INSTALL_DPKG//\"/}"
    CLEANED_PACKAGES="${CLEANED_PACKAGES//,/ }"
    
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $CLEANED_PACKAGES"
fi

# Check config file
DPKG_CONFIG_FILE="/home/coder/.config/dpkg.txt"
if [ -f "$DPKG_CONFIG_FILE" ]; then
    CONFIG_PACKAGES=$(parse_config_file "$DPKG_CONFIG_FILE")
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $CONFIG_PACKAGES"
fi

# Install packages if any were specified
if [ ! -z "$PACKAGES_TO_INSTALL" ]; then
    echo "Installing system packages: $PACKAGES_TO_INSTALL"
    
    # Update package lists
    sudo apt-get update
    
    # Install packages
    sudo apt-get install -y $PACKAGES_TO_INSTALL
fi

# Install extensions from environment variable or config file
EXTENSIONS_TO_INSTALL=""

# Check environment variable
if [ ! -z "${INSTALL_EXTENSIONS}" ]; then
    echo "Found extensions in environment variable: ${INSTALL_EXTENSIONS}"
    
    # Process multi-line extensions: replace newlines with spaces, then remove quotes and commas
    CLEANED_EXTENSIONS=$(echo "${INSTALL_EXTENSIONS}" | tr '\n' ' ')
    CLEANED_EXTENSIONS="${CLEANED_EXTENSIONS//\"/}"
    CLEANED_EXTENSIONS="${CLEANED_EXTENSIONS//,/ }"
    
    # Remove extra spaces that may result from newlines
    CLEANED_EXTENSIONS=$(echo "${CLEANED_EXTENSIONS}" | sed -e 's/[[:space:]]\+/ /g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    
    EXTENSIONS_TO_INSTALL="$EXTENSIONS_TO_INSTALL $CLEANED_EXTENSIONS"
fi

# Check config file
EXTENSIONS_CONFIG_FILE="/home/coder/.config/extensions.txt"
if [ -f "$EXTENSIONS_CONFIG_FILE" ]; then
    CONFIG_EXTENSIONS=$(parse_config_file "$EXTENSIONS_CONFIG_FILE")
    EXTENSIONS_TO_INSTALL="$EXTENSIONS_TO_INSTALL $CONFIG_EXTENSIONS"
fi

# Install extensions if any were specified
if [ ! -z "$EXTENSIONS_TO_INSTALL" ]; then
    echo "Final extensions to install: $EXTENSIONS_TO_INSTALL"
    # Convert the space-separated list to an array
    IFS=' ' read -ra EXTENSIONS <<< "$EXTENSIONS_TO_INSTALL"
    
    # Check if force flag should be used
    FORCE_FLAG=""
    if [ "${INSTALL_EXTENSIONS_FORCE}" = "true" ] || [ "${INSTALL_EXTENSIONS_FORCE}" = "True" ]; then
        FORCE_FLAG="--force"
        echo "Force flag enabled for extension installations"
    fi
    
    # Install each extension
    for ext in "${EXTENSIONS[@]}"; do
        if [ ! -z "$ext" ]; then
            echo "Installing extension: $ext"
            code-server --user-data-dir=/home/coder/.code/data --extensions-dir=/home/coder/.code/extensions --install-extension "$ext" $FORCE_FLAG
        fi
    done
fi

# Install npm packages if specified in environment variable or config file
NPM_PACKAGES_TO_INSTALL=""

# Check environment variable
if [ ! -z "${INSTALL_NPM}" ]; then
    echo "Found npm packages in environment variable: ${INSTALL_NPM}"
    
    # Remove quotes and replace commas with spaces
    CLEANED_NPM_PACKAGES="${INSTALL_NPM//\"/}"
    CLEANED_NPM_PACKAGES="${CLEANED_NPM_PACKAGES//,/ }"
    
    NPM_PACKAGES_TO_INSTALL="$NPM_PACKAGES_TO_INSTALL $CLEANED_NPM_PACKAGES"
fi

# Check config file
NPM_CONFIG_FILE="/home/coder/.config/npm.txt"
if [ -f "$NPM_CONFIG_FILE" ]; then
    CONFIG_NPM_PACKAGES=$(parse_config_file "$NPM_CONFIG_FILE")
    NPM_PACKAGES_TO_INSTALL="$NPM_PACKAGES_TO_INSTALL $CONFIG_NPM_PACKAGES"
fi

# Install npm packages if any were specified
if [ ! -z "$NPM_PACKAGES_TO_INSTALL" ]; then
    echo "Installing npm packages: $NPM_PACKAGES_TO_INSTALL"
    
    # Use nvm.sh script to install Node.js and npm
    if ! command -v npm &> /dev/null; then
        echo "npm not found, installing Node.js using nvm.sh..."
        # Source the nvm.sh script to install Node.js
        bash /home/coder/install/nvm.sh
        
        # Load nvm in the current shell
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    fi
    
    # Install packages globally
    npm install -g $NPM_PACKAGES_TO_INSTALL
    
    # Upgrade npm to latest version
    echo "Upgrading npm to latest version..."
    npm install -g npm@latest
fi

# Set default boot script path if not provided
BOOT_SCRIPT_PATH="${BOOT_INSTALL_SCRIPT:-/home/coder/.config/boot.sh}"

# Execute custom boot script if it exists
if [ -f "$BOOT_SCRIPT_PATH" ]; then
    echo "Executing custom boot script: $BOOT_SCRIPT_PATH"
    bash "$BOOT_SCRIPT_PATH"
fi

# Check if project folder exists and prepare command arguments
# Set authentication method based on PASSWORD environment variable
if [ ! -z "${PASSWORD}" ]; then
    echo "Password authentication enabled"
    AUTH_ARG="--auth password"
else
    echo "No authentication (auth=none)"
    AUTH_ARG="--auth none"
fi

CODE_SERVER_ARGS="--user-data-dir=/home/coder/.code/data --extensions-dir=/home/coder/.code/extensions $AUTH_ARG --disable-telemetry --host=0.0.0.0 --port=8080"

# Start code-server
if [ -d "/home/coder/project" ]; then
    echo "Project folder found, using as workspace"
    echo "Starting code-server with: code-server /home/coder/project $CODE_SERVER_ARGS"
    code-server /home/coder/project $CODE_SERVER_ARGS
else
    echo "No project folder found, starting without workspace"
    echo "Starting code-server with: $CODE_SERVER_ARGS"
    code-server $CODE_SERVER_ARGS
fi