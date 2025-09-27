# 🧹 THE GREAT CLEANUP - Following Linus Torvalds Philosophy

## 📋 CLEANUP CHECKLIST (Based on prd3.txt guidance)

### ✅ PHASE 0: THE GREAT CLEANUP

**"I won't build a house on a garbage dump" - Linus Torvalds**

#### 🗑️ FILES TO DELETE (Redundant game versions)
- [x] CULINARY_KAIJU_CHEF.gd + .tscn
- [x] CULINARY_KAIJU_CHEF_COMPLETE.gd + .tscn  
- [x] CULINARY_KAIJU_CHEF_REAL.gd
- [x] ENHANCED_COMPLETE.gd + .tscn
- [x] ENHANCED_GAME.gd
- [x] FINAL_GAME_WITH_UPGRADES.gd + .tscn
- [x] PERFECT_GAME.gd + .tscn
- [x] ULTIMATE_GAME.gd + .tscn
- [x] ULTIMATE_COMPLETE_GAME.gd
- [x] FINAL_PLAYABLE_GAME.gd
- [x] All other redundant game files

#### 📁 KEEP ONLY ONE MAIN SCENE
- [x] Choose: **WORKING_ULTIMATE_GAME.gd** (most complete, 37K+ lines)
- [x] Rename to: **main.gd** 
- [x] Move to: **src/main/main.gd**
- [x] Update project.godot: `run/main_scene="res://src/main/main.tscn"`

#### 🏗️ CLEAN DIRECTORY STRUCTURE
```
src/
├── autoload/          # Global singletons (EventBus, ObjectPool, etc.)
├── core/              # Data resources (WeaponData, EnemyData)
├── main/              # Main game scene and controller
├── player/            # Player character and controls
├── enemies/           # Enemy systems and AI
├── weapons/           # Weapon systems and projectiles
├── ui/                # User interface components
└── utils/             # Utility scripts and helpers
```

#### 🗂️ MIGRATION PLAN
1. **Move all `features/` content to `src/`**
2. **Delete `features/` directory**
3. **Consolidate redundant systems**
4. **Update all scene references**

### ✅ PHASE 1: ARCHITECTURE AUDIT

#### 🔍 DATA-DRIVEN VERIFICATION
- [ ] Check: No hardcoded values in player.gd
- [ ] Check: No hardcoded values in enemy scripts
- [ ] Check: All stats come from .tres resources
- [ ] Check: WeaponData.gd properly structured
- [ ] Check: EnemyData.gd properly structured

#### 🔗 SIGNAL BUS VERIFICATION  
- [ ] Check: No cross-scene get_node() calls
- [ ] Check: All communication via EventBus
- [ ] Check: Player doesn't directly reference UI
- [ ] Check: Enemies don't directly reference managers

### ✅ PHASE 2: CORE GAME LOOP VERIFICATION

#### 🎮 BASIC FUNCTIONALITY
- [ ] Player movement works (WASD)
- [ ] Enemy spawning works (one type)
- [ ] Weapon system works (one weapon)
- [ ] XP collection works
- [ ] Level up system works
- [ ] Upgrade selection works

#### 🎯 GAME JUICE (Fun Factor)
- [ ] Enemy death effects
- [ ] Weapon impact feedback
- [ ] Level up audio/visual
- [ ] Combat satisfaction

## 🎯 SUCCESS CRITERIA

**A project is clean when:**
1. ✅ Only ONE main game scene exists
2. ✅ File structure follows clear conventions
3. ✅ All data is resource-driven (.tres files)
4. ✅ All communication uses EventBus signals
5. ✅ Core game loop is fun and responsive

**"Talk is cheap. Show me the clean code." - Linus Torvalds**