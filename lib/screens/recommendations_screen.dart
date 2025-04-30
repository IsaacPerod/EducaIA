import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecommendationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    
    return Scaffold(
      appBar: AppBar(title: Text('Recomendações')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return Center(child: CircularProgressIndicator());
          
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final level = userData['level'];
          final interests = List<String>.from(userData['interests']);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('contents')
                .where('difficulty', isEqualTo: level)
                .where('topics', arrayContainsAny: interests)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
              
              final contents = snapshot.data!.docs;

              return ListView.builder(
                itemCount: contents.length,
                itemBuilder: (context, index) {
                  final content = contents[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(content['title']),
                      subtitle: Text('${content['type']} | ${content['difficulty']}'),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.pushNamed(context, '/content', arguments: content);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}