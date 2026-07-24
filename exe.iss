[Setup]
AppName=NoteSafe
AppVersion=2.2.5
DefaultDirName={autopf}\NoteSafe
DefaultGroupName=NoteSafe
OutputDir=Output
OutputBaseFilename=NoteSafe_Setup
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
SetupIconFile=windows\runner\resources\app_icon.ico

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"

[Files]
Source: "build\windows\x64\runner\Release\ntsapp.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\NoteSafe"; Filename: "{app}\ntsapp.exe"
Name: "{autodesktop}\NoteSafe"; Filename: "{app}\ntsapp.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\ntsapp.exe"; Description: "Launch NoteSafe"; Flags: nowait postinstall skipifsilent