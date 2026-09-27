{ inputs, ... }:
{
  flake.nixosModules.alpha = {
    imports = [ inputs.microvm.nixosModules.host ];
    microvm.vms = {
      alpha = {
        pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
        config = with inputs.flake.nixosModules; {
          imports = [
          ];
        };
      };
    };
  };
}
