{
  # Prometheus Metrics Collection Module for Microflake
  #
  # This module configures metric collection across the host (`omega`) and MicroVM guests (`alpha`).
  # It defines:
  #   1. Node Exporters on host and guest VMs for system-level telemetry (CPU, RAM, Disk, Network).
  #   2. Pi-hole Exporter on `alpha` VM for DNS query statistics and ad-blocking metrics.
  #   3. Prometheus server on `omega` scraping all metrics endpoints at defined intervals.

  flake.nixosModules.prometheus = _: {
    # Enable Node Exporter on the host (`omega`)
    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = [
        "systemd"
        "processes"
        "diskstats"
        "filesystem"
        "meminfo"
        "netdev"
        "cpu"
      ];
      # Restrict metrics exposure to internal host interface
      listenAddress = "127.0.0.1";
    };

    # Main Prometheus server running on host `omega`
    services.prometheus = {
      enable = true;
      port = 9090;
      listenAddress = "127.0.0.1";

      # Scrape interval for collecting time-series metrics
      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };

      # Metrics scrapers for all infrastructure components
      scrapeConfigs = [
        # 1. Host System Metrics (`omega`)
        {
          job_name = "omega-host";
          static_configs = [
            {
              targets = [ "127.0.0.1:9100" ];
              labels = {
                instance = "omega";
                role = "host";
              };
            }
          ];
        }

        # 2. Guest MicroVM System Metrics (`alpha`)
        {
          job_name = "alpha-vm";
          static_configs = [
            {
              targets = [ "10.0.0.2:9100" ];
              labels = {
                instance = "alpha";
                role = "microvm";
              };
            }
          ];
        }

        # 3. Pi-hole DNS Metrics from `alpha` MicroVM
        {
          job_name = "pihole-dns";
          static_configs = [
            {
              targets = [ "10.0.0.2:9617" ];
              labels = {
                instance = "alpha";
                service = "pihole";
              };
            }
          ];
        }

        # 4. Caddy Reverse Proxy Metrics on Host
        {
          job_name = "caddy-proxy";
          static_configs = [
            {
              targets = [ "127.0.0.1:2019" ];
              labels = {
                instance = "omega";
                service = "caddy";
              };
            }
          ];
        }

        # 5. Loki Log Engine Metrics
        {
          job_name = "loki";
          static_configs = [
            {
              targets = [ "127.0.0.1:3100" ];
              labels = {
                instance = "omega";
                service = "loki";
              };
            }
          ];
        }
      ];
    };
  };

  # Guest MicroVM Exporters Module (`alpha`)
  flake.nixosModules.alpha-exporters = _: {
    # System metrics exporter for `alpha` VM
    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;
      listenAddress = "0.0.0.0";
      openFirewall = true;
    };

    # Pi-hole metrics exporter running inside `alpha` VM
    services.prometheus.exporters.pihole = {
      enable = true;
      port = 9617;
      piholeHostname = "127.0.0.1";
      piholePort = 80;
      listenAddress = "0.0.0.0";
      openFirewall = true;
    };
  };
}
