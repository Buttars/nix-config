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
