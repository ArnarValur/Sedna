# DittoDatto Mobile — Codebase Analysis

> Reference analysis of `public-marketplace` Nuxt app to define the mobile feature surface.

## Source: DittoDatto Conductor

| Document                                                                                                     | Key Insight                                                                                           |
| ------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| [product.md](file:///media/addinator/Mercury/Projects/DittoDatto/conductor/product.md)                       | **Future Phase: Mobile Native (Flutter)** — "Steel Thread" MVP: Open App → Pick Slot → Book → Success |
| [vision.md](file:///media/addinator/Mercury/Projects/DittoDatto/conductor/vision.md)                         | Q2 2026 target. Flutter + FlutterFire + Riverpod. Consumer app only (portal stays web).               |
| [tech-stack.md](file:///media/addinator/Mercury/Projects/DittoDatto/conductor/tech-stack.md)                 | Mobile stack: Flutter, Riverpod, GoRouter. Connects to same Firebase backend.                         |
| [product-guidelines.md](file:///media/addinator/Mercury/Projects/DittoDatto/conductor/product-guidelines.md) | Primary: **Moody Blue** `#6F71CC`. Dark/Light modes. Ditto personality: witty, friendly.              |

## Public Marketplace — Feature Map

### Pages (21 routes)

| Route                | Purpose                 | Mobile Priority        |
| -------------------- | ----------------------- | ---------------------- |
| `/` (index)          | Landing / hero          | ⭐ Home screen         |
| `/browse`            | Browse all stores       | ⭐ Core                |
| `/discover`          | AI-powered discovery    | ⭐ Core                |
| `/categories`        | Category grid           | ⭐ Core                |
| `/[category]/`       | Category listing        | ⭐ Core                |
| `/[category]/[slug]` | Category-specific store | ⭐ Core                |
| `/s/[slug]`          | Store detail page       | ⭐ Core                |
| `/login`             | Auth login              | ⭐ Core                |
| `/signup`            | Auth signup             | ⭐ Core                |
| `/profile`           | User profile            | ⭐ Core                |
| `/profile/*`         | Profile sub-pages       | ⭐ Core                |
| `/bookings`          | My bookings             | ⭐ Core (Steel Thread) |
| `/favorites`         | Saved stores            | 🔸 Phase 2             |
| `/messages`          | User threads            | 🔸 Phase 2             |
| `/settings`          | User settings           | 🔸 Phase 2             |
| `/for-business`      | B2B landing             |                        |
| `/about`             | About page              |                        |
| `/contact`           | Contact form            |                        |
| `/cookies`           | Cookie policy           |                        |
| `/privacy`           | Privacy policy          | 🔸 In-app webview      |
| `/terms`             | Terms of service        | 🔸 In-app webview      |

### Components

| Component              | Purpose                                | Mobile Equivalent          |
| ---------------------- | -------------------------------------- | -------------------------- |
| `DDDittoBar` (18KB)    | Search bar with AI-powered suggestions | Central search widget      |
| `BookingCard`          | Booking display card                   | Booking list item widget   |
| `BookingChatMessages`  | Booking chat display                   | In-app chat view           |
| `BookingChatSlideover` | Chat drawer                            | Bottom sheet / chat screen |
| `auth/*`               | Auth forms                             | Auth screens               |
| `common/*`             | Shared UI elements                     | Shared widgets             |
| `messages/*`           | Messaging UI                           | Chat/messaging screens     |
| `profile/*`            | Profile management                     | Profile screens            |

### Composables → Dart Equivalents

| Nuxt Composable        | Purpose                     | Dart Pattern                  |
| ---------------------- | --------------------------- | ----------------------------- |
| `useAuth` (15KB)       | Firebase Auth + RBAC        | `AuthNotifier` (Riverpod)     |
| `useBooking`           | Booking flow state          | `BookingNotifier`             |
| `useDittoSearch` (7KB) | Semantic search via API     | `SearchRepository`            |
| `useFavorites`         | Favorite stores             | `FavoritesNotifier`           |
| `useUserBookings`      | User's booking list         | `BookingsNotifier`            |
| `useMarketplaceStores` | Store listing               | `StoresRepository`            |
| `useStore`             | Single store data           | `StoreDetailNotifier`         |
| `useCategories`        | Category list               | `CategoriesRepository`        |
| `useNotifications`     | Push/in-app notifications   | FCM + `NotificationsNotifier` |
| `useUserThreads`       | Messaging threads           | `ThreadsNotifier`             |
| `useBankID`            | Norwegian BankID auth       | BankID SDK integration        |
| `useSiteSettings`      | Site config                 | `AppConfigProvider`           |
| `useCallableFunctions` | Firebase callable functions | Cloud Functions client        |
| `useCategoryIcon`      | Category icon mapping       | Static icon map               |

### Config Highlights (nuxt.config.ts)

- **Firebase Project**: `cs-poc-4zmxog23jmy4io0d4yx6rj0`
- **i18n**: nb (Bokmål), en, nn (Nynorsk), pl (Polski) — default: nb
- **SSR routes**: `/discover/**`, `/restaurant/**`, `/venue/**`, `/service/**`
- **Google Maps**: Integrated for store locations
- **Shared UI**: Extends `@dittodatto/ui` (monorepo layer)

## Vault Resources

| Resource             | Path                                                                                                                                                              |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Flutter Docs**     | `MerkurialVault/Documentations/Flutter/Flutter Docs/` (Getting Started, UI, Beyond UI)                                                                            |
| **Dart Docs**        | [MerkurialVault/Documentations/Dart/](file:///home/addinator/MerkurialDrive/MerkurialVault/Documentations/Dart) (Language, Core, Effective, Packages, Dev, Tools) |
| **Flutter API Libs** | `MerkurialVault/Documentations/Flutter/!TODO Flutter API Libraries/`                                                                                              |
| **Flutter Book**     | `MerkurialVault/Ebooks/Flutter App Development How to Write for iOS and Android at Once/`                                                                         |

## Steel Thread MVP Scope (from vision.md)

```
Open App → Search/Browse → Select Store → View Service → Pick Slot → Book → Confirmation
```

This maps to: **Home → Browse/Discover → Store Detail → Slot Picker → Booking Confirmation → My Bookings**
