{
  flake.nixosModules.packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ripgrep
      git
    ];
  };
}
