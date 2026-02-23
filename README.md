# 🧘‍♂️👹 Monks & Demons — River Crossing Puzzle Game

> **An AI + Game Development + Flutter App Development Project**  
> Built with Flutter • Powered by BFS AI Logic • Deployed on Android via USB Debugging

---

## 📌 Project Overview

**Monks & Demons** is a mobile puzzle game based on the classic **Missionaries and Cannibals** problem from **Artificial Intelligence**. The game challenges players to transport 3 monks and 3 demons across a river using a boat that holds a maximum of 2 people — without ever letting demons outnumber monks on either side.

This project combines three domains:
- 🤖 **Artificial Intelligence** — BFS state-space search, constraint satisfaction
- 🎮 **Game Development** — animated characters, river, boat, sound effects, themes
- 📱 **Flutter App Development** — widget trees, state management, custom painters, Android deployment

---

## ✨ Features

| Feature | Details |
|--------|---------|
| 🎨 4 Themes | Light, Dark, Neon, Pink |
| 🔊 Sound Effects | Funny kid-friendly jump, demon roar, splash sounds |
| ⏱️ Live Timer | Displayed top-right corner |
| 📊 Analysis Report | Full move history and stats per attempt |
| ♾️ Unlimited Attempts | Play as many times as you want |
| 🌊 Animated River | Multi-layer wave animation with bubbles |
| 🚤 Animated Boat | Rocking boat with passenger display |
| 🤸 Somersault Jump | Characters flip when boarding/leaving boat |
| 📱 Android Deployment | Deployed via USB Debugging |

---

## 🎨 Themes (My Added Features)

Four hand-crafted themes, each with unique colors for every game element:

| Element | 🌞 Light | 🌙 Dark | ⚡ Neon | 🌸 Pink |
|---------|---------|--------|--------|--------|
| **Monk Color** | Yellow | Orange | Neon Orange | Lavender |
| **Demon Color** | Brown | Green | Crimson Red | Deep Blue |
| **Boat Color** | Brown | White | Fluorescent Green | Magenta |
| **Water Color** | Blue | Dark Blue | Dark Teal | Hot Pink |
| **Background** | Warm Beige | Near Black | Pure Black | Light Pink |
| **Sky** | Sky Blue | Deep Navy | Dark Purple | Soft Pink |

Each theme is defined as a constant `AppTheme` object in `lib/theme/app_theme.dart` and persisted across sessions using `shared_preferences`.

---

## 🤖 Game Logic — Artificial Intelligence

### The Classic Problem
The Monks & Demons problem (also called **Missionaries and Cannibals**) is a foundational problem in AI used to teach **state-space search**.

### State Representation
Each game state is represented as a 5-tuple:
```
State = (leftMonks, leftDemons, rightMonks, rightDemons, boatSide)
```
Example: `(3, 3, 0, 0, LEFT)` = starting state

### Constraint Rules
```
1. Boat capacity = 2 (minimum 1 person must be in boat)
2. If monks > 0 on any side → demons must NOT outnumber monks
3. Goal state = (0, 0, 3, 3, RIGHT)
```

### BFS — Breadth First Search Algorithm
The game uses **BFS (Breadth-First Search)** internally to:
- Validate whether a state is legal
- Find the **optimal 11-move solution** (used for hint system)
- Detect visited states to prevent infinite loops

```
BFS Algorithm:
1. Start with initial state (3,3,0,0,LEFT)
2. Add to queue
3. For each state, generate all valid moves (1-2 people)
4. Check constraints — skip invalid states
5. Mark visited states
6. Continue until goal state (0,0,3,3,RIGHT) is reached
7. Return the path of moves
```

### Optimal Solution (11 moves)
```
Move 1:  1 Monk  + 1 Demon  → Right
Move 2:  1 Monk             ← Left
Move 3:              2 Demons → Right
Move 4:              1 Demon ← Left
Move 5:  2 Monks            → Right
Move 6:  1 Monk  + 1 Demon  ← Left
Move 7:  2 Monks            → Right
Move 8:              1 Demon ← Left
Move 9:              2 Demons → Right
Move 10: 1 Monk             ← Left
Move 11: 1 Monk  + 1 Demon  → Right ✅
```

### Why It's an AI Problem
- **State Space**: 5×4×5×4×2 = 800 possible states (most invalid)
- **Search Strategy**: BFS guarantees the shortest path
- **Constraint Satisfaction**: Every move is validated against the safety rule
- **Goal Test**: Checks if all characters have crossed

---

## 🔊 Sound Effects (Kid-Friendly & Funny)

Three fun sound effects used throughout the game:

| File | Trigger | Description |
|------|---------|-------------|
| `jump.mp3` | Monk boards/leaves boat | Funny boing/jump sound |
| `demon_roar.mp3` | Demon boards boat | Silly monster roar |
| `splash.mp3` | GO button pressed | Water splash sound |

Sounds are implemented using the `audioplayers` package with separate `AudioPlayer` instances for each sound so they never cancel each other:

```dart
final AudioPlayer _jumpPlayer = AudioPlayer();
final AudioPlayer _demonPlayer = AudioPlayer();
final AudioPlayer _splashPlayer = AudioPlayer();
```

---

## 📁 File & Directory Structure

```
demonmonk/
│
├── lib/                              ← All Dart source code
│   ├── main.dart                     ← App entry point, Provider setup
│   ├── models/
│   │   └── game_model.dart           ← AI logic, BFS solver, state machine
│   ├── providers/
│   │   └── game_provider.dart        ← State management (ChangeNotifier)
│   ├── screens/
│   │   ├── home_screen.dart          ← Splash/home screen
│   │   ├── game_screen.dart          ← Main game UI
│   │   └── analysis_screen.dart      ← Player attempt analysis
│   ├── widgets/
│   │   ├── animated_water.dart       ← Multi-layer animated river
│   │   ├── boat_widget.dart          ← Rocking boat with passengers
│   │   └── character_widget.dart     ← Monk & Demon with somersault
│   └── theme/
│       └── app_theme.dart            ← All 4 theme definitions
│
├── assets/                           ← Static assets (NOT inside lib/)
│   └── sounds/
│       ├── jump.mp3                  ← Monk jump sound
│       ├── demon_roar.mp3            ← Demon boarding sound
│       └── splash.mp3                ← Boat crossing sound
│
├── android/                          ← Android platform files
│   ├── app/
│   │   ├── build.gradle.kts          ← Android build config (minSdk 21)
│   │   └── src/main/
│   │       └── AndroidManifest.xml   ← App permissions & config
│   ├── gradle/wrapper/
│   │   └── gradle-wrapper.properties ← Gradle version (8.3)
│   └── gradle.properties             ← AndroidX, Jetifier settings
│
├── pubspec.yaml                      ← Project config & dependencies
├── pubspec.lock                      ← Locked dependency versions
└── README.md                         ← This file
```

---

## 📦 pubspec.yaml — The Project Configuration File

`pubspec.yaml` is the **heart of every Flutter project**. It tells Flutter:
- What your app is called and its version
- Which external packages (libraries) to use
- Where your asset files (sounds, images, fonts) are located

```yaml
name: demonmonk
description: Classic Demons and Monks river crossing puzzle game.
version: 1.0.0+1

environment:
  sdk: ^3.11.0               # Minimum Dart SDK version required

dependencies:
  flutter:
    sdk: flutter

  provider: ^6.1.5           # State management — ChangeNotifier pattern
  audioplayers: ^6.5.1       # Sound effects — jump, roar, splash
  shared_preferences: ^2.5.4 # Save theme selection across sessions
  google_fonts: ^8.0.2       # Beautiful typography
  flutter_animate: ^4.5.2    # Chainable animation extensions

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0      # Code quality checks

flutter:
  uses-material-design: true

  assets:                    # ← Tells Flutter where sound files are
    - assets/sounds/jump.mp3
    - assets/sounds/demon_roar.mp3
    - assets/sounds/splash.mp3
```

> ⚠️ **Important**: If assets are not listed here, Flutter cannot find them even if the files exist on disk. This is a common mistake — always declare assets in pubspec.yaml!

---

## 🌳 Widget Tree Structure

### 1. Home Screen (`home_screen.dart`)
```
HomeScreen (StatefulWidget)
└── Scaffold
    └── Stack
        ├── Container (gradient sky background)
        ├── AnimatedWater (bottom, decorative)
        └── FadeTransition + ScaleTransition
            └── Center
                └── Column
                    ├── ShaderMask → Text "MONKS & DEMONS" (title)
                    ├── Text (subtitle)
                    ├── _CharacterPreview (StatefulWidget)
                    │   └── Row
                    │       ├── AnimatedBuilder → Transform.translate
                    │       │   └── CustomPaint (_MonkPreview)  ×3
                    │       └── AnimatedBuilder → Transform.translate
                    │           └── CustomPaint (_DemonPreview) ×3
                    ├── ElevatedButton "PLAY"
                    ├── Text "Choose Theme"
                    └── Row (theme selector circles) ×4
```

### 2. Game Screen (`game_screen.dart`)
```
GameScreen (StatefulWidget)
└── Consumer<GameProvider>
    └── Scaffold
        └── SafeArea
            └── Stack
                ├── _SkyBackground (AnimatedBuilder → CustomPaint)
                └── Column
                    ├── _TopBar
                    │   └── Row
                    │       ├── PopupMenuButton (theme selector)
                    │       ├── IconButton (analysis)
                    │       └── Container (Timer display)
                    ├── Text "Monks & Demons"
                    ├── AnimatedContainer (message banner)
                    ├── _GameArea
                    │   └── Column
                    │       ├── Row
                    │       │   ├── _BankSection (Left bank)
                    │       │   │   └── Column
                    │       │   │       ├── CharacterWidget (Monk) ×n
                    │       │   │       └── CharacterWidget (Demon) ×n
                    │       │   ├── Stack (River + Boat)
                    │       │   │   └── AnimatedBuilder
                    │       │   │       └── BoatWidget
                    │       │   │           └── Stack
                    │       │   │               ├── CustomPaint (_BoatPainter)
                    │       │   │               └── Row (mini passengers)
                    │       │   └── _BankSection (Right bank)
                    │       ├── ClipRRect → AnimatedWater
                    │       └── Container (boat count info)
                    └── _ControlPanel
                        └── Column
                            ├── Row
                            │   ├── _ActionButton "+ Monk"
                            │   ├── ElevatedButton "GO" ← Elevated Button
                            │   └── _ActionButton "+ Demon"
                            └── Row
                                ├── _ActionButton "- Monk"
                                ├── ElevatedButton "Reset"
                                └── _ActionButton "- Demon"
```

### 3. Analysis Screen (`analysis_screen.dart`)
```
AnalysisScreen (StatelessWidget)
└── Scaffold
    ├── AppBar
    └── Column
        ├── _SummaryCard
        │   └── Row
        │       ├── _Stat (Total attempts)
        │       ├── _Stat (Wins)
        │       ├── _Stat (Best Time)
        │       └── _Stat (Best Moves)
        └── ListView.builder
            └── _AttemptCard ×n
                └── ExpansionTile
                    ├── CircleAvatar (attempt number)
                    ├── Title (Success/Failed)
                    ├── Subtitle (time + moves)
                    └── Column (move history list)
```

---

## 🎬 Animations Involved

| Animation | Widget | Type | Details |
|-----------|--------|------|---------|
| River waves | `AnimatedWater` | `AnimationController` repeat | 3 wave layers with different speeds and phases |
| Bubble particles | `AnimatedWater` | `CustomPainter` | 8 rising bubbles with fade |
| Character somersault | `CharacterWidget` | `TweenSequence` | Y-axis translate + full 360° rotation |
| Boat rocking | `BoatWidget` | `AnimationController` repeat reverse | Sine-based rotation ±4° |
| Boat crossing | `GameScreen` | `CurvedAnimation` | Horizontal position lerp across river |
| Sky clouds/stars | `_SkyBackground` | `AnimationController` repeat | Moving clouds (light/pink) or twinkling stars (dark/neon) |
| Home characters | `_CharacterPreview` | `TweenSequence` | Alternating bounce effect |
| Home screen entry | `HomeScreen` | `FadeTransition` + `ScaleTransition` | Elastic scale-in on load |
| Message banner | `GameScreen` | `AnimatedContainer` | Smooth height/opacity transition |
| Theme circles | `HomeScreen` | `AnimatedContainer` | Size pulse on selection |

---

## 📱 Android Deployment via USB Debugging

The app was deployed to a **OnePlus Nord 2 Lite** Android phone using Flutter's USB debugging workflow:

### Steps Followed:
1. Enabled **Developer Options** on phone:
   - Settings → About Device → Tap **Build Number 7 times**
2. Enabled **USB Debugging**:
   - Settings → Additional Settings → Developer Options → USB Debugging ON
3. Connected phone via **USB cable** (Data Transfer / MTP mode)
4. Authorized the PC on phone popup ("Allow USB Debugging?")
5. Ran `flutter run` — Flutter automatically detected the device and deployed

### Why USB Debugging?
- Allows Flutter to directly install and debug apps on a real device
- Real device testing is critical for sound, touch, and performance
- Sounds (MP3) work correctly on Android but not on Chrome web

```bash
# Verify device is detected
adb devices

# Deploy to phone
flutter run

# Build release APK for distribution
flutter build apk --release
```

---

## 🚀 How to Run

```bash
# 1. Clone the repository
git clone https://github.com/LakshyaNayyar/Monks-and-Demon-Game.git
cd Monks-and-Demon-Game

# 2. Install dependencies
flutter pub get

# 3. Connect Android phone with USB Debugging enabled

# 4. Run the app
flutter run

# 5. For release APK
flutter build apk --release
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|-----------|---------|
| Flutter 3.x | UI framework |
| Dart 3.x | Programming language |
| Provider | State management |
| audioplayers | Sound effects |
| shared_preferences | Theme persistence |
| google_fonts | Typography |
| flutter_animate | Animation extensions |
| CustomPainter | Water, boat, character drawing |
| BFS Algorithm | AI game solver |
| Android SDK | Mobile deployment |
| Git + GitHub | Version control |

---

## 👨‍💻 Developer

**Lakshya Nayyar**  
AI + Game Development + Flutter App Development Project  
Deployed on: OnePlus Nord 2 Lite via USB Debugging

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).