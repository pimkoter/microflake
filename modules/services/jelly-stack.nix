{
  flake.nixosModules.jellyStack =
    {
      pkgs,
      ...
    }:
    let
      base = "/var/lib/jellystack";
    in
    {
      config = {
        systemd.services.create-jellystack-network = {
          description = "Create jellystack docker network";
          after = [
            "network.target"
            "docker.service"
          ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.docker}/bin/docker network create jellystack";
            ExecCondition = "${pkgs.bash}/bin/bash -c '! ${pkgs.docker}/bin/docker network inspect jellystack >/dev/null 2>&1'";
            RemainAfterExit = true;
          };
        };

        systemd.tmpfiles.rules = [
          "d '${base}/config/jellyfin' 0755 1000 1000 -"
          "d '${base}/config/prowlarr' 0755 1000 1000 -"
          "d '${base}/config/radarr' 0755 1000 1000 -"
          "d '${base}/config/sonarr' 0755 1000 1000 -"
          "d '${base}/config/qbittorrent' 0755 1000 1000 -"
          "d '${base}/config/bazarr' 0755 1000 1000 -"
          "d '${base}/config/seerr' 0755 1000 1000 -"
          "d '${base}/config/lidarr' 0755 1000 1000 -"
          "d '${base}/movies' 0755 1000 1000 -"
          "d '${base}/shows' 0755 1000 1000 -"
          "d '${base}/music' 0755 1000 1000 -"
          "d '${base}/downloads' 0755 1000 1000 -"
        ];

        virtualisation = {
          docker.enable = true;
          oci-containers = {
            backend = "docker";
            containers = {
              jellyfin = {
                image = "jellyfin/jellyfin:latest";
                volumes = [
                  "${base}/config/jellyfin:/config"
                  "${base}:/media"
                ];
                ports = [ "8096:8096" ];
                extraOptions = [
                  "--network=jellystack"
                  "--device=/dev/dri:/dev/dri"
                ];
              };
              prowlarr = {
                image = "lscr.io/linuxserver/prowlarr:latest";
                volumes = [ "${base}/config/prowlarr:/config" ];
                ports = [ "9696:9696" ];
                environment = {
                  TZ = "Europe/Amsterdam";
                  PUID = "1000";
                  PGID = "1000";
                };
                extraOptions = [ "--network=jellystack" ];
              };
              radarr = {
                image = "lscr.io/linuxserver/radarr:latest";
                volumes = [
                  "${base}/config/radarr:/config"
                  "${base}:/data"
                ];
                ports = [ "7878:7878" ];
                environment = {
                  TZ = "Europe/Amsterdam";
                  PUID = "1000";
                  PGID = "1000";
                };
                extraOptions = [ "--network=jellystack" ];
              };
              sonarr = {
                image = "lscr.io/linuxserver/sonarr:latest";
                volumes = [
                  "${base}/config/sonarr:/config"
                  "${base}:/data"
                ];
                ports = [ "8989:8989" ];
                environment = {
                  TZ = "Europe/Amsterdam";
                  PUID = "1000";
                  PGID = "1000";
                };
                extraOptions = [ "--network=jellystack" ];
              };
              qbittorrent = {
                image = "lscr.io/linuxserver/qbittorrent:latest";
                volumes = [
                  "${base}/config/qbittorrent:/config"
                  "${base}/downloads:/data/downloads"
                ];
                ports = [ "8080:8080" ];
                environment = {
                  TZ = "Europe/Amsterdam";
                  PUID = "1000";
                  PGID = "1000";
                };
                extraOptions = [ "--network=jellystack" ];
              };
              bazarr = {
                image = "lscr.io/linuxserver/bazarr:latest";
                volumes = [
                  "${base}/config/bazarr:/config"
                  "${base}:/data"
                ];
                ports = [ "6767:6767" ];
                environment = {
                  TZ = "Europe/Amsterdam";
                  PUID = "1000";
                  PGID = "1000";
                };
                extraOptions = [ "--network=jellystack" ];
              };
              seerr = {
                image = "ghcr.io/seerr-team/seerr:latest";
                volumes = [ "${base}/config/seerr:/app/config" ];
                ports = [ "5055:5055" ];
                environment = {
                  TZ = "Europe/Amsterdam";
                };
                extraOptions = [ "--network=jellystack" ];
              };
              lidarr = {
                image = "lscr.io/linuxserver/lidarr:latest";
                volumes = [
                  "${base}/config/lidarr:/config"
                  "${base}:/data"
                ];
                ports = [ "8686:8686" ];
                environment = {
                  TZ = "Europe/Amsterdam";
                  PUID = "1000";
                  PGID = "1000";
                };
                extraOptions = [ "--network=jellystack" ];
              };
            };
          };
        };
      };
    };
}
