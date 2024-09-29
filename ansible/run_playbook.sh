#!/bin/bash
set -x
ansible-playbook -i environments/localdev/inventory --become web.yaml
