{
  description = "Skill Issues (Dave's Skills Library)";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              uv
            ];
            shellHook = ''
              [[ -d .venv ]] || uv venv .venv
              source .venv/bin/activate
              which agentskills || $(uv sync && uv python install)
              
              echo ">> NOTE: Add ~/.local/bin to \$PATH to discover executables."
              echo ">> NOTE: Move/link this folder to ~/.agents/skills to install."
            '';
          };
        };
      }
    );
}
