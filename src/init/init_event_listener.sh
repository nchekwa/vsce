#!/bin/bash
echo 'READY'
read line
echo "RESULT 2"
echo "OK"
if [[ $line == *'PROCESS_STATE_EXITED'* && $line == *'init'* ]]; then
    supervisorctl start caddy sshd code-server ngrok
fi
