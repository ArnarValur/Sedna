import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'screens/home_screen.dart';
import 'screens/clip_screen.dart';
import 'services/drive_service.dart';

// ┌─────────────────────────────────────────────────────────────────┐
// │  CONFIGURATION                                                  │
// │  Set your Google Shared Drive folder ID here.                   │
// │  Find it in the URL when viewing the folder in Google Drive:    │
// │  https://drive.google.com/drive/folders/<THIS_IS_THE_ID>        │
// └─────────────────────────────────────────────────────────────────┘
const String targetFolderId = '';  // Your Google Drive folder ID here

/// main.dart — The entry point of the Flutter application.
///
/// KEY FLUTTER CONCEPTS:
///
/// 1. runApp(): Takes a Widget and makes it the root of the widget tree.
///    Everything you see on screen is a Widget — buttons, text, layout,
///    even the app itself.
///
/// 2. MaterialApp: The top-level widget that provides Material Design
///    styling, navigation routing, and theme configuration.
///
/// 3. ThemeData: Defines the visual appearance of the entire app.
///    Material 3 uses a "ColorScheme" generated from a seed color —
///    it automatically creates a harmonious palette.
///
/// 4. Widget Tree: Flutter builds UIs as a tree of nested widgets.
///    MaterialApp → HomeScreen → Scaffold → Column → [children]
///    When we navigate to ClipScreen, Flutter pushes it onto a
///    navigation stack on top of HomeScreen.
void main() {
  runApp(const SecondBrainApp());
}

class SecondBrainApp extends StatefulWidget {
  const SecondBrainApp({super.key});

  @override
  State<SecondBrainApp> createState() => _SecondBrainAppState();
}

class _SecondBrainAppState extends State<SecondBrainApp> {
  /// We create ONE DriveService instance and pass it down to all screens.
  /// This pattern is called "lifting state up" — the auth state lives at the
  /// top of the widget tree and is shared with children via constructor parameters.
  final DriveService _driveService = DriveService();

  /// GlobalKey gives us access to the Navigator from anywhere in the app.
  /// We need this to push the ClipScreen when a share intent arrives —
  /// even when the share happens outside of a normal user interaction.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  StreamSubscription? _intentSubscription;

  @override
  void initState() {
    super.initState();
    _setupShareListener();
  }

  /// Sets up listeners for incoming share intents.
  ///
  /// There are TWO scenarios to handle:
  /// 1. App is already running → getMediaStream() fires
  /// 2. App was closed and launched via share → getInitialMedia() fires
  ///
  /// On Linux/desktop, share intents don't exist, so we skip this.
  void _setupShareListener() {
    // Share intent only works on mobile platforms
    if (Platform.isAndroid || Platform.isIOS) {
      // Scenario 1: App is in memory, user shares while it's running
      _intentSubscription = ReceiveSharingIntent.instance
          .getMediaStream()
          .listen(
            (files) => _handleIncomingShare(files),
            onError: (err) => debugPrint('Share stream error: $err'),
          );

      // Scenario 2: App was closed, launched via share action
      ReceiveSharingIntent.instance.getInitialMedia().then((files) {
        _handleIncomingShare(files);
      });
    }
  }

  /// Extracts a URL from the shared data and navigates to the ClipScreen.
  void _handleIncomingShare(List<SharedMediaFile> files) {
    if (files.isEmpty) return;

    // The shared text typically contains the URL
    final raw = files.map((f) => f.path).join('\n');

    // Extract a URL using regex
    final urlMatch = RegExp(r'(https?://[^\s]+)').firstMatch(raw);

    if (urlMatch != null) {
      final url = urlMatch.group(0)!;

      // Navigate to ClipScreen with the extracted URL
      // We use pushReplacement so "back" goes to home, not a blank screen
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ClipScreen(
            url: url,
            driveService: _driveService,
            targetFolderId: targetFolderId,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _intentSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Second Brain',

      // ── Theme Configuration ──────────────────────────────────
      // Material 3 dark theme with a teal seed color.
      // ColorScheme.fromSeed automatically generates:
      // - primary, secondary, tertiary colors
      // - surface, background, error colors
      // - All their "on" variants (text colors that contrast properly)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      home: HomeScreen(driveService: _driveService),

      // Debug banner off — cleaner during development
      debugShowCheckedModeBanner: false,
    );
  }
}
