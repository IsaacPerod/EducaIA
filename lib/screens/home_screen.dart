import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/content_api_service.dart';
import '../services/firestore_service.dart';
import '../widgets/content_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _subjects = [
    'Programação',
    'Matemática',
    'Português',
    'Lógica',
  ];
  String? _selectedSubject;
  List<Map<String, dynamic>> _contents = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('EducaIA')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/cadastro');
                    },
                    child: const Text('Cadastrar'),
                  ),
                ],
              ),
            ),
          );
        }

        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('EducaIA'),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {
                  Navigator.pushNamed(context, '/chat');
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await Provider.of<AuthService>(context, listen: false).signOut();
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Escolha um assunto:', style: TextStyle(fontSize: 18)),
                DropdownButton<String>(
                  value: _selectedSubject,
                  hint: const Text('Selecione um assunto'),
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;
                      _loadContents(value!);
                    });
                  },
                  items: _subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('Progresso:', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user_history')
                        .where('user_id', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final histories = snapshot.data!.docs;
                      if (histories.isEmpty) {
                        return const Text('Nenhum progresso encontrado.');
                      }
                      return ListView.builder(
                        itemCount: histories.length,
                        itemBuilder: (context, index) {
                          final history = histories[index].data() as Map<String, dynamic>;
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('contents')
                                .doc(history['content_id'])
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text('Carregando...');
                              }
                              if (!snapshot.data!.exists || snapshot.data!.data() == null) {
                                return const ListTile(
                                  title: Text('Conteúdo não encontrado'),
                                  subtitle: Text('Status: Indisponível'),
                                );
                              }
                              final content = snapshot.data!.data() as Map<String, dynamic>;
                              return ListTile(
                                title: Text(content['title'] ?? 'Sem título'),
                                subtitle: Text('Status: ${history['status']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/study',
                                        arguments: history['content_id']);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedSubject != null)
                  const Text('Conteúdos:', style: TextStyle(fontSize: 18)),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_errorMessage != null)
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red))
                else if (_contents.isEmpty)
                  const Text('Nenhum conteúdo encontrado.')
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _contents.length,
                      itemBuilder: (context, index) {
                        final content = _contents[index];
                        if (content == null) {
                          return const ListTile(
                            title: Text('Erro: Conteúdo inválido'),
                          );
                        }
                        return ContentCard(
                          content: content,
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection('user_history')
                                .doc('${user.uid}_${content['id']}')
                                .set({
                              'user_id': user.uid,
                              'content_id': content['id'],
                              'status': 'in_progress',
                              'updated_at': FieldValue.serverTimestamp(),
                            });
                            await FirebaseFirestore.instance
                                .collection('contents')
                                .doc(content['id'])
                                .set({
                              'title': content['title'],
                              'type': content['type'],
                              'difficulty': content['difficulty'],
                              'url': content['url'],
                              'topics': content['topics'],
                            }, SetOptions(merge: true));
                            Navigator.pushNamed(context, '/study',
                                arguments: content['id']);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadContents(String subject) async {
    setState(() {
      _isLoading = true;
      _contents = [];
      _errorMessage = null;
    });

    final apiService = Provider.of<ContentApiService>(context, listen: false);
    final contents = await apiService.fetchContents(subject);

    setState(() {
      _contents = contents.where((c) => c != null).toList();
      _isLoading = false;
      if (contents.isEmpty) {
        _errorMessage = 'Nenhum conteúdo encontrado. Verifique a conexão.';
      }
    });
  }
}