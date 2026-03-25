/// ClipData — the data model for a single web clipping.
///
/// Think of this as the "container" that holds everything we extract
/// from a web page. Every field maps directly to an Obsidian frontmatter
/// property (see your Obsidian Clipper's Properties tab).
///
/// In Dart, we create a simple class to hold structured data.
/// No fancy state management needed — this is just a plain data object.
class ClipData {
  final String title;
  final String url;
  final String author;
  final String description;
  final String published;
  final String content;
  final DateTime createdAt;

  ClipData({
    required this.title,
    required this.url,
    this.author = '',
    this.description = '',
    this.published = '',
    this.content = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Quick summary for debug/UI display
  @override
  String toString() =>
      'ClipData(title: $title, url: $url, author: $author)';
}
