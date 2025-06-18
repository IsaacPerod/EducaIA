import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/content_api_service.dart';
import '../services/firestore_service.dart';
import '../widgets/content_card.dart';
import '../services/auth_service.dart';

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
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login), // Ícone nativo Flutter
                    label: const Text('Login'),
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add), // Ícone nativo Flutter
                    label: const Text('Cadastrar'),
                    onPressed: () => Navigator.pushNamed(context, '/cadastro'),
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
                icon: const Icon(
                    Icons.chat_bubble_outline), // Ícone nativo Flutter
                onPressed: () => Navigator.pushNamed(context, '/chat'),
              ),
              IconButton(
                icon: const Icon(Icons.logout), // Ícone nativo Flutter
                onPressed: () async {
                  await Provider.of<AuthService>(context, listen: false)
                      .signOut();
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (_selectedSubject != null) {
                await _loadContents(_selectedSubject!);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Escolha um assunto:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    hint: const Text('Selecione um assunto'),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.school, color: Color(0xFF00B4D8)),
                    ),
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
                  const SizedBox(height: 24),
                  const Text(
                    'Seu Progresso:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
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
                        return const Card(
                          child: ListTile(
                            title: Text('Nenhum progresso encontrado.'),
                            leading: Icon(Icons.info_outline,
                                color: Color(0xFF90E0EF)),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: histories.length,
                        itemBuilder: (context, index) {
                          final history =
                              histories[index].data() as Map<String, dynamic>;
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('contents')
                                .doc(history['content_id'])
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Card(
                                  child: ListTile(title: Text('Carregando...')),
                                );
                              }
                              if (!snapshot.data!.exists ||
                                  snapshot.data!.data() == null) {
                                return const Card(
                                  child: ListTile(
                                    title: Text('Conteúdo não encontrado'),
                                    subtitle: Text('Status: Indisponível'),
                                    leading:
                                        Icon(Icons.error, color: Colors.red),
                                  ),
                                );
                              }
                              final content =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              return Card(
                                child: ListTile(
                                  title: Text(content['title'] ?? 'Sem título'),
                                  subtitle:
                                      Text('Status: ${history['status']}'),
                                  leading: Icon(
                                    history['status'] == 'completed'
                                        ? Icons.check_circle
                                        : Icons.play_circle_outline,
                                    color: history['status'] == 'completed'
                                        ? const Color(0xFF90E0EF)
                                        : const Color(0xFF00B4D8),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/study',
                                          arguments: history['content_id']);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_selectedSubject != null)
                    const Text(
                      'Conteúdos Recomendados:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B4D8),
                      ),
                    )
                  else if (_errorMessage != null)
                    Card(
                      color: Colors.red.withOpacity(0.1),
                      child: ListTile(
                        title: Text(_errorMessage!),
                        leading: const Icon(Icons.error, color: Colors.red),
                      ),
                    )
                  else if (_contents.isEmpty)
                    const Card(
                      child: ListTile(
                        title: Text('Nenhum conteúdo encontrado.'),
                        leading: Icon(Icons.info_outline,
                            color: Color(0xFF90E0EF)), // Ícone nativo Flutter
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _contents.length,
                      itemBuilder: (context, index) {
                        final content = _contents[index];
                        if (content == null) {
                          return const Card(
                            child: ListTile(
                                title: Text('Erro: Conteúdo inválido')),
                          );
                        }
                        return AnimatedOpacity(
                          opacity: _isLoading ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: ContentCard(
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
                          ),
                        );
                      },
                    ),
                ],
              ),
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
