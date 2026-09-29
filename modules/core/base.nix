{
  flake.nixosModules.base = {

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    users.users.nix = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPassword = "$y$j9T$4.jAQ7E/7H4IFyDtW/A2R0$7fRCkI53bOJzDWdThWLmruFsZHoKXQQxDp0H50W0Et9";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNmZaXg2ohLL11M1nRcNO3uWMt3f9lhz39uoa3oJLsZ pim@NixBTW"
      ];
    };

    services.openssh = {
      enable = true;
      openFirewall = true;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
        X11Forwarding = false;
      };
    };

    networking = {
      useNetworkd = true;
    };

    system.stateVersion = "25.05";
  };
}
