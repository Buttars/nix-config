{
  aegix.password-manager = {
    _.keepassxc.homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ keepassxc ];
      };
    _.bitwarden.homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          bitwarden-cli
        ];

        programs.zsh.initContent = ''
          if [ -f "$HOME/.bw_session" ]; then
            export BW_SESSION="$(cat "$HOME/.bw_session")"
          fi
        '';

        programs.fish.interactiveShellInit = ''
          if test -f "$HOME/.bw_session"
            set -gx BW_SESSION (cat "$HOME/.bw_session")
          end
        '';

        programs.zsh.shellAliases.bw-unlock = ''sh -c 'bw unlock --raw > ~/.bw_session && chmod 600 ~/.bw_session && export BW_SESSION="$(cat ~/.bw_session)" && echo "Vault unlocked"' '';
        programs.fish.shellAliases.bw-unlock = ''sh -c 'bw unlock --raw > ~/.bw_session && chmod 600 ~/.bw_session && echo "Vault unlocked"' '';
      };
  };
}
