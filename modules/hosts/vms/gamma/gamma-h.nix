{ inputs, ... }:
{
  flake.nixosModules.gamma-h = {
    imports = [ inputs.microvm.nixosModules.microvm ];

    microvm = {
      vcpu = 2;
      mem = 4096;
      interfaces = [
        {
          type = "tap";
          id = "vm-gamma";
          mac = "02:00:00:00:00:03";
        }
      ];
      shares = [
        {
          tag = "ro-store";
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
        }
        {
          tag = "persistent";
          source = "/var/lib/microvms/gamma/persistent";
          mountPoint = "/var/lib";
          proto = "virtiofs";
        }
      ];
    };

    systemd.network = {
      enable = true;
      networks."20-lan" = {
        matchConfig.Type = "ether";
        networkConfig = {
          Address = [
            "10.0.0.4/24"
          ];
          Gateway = "10.0.0.1";
          DNS = [ "10.0.0.1" ];
        };
      };
    };
  };
}
