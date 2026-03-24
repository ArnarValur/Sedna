# Implementation Plan: MVP Link Receiver & Summarizer

## Phase 1: Environment & Skeleton
- [ ] Initialize the Flutter project (`flutter create .`)
- [ ] Review the default `main.dart` structure to understand Flutter UI, Widgets, and State.
- [ ] Clean up default counter app code to prepare a clean slate for SecondMobileBrain.

## Phase 2: Receiving Intent
- [ ] Add `receive_sharing_intent` to `pubspec.yaml`.
- [ ] Configure `AndroidManifest.xml` to declare the app as a share target.
- [ ] Implement Dart logic to listen for incoming intents and display the URL on screen.

## Phase 3: AI Summarization
- [ ] Add `http`, `html`, and `google_generative_ai` packages.
- [ ] Create a service class to fetch URL content and extract text.
- [ ] Create a service class to prompt Gemini with the extracted text.
- [ ] Update the UI to show a loading state while fetching/summarizing, and display the result.
