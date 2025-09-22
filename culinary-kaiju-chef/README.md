# Culinary Kaiju Chef

一個「類倖存者」遊戲，玩家扮演巨大的廚師怪獸，對抗成群結隊的敵人。

## 專案結構

```
culinary-kaiju-chef/
├── assets/                    # 遊戲資源
│   ├── audio/                # 音效和音樂
│   ├── fonts/                # 字體
│   ├── graphics/             # 圖形資源
│   └── shaders/              # 著色器
├── features/                 # 遊戲功能模組
│   ├── enemies/              # 敵人系統
│   ├── items/                # 道具系統
│   ├── player/               # 玩家系統
│   └── weapons/              # 武器系統
├── src/                      # 核心系統
│   ├── autoload/             # 全域單例
│   ├── core/                 # 核心工具和數據
│   ├── main/                 # 主遊戲場景
│   └── ui/                   # 用戶界面
└── project.godot             # Godot專案配置
```

## 核心系統

### ObjectPool (物件池)
- 管理所有需要頻繁實例化和銷毀的物件
- 預填充物件以提高性能
- 避免使用 `instantiate()` 和 `queue_free()`

### EventBus (事件總線)
- 全域事件通信系統
- 解耦各個遊戲模組
- 支援玩家傷害、XP獲得、敵人死亡等事件

### EnemySpawner (敵人生成器)
- 基於時間軸的波次系統
- 支援圓形分佈生成
- 與物件池整合

## 運行遊戲

1. 打開 Godot 編輯器
2. 導入專案 (`culinary-kaiju-chef/project.godot`)
3. 運行主場景 (`src/main/main.tscn`)

## 測試模式

在 `main.gd` 中設置 `test_mode = true` 來啟用測試波次：
- 2秒後：5個敵人
- 10秒後：10個敵人
- 20秒後：15個敵人

## 控制

- **WASD** 或 **方向鍵**：移動
- **ESC**：退出遊戲
- **P**：暫停/恢復遊戲

## 技術特點

- **高性能架構**：使用物件池和空間查詢優化
- **模組化設計**：清晰的功能分離
- **事件驅動**：鬆耦合的系統通信
- **數據驅動**：使用資源文件管理遊戲數據
