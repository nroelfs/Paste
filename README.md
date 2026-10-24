Paste is a small clipboard tool that extends the clipboard and allows you to store images and text in the clipboard for an extended period of time.

License: PolyForm Shield 1.0.0 (source-available, not OSI open source)

## How to Use
Press `cmd` + `shift` + `v` to open the overlay.

## Installation
After downloading the ZIP file, run the following commands to install Paste

```bash
unzip Paste.zip
xattr -cr Paste.app          # remove quarantine flag
mv Paste.app /Applications/
```

## Configuration
The configuration is located in the directory `~/.config/apizzacomp/paste.toml`

### clipboardLifeTime Section
These settings specify how long entries are stored in the clipboard. `kind` specifies the unit; the default is `hours`. You can switch between `minutes`, `seconds`, and `hours`. `timespan` specifies the exact duration; the default is `36`.

### general section
`autostart` specifies whether the app should start automatically. `capacity` specifies how many entries can be stored.

Translated with DeepL.com (free version)