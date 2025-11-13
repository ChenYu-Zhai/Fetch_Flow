<div align="center">
<img src="assets/logo/logo.png" alt="Fetch_Flow Logo" width="128"/>
<h1>Fetch_Flow</h1>
<p>
<strong>一款现代化、优雅、跨平台的媒体浏览器，专为 Civitai、Rule34 等网站设计。</strong>
</p>
<p>
<a href="#-english"><strong>English</strong></a> • <a href="#-简体中文"><strong>简体中文</strong></a>
</p>
<p>
<a href="https://github.com/ChenYu-Zhai/Fetch_Flow/releases "><img src="https://img.shields.io/github/v/release/ChenYu-Zhai/Fetch_Flow?style=for-the-badge " alt="Latest Release"></a>
<a href="https://github.com/ChenYu-Zhai/Fetch_Flow/actions/workflows/release.yml "><img src="https://img.shields.io/github/actions/workflow/status/ChenYu-Zhai/Fetch_Flow/release.yml?branch=main&style=for-the-badge " alt="Build Status"></a>
<a href="https://github.com/ChenYu-Zhai/Fetch_Flow/blob/main/LICENSE "><img src="https://img.shields.io/github/license/ChenYu-Zhai/Fetch_Flow?style=for-the-badge " alt="License"></a>
</p>
</div>

## 🇬🇧 English

Fetch_Flow is a high-performance media browser built with Flutter, designed for content enthusiasts. It aggregates images and videos from multiple popular online galleries (like Civitai, Rule34) into a unified, beautiful interface, providing a smooth browsing, searching, and downloading experience.

### ✨ Features

*   **Multi-Source Aggregation**: Seamlessly switch and browse content from different websites within one app.
*   **Modern UI**: Masonry grid layout with smooth playback support for images, GIFs, and videos, offering an immersive browsing experience.
*   **Powerful Filtering & Searching**: Customized filtering options (e.g., sort, period) for different sources and a robust tag-based search.
*   **Cross-Platform Support**: Runs perfectly on Web, Windows, Android, and more to come.
*   **Advanced Interactions**:
    *   Preview Prompts or Tags on mouse hover.
    *   Immersive image preview with scroll-to-zoom and drag-to-pan.
    *   Reliable download feature with progress indicators.
*   **Performance First**: Ensures an extremely smooth scrolling and loading experience through various optimizations like Isolate-based parsing, media preloading, and widget pre-rendering.

### 🎥 Demo

<div align="center">

**Main Interface & Masonry Layout**
<br>
*A smooth masonry layout for browsing media from multiple sources.*
<p align="center">
  <img src="assets/video/主界面展示.gif" width="700" alt="Main Interface Demo"/>
</p>

**Bottom Function Bar & Interactions**
<br>
*Hover to preview tags, click for immersive view, and download with ease.*
<p align="center">
  <img src="assets/video/底部功能栏位展示.gif" width="700" alt="Function Bar Demo"/>
</p>

**Powerful Filtering (Civitai)**
<br>
*Filter and sort content by period, favorites, and more.*
<p align="center">
  <img src="assets/video/civitai过滤.gif" width="700" alt="Civitai Filtering Demo"/>
</p>

**Powerful Filtering (Rule34)**
<br>
*Advanced tag-based search and filtering options.*
<p align="center">
  <img src="assets/video/rule34过滤.gif" width="700" alt="Rule34 Filtering Demo"/>
</p>

</div>

### 🚀 Quick Start

#### Download Releases

You can download the latest version for your platform directly from the [GitHub Releases page](https://github.com/ChenYu-Zhai/Fetch_Flow/releases ).

#### Build from Source

If you are a developer, you can build and run the project from the source code by following these steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ChenYu-Zhai/Fetch_Flow.git 
    cd Fetch_Flow
    ```

2.  **Install Flutter:**
    Ensure you have the Flutter SDK installed and configured according to the [official documentation](https://flutter.dev/docs/get-started/install ).

3.  **Get dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Generate code:**
    This project uses `freezed` and requires running `build_runner`.
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

5.  **Run the app:**
    Choose your target platform (e.g., `chrome`, `windows`, `android`).
    ```bash
    # Run the Web version
    flutter run -d chrome

    # Run the Windows version
    flutter run -d windows
    ```

### 🔑 **Configuration**

Before use, please go to the settings page and fill in the necessary authentication information (e.g., API Key). Some data sources, such as Civitai and Rule34, require a correct configuration to work properly.
<p align="center">
  <img src="assets\iamge\认证界面.png" width="700" alt="主界面演示"/>
</p>

### ❤️ Support This Project

If you enjoy Fetch_Flow and find it helpful, please consider supporting my work. Your support is the greatest motivation for me to continue updating and maintaining the project!

*   **Star on GitHub ⭐️**: The easiest way to show your support!
*   **Sponsor via Afdian**:
    <a href="https://afdian.com/a/hakimi_dev ">
    <img src="https://img.shields.io/badge/ 爱发电-@hakimi_dev-blue.svg?style=for-the-badge&logo=github-sponsors" alt="Afdian">
    </a>
*   **Sponsor via Patreon**:
    <a href="https://www.patreon.com/c/hakimi_dev ">
    <img src="https://img.shields.io/badge/Patreon-@hakimi_dev-orange.svg?style=for-the-badge&logo=patreon " alt="Patreon">
    </a>

<br>

## 🇨🇳 简体中文

Fetch_Flow 是一款使用 Flutter 构建的高性能媒体浏览器，专为内容爱好者设计。它通过一个统一、美观的界面，聚合了来自多个流行在线画廊（如 Civitai, Rule34）的图片和视频内容，提供了流畅的浏览、搜索和下载体验。

### ✨ 特性

*   **多源聚合**: 在一个应用内无缝切换和浏览来自不同网站的内容。
*   **现代化 UI**: 瀑布流布局，支持图片、GIF 和视频的流畅播放，提供沉浸式的浏览体验。
*   **强大的筛选与搜索**: 针对不同数据源提供定制化的筛选选项（如排序、时间范围）和强大的标签搜索功能。
*   **跨平台支持**: 完美运行在 Web, Windows等多个平台，未来将支持更多。
*   **高级交互**:
    *   鼠标悬浮即可预览 Prompt 或 Tags。
    *   支持滚轮缩放和拖动平移的沉浸式图片预览。
    *   带进度指示的、可靠的下载功能。
*   **性能优先**: 通过 Isolate 多线程解析、图片预加载和 Widget 预渲染等多种优化手段，确保极致的滚动和加载性能。

### 🎥 功能演示

<div align="center">

**主界面与瀑布流**
<br>
*流畅的多源媒体瀑布流浏览体验。*
<p align="center">
  <img src="assets/video/主界面展示.gif" width="700" alt="主界面演示"/>
</p>

**底部功能栏与交互**
<br>
*悬浮预览标签、沉浸式看图、以及便捷的下载功能。*
<p align="center">
  <img src="assets/video/底部功能栏位展示.gif" width="700" alt="功能栏演示"/>
</p>

**强大的筛选功能 (Civitai)**
<br>
*按时间范围、收藏数等多种方式筛选和排序内容。*
<p align="center">
  <img src="assets/video/civitai过滤.gif" width="700" alt="Civitai 筛选演示"/>
</p>

**强大的筛选功能 (Rule34)**
<br>
*专业的标签搜索和高级筛选选项。*
<p align="center">
  <img src="assets/video/rule34过滤.gif" width="700" alt="Rule34 筛选演示"/>
</p>

</div>

### 🚀 快速开始

#### 下载发行版

您可以直接从 [GitHub Releases 页面](https://github.com/ChenYu-Zhai/Fetch_Flow/releases )下载适用于您平台的最新版本。

#### 从源码构建

如果您是开发者，可以按照以下步骤从源码构建和运行项目：

1.  **克隆仓库**:
    ```bash
    git clone https://github.com/ChenYu-Zhai/Fetch_Flow.git 
    cd Fetch_Flow
    ```

2.  **安装 Flutter**:
    请确保您已根据[官方文档](https://flutter.cn/docs/get-started/install )安装并配置好 Flutter SDK。

3.  **获取依赖**:
    ```bash
    flutter pub get
    ```

4.  **生成代码**:
    本项目使用了 `freezed`，需要运行 `build_runner` 来生成代码。
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

5.  **运行应用**:
    选择您希望运行的平台（例如 `chrome`, `windows`, `android`）。
    ```bash
    # 运行 Web 版本
    flutter run -d chrome

    # 运行 Windows 版本
    flutter run -d windows
    ```

### 🔑 **配置**

在使用前，请先前往设置页面填写必要的认证信息（如 API Key）。部分数据源（如 Civitai, Rule34）需要正确配置后才能正常使用。
<p align="center">
  <img src="assets\iamge\认证界面.png" width="700" alt="主界面演示"/>
</p>

### ❤️ 支持项目

如果您喜欢 Fetch_Flow 并觉得它对您有帮助，欢迎通过以下方式支持我的开发工作。您的支持是我持续更新和维护项目的最大动力！

*   **在 GitHub 上 Star ⭐️**: 这是最简单直接的支持方式！
*   **通过 爱发电 (Afdian) 赞助**:
    <a href="https://afdian.com/a/hakimi_dev ">
    <img src="https://img.shields.io/badge/ 爱发电-@hakimi_dev-blue.svg?style=for-the-badge&logo=github-sponsors" alt="爱发电">
    </a>
*   **通过 Patreon 赞助**:
    <a href="https://www.patreon.com/c/hakimi_dev ">
    <img src="https://img.shields.io/badge/Patreon-@hakimi_dev-orange.svg?style=for-the-badge&logo=patreon " alt="Patreon">
    </a>