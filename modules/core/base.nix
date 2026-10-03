{ self, ... }:
{
  flake.nixosModules.base = {
    imports = with self.nixosModules; [
      misc
      packages
      users
    ];
  };
}
