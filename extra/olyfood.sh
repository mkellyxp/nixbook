DESKTOP_FILE="$HOME/Desktop/SOUPER_SUNDAY_GROUPS_LINK.desktop"

# Create the .desktop file
cat > "$DESKTOP_FILE" <<EOL
[Desktop Entry]
Version=1.0
Type=Link
Name=SOUPER SUNDAY GROUPS LINK
URL=https://soupersundayolympia.com/findagroup/
Icon=text-html
EOL

# Make it executable
chmod +x "$DESKTOP_FILE"
