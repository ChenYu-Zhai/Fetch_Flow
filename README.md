<div align="center">
<img src="assets/logo/logo.png" alt="Fetch_Flow Logo" width="128"/>
<h1>Fetch_Flow</h1>
<p>
<strong>一个跨平台 AI 数据集采集工具，用于从 Civitai、Rule34 等在线画廊获取图像与提示词（Prompt）数据。</strong>
<strong>A cross-platform AI dataset collection tool for fetching image and prompt data from online galleries such as Civitai and Rule34.</strong>
</p>
<p>
<a href="#-english"><strong>English</strong></a> • <a href="#-简体中文"><strong>简体中文</strong></a>
</p>
<p>
<a href="https://github.com/ChenYu-Zhai/Fetch_Flow/releases "><img src="https://img.shields.io/github/v/release/ChenYu-Zhai/Fetch_Flow?style=for-the-badge " alt="Latest Release"></a>
<a href="https://github.com/ChenYu-Zhai/Fetch_Flow/actions/workflows/release_build.yml"><img src="https://img.shields.io/github/actions/workflow/status/ChenYu-Zhai/Fetch_Flow/release_build.yml?branch=main&style=for-the-badge " alt="Build Status"></a>
<a href="https://github.com/ChenYu-Zhai/Fetch_Flow/blob/main/LICENSE "><img src="https://img.shields.io/github/license/ChenYu-Zhai/Fetch_Flow?style=for-the-badge " alt="License"></a>
</p>
</div>

## 🇬🇧 English

Fetch_Flow is a high-performance data acquisition tool built with Flutter. It is engineered to aggregate media and metadata from multiple online galleries (e.g., Civitai, Rule34) into a unified interface, facilitating the efficient collection of AI datasets, specifically image-text pairs.

### ✨ Features

*   **Paired Data Downloading**: The core function allows for the synchronized download of media files (images, GIFs, videos) and their corresponding metadata (prompts, tags) as `.txt` files, ensuring dataset integrity.
*   **Multi-Source Aggregation**: Integrates multiple online galleries as data sources, enabling centralized data acquisition.
*   **Data Preview Interface**: A masonry grid layout is utilized for efficient review of potential dataset items. It supports smooth rendering of images, GIFs, and videos.
*   **Precise Data Filtering**: Provides source-specific filtering options (e.g., sort, period) and tag-based search capabilities for refining data queries.
*   **Cross-Platform Support**: Operates on Web and Windows, with future platform support planned.
*   **Technical Interactions**:
    *   Hover-to-preview for prompt and tag metadata.
    *   Asset inspection viewer with scroll-to-zoom and drag-to-pan functionality.
    *   Download manager with progress indicators for batch operations.
*   **Performance Optimization**: Engineered for efficient processing of large data volumes through multi-threaded parsing (Isolates), asset pre-caching, and UI element pre-rendering.

### 🎥 Demo

<div align="center">

**Data Source Preview Interface**
<br>
*A masonry layout for reviewing media from multiple sources before acquisition.*
<p align="center">
  <img src="assets/video/主界面展示.gif" width="700" alt="Main Interface Demo"/>
</p>

**Metadata Inspection and Download Operations**
<br>
*Hover to inspect metadata and initiate downloads.*
<p align="center">
  <img src="assets/video/底部功能栏位展示.gif" width="700" alt="Function Bar Demo"/>
</p>

**Dataset Filtering (Civitai)**
<br>
*Filter and sort content by period, favorites, and other criteria.*
<p align="center">
  <img src="assets/video/civitai过滤.gif" width="700" alt="Civitai Filtering Demo"/>
</p>

**Dataset Filtering (Rule34)**
<br>
*Tag-based search and filtering for targeted data acquisition.*
<p align="center">
  <img src="assets/video/rule34过滤.gif" width="700" alt="Rule34 Filtering Demo"/>
</p>

</div>

### 🚀 Quick Start

#### Download Releases

Pre-compiled executables are available on the [GitHub Releases page](https://github.com/ChenYu-Zhai/Fetch_Flow/releases).

#### Build from Source

Developers can build the project from source by executing the following steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ChenYu-Zhai/Fetch_Flow.git 
    cd Fetch_Flow
    ```

2.  **Install Flutter:**
    Ensure the Flutter SDK is installed and configured as per the [official documentation](https://flutter.dev/docs/get-started/install).

3.  **Get dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Generate code:**
    This project uses `freezed` and requires code generation via `build_runner`.
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

5.  **Run the application:**
    Specify the target platform (`chrome`, `windows`, etc.).
    ```bash
    # Run for Web
    flutter run -d chrome

    # Run for Windows
    flutter run -d windows
    ```

### 🔑 **Configuration**

Prior to operation, navigate to the settings page to input necessary authentication credentials (e.g., API Key). Certain data sources require valid configuration for API access.
<p align="center">
  <img src="assets\iamge\认证界面.png" width="700" alt="Configuration Interface"/>
</p>

### ❤️ Support This Project

This project is maintained independently. If you find it valuable, consider providing support through the following channels. Support contributes to the project's continued development and maintenance.

*   **Star on GitHub ⭐️**: A direct way to indicate the project's utility.
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

Fetch_Flow 是一款基于 Flutter 构建的高性能数据采集工具。它旨在将多个在线画廊（如 Civitai, Rule34）的媒体及元数据聚合至统一界面，以服务于 AI 数据集——特别是图像与提示词（Prompt）配对数据的高效搜集。

### ✨ 特性

*   **配对数据下载**: 核心功能，支持同步下载媒体文件（图像、GIF、视频）及其对应的元数据（提示词、标签），并保存为 `.txt` 文件，以确保数据集的完整性。
*   **多源聚合**: 集成多个在线画廊作为数据源，实现集中化的数据获取。
*   **数据预览界面**: 采用瀑布流布局，用于高效审查待采集的数据项，支持图片、GIF 和视频的流畅渲染。
*   **精确数据筛选**: 提供针对不同数据源的筛选选项（如排序方式、时间范围）和基于标签的搜索功能，用于精确化数据查询。
*   **跨平台支持**: 当前可在 Web 和 Windows 平台上运行，未来计划支持更多平台。
*   **技术性交互**:
    *   鼠标悬浮预览提示词与标签元数据。
    *   内置支持滚轮缩放和拖动平移的资产查看器。
    *   集成带进度指示的下载管理器，支持批量下载操作。
*   **性能优化**: 通过 Isolate 多线程解析、媒体资源预加载和 UI 组件预渲染等技术，对大规模数据处理流程进行了优化。

### 🎥 功能演示

<div align="center">

**数据源预览界面**
<br>
*用于在采集前审查多源媒体的瀑布流布局。*
<p align="center">
  <img src="assets/video/主界面展示.gif" width="700" alt="主界面演示"/>
</p>

**元数据审查与下载操作**
<br>
*悬浮审查元数据并发起下载任务。*
<p align="center">
  <img src="assets/video/底部功能栏位展示.gif" width="700" alt="功能栏演示"/>
</p>

**数据集筛选 (Civitai)**
<br>
*按时间范围、收藏数等标准筛选和排序数据。*
<p align="center">
  <img src="assets/video/civitai过滤.gif" width="700" alt="Civitai 筛选演示"/>
</p>

**数据集筛选 (Rule34)**
<br>
*基于标签的搜索和筛选，用于目标数据的精确获取。*
<p align="center">
  <img src="assets/video/rule34过滤.gif" width="700" alt="Rule34 筛选演示"/>
</p>

</div>

### 🚀 快速开始

#### 下载发行版

已编译的程序实体可从 [GitHub Releases 页面](https://github.com/ChenYu-Zhai/Fetch_Flow/releases )获取。

#### 从源码构建

开发者可依照以下步骤从源代码构建项目：

1.  **克隆仓库**:
    ```bash
    git clone https://github.com/ChenYu-Zhai/Fetch_Flow.git 
    cd Fetch_Flow
    ```

2.  **安装 Flutter**:
    确保已根据[官方文档](https://flutter.cn/docs/get-started/install)指引完成 Flutter SDK 的安装与配置。

3.  **获取依赖**:
    ```bash
    flutter pub get
    ```

4.  **生成代码**:
    本项目使用 `freezed`，需要通过 `build_runner` 生成相应代码。
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

5.  **运行应用**:
    指定目标平台（如 `chrome`, `windows`）。
    ```bash
    # 运行 Web 版本
    flutter run -d chrome

    # 运行 Windows 版本
    flutter run -d windows
    ```

### 🔑 **配置**

在执行操作前，请前往设置页面填写必要的认证信息（如 API Key）。部分数据源需要有效配置以访问其 API。
<p align="center">
  <img src="assets\iamge\认证界面.png" width="700" alt="配置界面"/>
</p>

### ❤️ 支持项目

本项目为独立维护。若您认为此项目有价值，可考虑通过下列渠道提供支持。支持将用于项目的持续开发与维护。

*   **在 GitHub 上 Star ⭐️**: 表明该项目效用的直接方式。
*   **通过 爱发电 (Afdian) 赞助**:
    <a href="https://afdian.com/a/hakimi_dev ">
    <img src="https://img.shields.io/badge/ 爱发电-@hakimi_dev-blue.svg?style=for-the-badge&logo=github-sponsors" alt="爱发电">
    </a>
*   **通过 Patreon 赞助**:
    <a href="https://www.patreon.com/c/hakimi_dev ">
    <img src="https://img.shields.io/badge/Patreon-@hakimi_dev-orange.svg?style=for-the-badge&logo=patreon " alt="Patreon">
    </a>
