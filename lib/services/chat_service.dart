import 'package:cloud_functions/cloud_functions.dart';

class ChatService {
  Future<String> sendMessage(String message) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('chatTutor')
          .call({'message': message});
      return result.data['reply'];
    } catch (e) {
      return 'Erro: $e';
    }
  }
}