{ inputs, ... }:
{
  flake.nixosModules.alpha-h = {
    imports = [ inputs.microvm.nixosModules.microvm ];

    microvm = {
      vcpu = 1;
      mem = 4096;
      user = "nix";
      interfaces = [
        {
          type = "tap";
          id = "vm-alpha";
          mac = "02:00:00:00:00:01";
        }
      ];
      shares = [
        {
          tag = "ro-store";
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
        }
      ];
    };

    systemd.network = {
      enable = true;
      networks."20-lan" = {
        matchConfig.Type = "ether";
        networkConfig = {
          Address = [
            "10.0.0.2/24"
          ];
          Gateway = "10.0.0.1";
          DNS = [ "10.0.0.1" ];
        };
      };
    };
  };
}
