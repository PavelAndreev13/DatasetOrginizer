# Dataset Organizer

<p align="center">
  <img src="DatasetOrganizer/Assets.xcassets/SwiftyForge.imageset/SwiftyForge.png" width="120" alt="SwiftyForge Logo">
</p>

<p align="center">
  A macOS desktop application by <strong>SwiftyForge</strong> that automatically sorts raw dataset files into labeled class folders based on their filenames — with no manual tagging required.
</p>

---

## Overview

Dataset Organizer is designed for machine learning practitioners and dataset curators who need to quickly structure large collections of audio, image, video, or text files into class-labeled directories ready for training pipelines.

Instead of manually sorting thousands of files, you point the app at your source folder, pick a file format, choose a destination, and let it do the work — either copying or moving files as needed.

---

## Features

- **Recursive folder scan** — finds files at any depth inside the source folder
- **Copy or Move mode** — keep originals intact (Copy) or relocate them (Move)
- **Automatic class detection** — extracts class labels directly from filenames
- **Unique filename generation** — prevents collisions when files share names across subfolders
- **Animated progress bar** — color-coded from red to green with a minimum 1.5s display
- **Non-blocking processing** — file operations run on a background thread; UI stays responsive
- **Five supported formats** — `.wav`, `.mp3`, `.jpeg`, `.mov`, `.txt`

---

## How It Works

### 1. File Naming Convention

The app reads the class label from the **last underscore-separated segment** of the filename (before the extension):

```
anything_ClassName.ext
```

| Filename | Detected Class |
|---|---|
| `recording_001_dog.wav` | `dog` |
| `sample_cat.mp3` | `cat` |
| `clip_0042_bird.mov` | `bird` |
| `data_hello_world.txt` | `world` |

Files that contain no underscore are skipped silently.

---

### 2. Step-by-Step Workflow

```
┌─────────────────────────────────────────────────┐
│  1. Select file format  (.wav / .mp3 / ...)     │
│  2. Select Source Folder                        │
│  3. Select Dataset Folder                       │
│  4. Choose Copy or Move mode                    │
│  5. Click "Distribute Files"                    │
└─────────────────────────────────────────────────┘
```

**What happens internally:**

1. The app recursively enumerates the source folder for files matching the selected extension.
2. For each file, it extracts the class name from the filename.
3. A subfolder named after the class is created inside the dataset folder (if it doesn't exist yet).
4. Each file is given a new unique name and copied or moved into its class subfolder.
5. Progress is reported in real time; the bar stays visible for at least **1.5 seconds**.

---

### 3. Output Structure

Given a source folder with these files:

```
SourceFolder/
├── audio_dog.wav
├── subdir/
│   ├── clip_cat.wav
│   └── rec_001_dog.wav
└── sample_bird.wav
```

The result in the dataset folder:

```
DatasetFolder/
├── dog/
│   ├── a3f1c2_audio.wav
│   └── 9d4e7b_001.wav
├── cat/
│   └── f2c8a1_clip.wav
└── bird/
    └── 3b5d9e_sample.wav
```

---

### 4. Filename Renaming Logic

Each moved or copied file is renamed to avoid collisions:

- If the original name contains a `-`:
  ```
  <6-char-id>-<original-suffix>.<ext>
  ```
- Otherwise:
  ```
  <6-char-id>_<original-name>.<ext>
  ```

The 6-character ID is derived from a UUID, making filename clashes practically impossible.

---

### 5. Copy vs Move Mode

| Mode | Behavior |
|---|---|
| **Move** *(default)* | Files are relocated from the source to the dataset folder. Originals are removed. |
| **Copy** | Files are duplicated into the dataset folder. Originals remain untouched. |

The active mode is shown in the UI with a labeled toggle and a distinct icon:
- `doc.on.doc` (blue) — Copy mode
- `arrow.right.doc.on.clipboard` (orange) — Move mode

---

### 6. Progress Bar

The progress bar fills left to right and smoothly transitions color:

```
  0%  ████░░░░░░░░░░░░░░░░░  50%  ░░░░░░░░░░  100%
  🔴 Red                    🟡 Yellow           🟢 Green
```

- Updates after each file is processed
- Always visible for a **minimum of 1.5 seconds**, even for small datasets
- File count is displayed below the bar: `Processed: N / Total`

---

## Supported File Types

| Category | Extensions |
|---|---|
| **Audio** | `.wav`, `.mp3`, `.aac`, `.flac`, `.ogg`, `.m4a`, `.aiff`, `.opus`, `.wma`, `.amr` |
| **Video** | `.mov`, `.mp4`, `.avi`, `.mkv`, `.wmv`, `.flv`, `.webm`, `.m4v`, `.mpeg`, `.ts` |
| **Image** | `.jpeg`, `.jpg`, `.png`, `.gif`, `.bmp`, `.tiff`, `.tif`, `.webp`, `.heic`, `.heif`, `.svg`, `.ico`, `.raw` |
| **Text & Data** | `.txt`, `.json` |

---

## Requirements

| Requirement | Version |
|---|---|
| macOS | 13.0 or later |
| Xcode | 15.0 or later |
| Swift | 5.9 or later |

---

## Project Structure

```
DatasetOrganizer/
├── DatasetOrganizer/
│   ├── DatasetOrganizerApp.swift     # App entry point
│   ├── ContentView.swift             # Main UI, ColorProgressBar view
│   ├── OrganizerViewModel.swift      # Business logic, file operations
│   ├── FileType.swift                # Supported file format enum
│   ├── Color+Theme.swift             # Brand color theme extension
│   └── Assets.xcassets/             # App icon, logo, theme colors
└── DatasetOrganizer.xcodeproj/
```

---

## Architecture

The app follows the **MVVM** pattern:

- **`OrganizerViewModel`** — `@Observable` class marked `@MainActor`. Manages all state (source/destination URLs, progress, mode) and dispatches file work via `Task.detached` to keep the main thread free.
- **`ContentView`** — Declarative SwiftUI view that binds directly to the view model. Contains the embedded `ColorProgressBar` view.
- **`FileType`** — Plain enum powering the format picker with `CaseIterable` and `Identifiable`.

---

## Notes

- If a file operation fails (e.g. due to permissions or a locked file), the error is printed to the console and processing continues with the remaining files.
- Files without an underscore in their name are skipped — they cannot be assigned to a class.
- The app does **not** require sandbox entitlements, so it has full access to the file system.
- Mac App Store distribution is not supported in the current configuration (`ENABLE_APP_SANDBOX = NO`).

---

## License

© SwiftyForge. All rights reserved.
