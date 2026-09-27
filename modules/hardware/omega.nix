{ inputs, ... }:
{
  flake.nixosModules.omega-h = {
    imports = [ inputs.microvm.nixosModules.microvm ];

    networking.hostName = "Omega";
    microvm.hypervisor = "cloud-hypervisor";

    system.stateVersion = "25.11";
    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
