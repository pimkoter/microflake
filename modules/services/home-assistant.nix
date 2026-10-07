{
  flake.nixosModules.homeAssistant = _: {
    virtualisation = {
      docker = {
        enable = true;
      };

      oci-containers = {
        backend = "docker";
        containers.homeassistant = {
          image = "ghcr.io/home-assistant/home-assistant:stable";
          volumes = [
            "/var/lib/homeassistant:/config"
            "/run/dbus:/run/dbus:ro"
          ];
          environment = {
            TZ = "America/New_York";
          };
          extraOptions = [
            "--network=host"
            "--privileged"
          ];
        };
      };
    };
    networking.firewall = {
      allowedTCPPorts = [
        8123
        1400
      ];
      allowedUDPPorts = [
        5353
        1900
      ];
    };
  };
}
