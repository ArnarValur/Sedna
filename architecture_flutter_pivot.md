# Architectural Pivot: Nuxt Frontpage to Flutter

**Date:** 2026-03-24
**Context:** Conceptual pivot of transitioning the consumer-facing `public-marketplace` from Nuxt.js to Flutter, while keeping the internal Business Portal in Nuxt.

## Core Rationale
- **Traffic Model:** The primary user acquisition strategy does not rely on traditional Google Search (SEO), but rather on AI Agents and direct B2C/B2B onboarding.
- **Backend Architecture:** The backend booking engine is heavily decoupled (`mercury.dittodatto.no` microservice).
- **Consolidation:** Migrating to Flutter enables a single codebase for iOS, Android, and Web clients. It eliminates maintaining duplicate API client models, state management (e.g., Auth, Bookings), and UI components in both Vue/TypeScript and Dart.

## The "Business Portal Preview" Solution
The main blocker for this pivot is how the Nuxt-based Business Portal (which is maintained for Admin/B2B users) can provide a live preview of the Store Page, given the Store Page is now written in Flutter.

### Industry-Standard Solution: Iframe + PostMessage
1. **Flutter Web Hosting:** The consumer app is compiled to Flutter Web and hosted at e.g. `app.dittodatto.no`.
2. **The Nuxt Portal Iframe:** Inside the Business Portal's "Store Builder" view, render an HTML `<iframe>` pointing to the Flutter web app: 
   `<iframe src="https://app.dittodatto.no/s/my-store?mode=preview" />`
3. **Live Syncing (`postMessage`):**
   - As the business owner updates data in the Nuxt form, the Nuxt app sends a JavaScript event into the iframe: `iframe.contentWindow.postMessage(newStoreData, '*')`.
   - The Flutter Web app uses `dart:js_interop` (or the `web` package) to listen for these browser messages. 
   - When new JSON data arrives, Flutter updates its local state (e.g., via Riverpod), instantly re-rendering the UI canvas to reflect the unsaved changes.

### Benefits
- **Zero UI Duplication:** The preview shows the exact, literal compiled Flutter code the consumer will see. You do not need a mock "mobile preview" Vue component.
- **Clear Separation of Concerns:** B2B Admin workflows remain in Nuxt (ideal for data-dense dashboards), while consumer flows remain in Flutter (ideal for mobile interaction and "Steel Thread" app journeys).
