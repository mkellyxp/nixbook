# This script ensures system is on the right channel.
# This has been moved to a script so it can live outside the main config and channel switching updates are faster

/run/current-system/sw/bin/nix-channel --add https://nixos.org/channels/nixos-25.11 nixos
