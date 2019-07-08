# swarm-vmwarevsphere

#### prerequisites
- Docker Machine (https://docs.docker.com/machine/install-machine)
- LastPass CLI (https://github.com/lastpass/lastpass-cli)

#### setup

- create `.envrc` file with the following environment variables

```
export MACHINE_DRIVER=vmwarevsphere
export VMWAREVSPHERE_USERNAME={{vmware-vsphere-username}}
export VMWAREVSPHERE_PASSWORD={{vmware-vsphere-password}}
export VMWAREVSPHERE_VCENTER={{vmware-vsphere-vcenter}}
export VMWAREVSPHERE_DATASTORE={{vmware-vsphere-datastore}}
```

#### usage

`$ make setup`
