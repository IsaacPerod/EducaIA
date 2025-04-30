import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudyScreen extends StatelessWidget {
  Future<void> _markContent(String contentId, String status) async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('user_history')
        .doc('${user.uid}_$contentId')
        .set({
      'user_id': user.uid,
      'content_id': contentId,
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    
    return Scaffold(
      appBar: AppBar(title: Text('Área de Estudo')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_history')
            .where('user_id', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
          final history = snapshot.data!.docs;
          final doneCount = history.where((doc) => doc['status'] == 'done').length;
          final progress = history.isEmpty ? 0 : doneCount / history.length;

          return Column(
            children: [
              LinearProgressIndicator(value: progress.toDouble()),
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text('Conteúdo ${item['content_id']}'),
                      subtitle: Text('Status: ${item['status']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () => _markContent(item['content_id'], 'done'),
                          ),
                          IconButton(
                            icon: Icon(Icons.hourglass_empty),
                            onPressed: () => _markContent(item['content_id'], 'in_progress'),
                          ),
                          IconButton(
                            icon: Icon(Icons.warning),
                            onPressed: () => _markContent(item['content_id'], 'difficult'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}