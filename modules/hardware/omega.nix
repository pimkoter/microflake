{ inputs, ... }:
{
  flake.nixosModules.omega-h = {
    imports = [
      inputs.microvm.nixosModules.host
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "25.11";

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    networking = {
      hostName = "Omega";
      useNetworkd = true;

      # NAT private VM network through the physical LAN
      nat = {
        enable = true;

        externalInterface = "eno1";

        internalInterfaces = [
          "microvm"
        ];
      };
    };

    systemd = {
      network = {
        enable = true;
        networks = {
          # Physical LAN
          "10-lan" = {
            matchConfig.Name = "eno1";

            networkConfig = {
              DHCP = "yes";
            };

            linkConfig.RequiredForOnline = "routable";
          };

          "20-microvm" = {
            matchConfig.Name = "microvm";

            address = [
              "10.0.0.1/24"
            ];

            networkConfig = {
              IPv4Forwarding = true;
            };

            "21-microvm-taps" = {
              matchConfig.Name = "vm-*";

              networkConfig = {
                Bridge = "microvm";
              };
            };

          };

          # Private MicroVM bridge
          netdevs."20-microvm" = {
            netdevConfig = {
              Name = "microvm";
              Kind = "bridge";
            };
          };

        };
      };
    };
  };
}
