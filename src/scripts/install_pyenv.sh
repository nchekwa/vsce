#!/bin/bash

sudo apt-get update
sudo apt-get install -y make \
                build-essential \
                libssl-dev \
                zlib1g-dev \
                libbz2-dev \
                libreadline-dev \
                libsqlite3-dev \
                llvm \
                libncursesw5-dev \
                xz-utils \
                tk-dev \
                libxml2-dev \
                libxmlsec1-dev \
                libffi-dev \
                liblzma-dev \
                python3-venv \
                python3-pip \
                python-is-python3


curl -fsSL https://pyenv.run | bash

# Append pyenv initialization to shell profiles if not already present
if ! grep -q 'export PYENV_ROOT="$HOME/.pyenv"' "$HOME/.bashrc" 2>/dev/null; then
  {
    echo ''
    echo '# pyenv init'
    echo 'export PYENV_ROOT="$HOME/.pyenv"'
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    echo 'eval "$(pyenv init - bash)"'
    echo 'eval "$(pyenv virtualenv-init -)"'
  } >> "$HOME/.bashrc"
fi

if ! grep -q 'export PYENV_ROOT="$HOME/.pyenv"' "$HOME/.profile" 2>/dev/null; then
  {
    echo ''
    echo '# pyenv init (login shells)'
    echo 'export PYENV_ROOT="$HOME/.pyenv"'
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
  } >> "$HOME/.profile"
fi

# Load pyenv into current shell
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - bash)"
  eval "$(pyenv virtualenv-init -)"
fi

# Confirm and switch to interactive shell so pyenv is available immediately
if command -v pyenv >/dev/null 2>&1; then
  echo "pyenv loaded: $(pyenv --version)"
  exec bash -i
else
  echo "Warning: pyenv not found after initialization. Try 'source ~/.bashrc'."
fi
