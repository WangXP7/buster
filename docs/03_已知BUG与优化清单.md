# Nodebuster — 已知 BUG 与可优化点清单

> 逆向来源：`D:/REDACTED-DIR/Nodebuster`（Godot 4.2.2 发布版 exe+pck）
> 解包与重建工程：`D:/REDACTED-DIR/2026-07-23-19-24-50/Nodebuster-RE/`
> 源码基准：`D:/REDACTED-DIR/_reverse_tools/extracted/Scripts/`
>
> **本清单只记录、不修复。** 每条均标注文件与行号、现象、影响与建议，供后续修改批次参考。
> 严重度：🔴 高（会导致功能异常/数值错误）｜🟡 中（死代码/设计债务，影响维护与扩展）｜🔵 低（体验/健壮性边角）

---

## 一、确定的代码缺陷（死代码 / 逻辑错误）

### BUG-01 🔴 `BattleScene.gd` 转生 19 级被重复匹配，第二段永不可达
- **位置**：`Battle/BattleScene.gd` 第 323–330 行
- **代码**：
  ```gdscript
  elif State.curr_prestige == 19:
      s.enemy_xp = 54
      s.node_boost = 18
      s.bit_value = 40.0
  elif State.curr_prestige == 19:   # 重复！上面已命中，此段永远进不来
      s.enemy_xp = 58
      s.node_boost = 18
      s.bit_value = 50.0
  elif State.curr_prestige == 20:
      s.enemy_xp = 62
  ```
- **现象**：`match` 自上而下命中，第一个 `== 19` 命中后第二个 `== 19` 成为**死分支**。本应属于 19 级的数值（xp=58、bit_value=50）永远不会被赋给任何转生等级。
- **影响**：19→20 级的经验/比特价值出现断层（54→62，缺少 58/50 这一档），高周目数值曲线不连续。
- **建议**：第二个分支应为 `elif State.curr_prestige == 20:`（并把原 20 及之后整体后移），或直接删除重复段、确认 19 级的预期数值。

### BUG-02 🔴 `BattleScene.gd` 12–25 级敌人/BOSS 属性完全冻结，仅奖励缩放
- **位置**：`Battle/BattleScene.gd` 第 277–354 行（`else` 分支 + 13–25 覆盖块）
- **现象**：`setup_prestige()` 中 `else` 分支（覆盖 12 级及以上）写死了
  `enemy_base_health=1.5M`、`enemy_health_growth_per_sec=60000`、`enemy_base_damage=150000`、
  `enemy_damage_growth_per_sec=6000`、`boss_health=145000000`、`boss_damage=1000000`、
  `health_loss_per_sec=60000`、`enemy_speed_mod=2.2`。
  其后 13–25 级的覆盖块**只**改了 `enemy_xp` / `node_boost` / `bit_value`，**没有**再缩放上述任何一项。
- **影响**：转生 12 级与 25 级的 BOSS 血量同为 1.45 亿、每秒掉血同为 60000——高周目难度仅靠奖励（比特价值 8→720）区分，**战斗强度没有随转生提升**，明显是未完成的平衡表。
- **建议**：为 13–25 级补一张完整的属性递增表（或抽成公式），与 0–11 级的递增节奏一致。

### BUG-03 🔴 `EnemyDrop2.gd` 在 `_ready()` 里 `queue_free()`，脚本完全失效
- **位置**：`Enemy/EnemyDrop2.gd` 第 27 行（及第 34 行调试输出）
- **代码**：
  ```gdscript
  func _ready() -> void:
      rid = PhysicsServer2D.area_create()
      ...
      PhysicsServer2D.area_set_area_monitor_callback(rid, _test)
      queue_free()        # 出生后立刻自我销毁
  func _test(...): print("BBBBB")
  ```
- **现象**：任何 `EnemyDrop2` 实例在 `_ready()` 末尾被 `queue_free()` 销毁；且唯一回调只 `print("BBBBB")`。该脚本**无法产生任何掉落行为**。
- **影响**：纯废弃代码；若被误实例化会静默无效。同时 `print("BBBBB")` 会在发布版刷屏。
- **建议**：确认无引用后直接删除整个文件（见 BUG-04 关于另一套掉落实现）。

### BUG-04 🟡 `EnemyDrop.gd` 为被取代的遗留掉落实现，工程中无任何引用
- **位置**：`Enemy/EnemyDrop.gd`（class_name `EnemyDrop`）
- **现象**：全局检索 `EnemyDrop` / `EnemyDrop2` / `create_drop`，实际掉落路径是 `Battle/EnemyDropsCreator.gd`（经 `Refs.drop_creator.create_drop`），由 `PlayerCursor.gd:79` 拾取、`EnemySpawner.gd:263` 生成。
  `EnemyDrop.gd`（基于 `Area2D` 的高层实现）与 `EnemyDrop2.gd`（基于 `PhysicsServer2D` 的低层实现）**均未被实例化**。
- **影响**：两套并存的掉落架构，`EnemyDrop`/`EnemyDrop2` 是死重；阅读者容易误以为掉落走其中某条路径，增加维护成本。
- **建议**：删除 `EnemyDrop.gd` 与 `EnemyDrop2.gd`，仅保留 `EnemyDropsCreator.gd`（已在用的实现）。

### BUG-05 🟡 `test.gd` 是调试草稿脚本，却随发布版打包
- **位置**：`Scripts/test.gd`
- **代码**：仅含 `print("CCCC")`（`_physics_process`）与 `print("AAAA!")`（`_bla`），并引用 `$Area2D` / `Layers.bitmask`。
- **现象**：该文件未挂到任何场景/Autoload，但出现在 pck 内。
- **影响**：源码泄露与混淆；若被误挂载会输出调试噪声。
- **建议**：从工程与打包清单中移除。

### BUG-06 🔵 发布版残留调试 `print`
- **位置**：
  - `Enemy/EnemyDrop2.gd:34` → `print("BBBBB")`
  - `Scripts/test.gd:13,16` → `print("CCCC")` / `print("AAAA!")`
  - `Autoloads/MySteam.gd:5` → `print("Did Steam initialize?: %s" % response)`
- **影响**：运行时控制台噪音；`MySteam` 的打印还会把初始化响应暴露到日志。
- **建议**：统一移除或改用条件日志（`if OS.is_debug_build(): print(...)`）。

---

## 二、架构与可维护性（设计债务 / 可优化）

### OPT-07 🟡 `UpgradeProcessor.gain_upgrade` 巨型 `match`，数据与逻辑未分离
- **位置**：`Upgrades/UpgradeProcessor.gd` 第 6–197 行
- **现象**：90+ 个升级的效果全写在 `match upgrade.id:` 里，形如 `State.stats.damage += 1`、`State.stats.max_health += 4`。数值与分支硬编码在一起。
- **影响**：新增/调整升级必须同时改 `UpgradeStore`（数据）和这里（逻辑），极易漏改或错改；无法在外部表格/JSON 中平衡数值。
- **建议**：将每个升级的「效果函数 + 每级增量」数据化（例如 `Upgrade` 自带 `apply(stats, level)` 或效果描述表），`gain_upgrade` 改为查表分发。

### OPT-08 🟡 `UpgradeProcessor.check_upgrade_unlocked` 巨型并行 `match`，重复依赖图
- **位置**：`Upgrades/UpgradeProcessor.gd` 第 197–399 行
- **现象**：解锁前置依赖用第二个 `match` 硬编（`return connected["Damage1"] > 0` 等），与升级树结构、与 `gain_upgrade` 三处各自维护同一批 id。
- **影响**：三套 `match`（效果 / 解锁 / 里程碑）极易相互脱节——改了某个升级却忘了同步解锁条件，会导致「买不到」或「提前解锁」。
- **建议**：解锁依赖应直接由 `UpgradeNode.connected_nodes` 的结构推导，或在 `Upgrade` 数据里声明前置，避免手写第二份 `match`。

### OPT-09 🟡 两套掉落架构并存（见 BUG-04）
- 同上，建议删除遗留的 `EnemyDrop` / `EnemyDrop2`，统一到 `EnemyDropsCreator`。

### OPT-10 🟡 魔法数字散落，缺少集中配置
- **位置**（代表性）：
  - `BattleScene.gd` 转生全表（0–25 级的血量/伤害/速度/比特价值）
  - `BattleScene.gd:35` 血条宽度 `clamp(76+((get_max_health()-10)/8000.0)*124, 76, 200)`
  - `Systems/CryptoMine.gd:39–77` 37 级矿机速度表
  - `Battle/EnemySpawner.gd:52` 刷怪 `curr_spawn_delta` 累加逻辑中的常量
- **影响**：平衡数值无法集中调参，调一个数值要在多处对账。
- **建议**：抽出一个 `Balance` / `Tuning` 常量表或 `Resources/balance.tres`，所有数值引用它。

### OPT-11 🔵 `gain_upgrade(upgrade, level)` 的 `level` 参数从未被使用
- **位置**：`Upgrades/UpgradeProcessor.gd` 第 6 行签名，第 716–717 行调用处 `for level in upgrade.curr_level: Refs.upgrade_processor.gain_upgrade(upgrade, level)`
- **现象**：函数接收 `level` 但内部一律按固定增量叠加，未用 `level` 做任何区分。
- **影响**：无功能错误，但签名有误导性；若将来想做「每级效果递增」会被这个签名误导。
- **建议**：要么删除该参数，要么真正按 `level` 计算（如 `amount * (level+1)`）。

### OPT-12 🔵 多处遗留 `# TODO` / 待定注释
- `Battle/BattleScene.gd:406` `_on_boss_defeated` 上方 `# TODO`
- `Upgrades/UpgradeProcessor.gd:4` `# Maybe consider making this an Autoload...`
- `Enemy/Enemy.gd:66` `take_damage` 内 `# TODO: Move these out of this function, maybe?`
- `Systems/CryptoMine.gd:10` `processing: bool = true #TODO: Set this to false in main menu or w/e`
- **影响**：提示功能未完成或设计未定，修改时应先确认意图。

---

## 三、发行与运行（影响「可修改 / 可测试」）

### BUG-13 ✅ 历史问题：`MySteam.gd` 未订阅 Steam 时直接退出
- **状态**：已在 `batch-1-steam-offline` 修复，并由后续批次保留。
- **位置**：`Autoloads/MySteam.gd` 第 6–10 行
- **原始代码**：
  ```gdscript
  var is_owned: bool = Steam.isSubscribed()
  var family_shared: bool = Steam.isSubscribedFromFamilySharing()
  if not is_owned and not family_shared:
      print("User does not own this game")
      get_tree().quit()
  ```
- **原始现象**：若游戏不是通过 Steam 启动 / 当前账号未订阅该 AppID（3107330），`_ready()` 直接 `quit()`。
- **当前行为**：`MySteam.gd` 已加入 Steam 单例、初始化状态和所有权门控；Steam 不可用时进入离线/非 Steam 路径，不再阻塞编辑器测试。
- **剩余边界**：工程仍有直接引用 `Steam` 全局类的路径，因此 GodotSteam GDExtension 必须保留并成功加载，不能通过删除扩展实现离线运行。

### BUG-14 🟡 `CryptoMine` 仅「游戏开着」时累积，无真正离线（关游戏）收益
- **位置**：`Systems/CryptoMine.gd` 第 15–22 行 + `Autoloads/State.gd:104–106`（`_process` 每帧调用 `crypto_mine.process(delta)`）
- **现象**：挖矿依赖每帧 `delta` 推进；游戏关闭即停止。存档只记录 `mine_level` 与 `curr_bits`，**没有基于真实墙钟的离线追赶**。
- **影响**：玩家预期「放置/idle 游戏关掉也在赚」，实际关掉游戏矿机完全停摆。
- **建议**：在 `save()` 记录时间戳，`load_save()` 时按离线时长补算（需配合 BUG-13 的 `processing` 门控，先把 `processing` 默认/在合适时机置位）。

---

## 四、行为观察（可能为设计意图，需确认）

### OBS-15 🔵 低转生周目不刷 BOSS
- **位置**：`Battle/BattleScene.gd` 第 37–39 行
  ```gdscript
  if State.curr_prestige < State.max_prestige:
      progress_bar.hide()
      boss_spawned = true
  ```
- **现象**：当当前转生低于历史最高转生时，`boss_spawned=true`、进度条隐藏 → BOSS 永远不会生成。该周目只能靠「死亡」或「手动 Terminate」结束。
- **影响**：重刷旧周目 = 无限刷怪直到阵亡，无法「通关」拿 Core（Core 仅在最高转生击败 BOSS 时获得，符合设计）。属可能意图，但体验上缺少明确的「结束/结算」入口。
- **建议**：确认是否为预期；若是，可给低周目也提供一个明确的结算/返回商店按钮。

### OBS-16 🔵 存档无版本迁移，重命名属性会静默损坏
- **位置**：`Autoloads/State.gd` 第 151–169 行（`save()` 写 `save["version"] = 0` 但 `load_save()` 从不读取版本号）
- **现象**：存档用 `inst_to_dict(self)` 全量序列化，`load_save()` 用 `get_property_list()` + `set()` 反射回填。版本号写死 0 且未被消费。
- **影响**：一旦未来修改 `State` 的属性名/结构，旧存档按新结构 `set` 会丢失字段或产生默认值，且无迁移路径。
- **建议**：在 `load_save()` 中读取并比对 `version`，做字段迁移；或将存盘结构与运行时结构解耦（专用 SaveData 类）。

---

## 五、快速索引（按文件）

| 文件 | 行号 | 问题 | 严重度 |
|---|---|---|---|
| Battle/BattleScene.gd | 323–330 | 转生 19 级重复匹配（死分支） | 🔴 |
| Battle/BattleScene.gd | 277–354 | 12–25 级敌/BOSS 属性冻结 | 🔴 |
| Battle/BattleScene.gd | 37–39 | 低周目不刷 BOSS | 🔵 |
| Enemy/EnemyDrop2.gd | 27, 34 | `_ready` 里 queue_free + 调试 print | 🔴 |
| Enemy/EnemyDrop.gd | 全文 | 遗留掉落实现，无引用 | 🟡 |
| Scripts/test.gd | 全文 | 调试草稿脚本随包发布 | 🟡 |
| Upgrades/UpgradeProcessor.gd | 6–197 | gain_upgrade 巨型 match | 🟡 |
| Upgrades/UpgradeProcessor.gd | 197–399 | check_upgrade_unlocked 巨型 match | 🟡 |
| Upgrades/UpgradeProcessor.gd | 6 | level 参数未使用 | 🔵 |
| Systems/CryptoMine.gd | 10,15 | 矿机无离线收益 + TODO 门控 | 🟡 |
| Autoloads/MySteam.gd | 6–10 | 非 Steam 直接退出 | 🔴 |
| Autoloads/MySteam.gd | 5 | 调试 print | 🔵 |
| Autoloads/State.gd | 151–169 | 存档无版本迁移 | 🔵 |
| Enemy/Enemy.gd | 66 | TODO 注释 | 🔵 |

---

*生成于逆向重建工程 `Nodebuster-RE`，与 `01_项目结构与文件功用.md`、`02_游戏设计文档_GDD.md` 配套。*
