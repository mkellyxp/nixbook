{ ... }:
{
  nixpkgs.config.allowUnfree = true;
  # Fix for the pesky "insecure" broadcom
  nixpkgs.config.allowInsecurePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "broadcom-sta" # aka “wl”
    ];
}
