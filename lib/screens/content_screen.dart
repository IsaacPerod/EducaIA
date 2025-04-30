import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final content = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    return Scaffold(
      appBar: AppBar(title: Text(content['title'])),
      body: content['type'] == 'video'
          ? YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: YoutubePlayer.convertUrlToId(content['url'])!,
                flags: YoutubePlayerFlags(autoPlay: true),
              ),
            )
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
              : Center(child: Text('Conteúdo não suportado')),
    );
  }
}