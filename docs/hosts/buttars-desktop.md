# buttars-desktop: Remaining Work

Base config lives in `modules/hosts/buttars-desktop/`.

## Confirm Vulkan picks the NVIDIA GPU

`<aegix/ollama>` runs the server with `pkgs.ollama-vulkan` rather than
`pkgs.ollama-cuda`. The reason is purely practical: `ollama-cuda` is in no
binary cache (checked both `cache.nixos.org` and `cuda-maintainers.cachix.org`)
and needs a local CUDA compile, while `ollama-vulkan` is cached and accelerates
on the same card.

The catch is that this host reports **two** GPUs — `services.xserver.videoDrivers`
is `[ "amdgpu" "nvidia" ]` — so Vulkan device selection is ambiguous and may
enumerate the AMD iGPU instead of the discrete NVIDIA card.

- [ ] After `nixos-rebuild switch`, check which device the server actually
      chose: `journalctl -u ollama | grep -iE 'vulkan|gpu|device'`.
- [ ] If it picked the wrong device, pin it via
      `services.ollama.environmentVariables` in `modules/app/ollama.nix`.
      The exact variable was not verified — check ollama's Vulkan docs for the
      current name (likely a `GGML_VK_*` / device-index variable) rather than
      guessing.
- [ ] Measure throughput on `qwen2.5-coder:7b` (`ollama run --verbose`). If it
      disappoints, switch `package` to `pkgs.ollama-cuda` — a one-line change,
      at the cost of a one-time CUDA build that then caches locally.

## Ollama's nvidia guard is a config check, not a hardware probe

`modules/app/ollama.nix` guards on
`lib.elem "nvidia" config.services.xserver.videoDrivers`, which is true only
when `<aegix/nvidia>` is included. Nix evaluates at build time and cannot see
what is physically installed, so removing the card without editing the config
would leave the service enabled.

Two more obvious predicates are traps and should not be used —
`hardware.nvidia.modesetting.enable` and `hardware.graphics.enable` are both
`true` on buttars-laptop as well, so either would silently guard nothing.

- [ ] Optional: if real hardware detection is ever wanted here, add a
      `facter.json` (as `aegis`, `sentinel` and `torrens` have) and key off that
      instead.
