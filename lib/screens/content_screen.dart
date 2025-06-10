import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Tela para exibir conteúdos (vídeo, exercício, etc.)
class ContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args == null || args is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Conteúdo')),
        body: const Center(child: Text('Conteúdo não encontrado ou inválido')),
      );
    }
    final content = args as Map<String, dynamic>;

    return Scaffold(
      // Título do AppBar é o título do conteúdo
      appBar: AppBar(title: Text(content['title'])),
      body: content['type'] == 'video'
          // Se o conteúdo for vídeo, exibe o player do YouTube
          ? YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: YoutubePlayer.convertUrlToId(content['url'])!,
                flags: YoutubePlayerFlags(autoPlay: true),
              ),
            )
          // Se for exercício, mostra formulário para resposta
          : content['type'] == 'exercise'
              ? Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(content['title'], style: TextStyle(fontSize: 20)),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Sua resposta'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Enviar resposta ao backend
                        },
                        child: Text('Enviar'),
                      ),
                    ],
                  ),
                )
              // Caso contrário, mostra mensagem de conteúdo não suportado
              : Center(child: Text('Conteúdo não suportado')),
    );
  }
}
