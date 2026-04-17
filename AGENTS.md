# Agent Guidelines for `html-editor-enhanced`

## Overview
This is a Flutter package encapsulating the Summernote JavaScript WYSIWYG editor for Flutter apps on Android, iOS, and Web.

## Core Architecture
- The editor abstracts the Summernote JS core using different implementations for mobile/desktop platforms (using `webview_flutter` or similar local HTML host) and the web (using `dart:html` and iframe injections).
- Platform-specific code is routed via the `lib/src/` directory files:
    - `html_editor_web.dart`
    - `html_editor_mobile.dart`
    - `html_editor_unsupported.dart`

## Key Patterns
- **Webview vs. Iframe:** Cross-platform implementation heavily relies on conditionals for `kIsWeb`. Ensure platform checks are robust.
- **JavaScript Interop:** Controllers and handlers (`Callbacks`, `HtmlEditorOptions`, `HtmlToolbarOptions`) must seamlessly transition between Dart events and JS interop (via `evaluatingJavascript` on mobile and `window.postMessage` on Web).
- **Callbacks:** Defined in `utils/callbacks.dart`, defining interactions such as content change, image upload handling, etc.

## Coding Style
- Write clear, concise comments. Place them above the described line(s) and use full sentences ending with periods.
- Keep code line length ≤ 120 characters; split longer sentences across multiple lines.
- Do not use emojis in code or explanations.
- Do not leave "thinking in progress" style comments; wrap up any exploratory code and summarize it concisely.
- Flutter version: 3.35.4

## Intellectual Collaboration
- Our shared goal is to refine both our conclusions and our reasoning process toward high-quality software design and intellectual rigor.

