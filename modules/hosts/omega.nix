{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.omega = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs self;
    };
    modules = with self.nixosModules; [
      # Hardware
      omega-h

      # Hosts
      alpha
    ];
  };
}
