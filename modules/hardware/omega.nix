{ inputs, ... }:
{
  flake.nixosModules.omega-h = {
    imports = [
      inputs.microvm.nixosModules.host
      inputs.sops-nix.nixosModules.sops
    ];

    nixpkgs.hostPlatform = "x86_64-linux";

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
