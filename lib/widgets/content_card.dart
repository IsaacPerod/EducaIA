import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  final Map<String, dynamic> content;
  final VoidCallback onTap;

  const ContentCard({required this.content, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(content['title'] ?? 'Sem título'),
        subtitle: Text(
          '${content['type'] ?? 'Desconhecido'} | ${content['difficulty'] ?? 'N/A'}',
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}