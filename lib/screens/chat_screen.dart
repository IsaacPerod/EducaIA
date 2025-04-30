import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  Future<void> _sendMessage() async {
    final message = _messageController.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': message});
    });
    _messageController.clear();

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('chatTutor')
          .call({'message': message});
      setState(() {
        _messages.add({'role': 'assistant', 'content': result.data['reply']});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Erro: $e'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tutor IA')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ListTile(
                  title: Text(msg['role'] == 'user' ? 'Você' : 'Tutor'),
                  subtitle: Text(msg['content']!),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Digite sua dúvida...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}