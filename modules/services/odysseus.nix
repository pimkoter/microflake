{
  flake.nixosModules.odysseus =
    { lib, config, ... }:
    let
      cfg = config.services.odysseus;
    in
    {
      options.services.odysseus = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Odysseus AI Manager service";
        };
        workspaceHostPath = lib.mkOption {
          type = lib.types.str;
          default = "/home/pim/Repos/Microflake";
          description = "Host workspace path to mount inside Odysseus";
        };
      };

      config = lib.mkIf cfg.enable {
        virtualisation = {
          oci-containers = {
            backend = "docker";
            containers.odysseus = {
              image = "ghcr.io/microflake/odysseus-ai:latest";
              autoStart = true;
              environment = {
                OLLAMA_HOST = "http://127.0.0.1:11434";
                PROMETHEUS_URL = "http://127.0.0.1:9090";
                LOKI_URL = "http://127.0.0.1:3100";
                WORKSPACE_DIR = "/workspace";
                LOG_LEVEL = "info";
              };
              volumes = [
                "/var/log:/var/log:ro"
                "${cfg.workspaceHostPath}:/workspace:rw"
                "/var/lib/odysseus:/data"
                "/var/run/docker.sock:/var/run/docker.sock"
              ];
              extraOptions = [
                "--network=host"
              ];
            };
          };
        };

        systemd.tmpfiles.rules = [
          "d /var/lib/odysseus 0755 root root - -"
          "d /var/lib/odysseus/workspace 0755 root root - -"
        ];
      };
    };
}
