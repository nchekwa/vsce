#!/bin/bash


apt-get install -y python3-full \
                python3-venv \
                python3-pip \
                python-is-python3

PYTHON3_VERSION=$(python3 --version | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
echo "Detected python version: $PYTHON3_VERSION"

echo "Set break-system-packages true "
python3 -m pip config set global.break-system-packages true


if [ -d /usr/lib/python$PYTHON3_VERSION ]; then
    FILE_PATH="/usr/lib/python${PYTHON3_VERSION}/EXTERNALLY-MANAGED"
    if [ -f "$FILE_PATH" ]; then
        mv "$FILE_PATH" "${FILE_PATH}-DISABLED"
        echo "Remove EXTERNALLY-MANAGED blocker"
    fi
else
    echo "Listing all Python directories under /usr/lib:"
    ls -d /usr/lib/python*
fi
