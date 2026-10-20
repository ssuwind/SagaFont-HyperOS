# SagaFont - HyperOS 全局沙加体字体模块

基于 [MFGA (MakeFontsGreatAgain)](https://github.com/Numbersf/MakeFontsGreatAgain) 与 SagaFont 1.0.4 修改的全局字体模块，适配 HyperOS / MIUI，将系统中英文等字体统一显示为「沙加体」。

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

- 本模块面向 **HyperOS / MIUI**。主题商店请使用系统默认字体。
- 需要 Magisk 28.0+ 或 KernelSU 11986+。KernelSU 请关闭「默认卸载模块」。
- `system/fonts/SagaSans.ttf` 缺失或过小会中止安装，避免开机缺默认字体。
- 若已安装旧版 MFGA 或 ColorOS 版 SagaFont，请先卸载（模块 ID 同为 SagaFont 时会覆盖安装）。
- 小米设备请关闭空字体模块，或删除主题商店的空字体 overlay。
- 首次刷入后若界面异常，在 Magisk/KSU 禁用本模块即可回退，不会改写系统分区。

## 修改说明

- `fonts.xml`：主字体族（sans-serif、serif、默认 fallback、lang="zh"/zh-Hans/zh-Hant/ja/ko）全部引用 `SagaSans.ttf`；HyperOS/MIUI 的 `miui`/`mipro`/`misans`/`clock`/`mitype` 作为独立 family 指向沙加体。安装时会把该 XML 挂到 `system/etc` 与 `product/etc` 的 `fonts.xml`/`font_fallback.xml`。`monospace`/`serif-monospace`、`source-sans-pro`、`casual`/`cursive`/`sans-serif-smallcaps` 等英文/数字字体族沿用 1.0.4 全局统一为 `SagaSans.ttf`。
- `customize.sh`：安装时扫描 system、独立 product/system_ext/vendor/mi_ext/odm 字体目录，将 HyperOS 系统 UI 直接加载的 `MiSans*`/`MiLan*`/`MiClock*`/`Mitype*`/`MiSerif*`/`MiuiEx*`/`Roboto*`，以及 emoji（`NotoColorEmoji*`）与多语言补字（`MiSansArabic*` 等）替换为沙加体硬链接。`.ttc` 仍跳过。独立分区文件会放到 Magisk/KSU 对应的 `product/`、`system_ext/` 等 overlay 路径。
- `system/etc/hosts`：沿用 SagaFont 1.0.4 原始 hosts。
- `hyperos_cover.sh` + `post-fs-data.sh`/`service.sh`：开机早期只覆盖主题字体；开机完成后硬链接覆盖 GMS `/data/fonts` 与各 App `files/fonts` 等目录。已装 Play Integrity Fix 时不自动禁用 GMS FontsProvider。图标字体与 `.ttc` 不替换。
- `fonts_list.yaml`：保留系统字体 XML 黑白名单，维持 HyperOS 字体配置兼容。
- `module.prop`：更新模块名/描述为 HyperOS 适配。
