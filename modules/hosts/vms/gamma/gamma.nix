{ inputs, ... }:
{
  flake.nixosModules.gamma = {
    imports = [
      inputs.microvm.nixosModules.host
    ];

    microvm.vms.gamma = {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
      };

      config = {
        imports = with inputs.self.nixosModules; [
          base
          gamma-h
          jellyStack
        ];
      };
    };
  };
}
