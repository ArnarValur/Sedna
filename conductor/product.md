# Product Definition

## Initial Concept
**Sedna - SecondMobileBrain**
A Flutter application that accepts shared links, summarizes content using Gemini AI, and syncs data via Firebase for desktop access.

## Core Architecture
- **Ingestion Layer**: A Flutter "Share Extension" (iOS/Android) to catch URLs from other apps.
- **Intelligence Layer**: A service calling the Gemini API to summarize the content.
- **Persistence Layer**: Firebase Firestore to store the summaries and metadata.
