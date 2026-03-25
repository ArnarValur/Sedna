import '../models/clip_data.dart';

/// MarkdownGenerator — converts ClipData into an Obsidian-compatible
/// Markdown file with YAML frontmatter.
///
/// This matches the exact format that Obsidian Clipper produces,
/// so the files will look native in your vault:
///
/// ```yaml
/// ---
/// title: "Article Title"
/// source: "https://example.com/article"
/// author: "John Doe"
/// description: "A brief description"
/// published: "2026-03-25"
/// created: "2026-03-25"
/// tags:
///   - clippings
/// ---
/// ```
///
/// KEY DART CONCEPT:
/// - String interpolation with `$variable` and `${expression}`
/// - Multi-line strings with triple quotes '''
/// - Static methods: called on the class itself, not an instance.
///   `MarkdownGenerator.generate(data)` instead of needing `new MarkdownGenerator()`
class MarkdownGenerator {
  /// Generates the full Markdown file content from clip data.
  ///
  /// The output has two parts:
  /// 1. YAML frontmatter (between --- delimiters) — Obsidian reads this
  ///    as structured metadata and shows it in the Properties panel
  /// 2. Body content — the actual article text
  static String generate(ClipData data) {
    // Format the creation date as YYYY-MM-DD
    final created = _formatDate(data.createdAt);

    // Build the frontmatter block
    // We use _escapeYaml to handle titles/descriptions that contain
    // quotes or colons (which would break YAML parsing)
    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.writeln('title: "${_escapeYaml(data.title)}"');
    buffer.writeln('source: "${data.url}"');

    if (data.author.isNotEmpty) {
      buffer.writeln('author: "${_escapeYaml(data.author)}"');
    }

    if (data.description.isNotEmpty) {
      buffer.writeln('description: "${_escapeYaml(data.description)}"');
    }

    if (data.published.isNotEmpty) {
      buffer.writeln('published: "${data.published}"');
    }

    buffer.writeln('created: "$created"');
    buffer.writeln('tags:');
    buffer.writeln('  - clippings');
    buffer.writeln('---');
    buffer.writeln();

    // Add the page content as the markdown body
    if (data.content.isNotEmpty) {
      buffer.writeln(data.content);
    }

    return buffer.toString();
  }

  /// Generates a filesystem-safe filename from the clip title.
  ///
  /// Obsidian uses the filename as the note title, so we want it
  /// to be readable but safe for all filesystems.
  ///
  /// "How to Build a Flutter App!" → "How to Build a Flutter App.md"
  static String generateFilename(ClipData data) {
    if (data.title.isEmpty) {
      // Fallback: use timestamp if no title found
      return 'clip-${data.createdAt.millisecondsSinceEpoch}.md';
    }

    // Remove characters that are invalid in filenames
    // Keep letters, numbers, spaces, hyphens, and underscores
    final sanitized = data.title
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return '$sanitized.md';
  }

  /// Formats a DateTime as YYYY-MM-DD (ISO 8601 date only).
  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// Escapes special characters in YAML string values.
  /// Prevents titles like: My "Great" Article: A Review
  /// from breaking the YAML parser.
  static String _escapeYaml(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"');
  }
}
