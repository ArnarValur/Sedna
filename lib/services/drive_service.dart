import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'dart:convert';

/// DriveService — handles Google Sign-In and uploads markdown files
/// to a Google Shared Drive folder.
///
/// This service manages two things:
/// 1. Authentication via Google Sign-In (OAuth 2.0)
///    - The user signs in once and we get a token
///    - The token lets us call Google Drive API on their behalf
///
/// 2. File upload via Google Drive API
///    - We create a file in a specific Shared Drive folder
///    - The file content is the markdown string from MarkdownGenerator
///
/// KEY FLUTTER CONCEPTS:
/// - Google Sign-In: A Flutter plugin that handles the entire OAuth flow
///   (showing the Google account picker, requesting permissions, etc.)
/// - Scopes: We request `drive.file` scope — this lets us create/edit
///   files that our app created, but NOT read the user's other files.
///   This is the principle of least privilege.
class DriveService {
  // Google Sign-In instance with Drive file scope.
  // The Android OAuth client is matched automatically by package name + SHA-1
  // from the GCP console — no client ID needed in code.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  /// Whether the user is currently signed in
  bool get isSignedIn => _currentUser != null;

  /// The signed-in user's display name
  String? get userName => _currentUser?.displayName;

  /// The signed-in user's email
  String? get userEmail => _currentUser?.email;

  /// Signs in with Google. Shows the account picker on first sign-in,
  /// silently refreshes the token on subsequent launches.
  ///
  /// Returns true if sign-in succeeded, false otherwise.
  Future<bool> signIn() async {
    try {
      // Try silent sign-in first (user previously signed in)
      _currentUser = await _googleSignIn.signInSilently();

      // If that fails, show the interactive sign-in UI
      _currentUser ??= await _googleSignIn.signIn();

      if (_currentUser == null) return false;

      // Initialize the Drive API client with auth headers
      await _initDriveApi();
      return true;
    } catch (e) {
      debugPrint('Sign-in error: $e');
      return false;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  /// Uploads a markdown clipping to the specified Shared Drive folder.
  ///
  /// [filename] — the name of the .md file (e.g. "My Article.md")
  /// [content] — the full markdown content (frontmatter + body)
  /// [folderId] — the Google Drive folder ID to upload into
  ///
  /// Returns the file ID of the created file, or null on failure.
  Future<String?> uploadClipping({
    required String filename,
    required String content,
    required String folderId,
  }) async {
    if (_driveApi == null) {
      throw Exception('Not signed in. Call signIn() first.');
    }

    try {
      // Create the file metadata
      // In Google Drive API, a "File" object describes WHERE to put the file
      // and what it's called. The actual content is sent separately as a Media stream.
      final fileMetadata = drive.File()
        ..name = filename
        ..parents = [folderId]
        ..mimeType = 'text/markdown';

      // Convert our markdown string to a byte stream for upload
      final contentBytes = utf8.encode(content);
      final mediaStream = drive.Media(
        Stream.value(contentBytes),
        contentBytes.length,
      );

      // Upload! This creates the file in the specified folder.
      // supportsAllDrives: true is required for Shared Drive access.
      final result = await _driveApi!.files.create(
        fileMetadata,
        uploadMedia: mediaStream,
        supportsAllDrives: true,
      );

      return result.id;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  /// Initializes the Drive API client with the current user's auth headers.
  ///
  /// Google Sign-In gives us auth tokens. We wrap an HTTP client with
  /// those tokens so every Drive API call is automatically authenticated.
  Future<void> _initDriveApi() async {
    final authHeaders = await _currentUser!.authHeaders;
    final authenticatedClient = _GoogleAuthClient(authHeaders);
    _driveApi = drive.DriveApi(authenticatedClient);
  }
}

/// A simple HTTP client wrapper that adds Google auth headers to every request.
///
/// Google's API libraries need an http.Client that automatically includes
/// the OAuth token. This class wraps the standard HTTP client and injects
/// the Authorization header into every request.
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
  }
}
