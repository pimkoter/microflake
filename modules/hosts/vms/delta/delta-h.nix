{ inputs, ... }:
{
  flake.nixosModules.delta-h = {
    imports = [ inputs.microvm.nixosModules.microvm ];

    microvm = {
      vcpu = 1;
      mem = 512;
      interfaces = [
        {
          type = "tap";
          id = "vm-delta";
          mac = "02:00:00:00:00:04";
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
          source = "/var/lib/microvms/delta/persistent";
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
            "10.0.0.5/24"
          ];
          Gateway = "10.0.0.1";
          DNS = [ "10.0.0.1" ];
        };
      };
    };
  };
}
