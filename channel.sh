# This script ensures system is on the right channel.
# This has been moved to a script so it can live outside the main config and channel switching updates are faster

/run/current-system/sw/bin/nix-channel --add https://nixos.org/channels/nixos-25.11 nixos
/run/current-system/sw/bin/nix-channel --update

FREE_GB=$(/run/current-system/sw/bin/df -BG --output=avail / | /run/current-system/sw/bin/awk 'NR==2 { gsub(/G/, "", $1); print $1 }')

if [ "$FREE_GB" -lt 16 ]; then
  echo "Low on space, removing all generations"
  /run/current-system/sw/bin/nix-collect-garbage -d
elif [ "$FREE_GB" -lt 64 ]; then
  echo "Removing generations over 15 days old"
  /run/current-system/sw/bin/nix-collect-garbage --delete-older-than 15d
else
  echo "Removing generations over 30 days old"
  /run/current-system/sw/bin/nix-collect-garbage --delete-older-than 30d
fi

