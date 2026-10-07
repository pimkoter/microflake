{
  flake.nixosModules.unbound = _: {
    services.unbound = {
      enable = true;
      settings = {
        server = {
          interface = [ "127.0.0.1" ];
          port = 5335;
          prefetch = "yes";
          do-ip6 = "no";
          access-control = [
            "127.0.0.0/8 allow"
            "192.168.1.0/24 allow"
          ];
        };
      };
    };
  };
}
