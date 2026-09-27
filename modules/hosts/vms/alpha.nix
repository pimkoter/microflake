{ inputs, ... }:
{
  flake.nixosModules.alpha = {
    imports = [
      inputs.microvm.nixosModules.host
    ];

    microvm.vms.alpha = {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
      };

      config = {
        imports = with inputs.self.nixosModules; [
          alpha-h
          pihole
        ];
      };
    };
  };
}
