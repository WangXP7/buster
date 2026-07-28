# Nodebuster 恢复工程

这是从 Windows Steam 发布包恢复并整理的 Godot 4.2.2 工程。当前 `main` 已具备可阅读、可编辑、可运行和可导出 Windows x86_64 开发包的状态；各阶段通过独立提交和标签保留。

## 快速开始

在仓库根目录执行：

```powershell
# 首次部署精确版本 Godot 与 Windows x64 导出模板
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Setup-DevEnvironment.ps1

# 检查环境
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Dev.ps1 doctor

# 打开编辑器
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Dev.ps1 editor

# 构建并验证 Release
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Dev.ps1 build -Configuration Release
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Dev.ps1 smoke -Configuration Release
```

构建产物默认位于 `build/windows/`；测试存档位于 `.runtime/`。两者均不进入 Git。

## 文档

- [项目结构与文件功用](docs/01_项目结构与文件功用.md)
- [反向游戏设计文档（GDD）](docs/02_游戏设计文档_GDD.md)
- [已知 BUG 与优化清单](docs/03_已知BUG与优化清单.md)
- [反编译与版本批次记录](docs/04_反编译与版本批次记录.md)
- [开发与构建环境](docs/05_开发与构建环境.md)

## 当前边界

- 支持 Godot `4.2.2.stable.official.15073afe3`、Windows x86_64。
- 必须保留随工程恢复的 GodotSteam Windows x64 GDExtension。
- 当前导出预设用于开发和验证，不包含原始签名、Steam depot 或已丢失的发布参数。
- EXE、PCK、TPZ、ZIP、`raw_pck/`、工具缓存和本地运行数据不得提交到普通 Git 历史。
