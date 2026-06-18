deploy host user='' +args='':
    #!/usr/bin/env sh
    _user="{{user}}"
    nixos-rebuild switch --flake .#{{host}} \
        --target-host "${_user:-{{host}}}@{{host}}.lan" \
        --sudo \
        --ask-sudo-password \
        {{args}}

aegis:
    just deploy aegis

sentinel:
    just deploy sentinel

check:
    nix flake check --impure

switch +args='':
    #!/usr/bin/env sh
    host=$(hostname -s)
    if [ "$(uname)" = "Darwin" ]; then
        darwin-rebuild switch --flake .#"$host" {{args}}
    else
        sudo nixos-rebuild switch --flake .#"$host" {{args}}
    fi
