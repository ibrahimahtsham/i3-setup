#!/bin/bash
# Audio fix script for Chromebook
# This script helps with common Chromebook audio issues

echo "🔊 Applying Chromebook audio fixes..."

# Set default audio device
pactl set-default-sink 0 2>/dev/null || echo "Could not set default sink"

# Unmute and set reasonable volume
pactl set-sink-mute @DEFAULT_SINK@ false 2>/dev/null
pactl set-sink-volume @DEFAULT_SINK@ 50% 2>/dev/null

# Unmute microphone
pactl set-source-mute @DEFAULT_SOURCE@ false 2>/dev/null

echo "✅ Audio fix applied"