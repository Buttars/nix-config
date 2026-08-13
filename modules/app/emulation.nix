{
  aegix.emulation.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        retroarch-full # NES/SNES/Genesis/GB/GBA/PS1/N64 and more, via libretro cores
        pcsx2 # PS2 (standalone gives better compatibility than the libretro core)
        xemu # Original Xbox
        extract-xiso # xemu needs discs in XISO format, not plain ISO
        dolphin-emu # GameCube/Wii
      ];
    };
}
