# Aspect Refactor Plan
Date: 2026-03-12
Status: Ready for Implementation

## Architecture Principles (Confirmed)

1. **Avoid single-package aspects** unless they have configuration worth centralizing
2. **Group packages by capability/feature** to provide higher-level abstractions
3. **Use providers with defaults** for capability aspects that group software
4. **Hierarchy**: aspects → classes (workstation/laptop/server) → hosts
5. **Inline simple packages** directly into host/class configs

## Immediate Actions

### 1. Remove Simple Package Aspects

**Delete these files**:
- `modules/features/element-desktop.nix` - just installs element-desktop, inline where needed
- `modules/features/nfs-utils.nix` - just installs nfs-utils, inline where needed

### 2. Fix Critical Issues

**File: `modules/features/password-manager.nix`**
- Line 3: Fix typo `homeManger` → `homeManager`

**File: `modules/features/cli.nix`**
- Line 17: Fix typo `pkg.stdenv` → `pkgs.stdenv`

**File: `modules/features/virtualization.nix`**
- Line 3: Add `.nixos` to `_.docker` export
- Change `_.docker = { virtualisation.docker = { ... }; };`
- To: `_.docker.nixos = { virtualisation.docker = { ... }; };`

**File: `modules/disks.nix`**
- Line 73: Uncomment the btrfs export
- Change: `# aegis.disks.provides.btrfs = diskoConfigurations.btrfs;`
- To: `aegis.disks.provides.btrfs = diskoConfigurations.btrfs;`

### 3. Add Defaults to Provider Aspects

#### Browser (modules/features/browser.nix)

```nix
{
  aegis.browser = {
    # Default: brave
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.brave ];
    };
    
    _.google-chrome.homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.google-chrome ];
    };
    
    _.brave.homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.brave ];
    };
  };
}
```

#### Password-manager (modules/features/password-manager.nix)

```nix
{
  aegis.password-manager = {
    # Default: bitwarden
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        bitwarden-cli
        bitwarden-desktop
      ];
    };
    
    _.keepassxc.homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.keepassxc ];
    };
    
    _.bitwarden.homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        bitwarden-cli
        bitwarden-desktop
      ];
    };
  };
}
```

#### Terminal-emulator (modules/features/terminal-emulator.nix)

```nix
{
  aegis.terminal-emulator = {
    # Default: both kitty and alacritty
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        kitty
        alacritty
      ];
    };
    
    _.alacritty.homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.alacritty ];
    };
    
    _.kitty.homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.kitty ];
    };
  };
}
```

### 4. Split Programming Aspect

**File: `modules/features/programming.nix`**

```nix
{
  aegis.programming = {
    # Core programming tools
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        ripgrep  # universal search tool
      ];
      programs.direnv.enable = true;
    };
    
    # Container development tools
    _.containers.homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        compose2nix
        devpod
        lazydocker
      ];
    };
    
    # Nix development tools
    _.nix.homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        nixpkgs-fmt
      ];
    };
    
    # API testing tools
    _.api-testing.homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        atac
      ];
    };
  };
}
```

**Removed from programming** (duplicates or misplaced):
- `delta` - already in cli._.git
- `git` - already in cli._.git
- `devenv` - already in devenv aspect
- `dig` - move to networking or cli (see Open Questions)

### 5. Fix CLI Aspect

**File: `modules/features/cli.nix`**

**Decision needed**: Should `direnv` stay in cli or move to programming?

**Option A: Keep direnv in cli** (remove from programming)
```nix
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
};
```

**Option B: Move direnv to programming** (remove from cli)
- Programming aspect now owns direnv configuration

**Recommendation**: Keep in cli since it's a general-purpose tool, not just for programming.

### 6. Neovim - Leave As-Is

**File: `modules/features/neovim.nix`**

**Status**: Keep as-is for now
**Reason**: User-specific configuration in migration, will be refactored later
**Future**: Consider creating `aegis.editor` with `_.neovim` provider

## Open Questions

### Q1: Where should `direnv` live?
- **Option A**: `cli` aspect (general-purpose tool)
- **Option B**: `programming` aspect (dev-specific tool)
- **Recommendation**: cli

### Q2: Where should `dig` live?
- **Option A**: `networking` aspect (DNS tool)
- **Option B**: `cli` aspect (general utility)
- **Recommendation**: networking

### Q3: How are classes currently defined?

Need to see current class definition pattern to ensure proper aspect → class → host hierarchy.

Example patterns:
```nix
# Pattern A
den.classes.workstation = {
  includes = [ <aegis/audio> <aegis/fonts> ... ];
};

# Pattern B
aegis.classes.workstation = {
  includes = [ <aegis/audio> <aegis/fonts> ... ];
};
```

## Implementation Checklist

### Phase 1: Critical Fixes
- [ ] Fix password-manager typo (homeManger → homeManager)
- [ ] Fix cli typo (pkg → pkgs)
- [ ] Fix virtualization docker export
- [ ] Fix disks btrfs export

### Phase 2: Deletions
- [ ] Delete element-desktop.nix
- [ ] Delete nfs-utils.nix
- [ ] Update any host configs that referenced these aspects

### Phase 3: Add Defaults
- [ ] Add default to browser aspect
- [ ] Add default to password-manager aspect
- [ ] Add default to terminal-emulator aspect

### Phase 4: Refactor Programming
- [ ] Split programming into providers
- [ ] Remove duplicate packages (delta, git, devenv)
- [ ] Decide on direnv location
- [ ] Decide on dig location
- [ ] Update host configs that use programming aspect

### Phase 5: Verification
- [ ] Test build for all hosts
- [ ] Verify no broken references
- [ ] Update documentation

## Files to Modify

**Delete**:
- `modules/features/element-desktop.nix`
- `modules/features/nfs-utils.nix`

**Modify**:
- `modules/features/password-manager.nix` (typo + add default)
- `modules/features/cli.nix` (typo + direnv decision)
- `modules/features/virtualization.nix` (docker export)
- `modules/disks.nix` (uncomment btrfs)
- `modules/features/browser.nix` (add default)
- `modules/features/terminal-emulator.nix` (add default + providers)
- `modules/features/programming.nix` (split into providers, remove duplicates)

**Potentially modify** (depending on decisions):
- `modules/networking.nix` (if dig moves here)
- Host configuration files (if they reference deleted aspects)

## Notes

- All provider aspects should follow the pattern: default at top level, providers under `_.*`
- Bundled providers (combining multiple providers) are acceptable but should be rare
- Hardware aspects (nvidia, zsa) still need parametric provides conversion (separate task)
- Font duplication between fonts and theming aspects still needs addressing (separate task)
