# Second Brain Clipper

An Android app that captures web pages from any app's share menu and saves them as Obsidian-compatible Markdown files to Google Drive.

Built with Flutter. Inspired by [Obsidian Web Clipper](https://github.com/obsidianmd/obsidian-clipper).

## What it does

1. **Share a URL** from Chrome, Reddit, Twitter — any app with a share button
2. **Extracts metadata** — title, author, description, published date (OG tags → meta tags → HTML fallback)
3. **Converts content to Markdown** — preserves headings, links, lists, code blocks, tables (powered by [html2md](https://pub.dev/packages/html2md))
4. **Uploads to Google Drive** — drops the `.md` file into your Obsidian vault's Shared Drive folder

The output matches (almost) [Obsidian Clipper's](https://github.com/obsidianmd/obsidian-clipper) YAML frontmatter format.

## Setup

### Prerequisites

- Flutter SDK
- Android device with USB debugging enabled
- Google Cloud project with Drive API enabled + Android OAuth client

### Configuration

1. Create an Android OAuth client in GCP with your app's package name + SHA-1
2. Set your Drive folder ID in `lib/main.dart`:
   ```dart
   const String targetFolderId = 'YOUR_FOLDER_ID';
   ```
3. Run:
   ```bash
   flutter run
   ```

## Architecture

```
lib/
├── main.dart                    # Entry point, share intent, theme
├── models/
│   └── clip_data.dart           # Web clipping data model
├── screens/
│   ├── home_screen.dart         # Sign-in + instructions
│   └── clip_screen.dart         # Clip processing + preview
└── services/
    ├── clip_service.dart        # URL → metadata extraction
    ├── markdown_generator.dart  # ClipData → Obsidian markdown
    └── drive_service.dart       # Google Sign-In + Drive upload
```

## Content Extraction

Inspired by Obsidian Clipper's [defuddle](https://github.com/kepano/defuddle) library:

- Finds main content (`<article>` → `<main>` → `<body>`)
- Strips noise (ads, nav, social buttons, cookie banners — 25+ CSS patterns)
- Converts cleaned HTML → Markdown with fenced code blocks

## License

MIT
