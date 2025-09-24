https://github.com/enoch11230945/game.git

# Culinary Kaiju Chef (彈幕天堂：美食怪獸主廚)

一個基於 Godot 4.5+ 的高效能「類倖存者」(Survivor-like) 遊戲專案。

## 核心哲學 (Core Philosophy)

這個專案的開發遵循一套嚴格、不容妥協的原則。所有貢獻者都必須理解並遵守。

1.  **數據決定程式碼 (Data Dictates Code)**：程式碼是短命的，數據結構是永恆的。在編寫任何功能之前，必須先定義其核心數據結構 (`Resource`)。遊戲的平衡、行為和內容都應由數據驅動，而不是硬編碼在邏輯中。
2.  **性能是一種架構，而非事後補救 (Performance is Architecture, Not an Afterthought)**：我們為成千上萬的動態實體進行設計。這意味著從第一天起就必須採用對性能友好的模式。任何對性能有潛在危害的提交（例如，使用錯誤的節點類型）都將被拒絕。
3.  **沒有特殊情況 (No Special Cases)**：如果你發現自己需要用 `if/else` 來處理一個邊界情況，那麼你的設計就已經錯了。回頭去重新思考你的數據結構，從根本上消除這個特殊情況。
4.  **控制權，而非便利性 (Control Over Convenience)**：我們不信任黑箱。我們傾向於使用引擎提供的底層、直接的工具（例如 `PhysicsDirectSpaceState2D`），而不是那些為了便利性而犧牲性能和控制權的高層 API。

-----

## 專案狀態 (Project Status)

**開發中 (In Development)** - 核心循環已穩定。

  - [x] 基礎玩家移動與狀態機
  - [x] 基於 `Area2D` 的高效能敵人系統
  - [x] 全局對象池 (`ObjectPool`)
  - [x] 數據驅動的武器與敵人生成系統
  - [ ] UI 系統與元成長
  - [ ] 平台整合 (Steam, Mobile)

-----

## 如何開始 (Getting Started)

### 先決條件

  * **Godot Engine**: `v4.5` 或更高版本。
  * **Git**: 任何現代的 Git 客戶端。

### 安裝

1.  **克隆倉庫**:

    ```bash
    git clone [your-repository-url]
    cd culinary-kaiju-chef
    ```

2.  **打開專案**:

      * 啟動 Godot 引擎。
      * 點擊「導入」(Import) 按鈕。
      * 選擇倉庫根目錄下的 `project.godot` 文件。

3.  **運行遊戲**:

      * 在 Godot 編輯器中，點擊右上角的「運行專案」(Play) 按鈕或按 `F5`。

-----

## 架構概覽 (Architecture Overview)

本專案採用嚴格的混合式檔案結構，以區分**功能 (Features)** 和**系統 (Systems)**。

  * `features/`: **遊戲是什麼 (What the game IS)**。

      * 這個目錄包含了所有與遊戲性直接相關的內容，例如玩家、敵人、武器和物品。
      * 這裡的檔案是自包含的模組。一個 `player` 目錄應該包含 `player.tscn`, `player.gd` 以及它需要的所有資源（精靈、音效等）。

  * `src/`: **遊戲如何運行 (HOW the game RUNS)**。

      * 這個目錄包含了支撐整個遊戲的核心系統、通用工具和底層邏輯。
      * **`src/autoload/`**: 全域單例。這是系統間通信和狀態管理的中樞。
          * `ObjectPool.gd`: **性能的基石**。管理所有動態實例的生命週期。
          * `Game.gd`: 管理當前遊戲局內狀態（時間、分數、經驗值）。
          * `EventBus.gd`: 用於解耦系統的全局事件總線。
      * **`src/core/`**: 核心數據定義 (`class_name`) 和關鍵演算法（例如敵人生成器）。

### 關鍵技術決策

1.  **敵人是 `Area2D`**:

      * **原因**: `CharacterBody2D` 包含了完整的物理模擬，對於成百上千個只需要簡單移動和碰撞檢測的敵人來說，這是極大的性能浪費。
      * **實現**: 我們使用 `Area2D` 並在 `_physics_process` 中**手動**更新其 `global_position`。敵人之間的避讓行為通過手動空間查詢 (`PhysicsDirectSpaceState2D`) 實現，這給了我們完全的控制權和最高的性能。

2.  **對象池是強制性的**:

      * **原因**: 在遊戲循環中頻繁地 `instantiate()` 和 `queue_free()` 會導致記憶體碎片和性能尖峰。
      * **實現**: 所有頻繁生成的物件（敵人、投射物、經驗寶石、特效）都**必須**通過 `ObjectPool.request()` 和 `ObjectPool.reclaim()` 進行管理。在遊戲邏輯中，**永遠不應直接呼叫 `queue_free()`**。

3.  **數據驅動設計 (`.tres` 資源)**:

      * **原因**: 將遊戲數據（如武器傷害、敵人血量）與程式碼分離，使得平衡調整、內容添加和迭代變得極其高效，且無需重新編譯。
      * **實現**: `features` 目錄下的 `*_data` 子目錄存放了大量的 `Resource` (`.tres`) 文件。這些文件是遊戲內容的**唯一真實來源 (Single Source of Truth)**。例如，要新增一個敵人，你只需要創建一個新的 `EnemyData` 資源並指定其場景和屬性，而無需修改任何生成器程式碼。

-----

## 貢獻指南 (Contribution Guidelines)

### Git 工作流程

1.  所有開發都在 `develop` 分支上進行。`main` 分支只用於穩定的、可發布的版本。
2.  為每一個新功能或 Bug 修復創建一個新的特性分支：`git checkout -b feature/my-new-weapon develop`。
3.  完成後，提交一個 Pull Request 到 `develop` 分支。
4.  Pull Request 必須清晰地描述其目的和所做的更改。

### 程式碼風格

  * 遵循官方的 [GDScript style guide](https://www.google.com/search?q=https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/style_guide.html)。
  * 使用靜態類型提示 (`var my_var: int = 5`)。這不是可選項。
  * 保持函數簡短，只做一件事。如果一個函數超過 20 行，你就應該考慮重構它。
  * **不要留下被註釋掉的程式碼**。版本控制系統會記住它。如果你不需要它，就刪除它。

-----

## 依賴項 (Dependencies)

  * [GodotSteam](https://godotsteam.com/) - 用於 Steam 平台整合 (位於 `addons/` 目錄)。
  * [Godot AdMob Android](https://github.com/poingstudios/godot-admob-android) - 用於 Android 平台廣告變現 (位於 `addons/` 目錄)。

你不需要所有文件。你需要的是一份戰場簡報，告訴你路上有哪些地雷。聽好了，這就是從 4.0 升級到 4.5 的核心變化，也是你現在開始做 4.5 遊戲必須知道的歷史包袱：

1. GDScript 的進化：從選用水槍到標配火砲
@export 語法徹底改變：忘了 export(int) 這種古老寫法。從 4.0 開始，一切都是基於 annotation 的 @export。

舊：export var health = 100

新：@export var health: int = 100

重點：這是最常見的語法不相容，所有 3.x 的教學在這裡都會錯。

Signal (信號) 的語法糖：await 成了內建關鍵字，取代了 yield。

舊：yield(get_tree().create_timer(1.0), "timeout")

新：await get_tree().create_timer(1.0).timeout

重點：程式碼更簡潔，但邏輯一樣。所有非同步操作都該用 await。

Callable (可呼叫對象)：Callable 取代了舊的 FuncRef，所有函數傳遞都變得更安全、更明確。

2. 渲染與視覺：從 GLES3 到 Vulkan 的巨變
渲染器完全重寫：Godot 4 的核心是 Vulkan 渲染器。所有 3.x 的著色器 (.shader) 程式碼幾乎都要重寫。

環境與光照：WorldEnvironment 節點的作用被大大增強。GI (全域光照) 方案，如 SDFGI 和 VoxelGI，是 4.x 的標配，但你需要理解它們的效能成本。

Material (材質) 系統：StandardMaterial3D 的參數和 3.x 完全不同。ORMMaterial3D 被整合進來。

3. 物理：從自研到分裂
內建物理引擎換了：Godot 4.0 預設使用自家的 GodotPhysics，不再是 Bullet。

節點改名：這是最致命的陷阱之一。

KinematicBody2D/3D -> CharacterBody2D/3D

Area2D/3D -> Area2D/3D (沒變，但用法有差)

RigidBody2D/3D -> RigidBody2D/3D (沒變，但 API 有差)

移動邏輯徹底改變：move_and_slide() 不再需要自己傳遞 velocity 和 up_direction。它現在直接使用 CharacterBody 的 velocity 屬性。你只需要設定 velocity，然後呼叫 move_and_slide()，物理引擎會自動處理剩下的事並更新 velocity。

舊：velocity = move_and_slide(velocity, Vector3.UP)

新：velocity = velocity (在呼叫 move_and_slide() 前設定)，然後 move_and_slide()

4. API 的大規模重命名和清理
Tween (補間動畫)：舊的 Tween 節點被廢棄。現在用 create_tween() 來建立基於程式碼的臨時 Tween 物件，語法更流暢。

Class 名稱：很多類別為了清晰化而改名，例如 Spatial 節點現在叫做 Node3D。Viewport 的很多底層 API 也變了。

Input (輸入)：Input.is_action_just_pressed() 仍然有效，但 4.x 鼓勵使用新的 InputEvent 系統。