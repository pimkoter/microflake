{ ... }:
{
  flake.nixosModules.omega-network = {
    networking = {
      hostName = "omega";
      useNetworkd = true;

      # NAT private VM network through physical LAN
      nat = {
        enable = true;
        externalInterface = "eno1";
        internalInterfaces = [
          "microvm"
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
