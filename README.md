# Daniel's NixOS Configuration

This repository contains my personal NixOS system configuration files.

## 📁 Structure

```
NixOSconfig/
├── configuration.nix       # Main system configuration
├── hardware-configuration.nix  # Hardware-specific settings
├── apps.nix               # Application configurations
├── sync.sh                # Automated sync script
└── README.md             # This file
```

## 🚀 Quick Setup

### Initial Clone
```bash
git clone git@github.com:Daniel-Saravia/NixOSconfig.git ~/nixos-config
cd ~/nixos-config
chmod +x sync.sh
```

### Apply Configuration
```bash
# Copy configs to system directory
sudo cp *.nix /etc/nixos/

# Rebuild system
sudo nixos-rebuild switch
```

## 🔄 Sync Script Usage

The `sync.sh` script automates copying configurations between your repo and `/etc/nixos/`:

### Copy FROM system TO repo (backup current config)
```bash
./sync.sh pull
```

### Copy FROM repo TO system (apply repo config)
```bash
./sync.sh push
```

### Rebuild system after pushing
```bash
./sync.sh rebuild
```

## 📝 Workflow

1. **Make changes** to configuration files in `~/nixos-config/`
2. **Test changes** by pushing to system: `./sync.sh push`
3. **Rebuild system**: `./sync.sh rebuild`
4. **Commit and push** to GitHub when satisfied:
   ```bash
   git add .
   git commit -m "Description of changes"
   git push
   ```

## ⚙️ Key Features

- Custom package configurations
- Development environment setup
- System-wide settings and preferences

## 🔧 Maintenance

### Update from current system
```bash
./sync.sh pull
git add .
git commit -m "Update from system $(date)"
git push
```

### Restore from backup
```bash
git pull
./sync.sh push
./sync.sh rebuild
```

## 📚 Useful Commands

```bash
# Test configuration without switching
sudo nixos-rebuild test

# Check configuration syntax
sudo nixos-rebuild dry-build

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## 🚨 Important Notes

- **Always backup** before major changes
- **Test configurations** before committing
- **hardware-configuration.nix** is machine-specific - be careful when sharing
- Keep sensitive information (passwords, keys) out of version control

## 🤝 Contributing

This is a personal configuration, but feel free to:
- Use parts for your own setup
- Suggest improvements via issues
- Fork for your own NixOS journey

---

*Last updated: $(date)*
