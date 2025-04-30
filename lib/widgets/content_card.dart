import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  final Map<String, dynamic> content;
  final VoidCallback onTap;

  ContentCard({required this.content, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(content['title']),
        subtitle: Text('${content['type']} | ${content['difficulty']}'),
        trailing: Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}