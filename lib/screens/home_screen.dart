import 'package:flutter/material.dart';
import '../services/drive_service.dart';

/// HomeScreen — the landing screen when the app is opened directly
/// (not via a share intent).
///
/// Shows:
/// - App branding
/// - Google Sign-In status/button
/// - Brief instructions
///
/// KEY FLUTTER CONCEPTS:
/// - StatefulWidget: A widget that can change over time. We use it here
///   because the sign-in state changes (signed in vs. not signed in).
/// - setState(): Tells Flutter "something changed, please rebuild this widget."
///   This is how we update the UI when the user signs in/out.
class HomeScreen extends StatefulWidget {
  final DriveService driveService;

  const HomeScreen({super.key, required this.driveService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    // Try silent sign-in when the screen loads
    _trySilentSignIn();
  }

  Future<void> _trySilentSignIn() async {
    final success = await widget.driveService.signIn();
    if (mounted) {
      setState(() {});
    }
    if (!success && mounted) {
      // Silent sign-in failed — that's fine, user will tap the button
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => _isSigningIn = true);
    await widget.driveService.signIn();
    if (mounted) {
      setState(() => _isSigningIn = false);
    }
  }

  Future<void> _handleSignOut() async {
    await widget.driveService.signOut();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.bookmark_add_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // App title
                Text(
                  'Second Brain',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Clip web pages to your Obsidian vault',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Sign-in state
                if (widget.driveService.isSignedIn) ...[
                  // Signed in — show status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green.shade400,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connected to Google Drive',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.driveService.userEmail ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          onPressed: _handleSignOut,
                          tooltip: 'Sign out',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _instructionRow(
                          context,
                          icon: Icons.share_rounded,
                          text: 'Share a link from any app',
                        ),
                        const SizedBox(height: 12),
                        _instructionRow(
                          context,
                          icon: Icons.auto_awesome_rounded,
                          text: 'Metadata extracted automatically',
                        ),
                        const SizedBox(height: 12),
                        _instructionRow(
                          context,
                          icon: Icons.cloud_upload_rounded,
                          text: 'Markdown saved to your vault',
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Not signed in — show sign-in button
                  Text(
                    'Sign in to connect your Google Drive\nwhere your Obsidian vault lives.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: _isSigningIn ? null : _handleSignIn,
                    icon: _isSigningIn
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login_rounded),
                    label: Text(_isSigningIn ? 'Signing in...' : 'Sign in with Google'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _instructionRow(BuildContext context, {required IconData icon, required String text}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
