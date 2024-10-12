{ pkgs, version ? "latest", sample ? "none", template ? "app", blank ? false, platforms ? "web,android", ... }:

pkgs.mkShell {
  buildInputs = [
    # Laravel
    pkgs.php83
    pkgs.php83Packages.composer
    pkgs.nodejs_20

    # Flutter
    pkgs.curl
    pkgs.gnutar
    pkgs.xz
    pkgs.git
    pkgs.busybox
    pkgs.flutter
  ];

  shellHook = ''
    # Set up Composer environment
    mkdir -p composer-home
    export COMPOSER_HOME=./composer-home

    # Create output directory
    mkdir -p "$out"

    # Create Laravel project
    composer create-project laravel/laravel "$out"

    # Prepare .idx directory and copy dev.nix
    mkdir -p "$out/.idx"
    install --mode u+rw ${./dev.nix} "$out/.idx/dev.nix"

    # Create Flutter project with optional parameters
    flutter create "$out" --template="${template}" --platforms="${platforms}" \
      ${if sample != "none" then "--sample=${sample}" else ""} \
      ${if blank then "-e" else ""}

  '';
}
