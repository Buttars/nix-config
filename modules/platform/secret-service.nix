{
  # Proton's keyring library, and anything else built on libsecret, refuses to
  # store credentials unless a Secret Service provider answers on the bus.
  aegix.secret-service.nixos = {
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
