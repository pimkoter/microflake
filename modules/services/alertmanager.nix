{
  # Prometheus Alertmanager & Alerting Rules Module for Microflake
  #
  # This module configures automated alerting for infrastructure failures, high resource utilization,
  # and MicroVM crashes across `omega` and `alpha`.
  #
  # Features:
  #   - Alerting rules for host and guest reachability, CPU/RAM exhaustion, disk capacity, and DNS service health.
  #   - Alertmanager service routing alerts with grouping, deduplication, and configurable notification receivers
  #     (e.g., Matrix, Discord, Telegram, or Webhook integration).

  flake.nixosModules.alertmanager = _: {
    # Alertmanager Service on `omega`
    services.prometheus.alertmanager = {
      enable = true;
      port = 9093;
      listenAddress = "127.0.0.1";

      # Routing and notification channel rules
      configuration = {
        route = {
          receiver = "default-webhook";
          group_by = [
            "alertname"
            "instance"
            "service"
          ];
          group_wait = "30s";
          group_interval = "5m";
          repeat_interval = "4h";
        };

        receivers = [
          # Default fallback receiver (can be parameterized or pointed to Matrix/Discord webhook)
          {
            name = "default-webhook";
            webhook_configs = [
              {
                url = "http://127.0.0.1:5001/alerts";
                send_resolved = true;
              }
            ];
          }
        ];

        inhibit_rules = [
          # Inhibit individual service alerts if the entire host/VM instance is down
          {
            source_matchers = [ "alertname = InstanceDown" ];
            target_matchers = [ "severity = warning" ];
            equal = [ "instance" ];
          }
        ];
      };
    };

    # Alert Rules evaluated by Prometheus server
    services.prometheus = {
      # Instruct Prometheus to route triggered alerts to Alertmanager
      alertmanagers = [
        {
          static_configs = [
            {
              targets = [ "127.0.0.1:9093" ];
            }
          ];
        }
      ];

      # PromQL Alert Definitions
      rules = [
        (builtins.toJSON {
          groups = [
            {
              name = "infrastructure_alerts";
              rules = [
                # 1. Instance/VM Down Alert
                {
                  alert = "InstanceDown";
                  expr = "up == 0";
                  for = "1m";
                  labels = {
                    severity = "critical";
                  };
                  annotations = {
                    summary = "Instance {{ $labels.instance }} is unreachable";
                    description = "Target {{ $labels.instance }} (job {{ $labels.job }}) has been down for over 1 minute.";
                  };
                }

                # 2. High CPU Utilization Alert (>85% for 5 mins)
                {
                  alert = "HighCpuUtilization";
                  expr = ''100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85'';
                  for = "5m";
                  labels = {
                    severity = "warning";
                  };
                  annotations = {
                    summary = "High CPU usage on {{ $labels.instance }}";
                    description = "CPU utilization on {{ $labels.instance }} is above 85% for more than 5 minutes.";
                  };
                }

                # 3. High RAM Usage Alert (>90% for 5 mins)
                {
                  alert = "HighMemoryUsage";
                  expr = "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 90";
                  for = "5m";
                  labels = {
                    severity = "warning";
                  };
                  annotations = {
                    summary = "High Memory usage on {{ $labels.instance }}";
                    description = "Memory utilization on {{ $labels.instance }} exceeds 90%.";
                  };
                }

                # 4. Low Disk Space Alert (<15% remaining)
                {
                  alert = "LowDiskSpace";
                  expr = ''node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} * 100 < 15'';
                  for = "5m";
                  labels = {
                    severity = "critical";
                  };
                  annotations = {
                    summary = "Low disk space on {{ $labels.instance }}";
                    description = "Root filesystem free space on {{ $labels.instance }} is below 15%.";
                  };
                }

                # 5. Pi-hole Service Failure Alert
                {
                  alert = "PiholeDnsExporterDown";
                  expr = ''up{job="pihole-dns"} == 0'';
                  for = "2m";
                  labels = {
                    severity = "critical";
                  };
                  annotations = {
                    summary = "Pi-hole DNS exporter unreachable";
                    description = "Pi-hole DNS exporter on alpha MicroVM is not responding.";
                  };
                }
              ];
            }
          ];
        })
      ];
    };
  };
}
