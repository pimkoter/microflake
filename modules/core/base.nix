{
  flake.nixosModules.base = { pkgs, ... }: {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    users.users.nix = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "12345";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNmZaXg2ohLL11M1nRcNO3uWMt3f9lhz39uoa3oJLsZ pim@NixBTW"
      ];
    };

    environment.systemPackages = with pkgs; [
      ripgrep
      git
    ];

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
