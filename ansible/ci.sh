#!/usr/bin/env bash
set +e
set -o pipefail

# Test inventory
__INVENTORY__=ci_test_inventory

# Playbooks
__PLAYBOOKS__=$(grep -l roles: *.yaml|sed -e "s/.yaml//")

# Get a list of groups from the current playbooks so we can use this to set up
# a dummy inventory for running tests
__GROUPS__=$(grep hosts: *.yaml | awk '{print $NF}' | sed -e "s/:/\n/" | sort -n | uniq)
#                                                     ^^^^^^^^^^^^^^^^ 
#                                                            └ when `host:` in
#                                                              an existing playbook
#                                                              contains multiple groups
#                                                              separated by `:`, we replace
#                                                              this with `\n` (newline)
#                                                              so that we have one group per line.
#                                                              We then sort this alphabetically
#                                                              and remove any duplicates to
#                                                              create a list of uniq(ue) groups.


# Set some colours
red='\033[0;31m'
green='\033[0;32m'
reset='\033[0;39m'
bold='\033[0;1;39m'
normal='\033[0;0;39m'


# ---------------------
# Define some functions
# ---------------------

test_pass(){
  echo -e " ${green}[ ok ]${reset}"
}

test_fail(){
  echo -e " ${red}[ error ]${reset}"
}

ci_pass(){
  echo
  echo -e "${green}"
  echo "##############################################"
  echo "#                                            #"
  echo "#  No errors detected. Test marked as: PASS  #"
  echo "#                                            #"
  echo "##############################################"
  echo -e "${reset}"
}

ci_fail(){
  echo
  echo -e "${red}"
  echo "###########################################"
  echo "#                                         #"
  echo "#  Errors detected. Test marked as: FAIL  #"
  echo "#                                         #"
  echo "###########################################"
  echo -e "${reset}"
}

echo -e "${bold}Ansible Playbook Version:${reset} ${green}$(ansible-playbook --version)${reset}"
echo -e "${bold}Operating System:${reset} ${green}$(cat /etc/lsb-release 2>/dev/null  || cat /etc/redhat-release 2>/dev/null || echo "Not detected")${reset}"
echo -e "${bold}Kernel:${reset} ${green}$(uname -a)${reset}"

# We will run all tests and continue on fail, but exit this script with a none zero exit
# code if any test fails.
EXIT_CODE=0

# Ensure all yaml files end with .yaml - .yml is forbidden!
echo
echo -ne "${bold}Checking all yaml files end with .yaml and not .yml${reset}"
YML_FILES=$(find . -type f -iname "*.yml")
if [ ${#YML_FILES} -gt 0 ]
then
  test_fail
  echo
  echo -e "Found yaml files using ${red}.yml${reset} as their extension."
  echo -e "To fix, rename the following files so that they have a ${green}.yaml${reset} extension."
  echo -e "${red}${YML_FILES}${reset}"
  echo
  ci_fail
  exit 1
else
  test_pass
fi

# Yaml lint checks - just check the modified (committed) files. We do this by getting a list of yaml
# files that differ from the develop branch (but filter out deleted files)
# Note: we `egrep || true` to prevent a none zero exit code from occurring if no yaml files have been modified
echo
echo -ne "${bold}Running yaml lint checks:${reset}"

# Get a list of YAML files in the repo/branch. We exclude vault encrypted yaml
# files and Jenkins JCasC yaml files (which are exported by Jenkins - too time consuming to lint fix)
YAML_FILES=$(find . -name "*.yaml"|grep -Fv "vault.yaml")

if [ ${#YAML_FILES} -gt 0 ]
then
  TEST_RESULT=$(yamllint -s ${YAML_FILES})
  if [ $? -ne 0 ]
    then
    echo "${TEST_RESULT}"
    EXIT_CODE=1
  fi
fi

if [ $EXIT_CODE -eq 0 ]
then
  test_pass
fi

echo
echo -ne "${bold}Checking ansible syntax for playbooks and tasks:${reset}"
echo

# Generate test inventory for running ansible checks
[ -f ${__INVENTORY__} ] && rm -f ${__INVENTORY__}
for group in ${__GROUPS__}
do
  echo "[${group}]" >> ${__INVENTORY__}
  echo "127.0.0.1" >> ${__INVENTORY__}
  echo >> ${__INVENTORY__}
done

for playbook in ${__PLAYBOOKS__}
do
  echo -n " > Testing ${playbook}.yaml"
  TEST_RESULT=$(ansible-playbook --syntax-check --list-tasks -i ${__INVENTORY__} ${playbook}.yaml 2>&1)
  if [ $? -ne 0 ]
  then
    EXIT_CODE=1
    test_fail
    echo "${TEST_RESULT}"
  else
    test_pass
    # Print any warnings
    echo "${TEST_RESULT}" | grep -qF "WARNING]"
    if [ $? -eq 0 ]
    then
      echo "$TEST_RESULT"|grep -v "playbook:"
    fi
  fi
done

# Remove the ci inventory file
[ -f ${__INVENTORY__} ] && rm -f ${__INVENTORY__}

if [ ${EXIT_CODE} -ne 0 ]
then
  ci_fail
else
  ci_pass
fi
exit ${EXIT_CODE}
