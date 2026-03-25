# Specification: Second Brain Clipper

## Goal
Build an Android app that replicates the core workflow of **Obsidian Web Clipper** — but for mobile. When a user shares a URL from any Android app (Chrome, Reddit, etc.), the app extracts page metadata, generates a Markdown file with Obsidian-compatible YAML frontmatter, and saves it directly to a Google Shared Drive folder (the user's Obsidian vault).

## Problem
The user currently collects URLs in Google Keep Notes while browsing on their phone. These links accumulate and are forgotten. On desktop, Obsidian Clipper solves this perfectly — but no equivalent exists for Android share intents.

## Solution
An Android app that acts as a share target. The flow:
1. User sees an interesting link → taps **Share** → selects **Second Brain**
2. App fetches the page and extracts: title, URL, description, author, published date, content
3. App generates an Obsidian-compatible `.md` file with YAML frontmatter
4. App uploads the file to the user's Google Shared Drive (Obsidian vault folder)
5. User sees a brief confirmation and the file appears in Obsidian on all devices

## Frontmatter Template (Matching Obsidian Clipper)
```yaml
---
title: "{{title}}"
source: "{{url}}"
author: "{{author}}"
description: "{{description}}"
published: "{{published}}"
created: "{{date}}"
tags:
  - clippings
---
```

## Requirements
1. **Share Intent Receiver** — catch URLs shared from other Android apps
2. **Page Metadata Extraction** — HTTP fetch + HTML parsing for meta tags, OG tags
3. **Markdown Generation** — YAML frontmatter + cleaned body content
4. **Google Drive Upload** — OAuth via Google Sign-In, write to specific Shared Drive folder
5. **Minimal UI** — confirmation screen, basic clip history (local)

## Non-Requirements (for MVP)
- No AI summarization (scrapped from old track)
- No custom templates (hardcoded Obsidian Clipper format)
- No iOS support
- No offline queue (future enhancement)

## Educational Focus
The developer is learning Flutter. Each phase teaches specific concepts:
- **Phase 1**: Project structure cleanup, widget tree, StatefulWidget lifecycle
- **Phase 2**: Services, async/await, HTTP, HTML parsing in Dart
- **Phase 3**: Markdown string templating, file I/O patterns
- **Phase 4**: OAuth, Google APIs, package integration, permission handling
- **Phase 5**: UI polish, Material Design 3, snackbars, navigation
