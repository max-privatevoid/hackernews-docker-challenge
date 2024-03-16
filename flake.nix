{
  description = "Java Sprint";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
    flake-utils.url = "github:numtide/flake-utils"; 
  };


  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        jdk = pkgs.jdk21_headless;

        jre = pkgs.jre_minimal.override {
          inherit jdk;
          modules = [
            "java.base"
            "java.desktop"
            "java.logging"
            "java.management"
            "java.naming"
            "java.security.jgss"
            "java.instrument"
          ];
        };

        app = pkgs.stdenvNoCC.mkDerivation {
          pname = "app";
          version = "1.0.0";

          nativeBuildInputs = [ pkgs.makeWrapper ];

          buildCommand = ''
            mkdir -pv $out/share/java $out/bin
            cp ${./build/libs/demo-0.0.1-SNAPSHOT.jar} $out/share/java/$pname.jar
            makeWrapper ${jre}/bin/java $out/bin/app --add-flags "-jar $out/share/java/$pname.jar" 
          '';
        };

        dockerImage = pkgs.dockerTools.buildLayeredImage {
          name = "docker-challenge-image";

          config.Cmd = [ "${app}/bin/app" ];

          fakeRootCommands = ''
            install -dm 1777 tmp
          '';
        };
      in 
      {
        packages = {
          inherit app dockerImage;
          default = app;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ jdk pkgs.gradle ];
        };
      }
    );
}
