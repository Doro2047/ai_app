# Performance Profiling Guide

## Overview
This guide explains how to profile the AI Apps Flutter application using Flutter DevTools.

## Prerequisites
- Flutter SDK >= 3.41.0
- Chrome browser (for DevTools web UI)
- Running app instance (debug or profile mode)

## Quick Start

### 1. Run the app in profile mode
```bash
flutter run --profile -d windows
```

### 2. Launch DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Or use the built-in DevTools:
```bash
flutter run --profile -d windows --observatory-port=8888
# Then open chrome://inspect in Chrome
```

## Key Profiling Areas

### Memory Analysis
1. Open DevTools → Memory tab
2. Take a snapshot before and after heavy operations
3. Look for:
   - Growing heap size (memory leak indicator)
   - Large number of duplicate objects
   - Unreleased controllers/streams

### CPU Analysis
1. Open DevTools → CPU Profiler tab
2. Record a profile during heavy operations
3. Look for:
   - Long frames (>16ms for 60fps)
   - Jank in build methods
   - Synchronous file I/O on main thread

### Widget Rebuild Analysis
1. Open DevTools → Widget Inspector
2. Enable "Track widget rebuilds"
3. Look for:
   - Unnecessary rebuilds of large widget subtrees
   - BlocBuilder rebuilding entire page instead of specific widgets

## Known Performance Concerns

### 1. File Scanning (High Priority)
- **Issue**: File scanning runs on main thread
- **Impact**: UI freezes during scan of large directories
- **Mitigation**: Use IsolateHelper (already created at `lib/core/utils/isolate_helper.dart`)
- **How to verify**: Scan a directory with 10000+ files, check for jank

### 2. Hash Calculation (High Priority)
- **Issue**: MD5 hash calculation blocks main thread
- **Impact**: UI unresponsive during file dedup
- **Mitigation**: Use IsolateHelper.runWithProgress for hash computation
- **How to verify**: Run file dedup on 1000+ files, check CPU profiler

### 3. Theme Switching (Medium Priority)
- **Issue**: Nested BlocBuilder rebuilds entire MaterialApp
- **Impact**: Brief freeze during theme/skin change
- **Mitigation**: Consider using BlocSelector for fine-grained rebuilds
- **How to verify**: Switch themes rapidly, check frame times

### 4. App Startup (Low Priority)
- **Issue**: Sequential async initialization in main()
- **Impact**: Slower cold start
- **Mitigation**: Parallelize independent init tasks
- **How to verify**: Measure time from launch to first frame

## Benchmark Commands

### Run with performance overlay
```bash
flutter run --profile -d windows --profile
```
Then press 'P' in the terminal to toggle performance overlay.

### Run with timeline tracing
```bash
flutter run --profile -d windows --trace-startup
```

### Run integration tests with tracing
```bash
flutter drive --profile -d windows --trace-startup ^
  --driver=test_driver/integration_test.dart ^
  --target=integration_test/app_test.dart
```

## Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| Cold start time | < 2s | TBD |
| Frame render time | < 16ms | TBD |
| Memory usage (idle) | < 100MB | TBD |
| Memory usage (scanning 10K files) | < 300MB | TBD |
| Theme switch time | < 100ms | TBD |
