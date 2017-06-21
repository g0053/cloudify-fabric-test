#!/bin/bash
set -x
unlink /etc/motd
echo "NODE: $(ctx node id)"
echo "NODE PROPERTIES: $(ctx -j node properties)"
ctx download-resource resources/motd '@{"target_path": "/etc/motd"}'
