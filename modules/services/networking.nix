{
  flake.nixosModules.networking = {
    networking = {
      useNetworkd = true;
    };
  };
}
