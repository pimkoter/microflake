{ inputs, ... }:
{
  flake.nixosModules.omega-h = {
    imports = [
      inputs.microvm.nixosModules.host
    ];

    nixpkgs.hostPlatform = "x86_64-linux";

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
