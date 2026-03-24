# **Flutter Second Brain: Project Roadmap**

This roadmap outlines how to build a Flutter application that accepts shared links, summarizes content using Gemini AI, and syncs data via Firebase for desktop access.

## **1\. Core Architecture**

To match the "Second Brain" workflow, your app needs three primary layers:

- **Ingestion Layer**: A Flutter "Share Extension" (iOS/Android) to catch URLs from other apps.
- **Intelligence Layer**: A backend or client-side service calling the Gemini API to summarize the content.
- **Persistence Layer**: Firebase Firestore to store the summaries and metadata.

## **2\. Technical Stack**

- **Frontend**: Flutter (Mobile & Web/Desktop).
- **Sharing**: receive_sharing_intent package to handle incoming links.
- **AI**: google_generative_ai package (Dart SDK for Gemini).
- **Backend**: Firebase (Auth, Firestore, and optionally Cloud Functions).
- **Scraping**: http and html packages (to extract text from URLs before sending to Gemini).

## **3\. Implementation Steps**

### **Phase 1: Receiving Data**

1. **Dependency**: Add receive_sharing_intent to pubspec.yaml.
2. **Native Setup**:
   - **Android**: Modify AndroidManifest.xml to include an intent-filter for text/plain or text/uri-list.

### **Phase 2: Content Extraction & Summarization**

1. **Scraping**: When a URL is received, use a simple http.get() to fetch the HTML.
2. **Cleaning**: Use the html parser to extract the main article text (similar to the Readability SDK mentioned in the video).
3. **Gemini Integration**:
   - Initialize the Gemini model: GenerativeModel(model: 'gemini-3-flash', apiKey: apiKey).

### **Phase 3: Firebase Storage**

1. **Auth**: Implement Anonymous or Google Sign-In so users can sync data across devices.
2. **Firestore Schema**:
   - collection('artifacts')
   - document: { title, original_url, summary, timestamp, userId }
3. **Cross-Platform Access**: Since Firebase is platform-agnostic, building a **Flutter Web** or **Flutter Desktop** version of the app will automatically give you access to the same summaries you saved on mobile.

## **4\. Enhanced Workflow (Cloud-Side)**

For a more robust app, consider using **Firebase Cloud Functions**:

1. App saves the **URL** to Firestore.
2. A Firestore **Trigger** (Cloud Function) fires.
3. The Function performs the scraping and Gemini summarization in the background.
4. The Function updates the document with the summary.  
   _This ensures the user doesn't have to keep the app open while the AI works._

## **5\. Learning Exercises**

- **Task 1**: Build a simple Flutter app that can print a shared URL to the console.
- **Task 2**: Connect the Gemini API and summarize a hardcoded string of text.
- **Task 3**: Create a "History" tab that fetches and displays list tiles from Firestore.
