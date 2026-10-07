{ inputs, ... }:
{
  flake.nixosModules.beta-h = {
    imports = [ inputs.microvm.nixosModules.microvm ];

    microvm = {
      vcpu = 2;
      mem = 2047;
      interfaces = [
        {
          type = "tap";
          id = "vm-beta";
          mac = "02:00:00:00:00:02";
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
          source = "/var/lib/microvms/beta/persistent";
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
            "10.0.0.3/24"
          ];
          Gateway = "10.0.0.1";
          DNS = [ "10.0.0.1" ];
        };
      };
    };
  };
}
