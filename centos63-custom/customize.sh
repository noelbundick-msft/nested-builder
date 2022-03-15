#!/bin/bash

# Run a Python web server at startup
cat <<EOF >> /etc/rc.d/rc.local
cd /root
python -m SimpleHTTPServer 80 &
EOF
