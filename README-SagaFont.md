# SagaFont - HyperOS 全局沙加体字体模块

基于 [MFGA (MakeFontsGreatAgain)](https://github.com/Numbersf/MakeFontsGreatAgain) 与 SagaFont 1.0.4 修改的全局字体模块。配合独立模块 [DisableMiFontOverlay 1.0.6](https://github.com/YuKongA/DisableMiFontOverlay/releases/tag/v1.0.6) 使用，将 HyperOS / MIUI 中英文等字体统一显示为「沙加体」。

两个模块分开安装，互不整合。本仓库只改字体模块，不修改 DisableMiFontOverlay。

## 需要你做的：放置沙加体字体文件

1. 将你的沙加体字体文件（单文件，含中英文全字重）重命名为：
    ```
    SagaSans.ttf
    ```
2. 放入本模块目录：
    ```
    system/fonts/SagaSans.ttf
    ```

放置完成后即可打包刷入。

## 使用前检查（重要）

- 需要 Magisk 28.0+ 或 KernelSU 11986+。KernelSU 请关闭「默认卸载模块」。
- 请同时安装 [DisableMiFontOverlay v1.0.6](https://github.com/YuKongA/DisableMiFontOverlay/releases/tag/v1.0.6)，用于关闭小米字体 overlay。本字体模块不包含该项能力。
- 主题商店请使用系统默认字体。
- `system/fonts/SagaSans.ttf` 缺失或过小会中止安装。
- 若已安装旧版 MFGA 或 ColorOS 版 SagaFont，请先卸载（模块 ID 同为 SagaFont 时会覆盖安装）。

## 两个模块怎么配合

1. 刷入 `DisableMiFontOverlay_v1.0.6.zip`：Zygisk 关闭 `HAS_MIUI_VAR_FONT` / `MIUI_OPTIMIZE_ENABLED`，系统改走标准 `fonts.xml`。
2. 刷入本模块：把 sans-serif / miui / mipro / misans 等族和 HyperOS 直载的 `MiSans*` / `Roboto*` 换成 `SagaSans.ttf`。
3. 重启。

## 修改说明

- `fonts.xml`：沿用 1.0.4 主族全部引用 `SagaSans.ttf`；为 HyperOS 补齐 `miui` / `mipro` / `misans` / `clock` / `mitype` 别名，指向 sans-serif。安装时挂到 `system/etc` 与独立 `product/etc` 的 `fonts.xml` / `font_fallback.xml`。
- `customize.sh`：在 1.0.4 基础上扫描 system / product / system_ext / vendor / mi_ext / odm，将 HyperOS 系统 UI 直载的 `MiSans*` / `MiLan*` / `MiClock*` / `Mitype*` / `MiSerif*` / `MiuiEx*` / `Roboto*` 硬链接为沙加体。`.ttc` 与 emoji 补字不替换。本模块不含 Zygisk overlay 禁用。
- `fonts_list.yaml`：沿用 1.0.4 黑白名单。
- `module.prop`：更新为 HyperOS 字体模块，并注明需配合 DisableMiFontOverlay 1.0.6。
