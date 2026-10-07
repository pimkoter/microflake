{ inputs, ... }:
{
  flake.nixosModules.delta = {
    imports = [
      inputs.microvm.nixosModules.host
    ];

    microvm.vms.delta = {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
      };

      config = {
        imports = with inputs.self.nixosModules; [
          base
          delta-h
          exitNode
        ];
      };
    };
  };
}
