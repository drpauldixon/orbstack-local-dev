# Local dev using Orbstack on Mac

Orbstack is a great tool for local development on Mac (especially on Apple Silicon Macs when you need to develop for Intel). Here's a an example of a local development environment for Ansible using an Orbstack virtual machine.

See: [https://orbstack.dev](https://orbstack.dev)

## Example: Developing Ansible for Red Hat 8
A simple example develping Ansible locally using Rocky Linux 8 as a substitute for Red Hat 8.

**Prerequisites:**

- Install Orbstack
- Ensure Orbstack is running.


We will:

- clone the repo
- change to the repo directory
- start a VM and configure it via the cloud config file: `vm_config.yaml`
- change to the ansible directory
- run some basic Ansible checks
- run a playbook
- stop the VM
- delete the VM.

Clone this repo then:

```
cd orbstack-local-dev  # change to the repo directory
./up.sh                # start the test VM and connect via a terminal
cd ansible             # change to the ansible directory
./ci.sh                # run basic checks: YAML linting / playbook syntax check
./run_playbook.sh      # run a sample playbook
```

Then to test, open [http://dev8.orb.local](http://dev8.orb.local) in a web browser.

Finally, to shut down:

```
exit                   # exit the vm
./down.sh              # shut down the test VM
./down.sh --delete     # delete the test vm
```
