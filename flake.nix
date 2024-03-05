{
  description = "Java Sprint";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };


  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      let 
        app = pkgs.stdenv.mkDerivation rec {
          name = "app";
          version = "1.0.0";
          src = ./.;
          buildInputs = [ pkgs.zulu pkgs.makeWrapper ];
          nativeBuildInputs = [ pkgs.removeReferencesTo ];
          installPhase = ''
            mkdir -pv $out/share/java $out/bin
            cp ${src}/build/libs/demo-0.0.1-SNAPSHOT.jar $out/share/java/${name}.jar
            makeWrapper ${pkgs.zulu}/bin/java $out/bin/app --add-flags "-jar $out/share/java/${name}.jar" 
          '';
        };
        dockerImage = pkgs.dockerTools.buildImage {
            name = "docker-challange-image";
            tag = "latest";
            copyToRoot = [ app ];
            config = {
              Cmd = [ "${app}/bin/app" ];
            };
          };
      in 
      rec {
        packages.app = app;
        packages.dockerImage = dockerImage;

        defaultPackage = packages.app;
        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.zulu pkgs.gradle ];
        };
      }
    );
}
