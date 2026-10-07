{
  flake.nixosModules.vaultwarden =
    { pkgs, ... }:
    {
      services.vaultwarden = {
        enable = true;
        dbBackend = "sqlite";
        config = {
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
          DOMAIN = "https://vaultwarden.local";
          SIGNUPS_ALLOWED = true;
          ADMIN_TOKEN = "";
        };
      };

      environment.systemPackages = [
        pkgs.vaultwarden
      ];
    };
}
