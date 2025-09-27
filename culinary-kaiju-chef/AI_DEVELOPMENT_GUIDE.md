# AI-Assisted Development Guide for Culinary Kaiju Chef

## 🎯 项目状态

✅ **架构完成** - 数据驱动、高性能、完全解耦的系统
✅ **核心系统** - ObjectPool、EventBus、数据管理器全部就位
✅ **MCP工具** - 三个顶级MCP服务器已配置
✅ **Godot 4.5** - 项目已在编辑器中成功打开

## 🛠️ 可用的AI工具

### 1. GDAI MCP Plugin (gdai-plugin)
- **用途**: 创建场景、节点、脚本，调试错误
- **最适合**: 实现新功能、修复代码错误
- **示例提示**: "Create a new enemy type with wobbling movement behavior"

### 2. Coding-Solo Godot MCP (godot-control)  
- **用途**: 运行项目、捕获调试输出、控制执行
- **最适合**: 测试性能、验证架构是否工作
- **示例提示**: "Run the project and check if enemy spawning works correctly"

### 3. ee0pdt Godot MCP (godot-editor)
- **用途**: 双向编辑器通信、高级场景操作
- **最适合**: 复杂的场景重构、批量操作
- **示例提示**: "Analyze the current scene structure and suggest optimizations"

## 🎮 下一步开发优先级

基于你完美的架构，AI应该按以下优先级协助开发：

### 阶段1: 验证核心循环 (当前阶段)
```
@mcp godot-control run the project and verify:
1. Player can move using WASD
2. Enemy spawning system works
3. Weapon firing system functions
4. XP collection and leveling works
5. Object pool is functioning correctly
```

### 阶段2: 完善敌人系统
```
@mcp gdai-plugin create new enemy types based on our EnemyData resources:
1. Implement the onion grunt enemy with basic AI
2. Add the tomato ranger with ranged attacks  
3. Create visual sprites for each enemy type
4. Test the separation algorithm performance with 100+ enemies
```

### 阶段3: 武器多样化
```
@mcp gdai-plugin expand the weapon system:
1. Implement the fan knife weapon (multi-directional)
2. Create the piercer weapon (penetrating shots)
3. Add weapon upgrade mechanics
4. Test weapon synergies and combinations
```

### 阶段4: UI与体验
```
@mcp gdai-plugin enhance the user experience:
1. Implement the upgrade screen with weapon selection
2. Add visual effects for hits and explosions
3. Create a proper HUD with health/XP bars
4. Add sound effects and background music
```

## 📋 测试检查清单

使用AI来验证每个系统：

- [ ] **性能测试**: 运行项目，生成500+敌人，确保60FPS
- [ ] **对象池测试**: 验证没有内存泄漏，对象正确回收
- [ ] **事件系统测试**: 确保EventBus事件正确触发和处理
- [ ] **数据驱动测试**: 修改.tres文件，确保游戏逻辑相应更新
- [ ] **碰撞层测试**: 验证物理层配置正确，没有错误的交互

## 🚀 AI提示模板

### 调试问题
```
@mcp gdai-plugin I'm seeing this error: [paste error]
Please analyze my project structure and fix the issue while maintaining the data-driven architecture.
```

### 性能分析
```
@mcp godot-control run the project with debug output enabled.
Monitor performance with 200+ enemies and report any bottlenecks.
```

### 功能实现
```
@mcp gdai-plugin implement [feature name] using our existing architecture:
- Use the established ObjectPool for any spawned objects
- Emit appropriate EventBus signals
- Store configuration data in Resource (.tres) files
- Follow the src/ vs features/ organization pattern
```

### 架构验证
```
@mcp godot-editor analyze the current project structure and verify:
1. All autoloads are properly configured
2. Scene organization follows the established pattern
3. No circular dependencies exist
4. Resource references use UID system correctly
```

## 💡 最佳实践提醒

当与AI协作时，始终强调：

1. **数据优先**: 任何新功能都应该先创建对应的Data资源
2. **对象池原则**: 频繁生成的对象必须使用ObjectPool
3. **事件解耦**: 模块间通信必须通过EventBus
4. **性能意识**: 任何涉及大量对象的操作都要考虑性能影响
5. **架构一致性**: 新代码必须遵循既定的src/和features/组织方式

## 🎯 成功标准

项目成功的标志：
- 屏幕上同时有500+敌人且保持60FPS
- 玩家可以体验完整的30分钟游戏循环
- 升级系统提供有意义的战略选择
- 代码库保持清晰、可维护的结构

---

*记住：你已经有了99%的架构。现在需要的是验证、填充内容、和打磨体验。AI工具将帮助你快速迭代而不破坏这个美丽的代码基础。*