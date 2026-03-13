# Lexicon — Developer Guide

**Version:** 1.2.0+3  
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
├── main.dart               # App entry, MainScaffold, floating nav pill
│
├── screens/
│   ├── lookup_screen.dart      # Search + animated result display
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
    └── app_theme.dart         # Color palette, typography, ThemeData
```

---

## Architecture

Simple flat architecture with `setState` throughout. No external state manager.

```
MainScaffold (GlobalKeys)
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

**Methods:**

| Method | Description |
|---|---|
| `getAll()` | Returns all entries, most-recent first |
| `contains(word)` | Checks if a word is already saved |
| `addWord(word, definition)` | Inserts at top; deduplicates by word |
| `removeWord(word)` | Removes by word (case-insensitive) |
| `clearAll()` | Drops the entire list |

---

## History Storage System

**File:** `lib/storage/history_storage.dart`  
**Key:** `'search_history'`  
**Max entries:** 10

**Methods (v1.2 additions):**

| Method | Description |
|---|---|
| `removeWord(word)` | Removes a single entry individually |

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

`Dismissible` handles the swipe gesture and built-in removal animation. No manual `AnimationController` needed — Flutter handles the collapse automatically.

### 5. Bookmark icon swap (`word_display.dart`)

`AnimatedSwitcher` wraps the `Icon` widget, keyed to `_isSaved`, producing a smooth crossfade between bookmark states.

---

## Progress Tracking

**File:** `lib/screens/lexicon_screen.dart`

Milestone logic is pure Dart, no storage needed:
```dart
String get _milestoneLabel {
  final n = _entries.length;
  if (n >= 100) return '100 word milestone reached';
  if (n >= 50)  return '50 word milestone reached';
  if (n >= 25)  return '25 word milestone reached';
  return '';
}
```

Word count is shown via `AnimatedSwitcher` so the number crossfades when it changes.

---

## API Integration

**Endpoint:** `GET https://api.dictionaryapi.dev/api/v2/entries/en/{word}`

**Model hierarchy:**
- `DictionaryEntry` — word, phonetic, audio, origin, `List<WordMeaning>`
- `WordMeaning` — partOfSpeech, `List<WordDefinition>`, synonyms
- `WordDefinition` — definition, example

To swap the API: update `_baseUrl` in `DictionaryApiService` and adjust `fromJson` factories.

---

## Theme & Design System

| Token | Color | Purpose |
|---|---|---|
| `backgroundColor` | `#0F0F10` | Scaffold background |
| `surfaceColor` | `#1A1A1C` | Search bar, pill nav |
| `accentColor` | `#F5F5F7` | Primary text, active icons |
| `secondaryTextColor` | `#86868B` | Subtitles |
| `mutedColor` | `#4A4A4F` | Labels, dividers |
| `iconColor` | `#5C5C62` | Inactive icons |

Typography: **Inter** via `google_fonts`. Generous spacing, no boxed cards in main flows.

---

## Adding New Features

### New Tab
1. Create screen in `lib/screens/`
2. Add `GlobalKey<YourScreenState>` in `_MainScaffoldState`
3. Add to `IndexedStack` children
4. Add `_NavIcon` entry in `_FloatingNavPill._items`

### New Storage Field
1. Add field to the relevant `*Entry` class
2. Update `toJson` / `fromJson`
3. Existing stored data degrades gracefully (null-safe parsing)

---

## Dependencies

| Package | Purpose |
|---|---|
| `http` | Dictionary API calls |
| `google_fonts` | Inter typeface |
| `url_launcher` | Open Google/browser links |
| `shared_preferences` | History + Lexicon local storage |
| `speech_to_text` | Voice search input |
| `audioplayers` | Pronunciation audio playback |

---

## App Metadata

| Property | Value |
|---|---|
| App Name | Lexicon |
| Version | 1.2.0+3 |
| Keywords | dictionary, vocabulary, word lookup, minimal, reading companion, personal lexicon |
| Short Description | Minimal dictionary & vocabulary tool with personal word saving |
