import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? _contentId;

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

    setState(() {
      _contentId = contentId;
    });

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
          enableCaption: true,
          showVideoAnnotations: false,
          strictRelatedVideos: true,
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

  Future<void> _markAsCompleted() async {
    if (_contentId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('user_history')
          .doc('${user.uid}_$_contentId')
          .set({
        'user_id': user.uid,
        'content_id': _contentId,
        'status': 'completed',
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conteúdo marcado como concluído!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao marcar como concluído: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                SizedBox(
                  height: MediaQuery.of(context).size.height - 100,
                  child: const Center(child: PulsingDotsIndicator()),
                )
              else if (_errorMessage != null)
                Card(
                  color: Colors.red.withOpacity(0.1),
                  child: ListTile(
                    title: Text(_errorMessage!),
                    leading: const Icon(Icons.error, color: Colors.red),
                  ),
                )
              else if (_controller != null)
                Card(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: YoutubePlayer(
                          controller: _controller!,
                          aspectRatio: 16 / 9,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Marcar como Concluído'),
                          onPressed: _markAsCompleted,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                )
              else
                const Card(
                  child: ListTile(
                    title: Text('Nenhum vídeo disponível.'),
                    leading: Icon(Icons.info, color: Color(0xFF90E0EF)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Indicador de carregamento com pulsar de pontos (estilo IA)
class PulsingDotsIndicator extends StatefulWidget {
  const PulsingDotsIndicator({super.key});

  @override
  _PulsingDotsIndicatorState createState() => _PulsingDotsIndicatorState();
}

class _PulsingDotsIndicatorState extends State<PulsingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 12.0,
              height: 12.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B4D8).withOpacity(
                  _animation.value - (index * 0.2),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}