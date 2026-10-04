_: {
  flake.nixosModules.omega-network = {
    networking = {
      hostName = "omega";
      useNetworkd = true;

      # NAT private MicroVM subnet through the physical LAN interface
      nat = {
        enable = true;
        externalInterface = "eno1";
        internalInterfaces = [
          "microvm"
        ];
      };

      # Firewall rules for host interfaces and MicroVM bridge
      firewall = {
        enable = true;
        allowedUDPPorts = [
          67 # DHCP relay server port
          68 # DHCP relay client port
        ];
      };
    };

    # DHCP Relay: Forward LAN DHCP requests arriving on eno1 to Pi-hole VM (10.0.0.2)
    services.dnsmasq = {
      enable = true;
      settings = {
        port = 0; # Disable DNS server functionality (handled by Pi-hole)
        dhcp-relay = [
          "10.0.0.1,10.0.0.2,eno1"
        ];
      };
    };

    systemd.network = {
      enable = true;
      networks = {
        # Physical LAN interface
        "10-lan" = {
          matchConfig.Name = "eno1";
          networkConfig = {
            DHCP = "yes";
          };
          linkConfig.RequiredForOnline = "routable";
        };

        # MicroVM bridge network
        "20-microvm" = {
          matchConfig.Name = "microvm";
          address = [
            "10.0.0.1/24"
          ];
          networkConfig = {
            IPv4Forwarding = true;
          };
        };

        # Tap interfaces created for MicroVMs assigned to microvm bridge
        "21-microvm-taps" = {
          matchConfig.Name = "vm-*";
          networkConfig = {
            Bridge = "microvm";
          };
        };
      };

      # Private MicroVM bridge device creation
      netdevs."20-microvm" = {
        netdevConfig = {
          Name = "microvm";
          Kind = "bridge";
        };
      };
    };
  };
}
