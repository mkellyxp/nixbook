{ pkgs, ... }:

let
  pythonEnv = pkgs.python3.withPackages (ps: [
    ps.pygobject3
  ]);
in {
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "welcome-installer" ''
      exec ${pythonEnv}/bin/python3 ${./welcome_installer.py}
    '')

    gtk3
    gobject-introspection
    flatpak
  ];
}

# To manually run:
#   python3 welcome_installer.py
