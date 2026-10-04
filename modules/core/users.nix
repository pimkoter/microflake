{
  flake.nixosModules.users = { config, ... }: {
    users = {
      mutableUsers = false;
      users = {
        nix = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          hashedPasswordFile = config.sops.secrets."passwords/nix".path;
          # Load SSH authorized keys dynamically from SOPS secret file
          openssh.authorizedKeys.keyFiles = [
            config.sops.secrets."allowed-key".path
          ];
        };
        root = {
          hashedPasswordFile = config.sops.secrets."passwords/root".path;
          # Remove plain text SSH key from source code; load dynamically from SOPS
          openssh.authorizedKeys.keyFiles = [
            config.sops.secrets."allowed-key".path
          ];
        };
      };
    };

    # Secret declarations managed by sops-nix
    sops.secrets = {
      "allowed-key" = { };
      "passwords/nix".neededForUsers = true;
      "passwords/root".neededForUsers = true;
    };
  };
}
