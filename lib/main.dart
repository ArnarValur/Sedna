import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:google_generative_ai/google_generative_ai.dart';

// TODO: Paste your Gemini API Key here to test the summarization!
const String geminiApiKey = 'REDACTED';

void main() {
  runApp(const SecondMobileBrainApp());
}

class SecondMobileBrainApp extends StatelessWidget {
  const SecondMobileBrainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Second Brain',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const IntentReceiverScreen(),
    );
  }
}

class IntentReceiverScreen extends StatefulWidget {
  const IntentReceiverScreen({super.key});

  @override
  State<IntentReceiverScreen> createState() => _IntentReceiverScreenState();
}

class _IntentReceiverScreenState extends State<IntentReceiverScreen> {
  late StreamSubscription _intentDataStreamSubscription;
  String _sharedText = "";

  bool _isLoading = false;
  String _summary = "";

  @override
  void initState() {
    super.initState();

    // Listen to media/text shared while the app is in memory.
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(
          (value) {
            _handleIncomingShare(value);
          },
          onError: (err) {
            print("Stream Error: $err");
          },
        );

    // Handle intent when the app is completely closed and launched via a share action.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      _handleIncomingShare(value);
    });
  }

  void _handleIncomingShare(List<SharedMediaFile> files) {
    if (files.isNotEmpty) {
      // Extract the raw text/URL shared to the app
      final rawInput = files.map((f) => f.path).join("\n");

      setState(() {
        _sharedText = rawInput;
      });

      // Attempt to extract a URL from the string.
      // (When users share from Chrome, the intent text often contains the URL).
      final urlRegExp = RegExp(r"(https?:\/\/[^\s]+)");
      final match = urlRegExp.firstMatch(rawInput);

      if (match != null) {
        _processUrl(match.group(0)!);
      } else {
        setState(() {
          _summary = "No valid URL found in the shared text.";
        });
      }
    }
  }

  Future<void> _processUrl(String url) async {
    setState(() {
      _isLoading = true;
      _summary = "";
    });

    try {
      // 1. Fetch HTML
      final response = await http.get(Uri.parse(url));

      // 2. Extract Text using HTML parser
      final document = parser.parse(response.body);
      final rawText = document.body?.text ?? '';

      // Basic cleanup of excessive whitespace for the AI prompt
      final cleanText = rawText.replaceAll(RegExp(r'\s+'), ' ').trim();

      // 3. Summarize with Gemini
      if (geminiApiKey == 'YOUR_GEMINI_API_KEY') {
        throw Exception(
          "Please add your Gemini API key at the top of lib/main.dart!",
        );
      }

      // We use gemini-1.5-flash as it is the fastest model for text tasks
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: geminiApiKey,
      );

      final prompt =
          'You are a highly capable summarizer for a Second Brain app. Please summarize the following article/content concisely and structure the key takeaways in bullet points:\n\n$cleanText';
      final content = [Content.text(prompt)];
      final aiResponse = await model.generateContent(content);

      setState(() {
        _summary = aiResponse.text ?? "Could not generate summary.";
      });
    } catch (e) {
      setState(() {
        _summary = "Error processing link: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sedna | Phase 3'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 24),

                if (_sharedText.isEmpty)
                  const Text(
                    'Share a URL from another app to generate a summary!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                else
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Shared URL: $_sharedText",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_isLoading)
                        const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("Reading and summarizing with Gemini..."),
                          ],
                        )
                      else if (_summary.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.deepPurple.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome_mosaic,
                                    color: Colors.deepPurple,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "AI Summary",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(
                                _summary,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
