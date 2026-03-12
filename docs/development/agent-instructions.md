# Den Aspect Model (Correct Mental Model)

In this repository we use the **Den dendritic configuration model**.

The core unit of composition is an **aspect**.

An aspect represents a **feature or concern** that can contribute configuration to one or more system classes.

Examples of aspects:

- audio
- cli
- programming
- browser/brave
- password-manager/bitwarden
- gpu/nvidia
- workspace

---

## Aspect Structure

An aspect is **an attrset containing modules for different classes**.

Example:

```nix
aegis.audio = {
  nixos = { pkgs, ... }: {
    services.pipewire.enable = true;
  };

  homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.pavucontrol ];
  };
};
```

Each key corresponds to a **module for that class**.

Supported classes typically include:

- nixos
- homeManager
- darwin

---

## Important Rule

An aspect is **not a module**.

Correct model:

```
aspect
  -> class modules
      -> configuration
```

Example:

```
programming
  -> homeManager module
```

Example:

```
audio
  -> nixos module
  -> homeManager module
```

---

## What Aspects Represent

Aspects may represent many kinds of features:

Capability

```
audio
fonts
xdg
```

Tooling

```
cli
neovim
programming
```

Applications

```
browser/brave
password-manager/bitwarden
```

Hardware

```
gpu/nvidia
input/zsa
```

Bundles

```
workspace
development
```

All of these are valid aspect types.

---

## Composition

Aspects can compose other aspects using:

```
includes
```

Example:

```
workspace
  -> includes audio
  -> includes cli
  -> includes browser/brave
```

This builds the configuration graph.

---

## Key Principle

Each aspect should represent a **reusable feature boundary**.

Avoid aspects that contain unrelated responsibilities.

However aspects do **not need to be limited to a single capability**.

Profiles and bundles are valid.
