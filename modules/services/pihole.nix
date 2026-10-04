{
  flake.nixosModules.pihole =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      services = {
        pihole-web = {
          enable = true;
        };

        pihole-ftl = {
          enable = true;

          openFirewallDNS = true;
          openFirewallDHCP = true;
          openFirewallWebserver = true;

          settings = {
            misc.readOnly = true;

            api = {
              active = true;

              allowedOrigins = [
                "https://pihole.puber.com"
                "http://pihole.puber.com"
              ];
            };

            webserver = {
              active = true;
              port = lib.mkForce "80";
              domain = lib.mkForce "pihole.puber.com";
              api.pwhash = config.sops.secrets."alpha/pihole-pass".path;
            };

            dns = {
              upstreams = [
                "127.0.0.1#5335"
              ];

              listeningMode = "all";

              domainNeeded = false;
              expandHosts = false;
              bogusPriv = true;
              queryLogging = true;
              localise = true;
              showDNSSEC = true;

              domain = {
                name = "home";
                local = true;
              };

              cache = {
                size = 10000;
                optimizer = 3600;
                upstreamBlockedTTL = 86400;
                rrtype = "ANY";
              };

              blocking = {
                active = true;
                mode = "NULL";
                edns = "TEXT";
              };

              specialDomains = {
                mozillaCanary = true;
                iCloudPrivateRelay = true;
                designatedResolver = true;
              };

              rateLimit = {
                burst = 1000;
                windowSeconds = 30;
              };
            };

            dhcp = {
              active = true;

              # DHCP leases are for the physical home LAN.
              start = "192.168.1.50";
              end = "192.168.1.254";

              # Omega is the gateway for the home LAN.
              router = "192.168.1.10";

              # Important when DHCP arrives through a relay.
              netmask = "255.255.255.0";

              leaseTime = "3h";
              ipv6 = true;
              rapidCommit = true;
            };

            ntp = {
              ipv4.active = true;
              ipv6.active = true;

              sync = {
                active = true;
                server = "pool.ntp.org";
                interval = 3600;
                count = 8;
                rtc.utc = true;
              };
            };

            resolver = {
              resolveIPv4 = true;
              resolveIPv6 = true;
              macNames = true;
              networkNames = true;
              refreshNames = "IPV4_ONLY";
            };

            database = {
              DBimport = true;
              maxDBdays = 91;
              DBinterval = 60;
              useWAL = true;

              network = {
                parseARPcache = true;
                expire = 91;
              };
            };

            misc = {
              privacylevel = 0;
              nice = -10;
              normalizeCPU = true;

              check = {
                load = true;
                shmem = 90;
                disk = 90;
              };
            };
          };

          lists = [ ];
        };
      };

      # SOPS secret declaration for Pi-hole web admin password hash
      sops.secrets."alpha/pihole-pass" = { };

      environment.systemPackages = with pkgs; [
        pihole
        pihole-ftl
      ];

      systemd.tmpfiles.rules = [
        "f /etc/pihole/versions 0644 pihole pihole - -"
      ];
    };
}
