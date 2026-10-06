{
  # Grafana Visualization Module for Microflake
  #
  # This module configures Grafana as the central metrics and log visualization platform.
  # Features:
  #   - Runs on host `omega` on port 3000, exposed securely via Caddy reverse proxy at `grafana.puber.com`.
  #   - Provisioned Data Sources: Prometheus (metrics) and Loki (logs).
  #   - Provisioned Dashboards: Pre-loaded system infrastructure overview and Pi-hole DNS analytics.

  flake.nixosModules.grafana =
    { pkgs, ... }:
    let
      dashboardDir = pkgs.runCommand "microflake-grafana-dashboards" { } ''
        mkdir -p $out
        cp ${./dashboards/system-overview.json} $out/system-overview.json
        cp ${./dashboards/pihole-dns.json} $out/pihole-dns.json
      '';
    in
    {
      # Enable Grafana Service
      services.grafana = {
        enable = true;

        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = 3000;
            domain = "grafana.puber.com";
            root_url = "https://grafana.puber.com";
          };

          security = {
            admin_user = "admin";
            # Explicit secret_key required in NixOS 26.05+
            secret_key = "SW2YcwTIb9zpOOhoPsMm";
            # Disable anonymous access for security
            allow_embedding = false;
          };

          analytics = {
            reporting_enabled = false;
            check_for_updates = false;
          };
        };

        # Declarative Provisioning of Data Sources & Dashboards
        provision = {
          enable = true;

          # Data Sources
          datasources.settings.datasources = [
            # 1. Prometheus Time-Series Metrics
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://127.0.0.1:9090";
              isDefault = true;
              jsonData = {
                timeInterval = "15s";
              };
            }

            # 2. Loki Log Engine
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://127.0.0.1:3100";
              jsonData = {
                maxLines = 1000;
              };
            }
          ];

          # Provisioned Dashboards Provider
          dashboards.settings.providers = [
            {
              name = "Microflake Standard Dashboards";
              type = "file";
              disableDeletion = true;
              updateIntervalSeconds = 30;
              options = {
                path = dashboardDir;
              };
            }
          ];
        };
      };
    };
}
