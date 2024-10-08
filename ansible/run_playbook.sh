#!/usr/bin/env bash
set -x
ansible-playbook -i environments/localdev/inventory --become web_server.yaml $@
