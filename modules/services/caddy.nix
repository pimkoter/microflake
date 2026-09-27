{
  flake.nixosModules.caddy =
    let
      domain = "puber";
    in
    {

      services.caddy = {
        enable = true;

        virtualHosts = {
          "pihole.${domain}.com".extraConfig = ''
            reverse_proxy http://10.0.0.2:80
          '';

          "beta.${domain}.com".extraConfig = ''
            reverse_proxy http://10.0.0.3:3000
          '';
        };
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
