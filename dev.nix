# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-23.11"; # or "unstable"
  
  # Use https://search.nixos.org/packages to find packages
  packages = [
    # Laravel
    pkgs.php83
    pkgs.php83Packages.composer
    pkgs.nodejs_20

    # Flutter
    pkgs.nodePackages.firebase-tools
    pkgs.jdk17
    pkgs.unzip
    pkgs.flutter
  ];

  # Sets environment variables in the workspace
  env = {};
  
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];
    
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = {
        installDependencies = "flutter pub get";
        
        # Create Flutter project with optional parameters
        flutterCreate = ''
          flutter create "$out" --template="${template}" --platforms="${platforms}" \
            ${if sample != "none" then "--sample=${sample}" else ""} \
            ${if blank then "-e" else ""}
          
          echo "Project created successfully at $out"
        '';

        # Build Flutter
        buildFlutter = ''
          cd ${out}/android  # Use the dynamic output path for the Android directory

          ./gradlew \
            --parallel \
            -Pverbose=true \
            -Ptarget-platform=android-x86 \
            -Ptarget=${out}/lib/main.dart \
            -Pbase-application-name=android.app.Application \
            -Pdart-defines=RkxVVFRFUl9XRUJfQ0FOVkFTS0lUX1VSTD1odHRwczovL3d3dy5nc3RhdGljLmNvbS9mbHV0dGVyLWNhbnZhc2tpdC85NzU1MDkwN2I3MGY0ZjNiMzI4YjZjMTYwMGRmMjFmYWMxYTE4ODlhLw== \
            -Pdart-obfuscation=false \
            -Ptrack-widget-creation=true \
            -Ptree-shake-icons=false \
            -Pfilesystem-scheme=org-dartlang-root \
            assembleDebug

          # TODO: Execute web build in debug mode.
          # flutter build web --profile --dart-define=Dart2jsOptimization=O0

          adb -s localhost:5555 wait-for-device
        '';
      };

      # To run something each time the workspace is (re)started, use the `onStart` hook
      onStart = {
        # Define any commands you want to run on workspace start
      };
    };

    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["php", "artisan", "serve", "--port", "$PORT", "--host", "0.0.0.0"];
          manager = "web";
        };
        android = {
          command = ["flutter", "run", "--machine", "-d", "android", "-d", "localhost:5555"];
          manager = "flutter";
        };
      };
    };
  };
}
