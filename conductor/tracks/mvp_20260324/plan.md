# Implementation Plan: Second Brain Clipper

## Phase 1: Clean Slate — Project Reset & Structure
- [x] Remove Gemini dependency, add Google Drive/Sign-In packages
- [x] Strip summarization code from main.dart
- [x] Create lib/services/, lib/screens/, lib/models/ directories
- [x] Set up Material 3 dark theme
- [x] flutter analyze — 0 issues

## Phase 2: Metadata Extraction
- [x] Create ClipData model
- [x] Create ClipService with extractMetadata()
- [x] OG tag → meta tag → HTML element fallback chain

## Phase 3: Markdown Generation
- [x] Create MarkdownGenerator (Obsidian-compatible YAML frontmatter)
- [x] Filename sanitization

## Phase 4: Google Drive Upload
- [x] Create DriveService with signIn() and uploadClipping()
- [ ] Set up GCP OAuth client + enable Drive API
- [ ] Configure Shared Drive folder ID
- [ ] Test auth flow + file upload

## Phase 5: UI & Wiring
- [x] Create HomeScreen with sign-in + instructions
- [x] Create ClipScreen with metadata preview + upload status
- [x] Wire pipeline: intent → extract → markdown → upload
- [ ] End-to-end test on Android

## Build Chain Fixes Applied
- [x] Installed openjdk-21-jdk (was JRE only)
- [x] Cleared stale Gradle toolchain cache
- [x] Upgraded Kotlin 1.8.22 → 2.1.0
- [x] Forced JVM 11 targets across all subprojects
