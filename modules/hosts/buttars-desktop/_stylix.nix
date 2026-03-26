{ inputs, ... }:
{
  stylix.enable = true;
  stylix.autoEnable = false;
  stylix.base16Scheme = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/scottmckendry/cyberdream.nvim/main/extras/base16/cyberdream.yaml";
    sha256 = "1bfi479g7v5cz41d2s0lbjlqmfzaah68cj1065zzsqksx3n63znf";
  };
  stylix.override = {
    base00 = "#0F0F11";
    base0E = "#DE4F72";
  };
}
