# Ruby Snake GUI

A classic Snake game built with Ruby and Glimmer DSL LibUI.

## Features

- Smooth snake movement with grid-based gameplay
- Score tracking
- Game over screen with restart option
- WASD and arrow key controls
- Standalone .exe available (no Ruby installation required)

## Playing the Game

### Controls
- **W / Up Arrow** - Move up
- **A / Left Arrow** - Move left
- **S / Down Arrow** - Move down
- **D / Right Arrow** - Move right
- **Y** - Play again (after game over)
- **N** - Exit (after game over)

### Running from Source
```bash
gem install glimmer-dsl-libui
ruby rubysnake_gui.rb
```

### Running the .exe
Download `rubysnake_gui.exe` from the [Releases](../../releases) page.

**Note:** Windows SmartScreen may show a warning. Click "More info" then "Run anyway" - this is normal for unsigned indie software.

## Verifying the Binary

### SHA256 Hash
Each release includes a SHA256 hash for integrity verification:

```powershell
powershell Get-FileHash rubysnake_gui.exe -Algorithm SHA256
```

Compare the output with the hash in the release notes.

### Sigstore Signature
Releases are signed with [Sigstore](https://www.sigstore.dev/). Verify with:

```bash
# Install cosign
cosign verify-blob rubysnake_gui.exe \
  --certificate rubysnake_gui.exe.cert \
  --signature rubysnake_gui.exe.sig \
  --certificate-identity-regexp ".*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

## Building from Source

### Prerequisites
- Ruby 3.x (tested on Ruby 3.4)
- `glimmer-dsl-libui` gem
- `ocran` gem (for building .exe)

### Build Steps
1. Install dependencies:
   ```bash
   gem install glimmer-dsl-libui ocran
   ```

2. Build the executable:
   ```bash
   ruby -S ocran rubysnake_gui.rb
   ```

Or use the included batch file (Windows):
```batch
build_rubysnake_exe.bat
```

## License

MIT License - Feel free to modify and distribute!

## Credits

Built with:
- [Glimmer DSL LibUI](https://github.com/AndyObtiva/glimmer-dsl-libui) - Native GUI framework
- [OCRAN](https://github.com/ocran/ocran) - One Click Ruby Application
- [Sigstore](https://www.sigstore.dev/) - Code signing infrastructure