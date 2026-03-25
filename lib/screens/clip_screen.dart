import 'package:flutter/material.dart';
import '../models/clip_data.dart';
import '../services/clip_service.dart';
import '../services/markdown_generator.dart';
import '../services/drive_service.dart';

/// ClipScreen — the screen shown when a URL is shared to the app.
///
/// This is the "action" screen. It appears automatically when the user
/// shares a URL from Chrome/Reddit/etc. The flow:
///
/// 1. Show "Extracting..." with a spinner
/// 2. Show the extracted metadata as a preview card
/// 3. Upload to Drive and show success/error
///
/// KEY FLUTTER CONCEPTS:
/// - Widget lifecycle: initState() runs once when the widget is created.
///   We kick off the async processing there.
/// - Builder pattern: We use different widgets based on _state to show
///   loading, preview, success, or error states.
/// - Navigator.pop(): Goes back to the previous screen (or closes the app
///   if this was the only screen).
class ClipScreen extends StatefulWidget {
  final String url;
  final DriveService driveService;
  final String? targetFolderId;

  const ClipScreen({
    super.key,
    required this.url,
    required this.driveService,
    this.targetFolderId,
  });

  @override
  State<ClipScreen> createState() => _ClipScreenState();
}

enum ClipState { extracting, preview, uploading, success, error }

class _ClipScreenState extends State<ClipScreen> {
  final ClipService _clipService = ClipService();
  ClipState _state = ClipState.extracting;
  ClipData? _clipData;
  String? _markdown;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _processUrl();
  }

  /// The main processing pipeline:
  /// URL → fetch & extract → generate markdown → preview
  Future<void> _processUrl() async {
    try {
      // Step 1: Extract metadata from the URL
      setState(() => _state = ClipState.extracting);

      final data = await _clipService.extractMetadata(widget.url);
      final markdown = MarkdownGenerator.generate(data);

      setState(() {
        _clipData = data;
        _markdown = markdown;
        _state = ClipState.preview;
      });
    } catch (e) {
      setState(() {
        _state = ClipState.error;
        _errorMessage = e.toString();
      });
    }
  }

  /// Upload the generated markdown to Google Drive
  Future<void> _uploadToDrive() async {
    if (_clipData == null || _markdown == null) return;

    final folderId = widget.targetFolderId;
    if (folderId == null || folderId.isEmpty) {
      setState(() {
        _state = ClipState.error;
        _errorMessage = 'No target folder configured. Set the Drive folder ID in settings.';
      });
      return;
    }

    if (!widget.driveService.isSignedIn) {
      final signedIn = await widget.driveService.signIn();
      if (!signedIn) {
        setState(() {
          _state = ClipState.error;
          _errorMessage = 'Google Sign-In required to upload.';
        });
        return;
      }
    }

    setState(() => _state = ClipState.uploading);

    try {
      final filename = MarkdownGenerator.generateFilename(_clipData!);
      final fileId = await widget.driveService.uploadClipping(
        filename: filename,
        content: _markdown!,
        folderId: folderId,
      );

      if (fileId != null) {
        setState(() => _state = ClipState.success);
      } else {
        setState(() {
          _state = ClipState.error;
          _errorMessage = 'Upload failed. Check your Drive permissions.';
        });
      }
    } catch (e) {
      setState(() {
        _state = ClipState.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipping'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: switch (_state) {
            ClipState.extracting => _buildLoadingState(theme, 'Extracting metadata...'),
            ClipState.preview => _buildPreviewState(theme),
            ClipState.uploading => _buildLoadingState(theme, 'Uploading to Drive...'),
            ClipState.success => _buildSuccessState(theme),
            ClipState.error => _buildErrorState(theme),
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            message,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            widget.url,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewState(ThemeData theme) {
    final data = _clipData!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Metadata preview card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    data.title.isNotEmpty ? data.title : '(No title)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // URL
                  _metadataRow(theme, Icons.link, data.url),

                  // Author
                  if (data.author.isNotEmpty)
                    _metadataRow(theme, Icons.person_outline, data.author),

                  // Description
                  if (data.description.isNotEmpty)
                    _metadataRow(theme, Icons.description_outlined, data.description),

                  // Published
                  if (data.published.isNotEmpty)
                    _metadataRow(theme, Icons.calendar_today, data.published),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Content preview
          if (data.content.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content Preview',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.content.length > 500
                          ? '${data.content.substring(0, 500)}...'
                          : data.content,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Action button
          FilledButton.icon(
            onPressed: _uploadToDrive,
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text('Save to Vault'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade900.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 48,
              color: Colors.green.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Clipped!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _clipData?.title ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Saved to your Obsidian vault',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _processUrl,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _metadataRow(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
