import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  _StudyScreenState createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  YoutubePlayerController? _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContent();
    });
  }

  Future<void> _loadContent() async {
    final contentId = ModalRoute.of(context)!.settings.arguments as String?;
    if (contentId == null) {
      setState(() {
        _errorMessage = 'ID do conteúdo não fornecido.';
        _isLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('contents')
          .doc(contentId)
          .get();
      if (!doc.exists || doc.data() == null) {
        setState(() {
          _errorMessage = 'Conteúdo não encontrado.';
          _isLoading = false;
        });
        return;
      }
      final content = doc.data() as Map<String, dynamic>;
      final url = content['url'] as String?;
      if (url == null || !url.contains('youtube.com')) {
        setState(() {
          _errorMessage = 'URL inválida ou não é um vídeo do YouTube.';
          _isLoading = false;
        });
        return;
      }

      // Extrai o ID do vídeo do URL
      final videoId = _extractVideoId(url);
      if (videoId == null) {
        setState(() {
          _errorMessage = 'Não foi possível extrair o ID do vídeo.';
          _isLoading = false;
        });
        return;
      }

      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar conteúdo: $e';
        _isLoading = false;
      });
    }
  }

  String? _extractVideoId(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    } else if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.last;
    }
    return null;
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estudar')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _controller != null
                  ? YoutubePlayer(
                      controller: _controller!,
                      aspectRatio: 16 / 9,
                    )
                  : const Center(child: Text('Nenhum vídeo disponível.')),
    );
  }
}