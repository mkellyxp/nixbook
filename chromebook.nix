# Common config used by the installer, Nixbook, and Nixbook Lite
{ pkgs, ... }:

let
  # Patched version of the alsa-ucm-conf package to also work on many Chromebooks
  # Including this in all computers shouldn't break audio for non-Chromebooks
  chromebook-ucm-conf =
    with pkgs;
    alsa-ucm-conf.overrideAttrs {
      crosSrc = fetchFromGitHub {
        owner = "WeirdTreeThing";
        repo = "alsa-ucm-conf-cros";
        rev = "a4e92135fd49e669b5ce096439289e05e25ae90c";
        hash = "sha256-3TpzjmWuOn8+eIdj0BUQk2TeAU7BzPBi3FxAmZ3zkN8=";
      };
      postInstall = ''
        cp -R $crosSrc/ucm2/* $out/share/alsa/ucm2
        cp -R $crosSrc/overrides/* $out/share/alsa/ucm2/conf.d
      '';
    };
in
{
  # Chromebook support
  environment.systemPackages = with pkgs; [
    # ectool is used for interacting with the ChromeOS Embedded Controller
    # It is not needed for regular people to use Chromebooks, but it might be a helpful utility for troubleshooting
    # The Framework ectool works well enough for Chromebooks
    # Framework laptops use a similar, if not exact same ChromeOS Embedded Controller
    # The ChromeOS ectool is not packaged in nixpkgs
    fw-ectool
    # For running the MrChromebox firmware utility script
    dmidecode
  ];
  # For flashing firmware on Chromebooks
  boot.kernelParams = [ "iomem=relaxed" ];
  # For running the MrChromebox firmware utility script
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libusb1
    ];
  };

  # For SOF audio on Chromebooks, adapted from https://github.com/WeirdTreeThing/chromebook-linux-audio
  environment.sessionVariables.ALSA_CONFIG_UCM2 = "${chromebook-ucm-conf}/share/alsa/ucm2";
  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-increase-headroom.conf" ''
      monitor.alsa.rules = [
        {
          matches = [
            {
              node.name = "~alsa_output.*"
            }
          ]
          actions = {
            update-props = {
              api.alsa.headroom = 2048
            }
          }
        }
      ]
    '')
  ];
}
