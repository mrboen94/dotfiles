# dotfiles

Just some of my dotfiles

## Installation (Using my soon™ to be released horrible(?) dotfile manager kvern)

**Big caveat**, these commands work for me as I have access to the repo, but you can just use the commands from the kvern file (hopefully),
not tested on every system yet, so **it might delete your system files accidentally (hopefully wont though)**, use at your own risk.

If you dont want to use it, just copy the files to their respective location in your OS or setup.

### macOS (Apple Silicon)

```bash
curl -L https://github.com/mrboen94/kvern/releases/latest/download/kvern-darwin-arm64.tar.gz | tar xz -C /usr/local/bin
```

### macOS (Intel)

```bash
curl -L https://github.com/mrboen94/kvern/releases/latest/download/kvern-darwin-amd64.tar.gz | tar xz -C /usr/local/bin
```

### Linux (x86_64)

```bash
curl -L https://github.com/mrboen94/kvern/releases/latest/download/kvern-linux-amd64.tar.gz | sudo tar xz -C /usr/local/bin
```

### Linux (ARM64)

```bash
curl -L https://github.com/mrboen94/kvern/releases/latest/download/kvern-linux-arm64.tar.gz | sudo tar xz -C /usr/local/bin
```

## Kvern usage

Don't usage, usage instructions are not clear at the moment, but it works for me, it might work for you. It creates symlinks from the folder to the default .config path.

```bash
# Initialize a new kvern workspace
kvern init [--dry-run] [--force] [--config <path>]

# Pull a dotfiles repository
kvern pull [--dry-run] <repository-url>

# Pull and automatically link files (uses kvern.json if present, otherwise defaults)
kvern pull --link <repository-url>

# Link specific files or directories (recursively)
kvern link [options] <paths...>

# Link files with backup (recommended)
kvern link --backup <paths...>

# Force overwrite of existing files
kvern link --force <paths...>

# Link with both backup and force
kvern link --backup --force <paths...>

# Preview changes without making them
kvern link --dry-run <paths...>
```
