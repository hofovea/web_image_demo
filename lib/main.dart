import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

/// The entry point of the application.
void main() {
  runApp(const MyApp());
}

/// The main application widget.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] instance.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Demo',
      home: const HomePage(),
    );
  }
}

/// The home page of the application.
class HomePage extends StatefulWidget {
  /// Creates a [HomePage] instance.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// The state for the [HomePage] widget.
class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  String? _imageUrl;
  bool _isFullscreen = false;
  bool _isMenuOpen = false;

  /// The ID for the original image element.
  static const String _imageElementId = 'image-element';

  /// The ID for the fullscreen image element.
  static const String _fullscreenImageElementId = 'fullscreen-image-element';

  /// The ID for the fullscreen exit button.
  static const String _fullscreenButtonId = 'fullscreen-button';

  @override
  void initState() {
    super.initState();
    ui.platformViewRegistry.registerViewFactory(
      _imageElementId,
      (int viewId) => html.ImageElement()
        ..id = _imageElementId
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..onClick.listen(
          (event) {
            _toggleFullscreen();
          },
        ),
    );
  }

  /// Toggles fullscreen mode by creating or removing the fullscreen image and button.
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      final originalImage = html.document.getElementById(_imageElementId) as html.ImageElement?;
      if (originalImage != null) {
        final fullscreenImage = html.ImageElement()
          ..id = _fullscreenImageElementId
          ..src = originalImage.src
          ..style.position = 'fixed'
          ..style.top = '0'
          ..style.left = '0'
          ..style.width = '100vw'
          ..style.height = '100vh'
          ..style.objectFit = 'cover'
          ..style.zIndex = '9998';

        final fullscreenButton = html.ButtonElement()
          ..id = _fullscreenButtonId
          ..text = 'Exit Fullscreen'
          ..style.position = 'fixed'
          ..style.right = '16px'
          ..style.bottom = '16px'
          ..style.zIndex = '9999'
          ..style.backgroundColor = 'white'
          ..style.color = 'black'
          ..style.border = 'none'
          ..style.padding = '12px'
          ..style.borderRadius = '4px'
          ..style.cursor = 'pointer'
          ..onClick.listen((event) {
            _toggleFullscreen();
          });

        html.document.body?.append(fullscreenImage);
        html.document.body?.append(fullscreenButton);
      }
    } else {
      final fullscreenImage = html.document.getElementById(_fullscreenImageElementId);
      final fullscreenButton = html.document.getElementById(_fullscreenButtonId);
      if (fullscreenImage != null) {
        fullscreenImage.remove();
      }
      if (fullscreenButton != null) {
        fullscreenButton.remove();
      }
    }
  }

  /// Toggles the visibility of the popup menu.
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  /// Closes the popup menu.
  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Loader'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _imageUrl != null
                          ? HtmlElementView(
                              viewType: _imageElementId,
                            )
                          : const Center(
                              child: Icon(
                                Icons.image,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Image URL',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _imageUrl = _urlController.text;
                          final imageElement = html.document.getElementById(
                            _imageElementId,
                          ) as html.ImageElement?;
                          if (imageElement != null) {
                            imageElement.src = _imageUrl!;
                          }
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          if (_isMenuOpen)
            GestureDetector(
              onTap: _closeMenu,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          if (_isMenuOpen)
            Positioned(
              right: 16,
              bottom: 80,
              child: Card(
                elevation: 8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        _toggleFullscreen();
                        _closeMenu();
                      },
                      child: const Text('Enter Fullscreen'),
                    ),
                    TextButton(
                      onPressed: () {
                        _toggleFullscreen();
                        _closeMenu();
                      },
                      child: const Text('Exit Fullscreen'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMenu,
        child: const Icon(Icons.add),
      ),
    );
  }
}
