{
  flake.nixosModules.immich =
    { lib, ... }:
    let
      baseDir = "/var/lib/immich";
      immichDataDir = "${baseDir}/immich-data";

      subDirs = [
        "thumbs"
        "upload"
        "backups"
        "library"
        "profile"
        "encoded-video"
      ];

      initScript = ''
        mkdir -p ${immichDataDir} ${baseDir}/library
        ${builtins.concatStringsSep "\n" (
          map (dir: ''
            mkdir -p ${immichDataDir}/${dir}
            touch ${immichDataDir}/${dir}/.immich
          '') subDirs
        )}
        chown -R immich:immich ${immichDataDir} ${baseDir}/library
        chmod -R 750 ${immichDataDir}
        chmod -R 755 ${baseDir}/library
      '';
    in
    {
      services.immich = {
        enable = true;
        host = "0.0.0.0";
        openFirewall = true;
        mediaLocation = immichDataDir;
      };

      systemd.services.immich-server = {
        preStart = lib.mkAfter initScript;
        serviceConfig.ReadWritePaths = [ baseDir ];
      };

      systemd.services.immich-machine-learning.serviceConfig.ReadWritePaths = [ baseDir ];
    };
}
