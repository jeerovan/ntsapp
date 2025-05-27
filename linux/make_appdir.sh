#!/bin/bash

# === Configuration ===
APP_NAME="NoteSafe"                      # Change to your app name
BUNDLE_DIR="/home/pi/ntsapp/build/linux/x64/release/bundle" # Path to Flutter bundle folder
ICON_PATH="/home/pi/ntsapp/assets/icon_512.png"           # Path to app icon
APP_EXECUTABLE="ntsapp"  # Name of your Linux executable (in BUNDLE_DIR)

# === Derived ===
APPDIR="${APP_NAME}.AppDir"

# === Create AppDir structure ===
echo "📁 Creating ${APPDIR} structure..."
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/share/applications"

# === Copy binaries and libraries ===
cp "${BUNDLE_DIR}/${APP_EXECUTABLE}" "$APPDIR/usr/bin/"
cp -r "${BUNDLE_DIR}/lib" "$APPDIR/usr/bin/"
cp -r "${BUNDLE_DIR}/lib" "$APPDIR/usr/"
cp -r "${BUNDLE_DIR}/data" "$APPDIR/usr/bin/"

# === Copy icon ===
for size in 16 24 32 48 64 128 256 512; do
  mkdir -p "$APPDIR/usr/share/icons/hicolor/${size}x${size}/apps"
  convert "$ICON_PATH" -resize ${size}x${size} "$APPDIR/usr/share/icons/hicolor/${size}x${size}/apps/${APP_NAME}.png"
done

# === Create AppRun launcher ===
cat > "$APPDIR/AppRun" <<EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\$0")")"
export LD_LIBRARY_PATH="\$HERE/usr/lib:\$LD_LIBRARY_PATH"
exec "\$HERE/usr/bin/${APP_EXECUTABLE}" "\$@"
EOF
chmod +x "$APPDIR/AppRun"

# === Create .desktop file ===
cat > "$APPDIR/${APP_NAME}.desktop" <<EOF
[Desktop Entry]
Name=${APP_NAME}
GenericName=Secure Note-Taking App
Comment=A secure and encrypted note-taking application
Exec=${APP_EXECUTABLE}
Icon=${APP_NAME}
Terminal=false
Type=Application
Categories=Utility;Security;Office;
Keywords=notes;encryption;security;
StartupWMClass=NoteSafe
MimeType=text/plain;
Actions=NewWindow;

[Desktop Action NewWindow]
Name=Open New Window
Exec=${APP_EXECUTABLE} --new-window

EOF

cp "$APPDIR/${APP_NAME}.desktop" "$APPDIR/usr/share/applications/"

echo "✅ Done!"

