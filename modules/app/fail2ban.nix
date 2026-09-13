{
  aegix.fail2ban = {
    nixos = {
      services.fail2ban = {
        enable = true;
        # Trusted internal networks. fail2ban exists to slow down the internet,
        # not to lock the admin out of his own fleet -- with bantime-increment
        # reaching 168h, one bad deploy costs a week of console trips.
        ignoreIP = [
          "127.0.0.1/8"
          "::1"
          "10.0.20.0/24" # workstations
          "10.0.40.0/24" # servers
          "10.0.45.0/24" # aegis
        ];
        maxretry = 5;
        bantime = "1h";
        bantime-increment = {
          enable = true;
          multipliers = "1 2 4 8 16 32 64";
          maxtime = "168h";
          overalljails = true;
        };
        jails.sshd.settings = {
          enabled = true;
          filter = "sshd[mode=aggressive]";
          maxretry = 3;
        };
      };
    };
  };
}
