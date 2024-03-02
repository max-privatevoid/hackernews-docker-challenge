{
  description = "Java Sprint";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
  #inputs.nixpkgs.url = "nixpkgs";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      #let deps = pkgs.stdenv.mkDerivation {
          #name = "Sample Spring";
          #src = ./.;
          #buildInputs = [ pkgs.perl];
          #buildPhase = ''
            #export GRADLE_USER_HOME=$(mktemp -d)
            #./gradlew run
              #find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\)' \
                #| LC_ALL=C sort \
                #| perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
                #| sh
          #'';
          #outputHashAlgo = "sha256";
          #outputHashMode = "recursive";
          #outputHash = "sha256-Om4BcXK76QrExnKcDzw574l+h75C8yK/EbccpbcvLsQ=";
      #}; in 
      let gradle2nix = import(fetchTarball {
          url = "https://github.com/tadfisher/gradle2nix/archive/master.tar.gz";
          sha256 = "sha256:1wdg7sirhv421wx6j7sdx3h95qdvrgqa55a18gvxqivyc15kxnv3";
        }); in
      rec {
        packages.app = pkgs.stdenv.mkDerivation {
          name = "my-app";
          version = "1.0.0";
          nativeBuildInputs = [ pkgs.jdk21 pkgs.gradle ];
        };

        defaultPackage = packages.app;
        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.jdk21 pkgs.gradle ];
        };
      }
    );
}
