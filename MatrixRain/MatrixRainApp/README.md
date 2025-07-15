# Matrix Rain App

A cross-platform Matrix Rain animation app for iOS and watchOS.

## Features

- Beautiful Matrix-style digital rain animation
- Runs on both iPhone and Apple Watch
- Shared codebase between platforms
- Start/Stop control

## Requirements

- Xcode 15+
- iOS 16.0+
- watchOS 9.0+

## Setup

1. Open the project in Xcode:
   ```bash
   open -a Xcode MatrixRainApp
   ```

2. Select the MatrixRainApp scheme and an iPhone simulator
3. Click the Run button (▶️) to build and run the iOS app
4. Select the MatrixRainWatchApp scheme and a Watch simulator
5. Click the Run button (▶️) to build and run the watchOS app

## Project Structure

- `Shared/` - Contains shared code between iOS and watchOS
  - `MatrixModel.swift` - The shared data model
- `iOS/` - iOS-specific code
  - `MatrixRainView.swift` - Main iOS view
- `watchOS/` - watchOS-specific code
  - `MatrixRainWatchView.swift` - Main watchOS view

## Using XcodeBuildMCP

1. Make sure the XcodeBuildMCP server is running:
   ```bash
   cd /path/to/XcodeBuildMCP
   npx xcodebuild-mcp
   ```

2. The server will automatically detect your Xcode projects
3. You can monitor builds and run tests through the MCP interface
