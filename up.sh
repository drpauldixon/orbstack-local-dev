#!/bin/bash
# Start and connect to an orbstack VM

if ! orbctl list | grep -q ^dev8
then
  orb create rocky:8 dev8 -c vm_config.yaml
fi

if ! orbctl list -r | grep -q ^dev8
then
  echo "Starting vm: dev8"
  orbctl start dev8
fi

echo "Starting terminal in: dev8.orb.local"
orb -m dev8
