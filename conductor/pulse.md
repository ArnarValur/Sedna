# 🎵 Project Pulse

**Last Updated:** 2026-03-25
**Session Focus:** End-to-end Obsidian Web Clipper — fully working on Android

## 🚀 Active Tracks
| Domain | Track | Status | Notes |
|--------|-------|--------|-------|
| core | mvp_20260324 | COMPLETE | Full pipeline working: share → extract → markdown → Drive → Obsidian |

## ✅ Recently Completed
| Track | Completed | Notes |
|-------|-----------|-------|
| mvp_20260324 | 2026-03-25 | End-to-end clipper with HTML→Markdown conversion |

## ⚠️ Blockers
None.

## 🧠 Session Memory
### 2026-03-25 (Full Pipeline + Content Upgrade)
- Pivoted from AI summarizer to Obsidian Web Clipper for Android.
- Built full codebase: models, services (clip, markdown, drive), screens (home, clip).
- Fixed build chain: JDK install, Gradle cache, Kotlin 1.8→2.1.0, JVM 11 alignment.
- **App deployed and tested on Samsung S21 Ultra (SM G998B).**
- Google Sign-In working with Android OAuth client (MercuryMarkdown GCP project).
- Drive upload working to Shared Drive folder `1NbKQ-2uMYjs9Nu66Fmj1syxDBME0tWFa`.
- Researched Obsidian Clipper → discovered `defuddle` library architecture.
- Upgraded content extraction: added `html2md` for HTML→Markdown, noise removal (25+ CSS patterns), fenced code blocks.
- **Verified in Obsidian: articles render with proper headings, links, lists, code blocks.**

### 2026-03-24 (Conductor Setup)
- Conductor initialized for project Sedna.
- Scaffolded Flutter app (`com.arnarvalur.secondmobilebrain`).

## 📋 Next Session Suggestions
1. Add desktop debug URL field for testing without Android.
2. Improve code block language detection.
3. Image handling (download/embed vs link).
4. Error handling UX polish.
5. Consider release build + APK signing for permanent install.
