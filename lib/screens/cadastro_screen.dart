import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedInterest;
  final List<String> _interests = ['Python', 'Matemática', 'Lógica'];

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Criar usuário no Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text, password: _passwordController.text);
        
        // Salvar perfil no Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text,
          'email': _emailController.text,
          'interests': [_selectedInterest],
          'level': 'unknown' // Será atualizado após o quiz
        });

        // Navegar para o quiz
        Navigator.pushReplacementNamed(context, '/quiz');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Nome é obrigatório' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Email é obrigatório' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedInterest,
                hint: Text('Selecione um interesse'),
                items: _interests
                    .map((interest) => DropdownMenuItem(
                          value: interest,
                          child: Text(interest),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedInterest = value),
                validator: (value) => value == null ? 'Selecione um interesse' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}