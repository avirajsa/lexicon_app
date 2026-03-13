# Lexicon — Developer Guide

**Version:** 1.3.0+4  
**Developer:** Aviraj Saha (aviraj.saha@outlook.com)

---

## Project Overview

Lexicon is a minimal Flutter dictionary app with a typography-first design. It uses the [Free Dictionary API](https://dictionaryapi.dev/) for definitions, `shared_preferences` for all local storage, and Flutter's built-in animation primitives for smooth interactions.

---

## Getting Started

```bash
cd lexicon_app
flutter pub get
flutter run
```

### Building APK

```bash
flutter build apk --release
```

### Building App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

---

## Folder Structure

```
lib/
├── main.dart               # App entry, MainScaffold, floating nav pill, theme state
│
├── screens/
│   ├── lookup_screen.dart      # Search + animated result display + theme toggle
│   ├── history_screen.dart     # Swipe-to-delete history list
│   ├── lexicon_screen.dart     # Personal saved words + progress
│   ├── tongue_twisters_screen.dart
│   └── dictionary_screen.dart  # Legacy (not in main nav)
│
├── widgets/
│   ├── word_display.dart       # Rich word result with animations + bookmark
│   ├── floating_search_bar.dart  # Pill-shaped search + voice input
│   ├── history_item.dart       # Dismissible history row
│   ├── lexicon_item.dart       # Dismissible lexicon row (word + def + date)
│   ├── theme_toggle.dart       # Custom animated sun/moon switch
│   ├── app_footer.dart         # Reusable footer with social links
│   ├── definition_card.dart    # Legacy widget
│   ├── twister_quote.dart      # Tongue twister display
│   └── twister_card.dart       # Legacy twister card
│
├── services/
│   └── dictionary_api.dart    # API parsing — DictionaryEntry, WordMeaning, WordDefinition
│
├── storage/
│   ├── history_storage.dart   # SharedPreferences wrapper for search history
│   └── lexicon_storage.dart   # SharedPreferences wrapper for saved words
│
├── data/
│   └── tongue_twisters.dart   # Static list of tongue twisters
│
└── theme/
    └── app_theme.dart         # Color palette, typography, Dark & Light (Reader) themes
```

---

## Architecture

Simple flat architecture with `setState` throughout. No external state manager.

```
LexiconApp (ThemeMode State)
  └── MainScaffold (GlobalKeys)
      ├── LookupScreen     → DictionaryApiService, HistoryStorage, LexiconStorage
      ├── HistoryScreen    → HistoryStorage
      ├── LexiconScreen    → LexiconStorage
      └── TongueTwistersScreen
```

**Cross-screen refresh pattern:** `GlobalKey<HistoryScreenState>` and `GlobalKey<LexiconScreenState>` held in `_MainScaffoldState` allow imperative `loadHistory()` / `loadLexicon()` calls without rebuilding the entire tree.

---

## Navigation Structure

`main.dart` uses a custom `_FloatingNavPill` widget (not `BottomNavigationBar`):

- Built with `ClipRRect` + `BackdropFilter` (blur effect) + `Container` (frosted glass)
- 4 `_NavIcon` items: Search, History, Lexicon, Twisters
- Each icon uses `AnimatedContainer` for subtle active-state expansion
- Tab switching: `AnimationController` in `_MainScaffoldState` fades the `IndexedStack` content in/out (200ms)
- `_switchTab()` runs: fade out → setState → fade in → refresh tab data

---

## Theme System & Persistence

Lexicon supports a smooth transition between Dark Mode and **Reader Mode** (Light Theme).

**File:** `lib/theme/app_theme.dart`  
**Light Theme Colors:**
- Background: `#F4E9D8` (Warm Paper)
- Surface: `#EAD9C4` (Parchment)
- Primary Text: `#1C1A18`
- Secondary Text: `#5A4632`

**Persistence:**  
Managed in `_LexiconAppState` (`main.dart`).  
Key: `'is_light_mode'` (bool) in `shared_preferences`.  
Theme switching is animated via `MaterialApp.themeMode`.

**Toggle Widget:** `widgets/theme_toggle.dart`  
Uses `AnimatedAlign` and `AnimatedSwitcher` to move the sun/moon icon and change colors.

---

## Social Links Footer

**Widget:** `widgets/app_footer.dart`  
Centralized footer used in `HistoryScreen` and `LexiconScreen`.  
Includes `url_launcher` links to X, LinkedIn, GitHub, and Instagram.

---

## Lexicon Storage System

**File:** `lib/storage/lexicon_storage.dart`  
**Key:** `'personal_lexicon'`  
**Format:** `SharedPreferences.getStringList` → each element is a JSON-encoded `LexiconEntry`

```dart
class LexiconEntry {
  final String word;
  final String definition;  // primary definition at time of save
  final DateTime dateAdded;
}
```

---

## History Storage System

**File:** `lib/storage/history_storage.dart`  
**Key:** `'search_history'`  
**Max entries:** 10

History is saved **before** the API call fires (`lookup_screen.dart`), so the History tab reflects searches instantly via `GlobalKey`.

---

## Animation Architecture

### 1. Word result fade + slide up (`word_display.dart`)

Uses `AnimationController` with `SingleTickerProviderStateMixin`:
- `_slideAnim`: `Tween<Offset>(begin: Offset(0, 0.06), end: Offset.zero)` — subtle upward nudge
- `_fadeAnim`: `CurvedAnimation` → opacity 0→1
- Plays on `initState` and re-plays on `didUpdateWidget` when word changes

### 2. Search result AnimatedSwitcher (`lookup_screen.dart`)

`_resultKey` increments on each search → `AnimatedSwitcher` with `FadeTransition` detects keychange and crossfades content.

### 3. Tab fade (`main.dart`)

`AnimationController` in `_MainScaffoldState` wraps `IndexedStack` in `FadeTransition`. `_switchTab()` sequences: `reverse()` → `setState` → `forward()`.

### 4. Swipe-to-delete collapse (`history_item.dart`, `lexicon_item.dart`)

`Dismissible` handles the swipe gesture and built-in removal animation.

---

## Progress Tracking

**File:** `lib/screens/lexicon_screen.dart`

Milestone logic tracks word counts at 25, 50, and 100 words.

---

## API Integration

**Endpoint:** `GET https://api.dictionaryapi.dev/api/v2/entries/en/{word}`

---

## Theme & Design System

| Dark Mode Token | Color | Purpose |
|---|---|---|
| `backgroundColor` | `#0F0F10` | Scaffold background |
| `surfaceColor` | `#1A1A1C` | Pill nav |
| `accentColor` | `#F5F5F7` | Primary text |
| `secondaryTextColor` | `#86868B` | Subtitles |

| Light Mode Token | Color | Purpose |
|---|---|---|
| `lightBackgroundColor`| `#F4E9D8` | Warm paper background |
| `lightSurfaceColor` | `#EAD9C4` | Parchment surface |
| `lightPrimaryText` | `#1C1A18` | Dark charcoal text |

Typography: **Inter** via `google_fonts`.

---

## App Metadata

| Property | Value |
|---|---|
| App Name | Lexicon |
| Version | 1.3.0+4 |
| Keywords | dictionary, vocabulary, word lookup, minimal, reader mode, paper theme |
| Short Description | Minimal dictionary tool with warm reader mode and personal lexicon |
