# Simple Head Physics

Version: ver0.1.0

## Overview

A simple cockpit camera extension for Assetto Corsa that provides basic head position tracking functionality.

## Features

- Lightweight head position management
- Easy integration with cockpit camera systems
- Lua-based implementation for Assetto Corsa

## Installation

### Option 1: Using Released Build (Recommended)

Drag and drop the released zip file into Content Manager.

### Option 2: Clone from Repository

1. Clone the repository to `<Your Assetto Corsa Folder>/extension/lua/cockpit-camera/simpleHP`
2. Set up the development environment by referring to the [ACC Lua SDK Wiki](https://github.com/ac-custom-shaders-patch/acc-lua-sdk/wiki)

## Usage

1. Open Content Manager → Settings → Custom Shaders Patch → Neck FX
2. Check "Active" for "Replace old csp implementation with a custom script"
3. Select "Simple Head Physics" from Scripts
4. Adjust parameters as needed

## Building for Release

Run `build.bat` to generate a Content Manager-compatible package:

```batch
build.bat
```

This script automatically structures the project files and creates a zip archive in the `./build` directory, ready to drag and drop into Content Manager.

## Files

- Core Lua scripts for camera control and head position tracking

---

# Simple Head Physics

バージョン: ver0.1.0

## 概要

Assetto Corsaの簡単なコックピットカメラ拡張機能で、基本的なヘッドポジション追跡機能を提供します。

## 機能

- 軽量なヘッドポジション管理
- コックピットカメラシステムとの簡単な統合
- Assetto Corsa用のLuaベース実装

## インストール

### オプション1: リリースビルドを使用（推奨）

リリースしたZIPファイルをContent Managerにドラッグアンドドロップします。

### オプション2: リポジトリからクローン

1. リポジトリを `<Assetto Corsaフォルダ>/extension/lua/cockpit-camera/simpleHP` にクローン
2. [ACC Lua SDK Wiki](https://github.com/ac-custom-shaders-patch/acc-lua-sdk/wiki) を参考に開発環境を構築

## 使用方法

1. Content Manager → Settings → Custom Shaders Patch → Neck FXを開く
2. 「Replace old csp implementation with a custom script」のActiveにチェック
3. Scriptsから「Simple Head Physics」を選択
4. 必要に応じてパラメータを調整

## リリース用ビルド

`build.bat` を実行してContent Manager互換パッケージを生成します：

```batch
build.bat
```

このスクリプトはプロジェクトファイルを自動的に構成し、`./build` ディレクトリにZipアーカイブを作成します。Content Managerにドラッグアンドドロップすぐに使用できます。

## ファイル

- カメラ制御とヘッドポジション追跡用のコアLuaスクリプト

