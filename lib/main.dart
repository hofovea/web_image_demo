import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:js' as js;

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Demo',
      home: const HomePage(),
    );
  }
}

/// [Widget] displaying the home page.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  String? _imageUrl;
  bool _isMenuOpen = false;

  static const String _imageElementId = 'image-element';

  @override
  void initState() {
    super.initState();
    ui.platformViewRegistry.registerViewFactory(
      _imageElementId,
      (int viewId) => html.ImageElement()
        ..id = _imageElementId
        ..style.width = '100%'
        ..style.height = '100%'
        ..onDoubleClick.listen((event) {
          js.context.callMethod(
            'toggleFullscreen',
            [html.document.getElementById(_imageElementId)],
          );
        }),
    );
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _toggleFullscreen() {
    js.context.callMethod(
      'toggleFullscreen',
      [html.document.getElementById(_imageElementId)],
    );
    _toggleMenu();
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
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black54,
              ),
            ),
          if (_isMenuOpen)
            Positioned(
              right: 16,
              bottom: 80,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _toggleFullscreen,
                    child: const Text('Enter Fullscreen'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      html.document.exitFullscreen();
                      _toggleMenu();
                    },
                    child: const Text('Exit Fullscreen'),
                  ),
                ],
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
