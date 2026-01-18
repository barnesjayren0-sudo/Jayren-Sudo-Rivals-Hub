# ⚡ ULTIMATE RIVALS HUB v2.5 - Enhanced Edition ⚡

## 🚀 Overview
This is a massively enhanced version of the original Rivals script, packed with advanced features and improved functionality for a superior gaming experience.

## ✨ Key Features

### 🎯 Enhanced Aimbot
- **Multiple Target Priority Modes**: Closest, Furthest, Lowest Health, Highest Health
- **Smart Bone Selection**: Head, Torso, Root, or Random bones
- **Advanced Prediction**: Velocity-based movement prediction
- **Human Jitter**: Randomized aim movement for natural-looking gameplay
- **Silent Aim**: Invisible targeting that doesn't move your camera
- **Visible Check**: Only targets enemies you can actually see
- **Team Check**: Optional team-based targeting
- **Multiple FOV Shapes**: Circle or Square FOV indicators
- **Customizable Smoothness**: Adjustable aim smoothing for legit play

### 👁️ Advanced ESP System
- **Box ESP**: Customizable player boxes with distance scaling
- **Tracer Lines**: Lines from crosshair to players
- **Health Bars**: Real-time health monitoring with color gradients
- **Name Tags**: Player names displayed above boxes
- **Distance Display**: Exact stud distance from player
- **Skeleton ESP**: Full body skeleton visualization
- **Custom Colors**: Fully customizable color schemes
- **Team Filter**: Optional team-based ESP filtering

### ⚔️ Combat Features
- **Auto Fire**: Automatic shooting when target acquired
- **Trigger Bot**: Auto-shoot when crosshair on enemy
- **Recoil Control**: Reduced recoil for better accuracy
- **Rapid Fire**: Faster fire rate
- **Infinite Ammo**: Never run out of ammunition

### 🏃 Movement Enhancements
- **Speed Boost**: Customizable speed multiplier (1.5x default)
- **Jump Boost**: Increased jump power
- **Flight Mode**: Fly around the map with ease
- **NoClip**: Walk through walls and obstacles
- **Smooth Movement**: Fluid, lag-free movement

### 🎨 Visual Improvements
- **FOV Circle**: Visual aim assist range indicator
- **Custom Crosshair**: Adjustable size and color
- **Full Bright**: Enhanced visibility in dark areas
- **Night Mode**: Reduced lighting for stealth gameplay
- **Custom UI**: Modern, clean interface design

### 🛡️ Anti-Detection Systems
- **Advanced Anti-Kick**: Blocks all kick methods and remote kicks
- **Anti-Cheat Bypass**: Enhanced detection evasion
- **Name Spoofing**: Optional name spoofing capability
- **Anti-AFK**: Prevents being kicked for inactivity
- **Remote Spy Protection**: Blocks malicious remote calls

### 🔧 Macro System
- **Custom Keybinds**: Set up to 3 custom macro keys
- **Quick Actions**: Fast toggle between different features
- **Combo Support**: Execute multiple actions with single key

## 🎮 Controls

### GUI Controls
- **Right Shift**: Toggle the main GUI on/off
- **Insert**: Quick toggle for aimbot
- **Mouse**: Click toggle buttons to enable/disable features

### Feature Keybinds (when Macros Enabled)
- **Z**: Macro Key 1 (customizable)
- **X**: Macro Key 2 (customizable) 
- **C**: Macro Key 3 (customizable)

## 📋 Configuration

All settings can be configured in the `UltimateConfig` table at the beginning of the script:

```lua
getgenv().UltimateConfig = {
    Aimbot = {
        Enabled = false,
        FOV = 120,
        Smooth = 0.05,
        TargetPriority = "Closest",
        AimPart = "Head",
        -- ... more settings
    },
    ESP = {
        Enabled = true,
        Boxes = true,
        Tracers = true,
        -- ... more settings
    },
    -- ... more sections
}
```

## 🚀 Installation & Usage

1. **Copy the Script**: Copy the entire `rivals_enhanced.lua` file content
2. **Execute in Executor**: Run the script in your preferred Roblox executor (Synapse X, KRNL, etc.)
3. **Configure Settings**: Use the GUI (Right Shift) to customize features
4. **Start Playing**: Press Insert to enable aimbot or use the GUI to enable specific features

## 🔧 Troubleshooting

### Script Not Loading
- Ensure you're using a compatible executor
- Check that the script is fully copied
- Try re-executing the script

### ESP Not Working
- Make sure ESP is enabled in the GUI
- Check team settings if you're playing team-based modes
- Verify character models are loading properly

### Aimbot Issues
- Adjust FOV and smoothness settings
- Check visible check if enemies are behind walls
- Try different aim parts (Head vs Torso)

### Anti-Kick Not Working
- Some games have advanced anti-cheat that may bypass this
- Consider using additional protection methods
- Be cautious about obvious cheating

## 📊 Performance Impact

This script is optimized for performance:
- Efficient ESP rendering with proper cleanup
- Smooth aimbot calculations without lag
- Minimal impact on game FPS
- Smart resource management

## ⚠️ Important Notes

- **Use Responsibly**: This script is for educational purposes
- **Risk of Bans**: Using cheats in any game carries ban risk
- **Game Updates**: Roblox updates may break functionality
- **Executor Compatibility**: Results may vary between executors
- **Fair Play**: Consider using in private servers only

## 🆚 Comparison with Original v1.8

| Feature | v1.8 | v2.5 Enhanced |
|---------|------|---------------|
| Aimbot | Basic | Advanced with multiple modes |
| ESP | Simple boxes | Full ESP with 6 types |
| Combat | None | Auto-fire, recoil control |
| Movement | None | Speed, flight, noclip |
| UI | Print statements | Full GUI interface |
| Anti-Detection | Basic | Advanced protection |
| Customization | Minimal | Fully configurable |
| Performance | Basic | Optimized |

## 📝 Changelog

### v2.5 - Enhanced Edition
- Completely rewritten aimbot with advanced features
- Full ESP system with 6 different visualization types
- Added combat features (auto-fire, recoil control)
- Implemented movement enhancements (speed, flight, noclip)
- Created modern GUI with easy configuration
- Enhanced anti-detection systems
- Added macro system for custom keybinds
- Improved performance and stability
- Better code organization and documentation

## 🎯 Best Settings for Different Playstyles

### Legit Play (Under the Radar)
```
Aimbot: Enabled, FOV: 80, Smooth: 0.12
ESP: Boxes only, no tracers
Movement: Speed 1.2x, no flight
```

### Rage Play (Maximum Performance)
```
Aimbot: Enabled, FOV: 180, Smooth: 0.02
ESP: All features enabled
Movement: Speed 2.0x, flight enabled
Combat: Auto-fire enabled
```

### Stealth Play (Minimal Detection)
```
Aimbot: Silent aim, FOV: 60
ESP: Health bars only
Movement: Stock settings
Anti-Ban: Maximum protection
```

## 💡 Tips & Tricks

1. **Start with High Smoothness**: Begin with smooth settings around 0.10 to avoid detection
2. **Use Silent Aim**: Keeps your crosshair movement natural
3. **Adjust FOV**: Lower FOV looks more legit, higher FOV is more effective
4. **Team Check**: Enable in team games to avoid targeting teammates
5. **Visible Check**: Prevents shooting through walls (more legit)
6. **Custom Colors**: Match ESP colors to game environment for stealth
7. **Hotkeys**: Learn the quick toggle keys for fast adaptation

## 🔒 Security Features

- **Code Obfuscation Ready**: Can be obfuscated for additional protection
- **Anti-Debug**: Built-in protection against common detection methods
- **Remote Call Filtering**: Blocks malicious remote calls
- **Memory Protection**: Reduces detection through memory analysis

## 📞 Support & Updates

This script is provided as-is. Updates may be released periodically to:
- Fix bugs and issues
- Add new features
- Improve performance
- Bypass new anti-cheat measures

## 📄 License

This script is for educational purposes only. Use responsibly and at your own risk.

---

**Enjoy the enhanced Rivals experience! ⚡**