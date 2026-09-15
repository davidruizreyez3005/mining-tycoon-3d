# Mining Tycoon 3D

A complete 3D mobile mining tycoon game built with Godot 4.x.

## Project Status

**Engine:** Godot 4.2.2  
**Platform:** Android (ARM64)  
**Build Status:** [![Android Build](https://github.com/davidruizreyez3005/mining-tycoon-3d/actions/workflows/android.yml/badge.svg)](https://github.com/davidruizreyez3005/mining-tycoon-3d/actions/workflows/android.yml)

## Features

### Core Gameplay
- **Mining System**: Extract resources from underground deposits
- **Resource Economy**: 12 resource types across 4 rarity tiers
- **Worker Management**: Hire and manage different worker types
- **Machinery**: Purchase and upgrade industrial equipment
- **Automation**: Progress from manual to fully automated operations
- **Offline Progression**: Earn resources while away
- **Save/Load**: Persistent game state with versioning

### Systems Implemented
- GameState management (14 states)
- Economy simulation
- Worker AI with state machines
- Machine operations
- Resource processing chains
- Inventory management
- Audio/VFX systems
- Mobile touch controls
- UI management

### Resources
| Rarity | Resources |
|--------|-----------|
| Common | Stone, Coal, Copper, Iron |
| Uncommon | Silver, Gold |
| Rare | Platinum, Emerald, Ruby, Sapphire |
| Very Rare | Diamond, Exotic Matter |

### Worker Types
- Miner (basic extraction)
- Skilled Miner (improved efficiency)
- Engineer (repair & operation)
- Supervisor (team bonuses)

### Machinery
- Extractor
- Processor
- Conveyor
- Storage
- Elevator

## Project Structure

```
mining-tycoon-3d/
├── project/              # Godot 4.x project
│   ├── scenes/          # Game scenes
│   ├── scripts/         # GDScript code
│   │   ├── core/        # Core systems
│   │   ├── systems/     # Game systems
│   │   └── ui/          # UI components
│   ├── assets/          # Game assets
│   ├── project.godot    # Project configuration
│   └── export_presets.cfg
├── assets/              # Source assets
├── blender/             # Blender scripts
├── .github/workflows/   # CI/CD pipelines
│   ├── validate.yml     # Project validation
│   └── android.yml      # Android build
└── README.md
```

## Building

### Prerequisites
- Godot 4.2.2
- JDK 17
- Android SDK
- Android NDK

### Local Build
```bash
cd project
godot --headless --export-release "Android" build/mining-tycoon.apk
```

### GitHub Actions
The APK is automatically built on:
- Push to main branch
- Manual workflow dispatch
- Tag creation (creates release)

## Download

APK artifacts are available from:
1. GitHub Actions runs (artifacts section)
2. Releases page (for tagged versions)

## License

MIT License
