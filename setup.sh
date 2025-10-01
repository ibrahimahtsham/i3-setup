#!/bin/bash

echo "🚀 Setting up i3 configuration symlinks..."

# Create config directories if they don't exist
mkdir -p ~/.config/i3
mkdir -p ~/.config/i3blocks

# Backup existing configs
if [ -f ~/.config/i3/config ]; then
    cp ~/.config/i3/config ~/.config/i3/config.backup
    echo "✅ Backed up existing i3 config"
fi

if [ -f ~/.config/i3blocks/i3blocks.conf ]; then
    cp ~/.config/i3blocks/i3blocks.conf ~/.config/i3blocks/i3blocks.conf.backup
    echo "✅ Backed up existing i3blocks config"
fi

# Remove existing files/symlinks
rm -f ~/.config/i3/config
rm -f ~/.config/i3blocks/i3blocks.conf

# Create symlinks
ln -sf ~/i3-setup/configs/i3/config ~/.config/i3/config
ln -sf ~/i3-setup/configs/i3blocks.conf ~/.config/i3blocks/i3blocks.conf

echo "🔗 Symlinks created successfully!"
echo "📝 Edit configs in ~/i3-setup/configs/ - changes will be reflected immediately"
echo "🎉 Setup complete! Restart i3 with Mod+Shift+r or reboot"