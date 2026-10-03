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
      # Base system defaults
      base

      # Hardware & Disk
      omega-h
      omega-disko

      # Networking
      omega-network

      # Reverse Proxy
      caddy

      # MicroVM Guests
      alpha
    ];
  };
}
