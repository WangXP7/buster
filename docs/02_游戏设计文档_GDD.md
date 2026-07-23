# Nodebuster —— 反推游戏设计文档（GDD）

> 本 GDD 由**逆向源码反推**而成（非官方原始设计稿），忠实反映当前 Steam 版本的实际实现与数值。
> 类型：Roguelite 生存射击 × 放置养成 ｜ 引擎：Godot 4.2.2 ｜ 平台：Steam(PC) ｜ AppID 3107330

---

## 1. 高层概念（High Concept）

**一句话**：你的鼠标就是一台"节点破坏者"，在 480×270 的赛博网络空间里不断脉冲攻击涌来的几何敌人，收集资源，在庞大的升级树中变强，通过"转生(Prestige)"层层拔高难度，最终在实验室里造出"神之病毒"通关。

- **核心体验**：割草爽快感 + 数值成长的复利快感 + "再玩一局"的放置挂机循环。
- **视觉母题**：极简几何 + 低分辨率像素 + CRT/Glitch 后期 + 赛博/黑客主题（Bits/Nodes/Cores/病毒）。
- **操作**：**纯鼠标**。移动鼠标 = 移动角色；攻击是**全自动**按攻速触发的方形范围脉冲。极低操作门槛。

---

## 2. 核心玩法循环（Core Loop）

```
        ┌────────────────── HOME（商店/家园）──────────────────┐
        │  用资源在升级树买强化 · 挖矿 · 领里程碑 · 造病毒        │
        └───────────────┬───────────────────────▲──────────────┘
                        │ Breach（可选转生等级）  │ 结算：带走本局资源
                        ▼                         │
        ┌────────────────── BATTLE（战斗）─────────┴──────────────┐
        │ 鼠标走位躲伤害 · 自动脉冲清敌 · 捡掉落 · 升级得SP · 打Boss │
        │ 结束条件：血量归零(败) / 击败Boss(胜, 进入下一转生) / 主动终止 │
        └──────────────────────────────────────────────────────────┘
```

- **一局(session)时长**：由玩家血量与敌人成长曲线共同决定，通常几分钟到十几分钟；玩家可随时点 **Terminate** 主动结束并保留已收集资源。
- **正反馈**：本局资源 → 商店变强 → 下一局活更久 / 打过 Boss → 解锁更高转生 → 更高资源产出。
- **放置维度**：Crypto Mine 在后台把 Bits 持续转成 Netcoin（即使不战斗也在产出），构成 idle 层。

---

## 3. 资源经济（Economy）

六种资源（`ResourceType`），颜色即身份：

| 资源 | 颜色 | 来源 | 稀有度/用途 |
|---|---|---|---|
| **Bits** | 🔴 红 | 红色敌人掉落（最常见） | 主消耗货币，升级树大量基础项 |
| **Nodes** | 🔵 蓝 | 蓝色敌人掉落（需升级提升出现率） | 中级货币，进阶升级 |
| **Cores** | 🟣 紫 | 击败 Boss（**每个转生等级仅 1 个**） | 稀缺，解锁攻速/体型/浮游炮等关键节点 |
| **SP** | 🔷 亮蓝 | 战斗中**升级**获得（每级 +1） | 稀缺，解锁脉冲弹/闪电链等强力节点 |
| **Netcoin** | 🟢 绿 | Crypto Mine 把 Bits 换算而来 | 高级货币（小数），高血量/伤害/护甲 |
| **Processors** | 🟡 黄 | 黄色敌人掉落（极稀有，需解锁） | 极稀缺，升级矿机 + 里程碑 |

> 设计意图：多币种形成**多条平行成长线**，把"打红怪"（量）、"打蓝怪"（质）、"打 Boss"（转生）、"升级"（时长）、"挂机挖矿"（idle）、"打黄怪"（运气/深度）解耦为不同追求目标，避免单一刷法。

**资源存储规则（`State.gd`）**：所有资源 setter 都 `max(val,0)` 防负；首次 >0 时置对应 `xxx_unlocked=true`（用于 UI 渐进解锁）。`total_bits/total_nodes` 累计总量（成就用）。

---

## 4. 战斗系统详解

### 4.1 玩家（`PlayerCursor.gd`）
- **角色即鼠标**：每帧把角色 clamp 在 480×270 视口内并贴到鼠标位置。
- **自动攻击**：`attacks_per_sec = 0.5 基础 ×(1+攻速加成)`，累计到 1.0 触发一次 `attack()`。
- **attack() 流程**：
  1. `box_cast` 以角色的方框范围（`player_size`）检测命中的所有敌人（最多 128）。
  2. **伤害公式**：
     `damage = (基础伤害 + 最大血量×max_health_damage) × (1 + 命中数×damage_mod_per_enemy)`
     - 命中越多敌人，单体伤害越高（"connection buster" 越围越痛）。
     - 对 Boss 额外 `×(1+boss_damage_mod)`。
     - 暴击：`wflip(crit_chance)` 命中则 `×(1+crit_damage)`。
     - 目标状态加成（在 `Enemy.take_damage`）：满血敌 `+undamaged_mod`；≤50% 血敌 `+execute_mod`；本局时长 `×damage_mod_per_sec`（学习型成长）。
  3. **护甲反伤**：每次攻击玩家也会被命中的敌人反伤，实际掉血 `= max(敌伤害 - 总护甲, 0)`。
     `总护甲 = (armor + 最大血量×max_health_armor) × armor_mod`，其中 `armor_mod = 1 + 命中数×armor_mod_per_enemy (+ focus_armor_mod 当命中≤8) (+ 时长×armor_mod_per_sec)`；对 Boss 再叠 `boss_armor` 与 `boss_armor_mod`。
  4. 攻击时向外发射脉冲弹（`create_pulse_bolts`）。
- **拾取**：`_physics_process` 用 `circle_cast(drop_pickup_radius)` 磁吸范围内掉落物。

### 4.2 敌人（`Enemy.gd` + `EnemySpawner.gd`）
- **形状即类型**（权重刷新，随转生解锁更多）：

| 形状 | 血量倍率 | 掉落倍率 | 经验倍率 | 特点 |
|---|---|---|---|---|
| Square | 1.0 | 1 | 1 | 基础方块 |
| SmallSquare | 0.6 | 1 | 1 | 小而快 |
| BigSquare | 5.0 | 3 | 4 | 大而肥（黄怪池排除） |
| Exploder | 1.0 | 1 | 1 | 死亡爆炸（需升级解锁刷新） |
| Pill | 1.0 | 1 | 1 | 波浪movement，朝速度方向 |
| Pentagon | 3.0 | 2 | 2 | 死亡分裂成 6 个小五边形 |
| PentagonSmall | 0.6 | 1 | 1 | 分裂产物 |
| Spiky | 2.0 | 4 | 2 | 高掉落、伤害 ×3 |

- **成长**：`enemy_base_health/damage` 每秒按 `growth_per_sec` 线性增长（越拖越难）。
- **敌色 = 掉落币种**：默认红(Bits)，`wflip(yellow_enemy_chance)` → 黄(Processors)，否则 `wflip(blue_enemy_chance)` → 蓝(Nodes)。
- **死亡结算**（`_on_enemy_died`）：
  - 掉落数 = `1 + (bit_boost/node_boost) `，再 `×drop_mult`，`wflip(bonus_drop_chance)` 则 ×2；`wflip(autocollect_chance)` 则直接入账不掉物。
  - 触发：永久最大血量偷取、击杀回血、Exploder 爆炸、Pentagon 分裂、`enemy_death_pulse_bolt_chance` 爆脉冲弹。
  - 给经验 `enemy_xp × xp_mult`。

### 4.3 生存压力（`BattleScene.gd`）
- 玩家血量**每秒持续流失** `health_loss_per_sec`（随转生急剧增大：P0=0.2 → P12=60000），必须靠击杀/命中/回血续命 → 制造"停不下来"的紧张感。
- **Boss**：非转生模式下进度条(`ProgressBar`)走满后刷 Boss；击败 Boss = 本局胜利 + 得 1 Core + 解锁下一转生。P18+ Boss 变彩虹色。

### 4.4 衍生武器/机制（升级解锁）
- **Pulse Bolts 脉冲弹**：攻击时向四周均分方向发射投射物；可增伤/增量/到期爆炸。
- **Auto Pulser 浮游炮**：自动追敌的无人机，周期性范围爆发；可增数量/体型/攻速/移速。
- **Lightning 连锁闪电**：命中时 `wflip(lightning_chance)` 触发，每 0.06s 跳到最近敌，`lightning_chains` 决定跳数。
- **Exploders 爆炸怪**：升级后敌群里混入死亡爆炸的圆形怪，形成连锁清屏。

---

## 5. 升级树（Progression Tree）—— 核心深度

`UpgradeStore.gd` 定义 **90+ 个升级**，`UpgradeProcessor.gd` 定义**效果**与**前置依赖**（`check_upgrade_unlocked`），构成一棵有向解锁图。

### 5.1 结构特征
- **多级升级**：多数升级有 `costs[]` 数组，可多次购买（如 Damage1 15 级、Armor5 20 级、Armor6 30 级）。
- **多币种门槛**：升级按资源类型分布——早期靠 Bits，关键节点卡 Cores/SP（稀缺），后期靠 Netcoin。
- **依赖解锁**：每个节点需前置节点达标才显示/可买（`connected["X"] > 0` 或 `>= max["X"]`），形成清晰的成长路径与"满级才开新枝"的节奏。
- **标签解锁**：`Milestones`、`CryptoMine`、`Laboratory` 三个升级分别解锁对应的商店标签页并触发 Steam 成就。

### 5.2 升级门类（按效果归类）
| 门类 | 代表升级 | 效果字段 |
|---|---|---|
| 直接伤害 | power/proficiency/potency/nodeblade/netblade | `damage` |
| 条件伤害 | first strike(满血)/last strike(残血)/giant slayer(Boss)/connection buster(密度) | `undamaged/execute/boss_damage/damage_mod_per_enemy` |
| 暴击 | crit chance / crit damage | `crit_chance/crit_damage` |
| 攻速/体型 | repeating / influence / domain expansion / b.i.g. | `attack_speed_mod/player_size(_mod)` |
| 生存-血量 | endurance→beyond（+4 → +10万） | `max_health` |
| 生存-护甲 | firewall→netarmor / blood armor(按血量) | `armor/max_health_armor` |
| 回复 | repair/salvaging/sapper/scaling regen/lifesteal | `health_regen/on_kill/on_hit/max_health_regen` |
| 掉落/刷怪 | crowding/swarming/plundering/node finder/auto-collect | `spawn_rate_mod/bonus_drop_chance/blue_enemy_chance/autocollect` |
| 衍生武器 | pulse bolts / auto pulser / lightning rod / exploders | 各自字段族 |
| 成长型 | learning(+1%伤害/秒) / growing(+1%护甲/秒) | `damage/armor_mod_per_sec` |
| 血量转化 | bloodblade(血→伤害) / blood armor(血→护甲) | `max_health_damage/armor` |
| 永久成长 | unending parasite(击杀永久+血) | `perma_max_health_on_kill` |
| Infinity 系列 | to infinity → singularity（9 个，描述全是 `???`，各 1 Core） | 隐藏彩蛋链，Infinity1 给巨额刷怪+永久血 |

> **设计意图**：升级树既是"数值成长"也是"叙事/彩蛋载体"（Infinity 系列 + 实验室病毒结局），把 build 构筑（暴击流/护甲反伤流/脉冲弹流/闪电流/血量转化流）与探索欲结合。

---

## 6. 转生系统（Prestige / "Breach"）

- 在商店点 **Breach** 进入战斗；若已解锁过转生（`max_prestige>0`）会弹出**转生等级选择器**（可选 0 ~ 已解锁上限，硬上限 25）。
- 每提升一个转生等级（`BattleScene.setup_prestige`）：
  - 敌人**基础血量/伤害/成长速率/移速/刷新种类/Boss 血量伤害**全面暴涨（示例）：

| 转生 | 敌基础血 | 血成长/秒 | Boss 血 | 血流失/秒 | 敌速 | 新增敌种 |
|---|---|---|---|---|---|---|
| 0 | 3 | 0.15 | 120 | 0.2 | ×1.0 | Square |
| 1 | 10 | 0.5 | 800 | 0.6 | ×1.0 | +Small/Big |
| 4 | 300 | 12 | 24,000 | 10 | ×1.3 | +Pill |
| 5 | 800 | 36 | 70,000 | 30 | ×1.5 | +Pentagon |
| 9 | 60,000 | 2,700 | 540万 | 2,400 | ×2.0 | +Spiky |
| 12 | 150万 | 60,000 | 1.45亿 | 60,000 | ×2.2 | (全部) |

  - 回报同步提升：`enemy_xp`、`bit_boost`（红怪额外掉 Bits）、`node_boost`、`bit_value`（每个 Bit 拾取价值，P7 起 >1，最高 P25 达 720）。
- **Core 获取规则**：只有在 `curr_prestige == max_prestige`（即挑战当前最高转生）击败 Boss 才 +1 Core，且 max_prestige 才 +1 → **Core 是转生进度的硬通货**，不能靠低转生刷。

> ⚠️ 注：P13~P25 的属性表存在明显的手工填表痕迹与一处重复分支（见 BUG 清单）。

---

## 7. 放置层：Crypto Mine（`CryptoMine.gd` + `CryptoMinePage.gd`）

- **换算**：`1 Bit = 0.00001 Netcoin`。玩家在矿场**存入 Bits**，矿机以 `curr_speed`（bits/秒）持续消耗并产出 Netcoin（`State._process` 每帧调用，**离场也在跑** → idle 产出）。
- **矿机升级**：花 **Processors（黄怪币）** 升级，速度按 37 级表增长：`5 → 10 → 20 → … → 128 万 bits/s`（level 36 封顶）。
- 存款档位：1k / 5k / 10k / 50k / 100k / 1M。
- 设计意图：把"打红怪囤 Bits"与"打黄怪升矿机"两条线用挂机产出（Netcoin）串起来，Netcoin 又是后期最强升级的货币 → 形成 **战斗↔放置** 的复利闭环。

---

## 8. 里程碑系统（`MilestoneStore.gd`）

- 25 个基于**累计击杀数**的成就（红怪 500→10万、蓝怪 10→8000、黄怪 5→15）。
- 达标后在里程碑页手动**领取**一次性资源奖励（Bits/Nodes/Processors），奖励随门槛升级（红怪 10万 → 100万 Bits）。
- 需先购买 `milestones` 升级解锁标签页。作用：给"刷同色怪"一个额外的阶段性目标与资源补给。

---

## 9. 等级与 SP（`XPBar.gd`）

- 战斗中击杀给经验，按 25 级查表曲线升级（`50 → 300 → … → 83000`，25 级后每级 +5000）。
- **每次升级 +1 SP**（战斗内即时反馈 + 全屏 "LEVEL UP" 特效 + 音效），SP 是解锁脉冲弹/闪电链等强力节点的稀缺货币。
- 25 级解锁 Steam 成就 `SP_25`。

---

## 10. 结局（`LabPage.gd` + `Ending.gd`）

- 解锁 Laboratory 后，向实验室**累计存入 1000 Netcoin** 即可"开发神之病毒"。
- 部署病毒 → 播放通关演出（"Deploying/Deployed virus" → glitch 全屏 → 截屏撕裂 → 制作人员表 → 回主菜单），并解锁 Steam 成就 `DEPLOY_GODVIRUS`。
- `State.virus_deployed` 存盘，通关后实验室页显示"已部署"。这是游戏的**主线终点/真结局**。

---

## 11. 存档系统（`Saver.gd`）

- 路径 `user://save.dat`，`var_to_str` 明文序列化（先写 `save_temp.dat` 再复制 → 防写坏的原子化技巧）。
- 存三块：`upgrades`（各升级等级）、`milestones`（领取状态）、`state`（资源/等级/转生/挖矿/统计）。
- **读档重算**：`Stats` 不存盘，读档时 `UpgradeStore.load_save` 遍历已购升级逐级 `gain_upgrade` **重新累加**出所有战斗属性 → 保证改数值/加升级后存档兼容。
- 触发点：进入商店/战斗、主菜单、窗口关闭均自动存。

---

## 12. 表现与氛围（Juice / Feel）

游戏"手感"投入极大，值得作为设计亮点保留：
- **弹簧反馈**（`Springer/Spring`）：几乎所有 UI 与命中都有挤压/回弹/旋转微动画。
- **屏震**（`Shaker/MyCamera`）：命中、爆炸、脉冲都触发相机抖动（可在设置调强度）。
- **后期**：CRT 扫描线 + Glitch + 辉光 bloom，强化赛博/复古质感。
- **音频**：50 路音效池 + 随机音高防腻；9 首 Lofi BGM 洗牌播放；转场/战斗用低通滤波做"闷/亮"氛围过渡。
- **打字机**：标题与转场文字逐字显示并配打字音。
- **低分辨率**：480×270 视口整数放大 → 统一像素风。

---

## 13. Steam 集成（`MySteam.gd`）

- 启动即 `steamInitEx(3107330)` 并校验所有权（含家庭共享），**未拥有直接退出**。
- 成就埋点（散落各处）：`MILESTONES / CRYPTO_MINE / THE_LAB / FIRST_SESSION / TOTAL_SESSIONS_50 / SP_25 / BITS_* / NODES_* / DEPLOY_GODVIRUS` 等；`storeStats()` 上报统计。

---

## 14. 设计者视角总结（可优化方向的锚点）

**优点**：手感极佳、成长曲线层次丰富（6 币种 × 90+ 升级 × 26 转生 × idle 挖矿）、纯鼠标零门槛、有真结局与彩蛋。

**结构性可优化点**（详见《03_已知BUG与优化清单》）：
- 升级效果与解锁依赖用巨型 `match` 硬编码在 `UpgradeProcessor` 里，新增/平衡升级需改两处 `match`，**数据与逻辑未分离**，扩展成本高。
- 转生属性表 P13~P25 手工填写、有重复/跳空分支，易出平衡漏洞。
- 存在废弃脚本（`test.gd`、`EnemyDrop2.gd`）与两套并存的掉落实现。
- 数值平衡（伤害/血量/护甲的指数膨胀）依赖大量魔法数字，缺少集中配置。

> 这些不是"bug"而是"可优化的架构与内容点"，适合作为后续优化批次的切入口。
