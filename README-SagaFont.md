# SagaFont - HyperOS 全局沙加体字体模块

基于 [MFGA (MakeFontsGreatAgain)](https://github.com/Numbersf/MakeFontsGreatAgain) 模板，将主字体替换为沙加体。配合独立模块 [DisableMiFontOverlay 1.0.6](https://github.com/YuKongA/DisableMiFontOverlay/releases/tag/v1.0.6) 使用，将 HyperOS / MIUI 中英文等字体统一显示为「沙加体」。

两个模块分开安装，互不整合。本仓库只改字体模块，不修改 DisableMiFontOverlay。

## 字体文件

主字体位于：

```
system/fonts/SagaSans.ttf
```

安装时会硬链接为 MFGA 主字形 `100.ttf`–`900.ttf`，以及 HyperOS 常见的 `MiSans*` / `Roboto*` / `DroidSansMono.ttf` 文件名。`fonts.xml` 的 sans-serif / serif / monospace / 中日韩回退直接引用 `SagaSans.ttf`。

## 使用前检查（重要）

- 需要 Magisk 28.0+ 或 KernelSU 11986+。KernelSU 请关闭「默认卸载模块」。
- 请同时安装 [DisableMiFontOverlay v1.0.6](https://github.com/YuKongA/DisableMiFontOverlay/releases/tag/v1.0.6)，用于关闭小米字体 overlay。本字体模块不包含该项能力。
- 主题商店请使用系统默认字体。
- `system/fonts/SagaSans.ttf` 缺失或过小会中止安装。
- 若已安装旧版 MFGA 或 ColorOS 版 SagaFont，请先卸载（模块 ID 同为 SagaFont 时会覆盖安装）。

## 两个模块怎么配合

1. 刷入 `DisableMiFontOverlay_v1.0.6.zip`：Zygisk 关闭 `HAS_MIUI_VAR_FONT` / `MIUI_OPTIMIZE_ENABLED`，系统改走标准 `fonts.xml`。
2. 刷入本模块：按 MFGA 模板把主字形换成 `SagaSans.ttf`，并为 HyperOS 补齐 `miui` / `mipro` / `misans` 等别名。
3. 重启。

## 修改说明

- `fonts.xml`：以 MFGA 为模板。sans-serif / serif / monospace / 中日韩回退改为 `SagaSans.ttf`。为 HyperOS 补齐 `miui` / `mipro` / `misans` / `clock` / `mitype` 别名。
- `customize.sh`：在 MFGA 安装流程上要求存在 `SagaSans.ttf`，硬链接为 `100.ttf`–`900.ttf`、`DroidSansMono.ttf` 与常见 HyperOS UI 字体文件名。不扫描分区，不覆盖主题 / GMS / App 运行时字体。
- `search_dirs.sh`：保留独立 `product` / `system_ext` / `vendor` / `mi_ext` / `odm` 分区的 `fonts.xml` 挂载，供 HyperOS 使用。
- `module.prop`：HyperOS 字体模块，需配合 DisableMiFontOverlay 1.0.6。
