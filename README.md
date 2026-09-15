# Mining Tycoon 3D

A complete 3D mobile idle/tycoon mining game built with Godot 4.x.

## Overview

Start with a primitive mining operation and build a large automated mining empire. Extract resources, process them, sell for profit, upgrade equipment, hire workers, automate production, expand underground, discover rare resources, and prestige to build an even larger empire.

## Features

- **Core Gameplay**: Mine → Collect → Transport → Process → Store → Sell → Upgrade → Automate
- **Resource System**: 12+ resources from common stone to legendary diamonds
- **Underground Progression**: 7+ distinct depth zones with unique environments
- **Worker AI**: Automated workers that mine, transport, and operate machinery
- **Economy**: Deterministic simulation with offline progression
- **Save System**: Versioned saves with migration support
- **Prestige System**: Reset for permanent bonuses
- **Mobile Controls**: Touch-optimized camera pan, zoom, and selection
- **Data-Driven Content**: All resources, machines, and upgrades defined in data files

## Tech Stack

- **Engine**: Godot 4.2+
- **Language**: GDScript
- **Target Platform**: Android (APK)
- **Asset Pipeline**: Blender (headless) → GLB/glTF → Godot
- **CI/CD**: GitHub Actions

## Project Structure

```
/workspace
├── project/              # Godot project
│   ├── scenes/           # Scene files (.tscn)
│   ├── scripts/          # GDScript files
│   │   ├── core/         # Core systems (game state, manager)
│   │   ├── systems/      # Game systems (economy, input, save)
│   │   ├── gameplay/     # Gameplay components
│   │   ├── ai/           # Worker AI
│   │   ├── ui/           # UI components
│   │   └── world/        # World generation
│   ├── data/             # Data resources
│   └── assets/           # Game assets
├── assets/               # Asset source files
│   ├── source/           # Blender files
│   ├── scripts/          # Asset generation scripts
│   └── manifests/        # Asset manifests
├── scripts/              # Build and tooling scripts
├── .github/workflows/    # CI/CD workflows
└── docs/                 # Documentation
```

## Asset Pipeline

### 3D Asset Generation

Assets are procedurally generated using Blender Python scripts for consistent quality and reproducibility.

**Generated Assets:**
- `SM_DrillExtractor.glb` - Industrial drill machine with PBR materials
- `SM_ConveyorBelt.glb` - Conveyor belt segment with rollers
- `SM_MineCart.glb` - Ore transport cart with wheels
- `SM_TunnelSegment.glb` - Underground tunnel module
- `Ore_*.glb` - Resource nodes (Stone, Coal, Copper, Iron, Gold, Crystal)
- `CHAR_Worker.glb` - Worker character with proper proportions

**Asset Features:**
- 3 LOD levels (LOD0: 100%, LOD1: 50%, LOD2: 25%)
- Simplified collision meshes
- PBR materials with principled BSDF shaders
- Smart UV unwrapping
- Triangle budgets enforced per asset type
- Naming conventions (SM_, CHAR_, Ore_ prefixes)

### Validation

All assets are validated for:
- GLB/glTF structure validity
- File size limits (< 10MB)
- Triangle count within budgets
- LOD presence
- Material definitions
- Naming conventions

```bash
# Run asset generation (requires Blender)
blender --background --python assets/scripts/generate_assets.py

# Validate generated assets
python3 assets/scripts/validate_assets.py
```

## CI/CD

### Workflows

| Workflow | Description | Triggers |\n|----------|-------------|----------|\n| `validate.yml` | Project structure, GDScript syntax, data files | push, PR |\n| `assets.yml` | Blender asset generation and validation | asset changes |\n| `android.yml` | Android APK build and verification | push to main |\n\n### Artifacts

- `generated-3d-models`: All GLB asset files\n- `asset-manifests`: JSON manifests with metadata\n- `asset-validation-report`: Detailed validation results\n- `mining-tycoon-android`: Built APK\n- `build-metadata`: Build logs and diagnostics

## Getting Started

### Prerequisites

- Godot 4.2+ (with Android export templates)
- Android SDK & NDK
- JDK 17+
- Git

### Local Development

1. Clone the repository
2. Open `project/project.godot` in Godot
3. Run the project

### Building Android APK

```bash
# Via GitHub Actions (recommended)
# Push to main branch or trigger workflow_dispatch

# Local build (requires full Android setup)
cd project
godot --headless --export-debug "Android" ../build/mining_tycoon.apk
```

## Game Systems

### Core Loop
1. Enter the mining operation
2. Mine resources manually or with workers
3. Collect and transport resources
4. Process raw materials
5. Store or sell resources
6. Earn money and upgrade
7. Expand to deeper levels
8. Discover rare resources
9. Prestige for bonuses

### Resources

| Rarity | Resources |
|--------|-----------|
| Common | Stone, Coal, Copper, Iron |
| Uncommon | Silver, Gold, Quartz |
| Rare | Platinum, Emerald, Ruby, Sapphire |
| Very Rare | Diamond |

### Underground Depths

| Depth | Environment | Resources |
|-------|-------------|-----------|
| 0-4 | Surface/Earth | Stone |
| 5-9 | Shallow Mines | Coal |
| 10-14 | Copper Veins | Copper |
| 15-24 | Iron Deposits | Iron |
| 25-34 | Silver Lodes | Silver, Quartz |
| 35-49 | Gold Rush | Gold |
| 50-54 | Platinum Strata | Platinum |
| 55-59 | Crystal Caverns | Emerald |
| 60-64 | Ruby Depths | Ruby |
| 65-79 | Sapphire Chambers | Sapphire |
| 80+ | Diamond Core | Diamond |

## CI/CD

### Workflows

- **validate.yml**: Project structure and script validation
- **android.yml**: Android APK build and verification

### Artifacts

- `mining-tycoon-android`: Built APK
- `build-metadata`: Build logs and diagnostics

## License

ISC

## Credits

Built with Godot Engine - https://godotengine.org
