{
  flake.nixosModules.mosquitto = _: {
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          acl = [
            "pattern readwrite homeassistant/#"
            "pattern readwrite esp32/#"
            "pattern readwrite odysseus/#"
            "pattern readwrite $SYS/#"
          ];
          omitPasswordAuth = true; # Local LAN MQTT broker for ESP32 & Home Assistant
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
