{
  # Centralized Log Aggregation Module for Microflake
  #
  # This module configures centralized log collection using Loki and Grafana Alloy.
  # - Loki runs on host `omega` as the central log storage engine listening on port 3100.
  # - Grafana Alloy runs on host `omega` and guest `alpha` to ingest systemd journal logs
  #   and stream them to Loki over the internal network.

  flake.nixosModules.logging =
    { pkgs, ... }:
    {
      # Loki Centralized Log Server on `omega`
      services.loki = {
        enable = true;
        configuration = {
          auth_enabled = false;

          server = {
            http_listen_port = 3100;
            grpc_listen_port = 9096;
            # Listen on all interfaces so MicroVM guests can stream logs
            http_listen_address = "0.0.0.0";
          };

          common = {
            instance_addr = "127.0.0.1";
            path_prefix = "/var/lib/loki";
            storage = {
              filesystem = {
                chunks_directory = "/var/lib/loki/chunks";
                rules_directory = "/var/lib/loki/rules";
              };
            };
            replication_factor = 1;
            ring = {
              kvstore = {
                store = "inmemory";
              };
            };
          };

          schema_config = {
            configs = [
              {
                from = "2024-01-01";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index = {
                  prefix = "index_";
                  period = "24h";
                };
              }
            ];
          };

          limits_config = {
            reject_old_samples = true;
            reject_old_samples_max_age = "168h"; # 7 days retention
          };
        };
      };

      # Allow Loki log ingestion port on host firewall for MicroVM guests
      networking.firewall.allowedTCPPorts = [ 3100 ];

      # Host Log Shipper: Grafana Alloy collecting systemd journal logs from `omega`
      services.alloy = {
        enable = true;
        configPath = pkgs.writeText "omega-alloy.alloy" ''
          // Collect logs from host systemd journal
          loki.source.journal "omega_journal" {
            forward_to = [loki.write.local_loki.receiver]
            labels     = {
              job  = "systemd-journal",
              host = "omega",
              env  = "production"
            }
          }

          // Push logs to local Loki instance
          loki.write "local_loki" {
            endpoint {
              url = "http://127.0.0.1:3100/loki/api/v1/push"
            }
          }
        '';
      };
    };

  # Guest MicroVM Log Shipper Module (`alpha`)
  flake.nixosModules.alpha-logging =
    { pkgs, ... }:
    {
      # MicroVM Log Shipper: Grafana Alloy collecting systemd journal logs from `alpha`
      services.alloy = {
        enable = true;
        configPath = pkgs.writeText "alpha-alloy.alloy" ''
          // Collect logs from guest VM systemd journal
          loki.source.journal "alpha_journal" {
            forward_to = [loki.write.host_loki.receiver]
            labels     = {
              job  = "systemd-journal",
              host = "alpha",
              env  = "microvm"
            }
          }

          // Forward logs across microvm bridge to Loki on host omega
          loki.write "host_loki" {
            endpoint {
              url = "http://10.0.0.1:3100/loki/api/v1/push"
            }
          }
        '';
      };
    };
}
