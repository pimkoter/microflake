{
  flake.nixosModules.vectorDb = _: {
    virtualisation = {
      oci-containers = {
        backend = "docker";
        containers.qdrant = {
          image = "qdrant/qdrant:latest";
          autoStart = true;
          ports = [
            "6333:6333"
            "6334:6334"
          ];
          volumes = [
            "/var/lib/qdrant:/qdrant/storage"
          ];
          extraOptions = [
            "--network=host"
          ];
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/qdrant 0755 root root - -"
    ];

    networking.firewall.allowedTCPPorts = [
      6333
      6334
    ];
  };
}
