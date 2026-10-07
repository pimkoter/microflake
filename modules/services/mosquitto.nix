{
  flake.nixosModules.mosquitto = _: {
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          acl = [ "pattern readwrite #" ];
          omitPasswordAuth = true; # Local network broker for ESP32 & Home Assistant
          port = 1883;
          settings = {
            allow_anonymous = true;
          };
        }
      ];
    };

    networking.firewall.allowedTCPPorts = [ 1883 ];
  };
}
