#!/bin/bash
# Shut down an orbstack VM and optionally delete it
if ! orbctl list|grep -q ^dev8
then
  echo "VM not found. You can start it by running ./up.sh"
  exit 1
fi

if orbctl list -r | grep -q ^dev8
then
  orbctl stop dev8 && echo "Stopped."
else
  echo "vm: dev8 is stopped."
fi

if [ "$1" = "--delete" ]
then
  orbctl delete dev8
else
  echo "If you run this command using --delete, the VM will also be deleted."
fi
