_: {
  flake.nixosModules.base = {
    system.stateVersion = "25.05";

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    networking = {
      useNetworkd = true;
    };
  };
}
