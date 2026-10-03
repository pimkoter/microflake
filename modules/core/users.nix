{
  flake.nixosModules.users = { config, ... }: {
    users.users = {
      nix = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.sops.secrets."passwords/nix".path;
        openssh.authorizedKeys.keys = [
          config.sops.secrets."keys/allowed".path
        ];
      };
      root = {
        hashedPasswordFile = config.sops.secrets."passwords/root".path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNmZaXg2ohLL11M1nRcNO3uWMt3f9lhz39uoa3oJLsZ pim@NixBTW"
        ];
      };
    };

    sops.secrets = {
      "keys/allowed" = { };
      "passwords/nix".neededForUsers = true;
      "passwords/root".neededForUsers = true;
    };
  };
}
