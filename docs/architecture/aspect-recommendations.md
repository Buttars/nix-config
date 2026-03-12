# Aspect Architecture Recommendations
Date: 2026-03-12
Repository: dendritic-from-scratch

## Executive Summary

This audit analyzed 23 aspects across the repository following Den's aspect-driven architecture principles. The configuration is generally well-structured with clear per-class separation (nixos/homeManager). Key findings:

- **Strengths**: Clean per-class module separation, good use of `provides` for vendor implementations, minimal junk drawer aspects
- **Opportunities**: Hardware aspects need parametric provides, some overlapping responsibilities, font duplication, one typo blocking functionality

## Critical Issues

### 1. Typo in password-manager aspect
**File**: `modules/features/password-manager.nix`
**Issue**: `_.keepassxc.homeManger` should be `_.keepassxc.homeManager` (typo: "homeManger")
**Impact**: KeePassXC provider is non-functional
**Fix**: Rename `homeManger` → `homeManager`

## Aspect Inventory & Analysis

### Aspect: audio
**Category**: capability  
**Exports**: nixos  
**Purpose**: Provides PipeWire audio stack with ALSA/Pulse compatibility

**Observations**:
- Clean system-level audio configuration
- Author's own note indicates planned migration to desktop/workstation aspects
- Contains both packages (pavucontrol, pulsemixer, qpwgraph) and service configuration

**Questions**:
- Do you want to keep this as a standalone capability aspect, or merge it into a workstation bundle as your note suggests?
- Should the audio control packages (pavucontrol, etc.) be split into a separate homeManager aspect for user-level tools?

---

### Aspect: browser
**Category**: vendor  
**Exports**: homeManager (via `_.google-chrome` and `_.brave`)  
**Purpose**: Provides browser implementations

**Observations**:
- Excellent use of `provides` pattern via `_.*` sub-aspects
- Clean vendor separation
- No capability layer (generic "browser" aspect)

**Recommendations**:
- Consider adding a capability layer aspect that other aspects can depend on (e.g., `aegis.browser.homeManager` that provides a default)
- This would allow aspects to declare "I need a browser" without specifying which one

**Questions**:
- Do you want a default browser selection mechanism, or is explicit provider selection preferred?

---

### Aspect: cli
**Category**: capability  
**Exports**: homeManager (main + `_.tui`, `_.aws`, `_.git`)  
**Purpose**: Core CLI utilities and tools

**Observations**:
- Well-organized with logical sub-aspects (tui, aws, git)
- Contains direnv configuration (also present in `programming` aspect - overlap)
- Typo: `pkg.stdenv.isLinux` should be `pkgs.stdenv.isLinux` (line 17)

**Potential Issues**:
- `direnv` configured in both `cli` and `programming` aspects (overlap)
- `git` packages appear in both `cli._.git` and `programming` aspects (delta, git)

**Recommendations**:
- Remove `direnv` from `programming` aspect (keep in `cli` only)
- Remove `git` and `delta` from `programming` aspect (keep in `cli._.git` only)
- Consider renaming `cli._.git` to `cli._.vcs` if you plan to add other version control tools

---

### Aspect: discord
**Category**: vendor  
**Exports**: homeManager  
**Purpose**: Discord with Vencord

**Observations**:
- Clean, focused aspect
- Vendor-specific implementation
- Could be part of a `communication` capability hierarchy

**Questions**:
- Would you like a `communication` capability aspect with providers (discord, element-desktop, etc.)?

---

### Aspect: element-desktop
**Category**: vendor  
**Exports**: homeManager  
**Purpose**: Element Matrix client

**Observations**:
- Clean, focused aspect
- Similar to discord - could be part of communication hierarchy

---

### Aspect: fish
**Category**: capability  
**Exports**: top-level `programs.fish` + homeManager  
**Purpose**: Fish shell configuration

**Observations**:
- Unusual structure: exports both top-level `programs.fish` and `homeManager`
- Top-level export suggests this is meant for NixOS system-level configuration
- Should likely be split or clarified

**Recommendations**:
- Split into `aegis.fish.nixos` (for system-level shell enablement) and `aegis.fish.homeManager` (for user config)
- Or document why the top-level export is needed

---

### Aspect: fonts
**Category**: capability  
**Exports**: nixos  
**Purpose**: System fonts

**Observations**:
- Comprehensive font collection
- Duplicates some fonts in `environment.systemPackages` and `fonts.packages` (noto-fonts appears in both)
- `theming` aspect also declares fonts (should reference this aspect instead)

**Recommendations**:
- Remove duplicate `noto-fonts` from `environment.systemPackages`
- Have `theming` aspect reference fonts from this aspect or use `lib.mkDefault` to allow override
- Consider whether `font-manager` (GUI tool) belongs here or in a desktop/workstation bundle

---

### Aspect: gaming
**Category**: capability  
**Exports**: nixos  
**Purpose**: Gaming support (Steam, GameMode, GameScope)

**Observations**:
- Clean, focused aspect
- Appropriate for workstation/desktop classes
- Not appropriate for server classes

**Questions**:
- Should this be a bundle aspect or remain a capability?

---

### Aspect: hyprland
**Category**: capability (window manager)  
**Exports**: nixos, homeManager  
**Purpose**: Hyprland Wayland compositor

**Observations** (inventory only per user instruction):
- Provides both system and user configuration
- Includes cursor theme (overlaps with theming)
- Includes cachix binary cache configuration

---

### Aspect: locale
**Category**: capability  
**Exports**: nixos  
**Purpose**: System locale and timezone

**Observations**:
- Clean, focused aspect
- Good use of `lib.mkDefault` for overridability
- Appropriate system-level configuration

---

### Aspect: neovim
**Category**: vendor  
**Exports**: homeManager  
**Purpose**: Neovim editor with supporting tools

**Observations**:
- Contains editor + supporting tools (imagemagick, statix, opencode)
- Supporting tools might belong in other aspects (statix in nix-ls or programming?)

**Questions**:
- Should this be `editor` capability with `_.neovim` provider?
- Should supporting tools be split out?

---

### Aspect: nfs-utils
**Category**: capability  
**Exports**: nixos  
**Purpose**: NFS utilities

**Observations**:
- Clean, focused aspect
- More appropriate for server/storage classes than workstations

---

### Aspect: nix-ls
**Category**: capability  
**Exports**: nixos  
**Purpose**: nix-ld for running unpatched binaries

**Observations**:
- Clean, focused aspect
- Name is slightly misleading (nix-ls vs nix-ld)

**Recommendations**:
- Consider renaming to `nix-ld` to match the actual program

---

### Aspect: nvidia
**Category**: hardware  
**Exports**: nixos  
**Purpose**: NVIDIA GPU drivers and configuration

**Observations**:
- Hardware-specific aspect
- Should be parametric provide that checks host attributes
- Currently applies to any host that includes it

**Recommendations**:
- Convert to parametric `provides` that accepts `{ host, ... }` and only applies when `host.gpu == "nvidia"` or similar
- Move to `hardware/nvidia` or `gpu/nvidia` hierarchy

---

### Aspect: password-manager
**Category**: vendor  
**Exports**: homeManager (via `_.keepassxc` and `_.bitwarden`)  
**Purpose**: Password manager implementations

**Observations**:
- **CRITICAL**: Typo `_.keepassxc.homeManger` should be `homeManager`
- Good use of `provides` pattern
- Clean vendor separation

**Recommendations**:
- Fix typo immediately
- Consider adding capability layer for "password manager" that other aspects can depend on

---

### Aspect: programming
**Category**: mixed (junk drawer risk)  
**Exports**: homeManager  
**Purpose**: Development tools

**Observations**:
- Contains overlapping functionality with `cli` aspect:
  - `direnv` (also in cli)
  - `git` (also in cli._.git)
  - `delta` (also in cli._.git)
  - `ripgrep` (general utility, could be in cli)
- Mix of concerns: API testing (atac), containers (compose2nix, lazydocker, devpod), formatting (nixpkgs-fmt), DNS (dig)
- Risk of becoming a junk drawer

**Recommendations**:
- Remove overlapping packages (direnv, git, delta)
- Consider splitting into focused aspects:
  - `containers` (compose2nix, lazydocker, devpod)
  - `nix-development` (nixpkgs-fmt, devenv)
  - Keep general dev tools here or in cli
- Move `dig` to networking or cli aspect

**Questions**:
- Do you want to keep this as a broad "programming" bundle, or split into capability aspects?
- Which tools do you consider essential for all programming vs specific use cases?

---

### Aspect: taskwarrior
**Category**: vendor  
**Exports**: homeManager  
**Purpose**: Taskwarrior task management

**Observations**:
- Clean, focused aspect
- Platform-aware (taskopen only on Linux)

---

### Aspect: terminal-emulator
**Category**: vendor  
**Exports**: homeManager  
**Purpose**: Terminal emulator implementations

**Observations**:
- Provides multiple implementations (alacritty, kitty)
- Not using `provides` pattern (both installed simultaneously)

**Recommendations**:
- Convert to `provides` pattern: `_.alacritty` and `_.kitty`
- Or document that multiple terminal emulators are intentional

---

### Aspect: theming
**Category**: capability  
**Exports**: homeManager  
**Purpose**: GTK/Qt theming and Stylix configuration

**Observations**:
- Comprehensive theming configuration
- Declares fonts inline (should reference `fonts` aspect)
- Contains cursor theme (also in hyprland)

**Recommendations**:
- Reference font packages from `fonts` aspect instead of declaring inline
- Use `lib.mkDefault` for font selections to allow override
- Consider extracting cursor theme to shared location

---

### Aspect: virtualization
**Category**: capability  
**Exports**: provides (via `_.docker` and `_.libvirtd.nixos`)  
**Purpose**: Virtualization providers

**Observations**:
- Good use of `provides` pattern
- `_.docker` missing class export (should be `_.docker.nixos`)
- Clean separation of implementations

**Recommendations**:
- Fix `_.docker` to `_.docker.nixos` for consistency

---

### Aspect: xdg
**Category**: capability  
**Exports**: homeManager  
**Purpose**: XDG base directory specification

**Observations**:
- Clean, focused aspect
- Appropriate for workstation environments

---

### Aspect: zsa
**Category**: hardware  
**Exports**: nixos  
**Purpose**: ZSA keyboard support

**Observations**:
- Hardware-specific aspect
- Should be parametric provide that checks host attributes
- Currently applies to any host that includes it

**Recommendations**:
- Convert to parametric `provides` that accepts `{ host, ... }` and only applies when host has ZSA keyboard
- Move to `hardware/zsa` or `input/zsa` hierarchy

---

### Aspect: devenv
**Category**: capability  
**Exports**: homeManager + flake inputs  
**Purpose**: Development environment tooling

**Observations**:
- Declares flake inputs (devenv, nix2container, mk-shell-bin)
- Provides devenv shell configuration
- Overlaps with `programming` aspect (both provide devenv)

**Recommendations**:
- Remove `devenv` package from `programming` aspect (keep here only)
- Consider merging with or referencing from `programming` aspect

---

### Aspect: disks
**Category**: capability  
**Exports**: provides.btrfs (currently empty)  
**Purpose**: Disk configuration with disko

**Observations**:
- Contains btrfs configuration function but `provides.btrfs` is empty `{ }`
- Commented out usage example suggests parametric provides pattern
- Configuration function exists but not exported

**Recommendations**:
- Uncomment and properly export the btrfs configuration: `aegis.disks.provides.btrfs = diskoConfigurations.btrfs;`
- Document usage pattern in comments

---

### Aspect: networking
**Category**: capability  
**Exports**: nixos  
**Purpose**: Network configuration (nftables, wireguard, firewall)

**Observations**:
- Clean, focused aspect
- Trusts virtualization interfaces (virbr0, podman0, docker0)
- Appropriate system-level configuration

---

### Aspect: power-management
**Category**: capability  
**Exports**: nixos  
**Purpose**: Power management services

**Observations**:
- Clean, focused aspect
- Appropriate for laptop/mobile classes
- Less relevant for desktop/server classes

---

### Aspect: secrets
**Category**: capability  
**Exports**: nixos, homeManager  
**Purpose**: sops-nix secrets management

**Observations**:
- Clean, focused aspect
- Properly exports both nixos and homeManager modules
- Declares flake inputs

---

## Structural Observations

### Strengths
1. **Clean per-class separation**: Most aspects properly separate nixos and homeManager modules
2. **Good use of provides**: Browser, password-manager, virtualization use the `provides` pattern effectively
3. **Minimal junk drawers**: Only `programming` shows signs of becoming a junk drawer
4. **Focused aspects**: Most aspects have clear, single responsibilities

### Issues
1. **Hardware aspects lack parametric provides**: nvidia and zsa should be host-gated
2. **Overlapping responsibilities**: cli and programming aspects overlap (direnv, git, delta)
3. **Font duplication**: fonts declared in both fonts and theming aspects
4. **Inconsistent provides usage**: terminal-emulator installs multiple implementations without using provides
5. **Missing capability layers**: No generic browser, editor, or password-manager capability aspects

### Maintainability Risks
1. **programming aspect**: Risk of becoming a junk drawer as more tools are added
2. **Font management**: Duplication between aspects could lead to conflicts
3. **Hardware aspects**: Non-parametric hardware aspects could be accidentally enabled on wrong hosts

## High-Level Recommendations

### Immediate Actions (High Priority)
1. **Fix typo**: `password-manager.nix` - change `homeManger` to `homeManager`
2. **Fix typo**: `cli.nix` - change `pkg.stdenv` to `pkgs.stdenv`
3. **Fix virtualization**: Add `.nixos` to `_.docker` export
4. **Fix disks**: Uncomment and export the btrfs configuration

### Short-Term Improvements (Medium Priority)
1. **Deduplicate cli/programming overlap**:
   - Remove direnv, git, delta from programming
   - Move dig to networking or cli
   
2. **Convert hardware to parametric provides**:
   - nvidia: `provides.nvidia = { host, ... }: lib.mkIf (host.gpu == "nvidia") { ... }`
   - zsa: `provides.zsa = { host, ... }: lib.mkIf (host.keyboard == "zsa") { ... }`

3. **Centralize font management**:
   - Remove font declarations from theming
   - Reference fonts aspect or use lib.mkDefault

4. **Fix fish aspect structure**:
   - Split into explicit nixos and homeManager exports

### Long-Term Improvements (Low Priority)
1. **Introduce capability layers**:
   - `browser` capability that provides default
   - `editor` capability with neovim as provider
   - `password-manager` capability with default

2. **Consider aspect hierarchy**:
   ```
   hardware/
     nvidia
     zsa
   communication/
     discord
     element-desktop
   development/
     containers
     nix-tools
   ```

3. **Split programming aspect**:
   - Create focused aspects for containers, nix-development
   - Keep only general dev tools in programming

4. **Add aspect documentation**:
   - Create `modules/features/README.md` explaining patterns
   - Add category headers to each aspect file

## Questions for User

1. **Audio aspect**: Keep standalone or merge into workstation bundle as your note suggests?

2. **Programming aspect**: Keep as broad bundle or split into focused capability aspects (containers, nix-development, etc.)?

3. **Communication apps**: Create a `communication` capability hierarchy for discord, element-desktop, etc.?

4. **Terminal emulator**: Should multiple terminals be available simultaneously, or use provides pattern for selection?

5. **Capability layers**: Do you want generic capability aspects (browser, editor, password-manager) that other aspects can depend on, or prefer explicit provider selection everywhere?

6. **Hardware organization**: Move hardware aspects to `hardware/*` hierarchy or keep flat?

## Implementation Priority

### Critical (Fix Now)
- [ ] Fix password-manager typo (homeManger → homeManager)
- [ ] Fix cli typo (pkg → pkgs)

### High (Fix Soon)
- [ ] Fix virtualization docker export
- [ ] Fix disks btrfs export
- [ ] Remove cli/programming overlaps

### Medium (Next Iteration)
- [ ] Convert nvidia to parametric provides
- [ ] Convert zsa to parametric provides
- [ ] Centralize font management
- [ ] Fix fish aspect structure

### Low (Future Consideration)
- [ ] Introduce capability layers
- [ ] Reorganize into hierarchy
- [ ] Split programming aspect
- [ ] Add documentation

---

## Appendix: Aspect Checklist

Each aspect should:
- ✅ Export `aegis.<name>` attrset
- ✅ Declare which classes it exports (nixos/homeManager/darwin)
- ✅ Use `provides` for multiple implementations
- ✅ Use `lib.mkDefault` for overridable values
- ✅ Ensure referenced packages are present
- ⚠️ Avoid hard-coding host specifics (use parametric provides)
- ⚠️ Avoid overlapping with other aspects

Most aspects meet these criteria. Primary gaps are hardware aspects lacking parametric provides and some overlapping responsibilities.
