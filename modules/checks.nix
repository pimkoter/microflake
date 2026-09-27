{ inputs, ... }:
{
  imports = [
    inputs.git-hooks.flakeModule
  ];

  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt-tree;
    pre-commit = {
      check.enable = true;

      settings.hooks = {
        # Nix
        nixfmt.enable = true;
        deadnix.enable = true;
        statix.enable = true;

        # General repository hygiene
        check-merge-conflicts.enable = true;
        check-symlinks.enable = true;
        end-of-file-fixer.enable = true;
        trim-trailing-whitespace.enable = true;

        # Security / validation
        flake-checker.enable = true;
        trufflehog.enable = true;
      };
    };
  };
}
