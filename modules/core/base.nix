{
  flake.nixosModules.base = { pkgs, ... }: {
    system.stateVersion = "25.05";

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    environment.systemPackages = with pkgs; [
      git
      ripgrep
    ];

    networking = {
      useNetworkd = true;
    };
  };
}
