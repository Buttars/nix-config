# AGENTS.md

## Purpose

This repository uses a **dendritic, aspect-oriented Nix architecture**.

The primary goals are:

- Explicit composition over implicit defaults
- Clear separation of concerns (host vs user vs capability)
- Predictable reasoning about “why something is enabled”
- Easy multi-user and multi-host scaling
- Minimal conditional logic inside features

There is **no global base configuration**.  
Everything that applies is applied because it was **explicitly included**.

---

## Core Concepts

### 1. Aspects are the unit of composition

An **aspect** is a named module fragment that implements a single capability or concern.

Examples:

- Git defaults for users
- CLI workflow tools
- SSH policy for hosts
- Fish shell configuration

Aspects are composed by **including them**, not by toggling flags.

---

### 2. Files do not define behavior, aspects do

File layout exists for **ownership and organization**, not semantics.

- Directories help humans navigate
- Aspect paths define meaning

You should be able to answer:

> “Why is this enabled?”

by pointing to **where the aspect is included**, not by hunting through conditionals.

---

## High-Level Structure
