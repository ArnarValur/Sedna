import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:html2md/html2md.dart' as html2md;
import '../models/clip_data.dart';

/// ClipService — the engine that fetches a URL and extracts page metadata.
///
/// This is where the "web clipping" magic happens. We:
/// 1. Fetch the raw HTML of the page (HTTP GET)
/// 2. Parse it into a DOM tree (just like a browser does)
/// 3. Extract metadata using a priority chain:
///    - OpenGraph (og:) tags first (most reliable for articles)
///    - Standard `<meta>` tags as fallback
///    - HTML elements (`<title>`, `<body>`) as last resort
/// 4. Convert the article HTML → Markdown (preserving structure)
///
/// CONTENT EXTRACTION STRATEGY (inspired by Obsidian Clipper / defuddle):
/// - Find the main content element (`<article>`, `<main>`, or `<body>`)
/// - Strip noise: scripts, styles, nav, footer, ads, social buttons,
///   hidden elements, cookie banners, and other non-content clutter
/// - Convert the cleaned HTML → Markdown using html2md, which preserves
///   headings, links, lists, bold/italic, code blocks, and tables
///
/// KEY FLUTTER/DART CONCEPTS:
/// - async/await: Every network call is asynchronous. We use `await` to
///   pause execution until the response arrives, without blocking the UI.
/// - The `Future` return type means "this function returns a value, but
///   not immediately — it returns a Future that resolves later."
class ClipService {
  /// Fetches a URL and extracts all available page metadata.
  ///
  /// Returns a [ClipData] object populated with whatever we can find.
  /// Fields we can't extract will be empty strings (never null).
  Future<ClipData> extractMetadata(String url) async {
    // 1. Fetch the HTML
    //    `http.get` returns a Future<Response>. The `await` keyword
    //    pauses this function until the HTTP response arrives.
    final response = await http.get(
      Uri.parse(url),
      headers: {
        // Some sites block requests without a User-Agent
        'User-Agent': 'SecondBrainClipper/1.0',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch URL: HTTP ${response.statusCode}');
    }

    // 2. Parse the HTML into a DOM tree
    //    This gives us a Document object we can query, just like
    //    document.querySelector() in JavaScript.
    final document = html_parser.parse(response.body);

    // 3. Extract each field using our priority chain
    return ClipData(
      title: _extractTitle(document),
      url: url,
      author: _extractAuthor(document),
      description: _extractDescription(document),
      published: _extractPublished(document),
      content: _extractContent(document),
    );
  }

  /// Title extraction priority:
  /// 1. og:title (OpenGraph — used by social media, very reliable)
  /// 2. <title> HTML element
  String _extractTitle(Document doc) {
    return _getMetaContent(doc, property: 'og:title') ??
        doc.querySelector('title')?.text.trim() ??
        '';
  }

  /// Description extraction priority:
  /// 1. og:description
  /// 2. <meta name="description">
  String _extractDescription(Document doc) {
    return _getMetaContent(doc, property: 'og:description') ??
        _getMetaContent(doc, name: 'description') ??
        '';
  }

  /// Author extraction priority:
  /// 1. <meta name="author">
  /// 2. article:author (OpenGraph)
  /// 3. <meta name="twitter:creator">
  String _extractAuthor(Document doc) {
    return _getMetaContent(doc, name: 'author') ??
        _getMetaContent(doc, property: 'article:author') ??
        _getMetaContent(doc, name: 'twitter:creator') ??
        '';
  }

  /// Published date extraction priority:
  /// 1. article:published_time (OpenGraph — ISO 8601 format)
  /// 2. <meta name="date">
  /// 3. <time> element's datetime attribute
  String _extractPublished(Document doc) {
    return _getMetaContent(doc, property: 'article:published_time') ??
        _getMetaContent(doc, name: 'date') ??
        doc.querySelector('time')?.attributes['datetime'] ??
        '';
  }

  /// Content extraction — the main upgrade over raw text dumping.
  ///
  /// Strategy (inspired by Obsidian Clipper's defuddle library):
  /// 1. Find the main content element (`<article>` → `<main>` → `<body>`)
  /// 2. Strip noise elements that pollute the content
  /// 3. Convert cleaned HTML → Markdown using html2md
  ///
  /// This preserves headings, links, lists, bold/italic, code blocks,
  /// and tables — making the output actually useful in Obsidian.
  String _extractContent(Document doc) {
    // Try <article> first — most news sites and blogs use this
    Element? contentElement = doc.querySelector('article');

    // Fall back to <main> or <body>
    contentElement ??= doc.querySelector('main');
    contentElement ??= doc.body;

    if (contentElement == null) return '';

    // ─── Noise Removal (inspired by defuddle) ────────────────────
    // Remove elements that are never useful content.
    // Tags: structural noise
    final noiseTags = [
      'script', 'style', 'nav', 'footer', 'header', 'aside',
      'iframe', 'noscript', 'svg',
    ];
    for (final tag in noiseTags) {
      contentElement.querySelectorAll(tag).forEach((e) => e.remove());
    }

    // CSS selectors: ad blocks, social buttons, cookie banners, etc.
    // These are common patterns across news sites and blogs.
    final noiseSelectors = [
      '[class*="social"]', '[class*="share"]', '[class*="sharing"]',
      '[class*="sidebar"]', '[class*="widget"]', '[class*="related"]',
      '[class*="comment"]', '[class*="newsletter"]', '[class*="subscribe"]',
      '[class*="cookie"]', '[class*="consent"]', '[class*="banner"]',
      '[class*="popup"]', '[class*="modal"]', '[class*="overlay"]',
      '[class*="advertisement"]', '[class*="sponsor"]',
      '[id*="sidebar"]', '[id*="comment"]', '[id*="footer"]',
      '[role="complementary"]', '[role="navigation"]',
      '[aria-hidden="true"]',
    ];
    for (final selector in noiseSelectors) {
      try {
        contentElement.querySelectorAll(selector).forEach((e) => e.remove());
      } catch (_) {
        // Some selectors may not be supported — skip them
      }
    }

    // ─── HTML → Markdown Conversion ──────────────────────────────
    // Get the cleaned HTML and convert to proper Markdown.
    // html2md handles: headings, links, lists, bold, italic,
    // code blocks, blockquotes, images, and tables.
    final cleanedHtml = contentElement.innerHtml;
    final markdown = html2md.convert(
      cleanedHtml,
      styleOptions: {
        'headingStyle': 'atx',
        'codeBlockStyle': 'fenced',
      },
      ignore: ['button', 'input', 'form', 'select'],
    );

    // Clean up excessive blank lines (more than 2 consecutive → 2)
    return markdown
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  // ─── Helper Methods ───────────────────────────────────────────

  /// Gets the content of a <meta> tag.
  ///
  /// HTML meta tags come in two flavors:
  /// - <meta name="description" content="...">      (name attribute)
  /// - <meta property="og:title" content="...">      (property attribute)
  ///
  /// This helper handles both. Returns null if not found (so the
  /// caller can use the ?? operator for fallback chains).
  String? _getMetaContent(Document doc, {String? name, String? property}) {
    Element? element;

    if (property != null) {
      // OpenGraph tags use the "property" attribute
      element = doc.querySelector('meta[property="$property"]');
    } else if (name != null) {
      // Standard meta tags use the "name" attribute
      element = doc.querySelector('meta[name="$name"]');
    }

    final content = element?.attributes['content']?.trim();
    return (content != null && content.isNotEmpty) ? content : null;
  }
}
