default:
  just --list

deploy:
  nixos-rebuild switch --flake . --use-remote-sudo

debug:
  nixos-rebuild switch --flake . --use-remote-sudo --show-trace --verbose

update:
  nix flake update

update-input:
  nix flake update $(i)

check:
  nix flake check . --impure

write-flake:
  nix run .#write-flake

history:
  nix profile history --profile /nix/var/nix/profiles/system

repl:
  nix repl -f flake:nixpkgs

clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

gc:
  sudo nix-collect-garbage --delete-old

