# SimpleShare

SimpleShare is a small Windows file sharing tool for quickly sharing a folder over the local network.

It starts a local upload/download server, shows access URLs, and generates QR codes for every available network address. If your computer is connected to multiple networks, SimpleShare shows multiple QR codes so you can scan the one that matches your phone's network.

## Features

- Share the selected folder over LAN
- Show one QR code per available IPv4 network address
- Show plain access URLs as fallback
- Support right-click folder sharing on Windows
- Support current-user context menu installation without administrator permission
- Auto-check required Python modules:
  - `uploadserver`
  - `qrcode`
- Includes English and Chinese batch scripts
- Includes packaged `SimpleShare.exe`

## Files

| File | Description |
| --- | --- |
| `SimpleShare.exe` | Packaged executable version, suitable for normal use |
| `SimpleShare_English.bat` | English batch script source, recommended for packaging to exe |
| `SimpleShare_Chinese.bat` | Chinese batch script source, useful when running bat directly |
| `Install_Context_Menu.bat` | Installs the right-click menu for the current Windows user |
| `Uninstall_Context_Menu.bat` | Removes the right-click menu and installed files |
| `icon.ico` | Icon used by the executable/context menu |

## Requirements

- Windows 10/11
- Python installed and added to `PATH`
- Python modules:
  - `uploadserver`
  - `qrcode`

The scripts can install missing modules automatically when you run them.

Manual install:

```bat
python -m pip install uploadserver qrcode
```

## Quick Start

### Option 1: Run directly

Double-click:

```text
SimpleShare.exe
```

or run one of the batch scripts:

```text
SimpleShare_English.bat
SimpleShare_Chinese.bat
```

By default, it shares the folder where the script/exe is located.

### Option 2: Add to right-click menu

Double-click:

```text
Install_Context_Menu.bat
```

This installs SimpleShare for the current Windows user only. Administrator permission is not required.

After installation, you can:

1. Right-click any folder.
2. Choose `Share with SimpleShare`.
3. Scan the QR code shown in the terminal.

On Windows 11, the menu may appear under:

```text
Show more options
```

The installer copies required files to:

```text
%LOCALAPPDATA%\SimpleShare
```

So after installation, you can move or delete the original downloaded folder and the context menu will still work.

## Uninstall Right-Click Menu

Double-click:

```text
Uninstall_Context_Menu.bat
```

This removes:

- The current-user right-click menu entries
- The installed files under `%LOCALAPPDATA%\SimpleShare`

## How It Works

SimpleShare uses:

```bat
python -m uploadserver 8000
```

to start a local file server on port `8000`.

Before starting the server, it uses PowerShell to find available IPv4 addresses and generates QR codes for URLs like:

```text
http://192.168.1.10:8000/
```

If multiple network addresses are available, multiple QR codes are displayed.

## Troubleshooting

### Phone cannot open the page

Check the following:

- Your phone and computer are connected to the same network.
- You scanned the QR code for the correct network.
- Windows Firewall allows Python network access.
- Your router does not enable client isolation.
- Port `8000` is not blocked or already used.

### QR code appears but cannot be scanned

Try:

- Make the terminal window larger.
- Use Windows Terminal.
- Use the plain URL shown above the QR code.

### Chinese text is garbled after packaging bat to exe

Use `SimpleShare_English.bat` when packaging with Bat To Exe Converter.

The Chinese script is mainly for direct `.bat` usage. Some bat-to-exe tools do not preserve Chinese text encoding correctly.

## Notes

- The server runs only while the terminal window is open.
- Close the window to stop sharing.
- Uploaded files are saved into the shared folder shown when SimpleShare starts.
