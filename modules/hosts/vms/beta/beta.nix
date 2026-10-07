{ inputs, ... }:
{
  flake.nixosModules.beta = {
    imports = [
      inputs.microvm.nixosModules.host
    ];

    microvm.vms.beta = {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
      };

      config = {
        imports = with inputs.self.nixosModules; [
          base
          beta-h
          immich
          vaultwarden
          homeAssistant
        ];
      };
    };
  };
}
