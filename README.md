# Getting Started Guide

Steps you can follow after cloning this template:

- Be sure to read the [den documentation](https://vic.github.io/den)

- Update den input.

```console
nix flake update den
```

- Edit [modules/hosts/](modules/hosts/)

- Run the VM

We recommend to use a VM develop cycle so you can play with the system before applying to your hardware.

See [modules/hosts/vm/default.nix](modules/hosts/vm/default.nix)

```console
nix run .#vm
```
