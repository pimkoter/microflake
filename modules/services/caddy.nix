_: {
  flake.nixosModules.caddy =
    let
      domain = "puber";
    in
    {
      services.caddy = {
        enable = true;

        # Global Caddy configuration for ACME / TLS certificates
        email = "admin@${domain}.com";

        virtualHosts = {
          # Pi-hole web interface reverse proxy with security headers
          "pihole.${domain}.com".extraConfig = ''
            header {
              # Security headers for HTTPS hardening
              Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
              X-Content-Type-Options "nosniff"
              X-Frame-Options "DENY"
              Referrer-Policy "strict-origin-when-cross-origin"
            }
            reverse_proxy http://10.0.0.2:80
          '';

          # Beta service reverse proxy
          "beta.${domain}.com".extraConfig = ''
            header {
              Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
              X-Content-Type-Options "nosniff"
              X-Frame-Options "DENY"
              Referrer-Policy "strict-origin-when-cross-origin"
            }
            reverse_proxy http://10.0.0.3:3000
          '';
        };
      };

      # Open HTTP and HTTPS ports on host firewall
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
